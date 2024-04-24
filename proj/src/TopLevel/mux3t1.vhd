LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;
USE work.MIPS_types.ALL;

ENTITY mux3t1 IS
    PORT (
        i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_select : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END mux3t1;
ARCHITECTURE structure OF mux3t1 IS

BEGIN

    o_O <= i_A WHEN (i_select = "00") ELSE
        i_B WHEN (i_select = "01") ELSE
        i_C WHEN (i_select = "10") ELSE
        x"00000000";

END structure;