----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.08.2016 13:23:26
-- Design Name: 
-- Module Name: unsigned_multiplier - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity unsigned_multiplier is
    generic(
        INPUT_WIDTH : natural := 24;
        N_PIPELINE_STAGES : natural := 5
    );
    port(
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        A     : in  STD_LOGIC_VECTOR(INPUT_WIDTH-1 downto 0);
        B     : in  STD_LOGIC_VECTOR(INPUT_WIDTH-1 downto 0);
        go    : in  STD_LOGIC;
        done  : out STD_LOGIC;
        M     : out STD_LOGIC_VECTOR((INPUT_WIDTH*2)-1 downto 0)
    );
end unsigned_multiplier;

architecture Behavioral of unsigned_multiplier is
    component mult_gen_0 is
    port(
        CLK  : IN  STD_LOGIC;
        A    : IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
        B    : IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
        SCLR : IN  STD_LOGIC;
        P    : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
    );
    end component;
    
    signal clk_i : std_logic;
begin
    BUFG_inst : BUFG
    port map (
        O => clk_i, -- 1-bit output: Clock output
        I => clk  -- 1-bit input: Clock input
    );

    generated_multiplier : mult_gen_0
    port map(
        CLK  => clk,
        A    => A,
        B    => B,
        SCLR => reset,
        P    => M
    );
    
    COUNT_STAGES : process(reset, clk_i)
        variable st_counter : natural range 0 to N_PIPELINE_STAGES := 0;
    begin
        if reset = '1' then
            st_counter := 0;
            done <= '0';
        elsif rising_edge(clk_i) then
            -- start the counter
            if go = '1' then
                st_counter := st_counter + 1;
                done <= '0';
            end if;
            
            -- check ready
            case st_counter is
                when 0 =>
                    st_counter := st_counter;
                    done <= '0';
                when N_PIPELINE_STAGES =>
                    st_counter := 0;
                    done <= '1';
                when others =>
                    st_counter := st_counter + 1;
                    done <= '0';
            end case;
        end if;
    end process COUNT_STAGES;

end Behavioral;
