-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY prediction IS
    PORT (
        i_branch : IN STD_LOGIC; -- if the branch is true or not
        o_Out : OUT STD_LOGIC); -- whether we predict true or false
END prediction;

ARCHITECTURE structure OF alu IS
    SIGNAL s_location : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11"; -- 2 bits to determine whether we predict true or false (starts at true)

BEGIN

    o_Out <= '1' WHEN (s_location = "11") ELSE
        '1' WHEN (s_location = "10") ELSE
        '0' WHEN (s_location = "01") ELSE
        '0' WHEN (s_location = "00") ELSE
        '0';

    s_location <= "10" WHEN (i_branch = '0' AND s_location = "11") ELSE
        "01" WHEN (i_branch = '0' AND s_location = "10") ELSE
        "00" WHEN (i_branch = '0' AND s_location = "01") ELSE
        "00" WHEN (i_branch = '0' AND s_location = "00") ELSE
        "11" WHEN (i_branch = '1' AND s_location = "11") ELSE
        "11" WHEN (i_branch = '1' AND s_location = "10") ELSE
        "10" WHEN (i_branch = '1' AND s_location = "01") ELSE
        "01" WHEN (i_branch = '1' AND s_location = "00") ELSE
        "00";

END structure;