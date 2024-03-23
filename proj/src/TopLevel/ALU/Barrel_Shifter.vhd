-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- Barrel_Shifter.vhd
-- Barrel Shifter module to perform left or right logical shifts on a 32-bit input vector.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY Barrel_Shifter IS
    PORT (
        i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Shift amount
        i_sign : IN STD_LOGIC; -- Shift direction control (left or right)
        i_leftShift : IN STD_LOGIC; -- Logical shift direction control
        i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input vector to be shifted
        o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output vector after shifting
    );
END Barrel_Shifter;

ARCHITECTURE structural OF Barrel_Shifter IS

    COMPONENT mux2t1 IS
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC;
            i_D1 : IN STD_LOGIC;
            o_O : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT mux2t1_N IS
        GENERIC (N : INTEGER := 32);
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC_VECTOR;
            i_D1 : IN STD_LOGIC_VECTOR;
            o_O : OUT STD_LOGIC_VECTOR
        );
    END COMPONENT;

    SIGNAL s_i_D : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000"; -- Input vector
    SIGNAL s_i_D_reverse : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000"; -- Reversed input vector
    SIGNAL s_shift_1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000"; -- Shifted by 1 bit
    SIGNAL s_shift_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000"; -- Shifted by 2 bits
    SIGNAL s_shift_4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000"; -- Shifted by 4 bits
    SIGNAL s_shift_8 : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000"; -- Shifted by 8 bits
    SIGNAL s_o_O : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000"; -- Output vector
    SIGNAL s_o_O_reverse : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000"; -- Reversed output vector

BEGIN

    -- Reverse bits if left shift
    G_REVERSE_INPUT_BITS : FOR i IN 0 TO 31 GENERATE
        s_i_D_reverse(i) <= i_D(31 - i);
    END GENERATE G_REVERSE_INPUT_BITS;

    -- MUX for selecting input based on leftShift signal
    G_INPUT_MUX : mux2t1_N
    PORT MAP(
        i_S => i_leftShift,
        i_D0 => i_D,
        i_D1 => s_i_D_reverse,
        o_O => s_i_D
    );

    -- First Level shift by 1 logic
    -- Shift inputs
    G_MUX_1_SHIFT : FOR i IN 0 TO 30 GENERATE
        MUXI : mux2t1
        PORT MAP(
            i_S => i_shamt(0),
            i_D0 => s_i_D(i),
            i_D1 => s_i_D(i + 1),
            o_O => s_shift_1(i)
        );
    END GENERATE G_MUX_1_SHIFT;

    -- Handle shifting of the MSB (Most Significant Bit) separately
    MUX_1_SHIFT_MSB : mux2t1
    PORT MAP(
        i_S => i_shamt(0),
        i_D0 => s_i_D(31),
        i_D1 => i_sign,
        o_O => s_shift_1(31)
    );

    -- First Level shift by 2 logic
    -- Shift inputs
    G_MUX_2_SHIFT_INPUTS : FOR i IN 0 TO 29 GENERATE
        MUXI : mux2t1
        PORT MAP(
            i_S => i_shamt(1),
            i_D0 => s_shift_1(i),
            i_D1 => s_shift_1(i + 2),
            o_O => s_shift_2(i)
        );
    END GENERATE G_MUX_2_SHIFT_INPUTS;

    -- Handle shifting of the MSBs separately
    G_MUX_2_SHIFT_MSB : FOR i IN 30 TO 31 GENERATE
        MUX_2_SHIFT : mux2t1
        PORT MAP(
            i_S => i_shamt(1),
            i_D0 => s_shift_1(i),
            i_D1 => i_sign,
            o_O => s_shift_2(i)
        );
    END GENERATE G_MUX_2_SHIFT_MSB;

    -- First Level shift by 4 logic
    -- Shift inputs
    G_MUX_4_SHIFT_INPUTS : FOR i IN 0 TO 27 GENERATE
        MUXI : mux2t1
        PORT MAP(
            i_S => i_shamt(2),
            i_D0 => s_shift_2(i),
            i_D1 => s_shift_2(i + 4),
            o_O => s_shift_4(i)
        );
    END GENERATE G_MUX_4_SHIFT_INPUTS;

    -- Handle shifting of the MSBs separately
    G_MUX_4_SHIFT_MSB : FOR i IN 28 TO 31 GENERATE
        MUX_4_SHIFT : mux2t1
        PORT MAP(
            i_S => i_shamt(2),
            i_D0 => s_shift_2(i),
            i_D1 => i_sign,
            o_O => s_shift_4(i)
        );
    END GENERATE G_MUX_4_SHIFT_MSB;

    -- First Level shift by 8 logic
    -- Shift inputs
    G_MUX_8_SHIFT_INPUTS : FOR i IN 0 TO 23 GENERATE
        MUXI : mux2t1
        PORT MAP(
            i_S => i_shamt(3),
            i_D0 => s_shift_4(i),
            i_D1 => s_shift_4(i + 8),
            o_O => s_shift_8(i)
        );
    END GENERATE G_MUX_8_SHIFT_INPUTS;

    -- Handle shifting of the MSBs separately
    G_MUX_8_SHIFT_MSB : FOR i IN 24 TO 31 GENERATE
        MUX_8_SHIFT : mux2t1
        PORT MAP(
            i_S => i_shamt(3),
            i_D0 => s_shift_4(i),
            i_D1 => i_sign,
            o_O => s_shift_8(i)
        );
    END GENERATE G_MUX_8_SHIFT_MSB;

    -- First Level shift by 16 logic
    -- Shift inputs
    G_MUX_16_SHIFT_INPUTS : FOR i IN 0 TO 15 GENERATE
        MUXI : mux2t1
        PORT MAP(
            i_S => i_shamt(4),
            i_D0 => s_shift_8(i),
            i_D1 => s_shift_8(i + 16),
            o_O => s_o_O(i)
        );
    END GENERATE G_MUX_16_SHIFT_INPUTS;

    -- Handle shifting of the MSBs separately
    G_MUX_16_SHIFT_MSB : FOR i IN 16 TO 31 GENERATE
        MUX_16_SHIFT : mux2t1
        PORT MAP(
            i_S => i_shamt(4),
            i_D0 => s_shift_8(i),
            i_D1 => i_sign,
            o_O => s_o_O(i)
        );
    END GENERATE G_MUX_16_SHIFT_MSB;

    -- Reverse bits if left shift
    G_REVERSE_OUTPUT_BITS : FOR i IN 0 TO 31 GENERATE
        s_o_O_reverse(i) <= s_o_O(31 - i);
    END GENERATE G_REVERSE_OUTPUT_BITS;

    -- MUX for selecting output based on leftShift signal
    G_OUTPUT_MUX : mux2t1_N
    PORT MAP(
        i_S => i_leftShift,
        i_D0 => s_o_O,
        i_D1 => s_o_O_reverse,
        o_O => o_O
    );

END structural;