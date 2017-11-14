----------------------------------------------------------------------------------
-- Company: KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Create Date: 04.08.2016
-- Module Name: FPP_MULT - Behavioral
-- Project Name: Labo Digitaal Ontwerp II
-- Target Devices: Artix 7
-- Description: Single precision floating point multiplier from the FloatPt package
--              see acknowledgement
-- 
-- Dependencies: none
-- 
----------------------------------------------------------------------------------
-- Johns Hopkins University - FPGA Senior Projects, R.E.Jenkins
-- Floating point vhdl Package - Ryan Fay, Alex Hsieh, David Jeang
-- This file contains the components and functions used for Floating point arithmetic
---------
-- Copywrite Johns Hopkins University ECE department. This software may be freely
-- used and modified as long as this acknowledgement is retained.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FPP_MULT is
  port(A        : in  std_logic_vector(31 downto 0);  --input operands
       B        : in  std_logic_vector(31 downto 0);
       clk      : in  std_logic;
       reset    : in  std_logic;
       go       : in  std_logic;
       done     : out std_logic;
       overflow : out std_logic;
       result   : out std_logic_vector(31 downto 0)
       );
end FPP_MULT;

-----------------------------------
architecture Behavioral of FPP_MULT is
    
    constant BIAS : unsigned(8 downto 0) := to_unsigned(127, 9);  --exponent bias of 127
    
    signal full_mantissa : std_logic_vector(47 downto 0);
    signal full_exp      : std_logic_vector(8 downto 0);  --extra msb for unsigned exponent addition
    signal R_sign        : std_logic;
    
    signal Aop, Bop : std_logic_vector(31 downto 0);  --latched operands
    alias A_sign    : std_logic is Aop(31);           --operand segments
    alias A_exp     : std_logic_vector(7 downto 0) is Aop(30 downto 23);
    alias A_man     : std_logic_vector(22 downto 0) is Aop(22 downto 0);
    
    alias B_sign : std_logic is Bop(31);
    alias B_exp  : std_logic_vector(7 downto 0) is Bop(30 downto 23);
    alias B_man  : std_logic_vector(22 downto 0) is Bop(22 downto 0);
    
    signal multA : std_logic_vector(23 downto 0);
    signal multB : std_logic_vector(23 downto 0);
    signal multM : std_logic_vector(47 downto 0);
    
    -- STATE MACHINE DECLARATION
    type MULT_SM is (WAITM, MAN_EXP, CHECK, NORMALIZE, PAUSE);
    signal MULTIPLY            : MULT_SM;
    attribute INIT             : string;
    attribute INIT of MULTIPLY : signal is "WAITM";
    -----------------------------------
    component mult_gen_0 is
    port(
        CLK : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
        P : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
    );
    end component;
begin

--    generated_multiplier : mult_gen_0
--    port map(
--        CLK => clk,
--        A   => multA,
--        B   => multB,
--        P   => multM
--    );
    multA <= '1' & A_man;
    multB <= '1' & B_man;
    multM <= std_logic_vector(unsigned(multA) * unsigned(multB));

  process (MULTIPLY, clk, go, reset) is
  begin
    if (reset = '1') then
      full_mantissa <= (others => '0');
      full_exp      <= (others => '0');
      done          <= '0';
      MULTIPLY      <= WAITM;
    elsif (rising_edge(clk)) then
      case (MULTIPLY) is
        when WAITM =>
          overflow <= '0';
          done     <= '0';
          if (go = '1') then
            Aop      <= A;              --latch input values
            Bop      <= B;
            MULTIPLY <= MAN_EXP;
          else
            MULTIPLY <= WAITM;
          end if;
        when MAN_EXP =>  --compute a sign, exponent and matissa for product
          if (Aop = x"00000000") or (Bop = x"00000000") then --modification by Geoffrey Ottoy
            R_sign <= '0';
            full_mantissa <= (others => '0');
            full_exp      <= (others => '0');
          else
              R_sign        <= A_sign xor B_sign;
              full_mantissa <= multM;
              --full_exp <= std_logic_vector( (unsigned(A_exp)-BIAS) + (unsigned(B_exp)-BIAS)+ BIAS );
              full_exp      <= std_logic_vector((unsigned(A_exp)- BIAS) + unsigned(B_exp));
          end if;
          --MULTIPLY <= CHECK;
          MULTIPLY      <= NORMALIZE;
        when CHECK =>                   --Check for exponent overflow
          if (unsigned(full_exp) > 255) then
            overflow <= '1';
            result   <= (31 => R_sign, others => '1');
            done     <= '1';
            MULTIPLY <= PAUSE;
          else
            MULTIPLY <= NORMALIZE;
          end if;
        when NORMALIZE =>
          if full_mantissa(47) = '1' then
            full_mantissa <= '0' & full_mantissa(47 downto 1);
            full_exp      <= std_logic_vector(unsigned(full_exp) + 1);
          else
            result   <= R_sign & full_exp(7 downto 0) & full_mantissa(45 downto 23);
            done     <= '1';            --signal that operation completed
            MULTIPLY <= PAUSE;
          end if;
        when PAUSE =>                   -- wait for acknowledgement
          if (go = '0') then
            done     <= '0';
            MULTIPLY <= WAITM;
          end if;
        when others =>
          MULTIPLY <= WAITM;
      end case;
    end if;
  end process;

end Behavioral;