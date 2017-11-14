----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.08.2016 14:33:46
-- Design Name: 
-- Module Name: single_precision_multiplier - Behavioral
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

entity single_precision_multiplier is
    port(
        A        : in  std_logic_vector(31 downto 0);  --input operands
        B        : in  std_logic_vector(31 downto 0);
        clk      : in  std_logic;
        reset    : in  std_logic;
        go       : in  std_logic;
        done     : out std_logic;
        result   : out std_logic_vector(31 downto 0)
    );
end single_precision_multiplier;

architecture Behavioral of single_precision_multiplier is
    component unsigned_multiplier is
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
    end component;
begin
    mantissamult : unsigned_multiplier
    generic map(
        INPUT_WIDTH => 24,
        N_PIPELINE_STAGES => 5
    )
    port map(
        clk    => clk,
        reset  => reset,
        A      => A,
        B      => B,
        go     => go,
        done   => done,
        M      => result
    );


end Behavioral;
