----------------------------------------------------------------------------------
-- Company: KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Create Date: 08.08.2016
-- Module Name: banddetect - Behavioral
-- Project Name: Labo Digitaal Ontwerp II
-- Target Devices: Artix 7
-- Description: This module analyses if audio is present in the frequency band
--              between 100 Hz and 300 Hz.
-- 
-- Dependencies: FPP_MULT.vhd
--               biquad.vhd
-- 
----------------------------------------------------------------------------------

-- TODO maybe we do the control of reading of the samples internally

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity banddetect is
    generic(
        -- biquad 1 and 2
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
end banddetect;

architecture Behavioral of banddetect is
    -- biquad 1 and 2 from a 4th order iir bandpass filter {100 Hz, 300 Hz} @ 16 kHz
    -- biquad 3 and 4 from a 4th order iir lowpass filter {0 Hz, 100 Hz} @ 16 kHz
    -- biquad 1 coefficients
    
    constant q1_b0 : std_logic_vector(31 downto 0) := VAR_Q1_B0;
    constant q1_b1 : std_logic_vector(31 downto 0) := VAR_Q1_B1;
    constant q1_b2 : std_logic_vector(31 downto 0) := VAR_Q1_B2;
    constant q1_a1 : std_logic_vector(31 downto 0) := VAR_Q1_A1; -- -a1 from matlab sos
    constant q1_a2 : std_logic_vector(31 downto 0) := VAR_Q1_A2; -- -a2 from matlab sos

    constant q2_b0 : std_logic_vector(31 downto 0) := VAR_Q2_B0;
    constant q2_b1 : std_logic_vector(31 downto 0) := VAR_Q2_B1;
    constant q2_b2 : std_logic_vector(31 downto 0) := VAR_Q2_B2;
    constant q2_a1 : std_logic_vector(31 downto 0) := VAR_Q2_A1; -- -a1 from matlab sos
    constant q2_a2 : std_logic_vector(31 downto 0) := VAR_Q2_A2; -- -a2 from matlab sos
    
--    constant q1_b0 : std_logic_vector(31 downto 0) := x"3d1c865f";
--    constant q1_b1 : std_logic_vector(31 downto 0) := x"00000000";
--    constant q1_b2 : std_logic_vector(31 downto 0) := x"bd1c865f";
--    constant q1_a1 : std_logic_vector(31 downto 0) := x"bff3bc7d"; -- -a1 from matlab sos
--    constant q1_a2 : std_logic_vector(31 downto 0) := x"3f6fbee1"; -- -a2 from matlab sos

--    constant q2_b0 : std_logic_vector(31 downto 0) := x"3d1c865f";
--    constant q2_b1 : std_logic_vector(31 downto 0) := x"00000000";
--    constant q2_b2 : std_logic_vector(31 downto 0) := x"bd1c865f";
--    constant q2_a1 : std_logic_vector(31 downto 0) := x"bff84f84"; -- -a1 from matlab sos
--    constant q2_a2 : std_logic_vector(31 downto 0) := x"3f749ea0"; -- -a2 from matlab sos
  
    
    -- biquad 3 coefficients
    constant q3_b0 : std_logic_vector(31 downto 0) := x"39BB32DB";
    constant q3_b1 : std_logic_vector(31 downto 0) := x"3A3B32DB";
    constant q3_b2 : std_logic_vector(31 downto 0) := x"39BB32DB";
    constant q3_a1 : std_logic_vector(31 downto 0) := x"3FFE695D"; -- -a1 from matlab sos
    constant q3_a2 : std_logic_vector(31 downto 0) := x"BF7D35E0"; -- -a2 from matlab sos
    -- biquad 4 coefficients
    constant q4_b0 : std_logic_vector(31 downto 0) := x"38D28242";
    constant q4_b1 : std_logic_vector(31 downto 0) := x"39528242";
    constant q4_b2 : std_logic_vector(31 downto 0) := x"38D28242";
    constant q4_a1 : std_logic_vector(31 downto 0) := x"3FFC9A66"; -- -a1 from matlab sos
    constant q4_a2 : std_logic_vector(31 downto 0) := x"BF7950AC"; -- -a2 from matlab sos

    ---------------------------------------------------------------------------------
    -- Function SIGNED_TO_FP taken from the FloatPt package
    ---------------------------------------------------------------------------------
    -- Copywrite Johns Hopkins University ECE department. This software may be freely
    -- used and modified as long as this acknowledgement is retained.
    ---------------------------------------------------------------------------------
    function SIGNED_TO_FP(v : signed) return std_logic_vector is
        --Convert a signed binary integer to 32-bit floating pt sign-magnitude format 
        variable i   : integer range 0 to v'left+1;
        variable j   : integer range 0 to 255;
        variable fp  : std_logic_vector(31 downto 0);  --returned FP
        variable exp : integer range -1024 to 1024;    --exponent
        variable m   : unsigned(v'length downto 0);    --mantissa + leading bit  
    begin
        m := '0' & unsigned(abs(v));  --we use the mag of v to create a mantissa
        --start with biased exp equiv to 2**(LENGTH-1), so m becomes the mantissa, m.mmmmm...
        --i.e. mag(v) = 2**(exp-127) * m.m m m m m....
        exp := 127 + m'length-1;
        --normalize m as the mantissa with one bit in front of the decimal point 
        for i in 0 to m'left loop
            if m(m'left) = '1' then
                j := i;
                exit;
            else
                m := m(m'left-1 downto 0) & '0';
                                          --exp:= exp - 1;
            end if;
        end loop;
        exp := exp - j;
        fp(30 downto 23) := std_logic_vector(TO_UNSIGNED(exp, 8));
        -- Make sure we have enough bits for a normalized full mantissa (23)
        -- and at the same time remove the mantissa leading 1
        if m'length < 24 then  -- <24 bits, bottom bits set to 0, and drop the leading 1        
            fp(23-m'length downto 0) := (others => '0');
            fp(22 downto 24-m'length) := std_logic_vector(m(m'length-2 downto 0));
        else  --if >= 24, drop leading 1 and take next 23 bits for fp
            fp(22 downto 0) := std_logic_vector(m(m'length-2 downto m'length-24));
        end if;
        
        if v(v'left) = '1' then
            fp(31) := '1';
        else fp(31) := '0';
        end if;
        return fp;
    end function SIGNED_TO_FP;
    ---------------------------------

    -- buffers to pass the intermediate results
    signal q12_i   :  std_logic_vector(31 downto 0) := (others=>'0');
    signal q2m_i   :  std_logic_vector(31 downto 0) := (others=>'0');
    signal mq3_i   :  std_logic_vector(31 downto 0) := (others=>'0');
    signal q34_i   :  std_logic_vector(31 downto 0) := (others=>'0');
    signal q4a_i   :  std_logic_vector(31 downto 0) := (others=>'0');
    signal a_i     :  std_logic_vector(31 downto 0) := (others=>'0');
    
    -- signals to control the modules
    signal control_i : std_logic_vector(4 downto 0) := (others=>'0');
    
    -- signals for the treshold detection
    -- constant treshold_i : std_logic_vector(31 downto 0) := SIGNED_TO_FP(THRESHOLD);
    signal th_neg_i : std_logic_vector(31 downto 0) := (others=>'0');

    -- component declaration of a biquad filter
    component biquad is
    port(
        clk        : in  std_logic;
        reset      : in  std_logic;
        new_sample : in  std_logic;
        sample_in  : in  std_logic_vector(31 downto 0);
        b0         : in  std_logic_vector(31 downto 0);
        b1         : in  std_logic_vector(31 downto 0);
        b2         : in  std_logic_vector(31 downto 0);
        a1         : in  std_logic_vector(31 downto 0); -- (-a1)
        a2         : in  std_logic_vector(31 downto 0); -- (-a2)
        ready      : out std_logic;
        sample_out : out std_logic_vector(31 downto 0)
    );
    end component;
    
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
    -- Operation:
    --  1) bandpass filter (Q1 & Q2)
    --  2) square result
    --  3) low-pass filter (Q3 & Q4)
    --  4) treshold detection

    Q1 : biquad
    port map(
        clk        => clk,
        reset      => reset,
        new_sample => new_sample,
        sample_in  => sample_in,
        b0         => q1_b0,
        b1         => q1_b1,
        b2         => q1_b2,
        a1         => q1_a1,
        a2         => q1_a2,
        ready      => control_i(0),
        sample_out => q12_i
    );
    
    Q2 : biquad
    port map(
        clk        => clk,
        reset      => reset,
        new_sample => control_i(0),
        sample_in  => q12_i,
        b0         => q2_b0,
        b1         => q2_b1,
        b2         => q2_b2,
        a1         => q2_a1,
        a2         => q2_a2,
        ready      => control_i(1),
        sample_out => q2m_i
    );
    
--    SQUARING : FPP_MULT
--    port map(
--        A        => q2m_i,
--        B        => q2m_i,
--        clk      => clk,
--        reset    => reset,
--        go       => control_i(1),
--        done     => control_i(2),
--        overflow => open,
--        result   => mq3_i
--    );
    -- absolute value (quick replacement)
    control_i(2) <= control_i(1);    
    mq3_i <= '0' & q2m_i(30 downto 0);

    Q3 : biquad
    port map(
        clk        => clk,
        reset      => reset,
        new_sample => control_i(2),
        sample_in  => mq3_i,
        b0         => q3_b0,
        b1         => q3_b1,
        b2         => q3_b2,
        a1         => q3_a1,
        a2         => q3_a2,
        ready      => control_i(3),
        sample_out => q34_i
    );

    Q4 : biquad
    port map(
        clk        => clk,
        reset      => reset,
        new_sample => control_i(3),
        sample_in  => q34_i,
        b0         => q4_b0,
        b1         => q4_b1,
        b2         => q4_b2,
        a1         => q4_a1,
        a2         => q4_a2,
        ready      => control_i(4),
        sample_out => q4a_i
    );
    
    -- negate the treshold
    th_neg_i <= not threshold(31) & threshold(30 downto 0);
    
    -- result = filter output (qa4_i) + -treshold (th_neg_i)
    LEVEL_DETECT: FPP_ADD_SUB
    port map(
        A        => q4a_i,
        B        => th_neg_i,
        clk      => clk,
        reset    => reset,
        go       => control_i(4),
        done     => open,
        result   => a_i
    );
    
    -- invert sign bit
    detect <= not(a_i(31));

end Behavioral;
