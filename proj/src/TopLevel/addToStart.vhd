------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
------------------------------------------------------------
-- addToStart.vhd
------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity addToStart is
   port(i_jBits : in std_logic_vector(27 downto 0);
        i_PCb   : in std_logic_vector(3 downto 0);
        o_Out   : out std_logic_vector(31 downto 0));
end addToStart;

architecture behavioral of addToStart is 
begin
   o_Out <= i_PCb & i_jBits;  -- Concatenates a 4-bit vector with a 28-bit vector to form a 32-bit vector.
end behavioral;
