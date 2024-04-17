-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY prediction IS
	PORT (
		i_branch : IN STD_LOGIC;    -- if the branch is true or not
		o_out    : OUT STD_LOGIC);  -- whether we predict true or false
END prediction;


ARCHITECTURE structure OF alu IS

	
	SIGNAL s_location : STD_LOGIC_VECTOR(1 DOWNTO 0) := '11';  -- 2 bits to determine whether we predict true or false (starts at true)

BEGIN

    o_out <= '1' when (s_location = '11') else
             '1' when (s_location = '10') else
             '0' when (s_location = '01') else
             '0' when (s_location = '00') else
             '0';

    s_location <= '10' when (i_branch = '0' and s_location = '11') else
                  '01' when (i_branch = '0' and s_location = '10') else
                  '00' when (i_branch = '0' and s_location = '01') else
                  '00' when (i_branch = '0' and s_location = '00') else
                  '11' when (i_branch = '1' and s_location = '11') else
                  '11' when (i_branch = '1' and s_location = '10') else
                  '10' when (i_branch = '1' and s_location = '01') else
                  '01' when (i_branch = '1' and s_location = '00') else
                  '00';

END structure;
