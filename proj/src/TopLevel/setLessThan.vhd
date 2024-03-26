-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- setLessThan.vhd
-- Module for comparing two signed 32-bit numbers and setting o_F accordingly.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

USE IEEE.numeric_std.ALL; -- Required for using signed data type

ENTITY setLessThan IS
    PORT (
        i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input signal for operand A
        i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input signal for operand B
        o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output signal for the comparison result
    );
END setLessThan;

ARCHITECTURE dataflow OF setLessThan IS
    SIGNAL s_A : signed(31 DOWNTO 0); -- Internal signal for operand A (signed)
    SIGNAL s_B : signed(31 DOWNTO 0); -- Internal signal for operand B (signed)
BEGIN
    s_A <= signed(i_A); -- Convert i_A to signed and assign to s_A
    s_B <= signed(i_B); -- Convert i_B to signed and assign to s_B

    -- Compare s_A and s_B, if s_A < s_B then set o_F to x"00000001", else set o_F to x"00000000"
    o_F <= x"00000001" WHEN (s_A < s_B) ELSE
        x"00000000";
END dataflow;