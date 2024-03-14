------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
------------------------------------------------------------
-- addToEnd.vhd
------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity addToEnd is 
   port(i_In   : in std_logic_vector(25 downto 0);
        o_Out  : out std_logic_vector(27 downto 0));
end addToEnd;

architecture behavioral of addToEnd is
begin 
   o_Out <= i_In & "00";  -- Concatenates two 26-bit vectors to form a 28-bit vector with two additional zeros at the end.
end behavioral;
