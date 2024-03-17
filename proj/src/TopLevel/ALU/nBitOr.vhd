--Benjamin Towle
--9/30/2023
--nBitOr.vhd
--To be used by the ALU for or and ori operations

library IEEE;
use IEEE.std_logic_1164.all;

entity nBitOr is 
 port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end nBitOr;

architecture structure of nBitOr is 

component org2 is 
   port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

begin 
G_NBit_OR: for i in 0 to 31 generate

NBitOR: org2
port map(i_A  => i_A(i),
	 i_B  => i_B(i),
	 o_F  => o_F(i));

end generate G_NBit_OR;

end structure;
