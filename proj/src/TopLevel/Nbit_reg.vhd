-- Nbit_reg.vhd

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.MIPS_types.ALL;

ENTITY Nbit_reg IS
  GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
  PORT (
    i_CLK : IN STD_LOGIC; -- Clock input
    i_RST : IN STD_LOGIC; -- Reset input
    i_WE : IN STD_LOGIC; -- Write enable input
    i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- 32 bit input
    o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- 32 bit output
END Nbit_reg;
ARCHITECTURE structural OF Nbit_reg IS

  COMPONENT dffg IS
    PORT (
      i_CLK : IN STD_LOGIC; -- Clock input
      i_RST : IN STD_LOGIC; -- Reset input
      i_WE : IN STD_LOGIC; -- Write enable input
      i_D : IN STD_LOGIC; -- Data value input
      o_Q : OUT STD_LOGIC); -- Data value output
  END COMPONENT;

BEGIN

  -- Instantiate N mux instances.
  G_NBit_Reg : FOR i IN 0 TO N - 1 GENERATE
    REG : dffg
    PORT MAP(
      i_CLK => i_CLK, -- Clock input
      i_RST => i_RST, -- Reset input
      i_WE => i_WE, -- Write enable input
      i_D => i_D(i), -- All instances share the same input.
      o_Q => o_Q(i)); -- ith instance's data output hooked up to ith data output.
  END GENERATE G_NBit_Reg;

END structural;