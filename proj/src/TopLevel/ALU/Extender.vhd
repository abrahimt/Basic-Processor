
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Extender is
  port(i_data       : in std_logic_vector(15 downto 0);
       o_out        : out std_logic_vector(31 downto 0));
end Extender;

architecture structural of Extender is

  -- Signal to carry 15th bit
  signal i_D1       : std_logic;
  -- Signal to carry vector for sign
  signal i_sign     : std_logic_vector(15 downto 0);
  -- Signal to carry vextor zero
  signal i_zero     : std_logic_vector(15 downto 0);



begin

  i_D1   <= i_data(15);

  i_sign <= x"FFFF" when (i_D1 = '1') else
	    x"0000";

  i_zero <= x"0000" when (i_D1 = '1') else
            x"0000";

  o_out  <= i_zero & i_data when (i_D1 = '0') else
	    i_sign & i_data;
  
  
end structural;