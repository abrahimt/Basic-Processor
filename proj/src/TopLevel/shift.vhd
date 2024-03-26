------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2023
------------------------------------------------------------
-- shift.vhd
------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift is 
   port(i_In  : in std_logic_vector(31 downto 0); -- Input data
        o_Out : out std_logic_vector(31 downto 0)); -- Output data
end shift; 

architecture behavioral of shift is 
begin 
   -- Performs a logical left shift by 2 bits on the input data
   o_Out <= std_logic_vector(shift_left(unsigned(i_In), 2));
end behavioral;
