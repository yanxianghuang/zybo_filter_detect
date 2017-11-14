----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.08.2016 13:34:19
-- Design Name: 
-- Module Name: bandpass_iir4 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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

entity bandpass_iir4 is
    port(
        clk : in std_logic;
        reset : in std_logic;
        new_sample : in std_logic;
        ready : out std_logic;
        datain : in std_logic_vector(31 downto 0);
        dataout : out std_logic_vector(31 downto 0)
    );
end bandpass_iir4;

architecture Behavioral of bandpass_iir4 is
    --------Filter Modeled constants with matlab----------
    --Fs = 16e+3 Hz, Fc = [100, 400] Hz, Order = 4
    --Process steps: 
    -- x2<=x1, x1<=x0, x0<=datain, y3<=y2, y2<= y1, y1<= y0
    --	y0 <= b3*x3 (this is actually the old x2. the new x3 is not saved)		
    --	y0<=y0+b2*x2  			
    --	y0<=y0+b1*x1			
    --	y0<=y0+b0*x0  
    --	y0<=y0+a3*y3 --signs of a3-a1 are flipped			
    --	y0<=y0+a2*y2 			
    --	y0<=y0+a1*y1
    --	vout<= y0;  
    -- NOTE the signs of a are flipped so we can use adders 
    -----------------------------------

    -- bandpass constants
    constant b0 : std_logic_vector := x"3ABF6815";	--  0.0015 ...
    constant b1 : std_logic_vector := x"00000000";	--  0.0000 ...
    constant b2 : std_logic_vector := x"BB3F6815";	-- -0.0029 ...
    constant b3 : std_logic_vector := x"00000000";	--  0.0000 ...
    constant b4 : std_logic_vector := x"3ABF6815";	--  0.0015 ...
    -- a0 is always zero (coefficients are negated)
    constant a1 : std_logic_vector := x"40785282";	--  3.8800 ...
    constant a2 : std_logic_vector := x"C0B4F977";	-- -5.6555 ...
    constant a3 : std_logic_vector := x"406AE5B8";	--  3.6703 ...
    constant a4 : std_logic_vector := x"BF65167C";	-- -0.8949 ...

    -- state machine declarations
    type FILT_SM is 
        (IDLE, B3MUL, B3ADD, B2MUL, B2ADD, B1MUL, B1ADD, B0MUL, B0ADD, A3MUL, A4ADD, A4MUL, A3ADD, A2MUL, A2ADD, A1MUL, A1ADD, A0ADD, FINI);
    signal state: FILT_SM := IDLE;
    --attribute INIT: string;
    --attribute INIT of state: signal is "IDLE";

    -- delayed values
    type dbuf is array (0 to 4) of std_logic_vector(31 downto 0);
    signal x : dbuf := (
        0 => x"00000000",
        1 => x"00000000",
        2 => x"00000000",
        3 => x"00000000",
        4 => x"00000000"
    );
    signal y : dbuf := (
        0 => x"00000000",
        1 => x"00000000",
        2 => x"00000000",
        3 => x"00000000",
        4 => x"00000000"
    );
    
    --- signals to the floating point arithmetic units ------
    signal numA       : std_logic_vector(31 downto 0);  -- floating point A argument
    signal numB       : std_logic_vector(31 downto 0);  -- floating point B argument
    signal add_result : std_logic_vector(31 downto 0);  -- FP answer from add operation
    signal mul_result : std_logic_vector(31 downto 0);  -- FP answer from multiply operation
    signal go_add     : std_logic := '0';               -- signal to start an add operation
    signal go_mul     : std_logic := '0';               -- signal to start an multiply operation
    signal done_add   : std_logic;                      -- signals that addition is finished
    signal done_mul   : std_logic;                      -- signals that multiplication is finished
    
    -- component declarations of the FP multiplier and adder
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
    -- instantiation of a floating point multiplier (FloatPt package)
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
    
    -- instantiation of a floating point adder (FloatPt package)
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
            ---Filter Initialization 
            x(0) <= (others => '0');
            x(1) <= (others => '0');
            x(2) <= (others => '0');
            x(3) <= (others => '0');
            y(0) <= (others => '0');
            y(1) <= (others => '0');
            y(2) <= (others => '0');
            y(3) <= (others => '0');
            y(4) <= (others => '0');
            
            go_add <= '0';
            go_mul <= '0';
            state <= IDLE;
        elsif rising_edge(clk) then  
            case state is
            when IDLE	=>	 --wait for a new sample, latch it and start computation
                if new_sample = '1' then
                    ready <= '0';
                    
                    x(0) <= datain; 
                    x(1) <= x(0);
                    x(2) <= x(1);
                    x(3) <= x(2);
                    y(1) <= y(0);
                    y(2) <= y(1);
                    y(3) <= y(2);
                    y(4) <= y(3);
                    
                    numA <= x(3);	--on this clock x2 is the old x2, i.e. the new x3
                    numB <= b4;	    --start computing the new b3*x3 term (new x3=old x2)
                    go_mul <= '1';  --start B4MUL
                    state <= B3MUL;	--start accumulating a new y0 with a new x3 term
                end if;
            ------
            when B3MUL =>		--wait for b4*x4  to be computed
                if done_mul = '1' then
                    go_mul<= '0';
                    y(0) <= mul_result;	 --new y0=b3x3
                    numA<= x(3);	--start computing new b2x2 (in this state, x2 is the new value) 
                    numB<= b3;
                    state<= B3ADD;
                end if;
            ------
            when B3ADD =>		--wait for x2 product to complete
                go_mul<= '1';
                if done_mul = '1' then
                    go_mul<= '0';
                    numA<= y(0);			--start accumulation of b2x2 term into y0
                    numB<= mul_result;
                    go_add<= '1';
                    state<= B2MUL;
                end if;
            ------
            when B2MUL =>		--wait for x2 to be accumulated into y0
                if done_add = '1' then
                    go_add<= '0';
                    y(0) <= add_result; --y0 now = b3x3+b2x2
                    numA<= x(2);
                    numB<= b2;
                    go_mul<= '1';	--start computing new b1*x1 term
                    state<= B2ADD;
                end if;
            ------
            when B2ADD =>		--wait for computation of new x1 to complete
                if done_mul = '1' then
                    go_mul<= '0';
                    numA<= y(0);			--start accumulation of new b1x1 term  into y0
                    numB<= mul_result;
                    go_add<= '1';
                    state<= B1MUL;
                end if;
            ------
            when B1MUL =>        --wait for x2 to be accumulated into y0
                if done_add = '1' then
                    go_add<= '0';
                    y(0) <= add_result; --y0 now = b3x3+b2x2
                    numA<= x(1);
                    numB<= b1;
                    go_mul<= '1';    --start computing new b1*x1 term
                    state<= B1ADD;
                end if;
            ------
            when B1ADD =>        --wait for computation of new x1 to complete
                if done_mul = '1' then
                    go_mul<= '0';
                    numA<= y(0);            --start accumulation of new b1x1 term  into y0
                    numB<= mul_result;
                    go_add<= '1';
                    state<= B0MUL;
                end if;
            ------
            when B0MUL =>		--wait for x1 term to be accumulated into y0
                if done_add = '1' then
                    go_add<= '0';
                    y(0) <= add_result;		--y0 now = b3x3+b2x2+b1x1
                    numA<= x(0);		--x0 is the current sample
                    numB<= b0;		--start computing new b0*sample term
                    go_mul<= '1';
                    state<= B0ADD;
                end if;
            ------
            when B0ADD =>		--wait for new x0 to be computed
                if done_mul = '1' then
                    go_mul<= '0';	
                    numA<= y(0);	--start accumulating x0 term into y0
                    numB<= mul_result;
                    go_add<= '1';
                    state<= A4MUL;
                end if;
            ------
            when A4MUL =>		--wait for accumulation of new x0 term
                if done_add = '1' then
                    go_add<= '0';
                    y(0) <= add_result;	--now y0=b3x3+b2x2+b1x1+b0x0
                    numA<= y(4);			--start computing new a3*y3
                    numB<= a4;
                    go_mul<= '1';
                    state<= A4ADD;
                end if;
            ------
            when A4ADD =>		--wait for computation of new a3y3 to complete
                if done_mul = '1' then
                    go_mul<= '0';
                    numA<= y(0);			--start accumulation of new y3 term into y0
                    numB<= mul_result;
                    go_add<= '1';
                    state<= A3MUL;
                end if;
            ------
            when A3MUL =>		--wait for accumulation of new x0 term
                if done_add = '1' then
                    go_add<= '0';
                    y(0) <= add_result;    --now y0=b3x3+b2x2+b1x1+b0x0
                    numA<= y(3);            --start computing new a3*y3
                    numB<= a3;
                    go_mul<= '1';
                    state<= A3ADD;
                end if;
            ------
            when A3ADD =>        --wait for computation of new a3y3 to complete
                if done_mul = '1' then
                    go_mul<= '0';
                    numA<= y(0);            --start accumulation of new y3 term into y0
                    numB<= mul_result;
                    go_add<= '1';
                    state<= A2MUL;
                end if;
            ------
            when A2MUL =>		--wait for accumulation of new x0 term
                if done_add = '1' then
                    go_add<= '0';
                    y(0) <= add_result;    --now y0=b3x3+b2x2+b1x1+b0x0
                    numA<= y(2);            --start computing new a3*y3
                    numB<= a2;
                    go_mul<= '1';
                    state<= A2ADD;
                end if;
            ------
            when A2ADD =>        --wait for computation of new a3y3 to complete
                if done_mul = '1' then
                    go_mul<= '0';
                    numA<= y(0);            --start accumulation of new y3 term into y0
                    numB<= mul_result;
                    go_add<= '1';
                    state<= A1MUL;
                end if;
            ------
            when A1MUL =>		--wait for a2y2 term to be accumulated into y0
                if done_add = '1' then
                    go_add<= '0';
                    y(0) <= add_result;	--now y0 = b3x3+b2x2+b1x1+b0x0+a3y3+a2y2
                    numA<= y(1);
                    numB<= a1;		--start computing new a1y1 term
                    go_mul<= '1';
                    state<= A1ADD;
                end if;
            ------
            when A1ADD =>		--wait for computation of new y1 term to complete
                if done_mul = '1' then
                    go_mul<= '0';
                    numA<= y(0);			--start accumulation of a1y1 into y0
                    numB<= mul_result;
                    go_add<= '1';
                    state<= A0ADD;
                end if;
            ------
            when A0ADD =>		--wait for a1y1 to be accumulated into y0
                if done_add = '1' then
                    go_add<= '0';
                    y(0) <= add_result;	--final y0=b3x3+b2x2+b1x1+b0x0+a3y3+a2y2+a1y1
                    --vout <= FP_TO_SIGNED(add_result, 16); --convert and latch the new vout
                    dataout <= add_result;
                    --vout <= FP_TO_SIGNED(x0,16); --*****debug
                    state<= FINI;
                end if;
            ------
            when FINI	=>		--wait for samp_clk to go low to avoid a race condition
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
    end process;

end Behavioral;