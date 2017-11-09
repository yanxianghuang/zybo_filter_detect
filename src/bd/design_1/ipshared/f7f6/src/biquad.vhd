----------------------------------------------------------------------------------
-- Company: KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Create Date: 04.08.2016
-- Module Name: biquad - Behavioral
-- Project Name: Labo Digitaal Ontwerp II
-- Target Devices: Artix 7
-- Description: A biquad single precision floating point iir filter
-- 
-- Dependencies: FPP_MULT.vhd
--               FPP_ADD_SUB.vhd
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity biquad is
    port(
        clk        : in  std_logic;
        reset      : in  std_logic;
        new_sample : in  std_logic;
        sample_in  : in  std_logic_vector(31 downto 0);
        b0         : in  std_logic_vector(31 downto 0);
        b1         : in  std_logic_vector(31 downto 0);
        b2         : in  std_logic_vector(31 downto 0);
        a1         : in  std_logic_vector(31 downto 0); -- Make sure to provide -a1
        a2         : in  std_logic_vector(31 downto 0); -- Make sure to provide -a2
        ready      : out std_logic;
        sample_out : out std_logic_vector(31 downto 0)
    );
end biquad;

architecture Behavioral of biquad is
    -- state machine state declarations
    type FILTER_STATES is 
        (IDLE, B2MUL,  B1MUL, B1ADD, B0MUL, B0ADD, A2MUL, A2ADD, A1MUL, A1ADD, A0ADD, FINI);
    signal state: FILTER_STATES := IDLE;

    -- delayed values
    signal x0 : std_logic_vector(31 downto 0);
    signal x1 : std_logic_vector(31 downto 0);
    --signal x2 : std_logic_vector(31 downto 0);
    signal y0 : std_logic_vector(31 downto 0);
    signal y1 : std_logic_vector(31 downto 0);
    signal y2 : std_logic_vector(31 downto 0);

    --- signals to the floating point arithmetic units ------
    signal numA       : std_logic_vector(31 downto 0);  -- floating point A argument
    signal numB       : std_logic_vector(31 downto 0);  -- floating point B argument
    signal add_result : std_logic_vector(31 downto 0);  -- FP answer from add operation
    signal mul_result : std_logic_vector(31 downto 0);  -- FP answer from multiply operation
    signal go_add     : std_logic := '0';               -- signal to start an add operation
    signal go_mul     : std_logic := '0';               -- signal to start an multiply operation
    signal done_add   : std_logic;                      -- signals that addition is finished
    signal done_mul   : std_logic;                      -- signals that multiplication is finished
    
    -- component declaration of the FP multiplier
    component FPP_MULT is
    port(
        A        : in  std_logic_vector(31 downto 0);  --input operands
        B        : in  std_logic_vector(31 downto 0);
        clk      : in  std_logic;
        reset    : in  std_logic;
        go       : in  std_logic;
        done     : out std_logic;
        overflow : out std_logic;
        result   : out std_logic_vector(31 downto 0)
    );
    end component;
    
    -- component declaration of the FP adder
    component FPP_ADD_SUB is
    port(
        A      : in  std_logic_vector(31 downto 0);
        B      : in  std_logic_vector(31 downto 0);
        clk    : in  std_logic;
        reset  : in  std_logic;
        go     : in  std_logic;
        done   : out std_logic;
        result : out std_logic_vector(31 downto 0)
    );
    end component;
    
begin
    -- instantiation of a floating point multiplier
    FP_MULTPLIER : FPP_MULT
    port map(
        A        => numA,
        B        => numB,
        clk      => clk,
        reset    => reset,
        go       => go_mul,
        done     => done_mul,
        overflow => open,
        result	 => mul_result
    );
    
    -- instantiation of a floating point adder
    FP_ADDER: FPP_ADD_SUB
    port map(
    	A        => numA,
        B        => numB,
        clk      => clk,
        reset    => reset,
        go       => go_add,
        done     => done_add,
        result   => add_result
    );
        
    -- state machine logic that guides the samples through the filter
    FILTER_SM: process (clk, reset) is
    begin  
        if reset = '1' then
            -- Filter Initialization 
            x0 <= (others => '0');
            x1 <= (others => '0');
            y0 <= (others => '0');
            y1 <= (others => '0');
            y2 <= (others => '0');

            go_add <= '0';
            go_mul <= '0';
            state <= IDLE;
        elsif rising_edge(clk) then
            -- Run the state machine
            case state is
                when IDLE =>                -- wait for a new sample, latch it and start computation
                    ready <= '0';
                    if new_sample = '1' then
                        
                        x0 <= sample_in; 
                        x1 <= x0;
                        y1 <= y0;
                        y2 <= y1;
                        
                        numA <= x1;        -- on this clock x1 is the old x1, i.e. the new x2
                        numB <= b2;	       -- start computing the new b2*x2 term (new x2=old x1)
                        go_mul <= '1';     -- start B2MUL
                        state <= B2MUL;	
                    end if;
                    ------
                when B2MUL =>               -- wait for the first multiplication to complete
                    if done_mul = '1' then  -- this state only serves to disable the go_mul signal for the first time
                        go_mul <= '0';      -- because no addition is done here (for the other steps, the go_mul signal
                        state <= B1MUL;     -- will be disable in a consecutive addition)
                    end if;
                ------
                when B1MUL =>               
                    if done_mul = '1' then  -- this check is unnecessary
                        y0 <= mul_result;   -- buffer b2*x2 in y0
                        numA <= x1;         -- on this clock x1 is correct x1
                        numB <= b1;         -- start computing the new b1*x1 term
                        go_mul <= '1';      -- start B1MUL
                        state <= B1ADD;    
                    end if;
                ------
                when B1ADD =>                -- wait for x1*b1 product to complete
                    if done_mul = '1' then
                        go_mul<= '0';
                        numA<= y0;           -- start accumulation of b1*x1 term into y0
                        numB<= mul_result;
                        go_add<= '1';
                        state<= B0MUL;
                    end if;
                ------
                when B0MUL =>                -- wait for x1*b1 term to be accumulated into y0
                    if done_add = '1' then
                        go_add<= '0';
                        y0 <= add_result;    -- y0 now = b2*x2 + b1*x1
                        numA<= x0;           -- x0 is the current sample
                        numB<= b0;           -- start computing new b0*x0 term
                        go_mul<= '1';
                        state<= B0ADD;
                    end if;
                ------
                when B0ADD =>                -- wait for b0*x0 to be computed
                    if done_mul = '1' then
                        go_mul<= '0';	
                        numA<= y0;           -- start accumulating x0 term into y0
                        numB<= mul_result;
                        go_add<= '1';
                        state<= A2MUL;
                    end if;
                ------
                when A2MUL =>                -- straightforward multiply and accumulate until the end
                    if done_add = '1' then
                        go_add<= '0';
                        y0 <= add_result; 
                        numA<= y2;
                        numB<= a2;
                        go_mul<= '1';
                        state<= A2ADD;
                    end if;
                ------
                when A2ADD =>
                    if done_mul = '1' then
                        go_mul<= '0';
                        numA<= y0;
                        numB<= mul_result;
                        go_add<= '1';
                        state<= A1MUL;
                    end if;
                ------
                when A1MUL =>
                    if done_add = '1' then
                        go_add<= '0';
                        y0 <= add_result;
                        numA<= y1;
                        numB<= a1;
                        go_mul<= '1';
                        state<= A1ADD;
                    end if;
                ------
                when A1ADD =>
                    if done_mul = '1' then
                        go_mul<= '0';
                        numA<= y0;
                        numB<= mul_result;
                        go_add<= '1';
                        state<= A0ADD;
                    end if;
                ------
                when A0ADD =>                -- wait for a1*y1 to be accumulated into y0
                    if done_add = '1' then
                        go_add<= '0';
                        y0 <= add_result;    -- final y0=b2x2+b1x1+b0x0+a2y2+a1y1
                        sample_out <= add_result;
                        state<= FINI;
                    end if;
                ------
                when FINI =>                 -- wait for new_sample to go low to avoid a race condition
                    if new_sample = '0' then
                        ready <= '1';
                        state <= IDLE; 
                    end if;
                ------	
                when others		=>
                    state <= IDLE;
                ------	
            end case;
        end if;
    end process FILTER_SM;

end Behavioral;