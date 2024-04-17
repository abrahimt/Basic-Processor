LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;
USE work.MIPS_types.ALL;

ENTITY mux3t1 IS 
    port(
        i_A : in std_logic_vector(31 downto 0);
        i_B : in std_logic_vector(31 downto 0);
        i_C : in std_logic_vector(31 downto 0);
        i_select : in std_logic_vector(1 downto 0);
        o_O : out std_logic_vector(31 downto 0)
    );
END mux3t1;


ARCHITECTURE structure OF mux3t1 IS

begin

    o_O <= i_A when (i_select == '00') else
           i_B when (i_select == '01') else
           i_C when (i_select == '10') else
           x"00000000";

end structure;