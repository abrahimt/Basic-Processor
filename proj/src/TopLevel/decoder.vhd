

library IEEE;
use IEEE.std_logic_1164.all;

entity decoder is
	port(SEL   : in std_logic_vector(4 downto 0);
	     F_OUT : out std_logic_vector(31 downto 0));
end decoder;

architecture decode of decoder is

begin

with SEL select
	F_OUT <= x"0000_0001" when "00000",
		 x"0000_0002" when "00001",
		 x"0000_0004" when "00010",
		 x"0000_0008" when "00011",
		 x"0000_0010" when "00100",
		 x"0000_0020" when "00101",
		 x"0000_0040" when "00110",
		 x"0000_0080" when "00111",
		 x"0000_0100" when "01000",
		 x"0000_0200" when "01001",
		 x"0000_0400" when "01010",
		 x"0000_0800" when "01011",
		 x"0000_1000" when "01100",
		 x"0000_2000" when "01101",
		 x"0000_4000" when "01110",
		 x"0000_8000" when "01111",
		 x"0001_0000" when "10000",
		 x"0002_0000" when "10001",
		 x"0004_0000" when "10010",
		 x"0008_0000" when "10011",
		 x"0010_0000" when "10100",
		 x"0020_0000" when "10101",
		 x"0040_0000" when "10110",
		 x"0080_0000" when "10111",
		 x"0100_0000" when "11000",
		 x"0200_0000" when "11001",
		 x"0400_0000" when "11010",
		 x"0800_0000" when "11011",
		 x"1000_0000" when "11100",
		 x"2000_0000" when "11101",
		 x"4000_0000" when "11110",
		 x"8000_0000" when "11111",
		 x"0000_0000" when others;

end decode;

