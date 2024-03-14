------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 10/8/2023
------------------------------------------------------------
-- shift.vhd
------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift is 
   port(i_In	: in std_logic_vector(31 downto 0);
	o_Out	: out std_logic_vector(31 downto 0));
end shift; 

architecture behavioral of shift is 
begin 
   o_Out <= std_logic_vector(shift_left(unsigned(i_In), 2));
end behavioral;
