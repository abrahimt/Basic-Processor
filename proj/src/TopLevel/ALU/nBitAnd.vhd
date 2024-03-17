--Abrahim Toutoungi
--3/17/2024
--nBitAnd.vhd
--To be used by the ALU for and & andi operations

library IEEE;
use IEEE.std_logic_1164.all;

entity nBitAnd is 
 port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end nBitAnd;

architecture structure of nBitAnd is 

component andg2 is 
   port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

begin 
G_NBit_AND: for i in 0 to 31 generate

NBitAnd: andg2
port map(i_A  => i_A(i),
	 i_B  => i_B(i),
	 o_F  => o_F(i));

end generate G_NBit_AND;

end structure;