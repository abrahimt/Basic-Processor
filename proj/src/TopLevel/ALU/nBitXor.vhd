--Benjamin Towle
--9/30/2023
--nBitXor.vhd
--To be used by the ALU for xor & xori operations

library IEEE;
use IEEE.std_logic_1164.all;

entity nBitXor is 
 port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end nBitXor;

architecture structure of nBitXor is 

component xorg2 is 
   port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

begin 
G_NBit_XOR: for i in 0 to 31 generate

NBitXor: xorg2
port map(i_A  => i_A(i),
	 i_B  => i_B(i),
	 o_F  => o_F(i));

end generate G_NBit_XOR;

end structure;