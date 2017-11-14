----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2017 01:01:20 PM
-- Design Name: 
-- Module Name: detect_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity detect_tb is
--  Port ( );
end detect_tb;

architecture Behavioral of detect_tb is

	component banddetect
        generic(
            -- biquad 1 and 2 300-500Hz
            VAR_Q1_B0   : std_logic_vector(31 downto 0) := x"3d1c865f";
            VAR_Q1_B1   : std_logic_vector(31 downto 0) := x"00000000";
            VAR_Q1_B2   : std_logic_vector(31 downto 0) := x"bd1c865f";
            VAR_Q1_A1   : std_logic_vector(31 downto 0) := x"bff3bc7d";
            VAR_Q1_A2   : std_logic_vector(31 downto 0) := x"3f6fbee1";
            
            VAR_Q2_B0   : std_logic_vector(31 downto 0) := x"3d1c865f";
            VAR_Q2_B1   : std_logic_vector(31 downto 0) := x"00000000";
            VAR_Q2_B2   : std_logic_vector(31 downto 0) := x"bd1c865f";
            VAR_Q2_A1   : std_logic_vector(31 downto 0) := x"bff84f84";
            VAR_Q2_A2   : std_logic_vector(31 downto 0) := x"3f749ea0"
        );
        port(
            clk        : in  std_logic;
            reset      : in  std_logic;
            new_sample : in  std_logic;
            sample_in  : in  std_logic_vector(31 downto 0);
            threshold  : in  std_logic_vector(31 downto 0);
            detect     : out std_logic
        );
    end component;
    
    component banddetect100300
        generic(
            TRESHOLD   : signed(15 downto 0) := to_signed(16,16)
        );
        port(
            clk        : in  std_logic;
            reset      : in  std_logic;
            new_sample : in  std_logic;
            sample_in  : in  std_logic_vector(31 downto 0);
            detect     : out std_logic
        );
    end component;
    
    signal clk : std_logic := '0'; 
    signal reset : std_logic := '1';
    signal valid_i : std_logic := '0';
    signal slv_reg0 : std_logic_vector(31 downto 0);
    signal slv_reg2 : std_logic_vector(31 downto 0);
    signal detect, detect_2 : std_logic;
    
    
    
    


begin

    inst2_banddetect : banddetect100300
    generic map(
        TRESHOLD => to_signed(4096,16)
        )
       port map(
            clk        => clk,
            reset      => reset,
            new_sample => valid_i,
            sample_in  => slv_reg0,
            detect     => detect_2    
        );
        




    inst1_banddetect : banddetect 
    generic map(
    -- 100 ~ 300 Hz @ 16kHz
--            VAR_Q1_B0   => x"3D1C865F",
--            VAR_Q1_B1   => x"00000000",
--            VAR_Q1_B2   => x"BD1C8655",
--            VAR_Q1_A1   => x"3FF51207",
--            VAR_Q1_A2   => x"BF6CD148",
            
--            VAR_Q2_B0   => x"3D1C865F",
--            VAR_Q2_B1   => x"00000000",
--            VAR_Q2_B2   => x"BD1C8655",
--            VAR_Q2_A1   => x"3FFB92FD",
--            VAR_Q2_A2   => x"BF77A4EB"
    
        -- 300 ~ 500 Hz @ 16kHz
        VAR_Q1_B0   => x"3d1c865f",
        VAR_Q1_B1   => x"00000000",
        VAR_Q1_B2   => x"bd1c865f",
        VAR_Q1_A1   => x"bff3bc7d",
        VAR_Q1_A2   => x"3f6fbee1",
        
        VAR_Q2_B0   => x"3d1c865f",
        VAR_Q2_B1   => x"00000000",
        VAR_Q2_B2   => x"bd1c865f",
        VAR_Q2_A1   => x"bff84f84",
        VAR_Q2_A2   => x"3f749ea0"
    )
    port map(
        clk        => clk,
        reset      => reset,
        new_sample => valid_i,
        sample_in  => slv_reg0,
        threshold  => slv_reg2,
        detect     => detect    
    );
    
    clock_gen : process is
    begin
        clk <= '1' after 10 ns, '0' after 20 ns;
        wait for 20 ns;
    end process clock_gen;
    
    reset_gen : process is
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait;
    end process reset_gen;
    
    sti_gen : process is
    begin
        slv_reg0 <= x"45800000";
        slv_reg2 <= x"45800000";    
        
        for i in 0 to 1000 loop
            valid_i <= '1';
            wait for 20 ns;
            valid_i <= '0';
            wait for 10us;
        end loop;
    
    end process sti_gen;


end Behavioral;
