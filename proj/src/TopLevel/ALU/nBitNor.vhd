-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitNor.vhd
-- Module to perform bitwise NOR operation on two 32-bit input vectors.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity nBitNor is 
  port (
    i_A : in std_logic_vector(31 downto 0);  -- Input vector A
    i_B : in std_logic_vector(31 downto 0);  -- Input vector B
    o_F : out std_logic_vector(31 downto 0)  -- Output vector after NOR operation
  );
end nBitNor;

architecture dataflow of nBitNor is 
begin
  -- Generate loop to perform bitwise NOR operation on each bit of the input vectors
  G_NBit_NOR: for i in 0 to 31 generate
    o_F(i) <= not (i_A(i) or i_B(i));  -- NOR operation on bits i of vectors A and B
  end generate G_NBit_NOR;
end dataflow;
