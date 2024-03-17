--Abrahim Toutoungi
-- 3/17/2024
--nBitNor.vhd
--To be used by the ALU for nor operations

library IEEE;
use IEEE.std_logic_1164.all;

entity nBitNor is 
 port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end nBitNor;

architecture dataflow of nBitNor is 

begin
G_NBit_NOR: for i in 0 to 31 generate
  o_F(i) <= not(i_A(i) or i_B(i)); 
end generate G_NBit_NOR;

end dataflow;