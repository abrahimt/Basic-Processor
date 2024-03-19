-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- Barrel_Shifter.vhd
-- Barrel Shifter module to perform left or right logical shifts on a 32-bit input vector.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Barrel_Shifter is
  port(
    i_shamt      : in std_logic_vector(4 downto 0);  -- Shift amount
    i_sign       : in std_logic;                     -- Shift direction control (left or right)
    i_leftShift  : in std_logic;                     -- Logical shift direction control
    i_D          : in std_logic_vector(31 downto 0); -- Input vector to be shifted
    o_O          : out std_logic_vector(31 downto 0) -- Output vector after shifting
  );
end Barrel_Shifter;

architecture structural of Barrel_Shifter is

  component mux2t1 is
    port(
      i_S  : in std_logic;
      i_D0 : in std_logic;
      i_D1 : in std_logic;
      o_O  : out std_logic
    );
  end component;
  
  component mux2t1_N is
    generic(N : integer := 32);
    port(
      i_S  : in std_logic;
      i_D0 : in std_logic_vector;
      i_D1 : in std_logic_vector;
      o_O  : out std_logic_vector
    );
  end component;
  
  signal s_i_D           : std_logic_vector(31 downto 0) := x"00000000";  -- Input vector
  signal s_i_D_reverse   : std_logic_vector(31 downto 0) := x"00000000";  -- Reversed input vector
  signal s_shift_1       : std_logic_vector(31 downto 0) := x"00000000";  -- Shifted by 1 bit
  signal s_shift_2       : std_logic_vector(31 downto 0) := x"00000000";  -- Shifted by 2 bits
  signal s_shift_4       : std_logic_vector(31 downto 0) := x"00000000";  -- Shifted by 4 bits
  signal s_shift_8       : std_logic_vector(31 downto 0) := x"00000000";  -- Shifted by 8 bits
  signal s_o_O           : std_logic_vector(31 downto 0) := x"00000000";  -- Output vector
  signal s_o_O_reverse   : std_logic_vector(31 downto 0) := x"00000000";  -- Reversed output vector

begin

-- Reverse bits if left shift
G_REVERSE_INPUT_BITS: for i in 0 to 31 generate
    s_i_D_reverse(i) <= i_D(31 - i);
end generate G_REVERSE_INPUT_BITS;

-- MUX for selecting input based on leftShift signal
G_INPUT_MUX: mux2t1_N
    port map(
        i_S => i_leftShift,
        i_D0 => i_D,
        i_D1 => s_i_D_reverse,
        o_O => s_i_D
    );

-- First Level shift by 1 logic
-- Shift inputs
G_MUX_1_SHIFT: for i in 0 to 30 generate
    MUXI: mux2t1
        port map(
            i_S => i_shamt(0),
            i_D0 => s_i_D(i),
            i_D1 => s_i_D(i + 1),
            o_O => s_shift_1(i)
        ); 
end generate G_MUX_1_SHIFT;

-- Handle shifting of the MSB (Most Significant Bit) separately
MUX_1_SHIFT_MSB: mux2t1
    port map(
        i_S => i_shamt(0),
        i_D0 => s_i_D(31),
        i_D1 => i_sign,
        o_O => s_shift_1(31)
    ); 
  
-- First Level shift by 2 logic
-- Shift inputs
G_MUX_2_SHIFT_INPUTS: for i in 0 to 29 generate
    MUXI: mux2t1 
        port map(
            i_S => i_shamt(1),
            i_D0 => s_shift_1(i),
            i_D1 => s_shift_1(i + 2),
            o_O => s_shift_2(i)
        ); 
end generate G_MUX_2_SHIFT_INPUTS;

-- Handle shifting of the MSBs separately
G_MUX_2_SHIFT_MSB: for i in 30 to 31 generate
    MUX_2_SHIFT: mux2t1
        port map(
            i_S => i_shamt(1),
            i_D0 => s_shift_1(i),
            i_D1 => i_sign,
            o_O => s_shift_2(i)
        ); 
end generate G_MUX_2_SHIFT_MSB;
  
-- First Level shift by 4 logic
-- Shift inputs
G_MUX_4_SHIFT_INPUTS: for i in 0 to 27 generate
    MUXI: mux2t1 
        port map(
            i_S => i_shamt(2),
            i_D0 => s_shift_2(i),
            i_D1 => s_shift_2(i + 4),
            o_O => s_shift_4(i)
        ); 
end generate G_MUX_4_SHIFT_INPUTS;

-- Handle shifting of the MSBs separately
G_MUX_4_SHIFT_MSB: for i in 28 to 31 generate
    MUX_4_SHIFT: mux2t1
        port map(
            i_S => i_shamt(2),
            i_D0 => s_shift_2(i),
            i_D1 => i_sign,
            o_O => s_shift_4(i)
        ); 
end generate G_MUX_4_SHIFT_MSB;

-- First Level shift by 8 logic
-- Shift inputs
G_MUX_8_SHIFT_INPUTS: for i in 0 to 23 generate
    MUXI: mux2t1 
        port map(
            i_S => i_shamt(3),
            i_D0 => s_shift_4(i),
            i_D1 => s_shift_4(i + 8),
            o_O => s_shift_8(i)
        ); 
end generate G_MUX_8_SHIFT_INPUTS;

-- Handle shifting of the MSBs separately
G_MUX_8_SHIFT_MSB: for i in 24 to 31 generate
    MUX_8_SHIFT: mux2t1
        port map(
            i_S => i_shamt(3),
            i_D0 => s_shift_4(i),
            i_D1 => i_sign,
            o_O => s_shift_8(i)
        ); 
end generate G_MUX_8_SHIFT_MSB;

-- First Level shift by 16 logic
-- Shift inputs
G_MUX_16_SHIFT_INPUTS: for i in 0 to 15 generate
    MUXI: mux2t1 
        port map(
            i_S => i_shamt(4),
            i_D0 => s_shift_8(i),
            i_D1 => s_shift_8(i + 16),
            o_O => s_o_O(i)
        ); 
end generate G_MUX_16_SHIFT_INPUTS;

-- Handle shifting of the MSBs separately
G_MUX_16_SHIFT_MSB: for i in 16 to 31 generate
    MUX_16_SHIFT: mux2t1
        port map(
            i_S => i_shamt(4),
            i_D0 => s_shift_8(i),
            i_D1 => i_sign,
            o_O => s_o_O(i)
        ); 
end generate G_MUX_16_SHIFT_MSB;

-- Reverse bits if left shift
G_REVERSE_OUTPUT_BITS: for i in 0 to 31 generate
    s_o_O_reverse(i) <= s_o_O(31 - i);
end generate G_REVERSE_OUTPUT_BITS;

-- MUX for selecting output based on leftShift signal
G_OUTPUT_MUX: mux2t1_N
    port map(
        i_S => i_leftShift,
        i_D0 => s_o_O,
        i_D1 => s_o_O_reverse,
        o_O => o_O
    );

end structural;
