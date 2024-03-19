-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- setLessThan.vhd
-- Module for comparing two signed 32-bit numbers and setting o_F accordingly.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use IEEE.numeric_std.all; -- Required for using signed data type

entity setLessThan is 
    port(
        i_A : in std_logic_vector(31 downto 0);  -- Input signal for operand A
        i_B : in std_logic_vector(31 downto 0);  -- Input signal for operand B
        o_F : out std_logic_vector(31 downto 0)  -- Output signal for the comparison result
    );
end setLessThan;

architecture dataflow of setLessThan is 
    signal s_A : signed(31 downto 0); -- Internal signal for operand A (signed)
    signal s_B : signed(31 downto 0); -- Internal signal for operand B (signed)
begin 
    s_A <= signed(i_A); -- Convert i_A to signed and assign to s_A
    s_B <= signed(i_B); -- Convert i_B to signed and assign to s_B

    -- Compare s_A and s_B, if s_A < s_B then set o_F to x"00000001", else set o_F to x"00000000"
    o_F <= x"00000001" when (s_A < s_B) else x"00000000";
end dataflow;
