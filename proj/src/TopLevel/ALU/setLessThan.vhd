--Abrahim Toutoungi
--3/17/2024
--setLessThan.vhd
--To be used by the ALU for slt and slti operations

library IEEE;
use IEEE.std_logic_1164.all;

use IEEE.numeric_std.all;


entity setLessThan is 
 port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end setLessThan;


architecture dataflow of setLessThan is 
signal s_A   : signed(31 downto 0);
signal s_B   : signed(31 downto 0); 

begin 
   s_A  <= signed(i_A);
   s_B  <= signed(i_B);


   o_F <= x"00000001" when (s_A < s_B) else 
       x"00000000";


end dataflow;