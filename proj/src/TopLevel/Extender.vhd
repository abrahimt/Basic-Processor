
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY Extender IS
  PORT (
    i_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    i_S : IN STD_LOGIC;
    o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

END Extender;
ARCHITECTURE behavior OF Extender IS
BEGIN
  PROCESS (i_data, i_S)
  BEGIN
    FOR i IN 0 TO 15 LOOP
      o_out(i) <= i_data(i);
    END LOOP;
    FOR i IN 16 TO 31 LOOP
      o_out(i) <= (i_data(15) AND i_S);
    END LOOP;
  END PROCESS;
END behavior;