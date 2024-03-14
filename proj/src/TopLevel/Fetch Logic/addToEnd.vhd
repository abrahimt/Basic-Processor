------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 10/8/2023
------------------------------------------------------------
-- addToEnd.vhd
------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity addToEnd is 
   port(i_In	: in std_logic_vector(25 downto 0);
	o_Out	: out std_logic_vector(27 downto 0));
end addToEnd;

architecture behavioral of addToEnd is
begin 
   o_Out <= i_In & "00";
end behavioral;