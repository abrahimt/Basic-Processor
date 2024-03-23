-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- onesComp.vhd
-- Module to perform one's complement operation on an input vector.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY onesComp IS
  GENERIC (
    N : INTEGER := 32 -- Generic parameter specifying the input/output data width, default is 32 bits
  );
  PORT (
    i_Num : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Input vector for one's complement operation
    o_Num : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0) -- Output vector after one's complement operation
  );
END onesComp;

ARCHITECTURE structure OF onesComp IS

  -- Component declaration for inverter
  COMPONENT invg
    PORT (
      i_A : IN STD_LOGIC;
      o_F : OUT STD_LOGIC
    );
  END COMPONENT;

BEGIN
  -- Generate loop to perform one's complement operation on each bit of the input vector
  G_NBit_OnesComp : FOR i IN 0 TO N - 1 GENERATE

    g_inv : invg
    PORT MAP(
      i_A => i_Num(i),
      o_F => o_Num(i)
    );

  END GENERATE G_NBit_OnesComp;

END structure;