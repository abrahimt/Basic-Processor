-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitNor.vhd
-- Module to perform bitwise NOR operation on two 32-bit input vectors.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY nBitNor IS
  PORT (
    i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input vector A
    i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input vector B
    o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output vector after NOR operation
  );
END nBitNor;

ARCHITECTURE dataflow OF nBitNor IS
BEGIN
  -- Generate loop to perform bitwise NOR operation on each bit of the input vectors
  G_NBit_NOR : FOR i IN 0 TO 31 GENERATE
    o_F(i) <= NOT (i_A(i) OR i_B(i)); -- NOR operation on bits i of vectors A and B
  END GENERATE G_NBit_NOR;
END dataflow;