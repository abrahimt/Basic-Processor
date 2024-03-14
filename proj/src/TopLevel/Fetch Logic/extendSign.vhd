------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
------------------------------------------------------------
-- extendSign.vhd
------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity extendSign is 
   port(i_sign : in std_logic_vector(15 downto 0);
        o_sign : out std_logic_vector(31 downto 0));
end extendSign;

architecture behavioral of extendSign is 
begin 
   o_sign <= "0000000000000000" & i_sign when i_sign(15) = '0' 
   else "1111111111111111" & i_sign;  -- Sign extends a 16-bit input to a 32-bit output based on the MSB.
end behavioral;
