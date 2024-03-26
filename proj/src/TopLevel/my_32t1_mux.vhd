library IEEE;
use IEEE.std_logic_1164.all;
use work.MIPS_types.all;

entity my_32t1_mux is
	port(i_S         : in std_logic_vector(4 downto 0);
	     registers   : in reg;
	     mx_out      : out std_logic_vector(31 downto 0));
end my_32t1_mux;

architecture mux32t1 of my_32t1_mux is


begin

	mx_out    <= 	registers(0)  when (i_S = "00000") else
			registers(1)  when (i_S = "00001") else
			registers(2)  when (i_S = "00010") else
			registers(3)  when (i_S = "00011") else
			registers(4)  when (i_S = "00100") else
			registers(5)  when (i_S = "00101") else
			registers(6)  when (i_S = "00110") else
			registers(7)  when (i_S = "00111") else
			registers(8)  when (i_S = "01000") else
			registers(9)  when (i_S = "01001") else
			registers(10) when (i_S = "01010") else
			registers(11) when (i_S = "01011") else
			registers(12) when (i_S = "01100") else
			registers(13) when (i_S = "01101") else
			registers(14) when (i_S = "01110") else
			registers(15) when (i_S = "00111") else
			registers(16) when (i_S = "10000") else
			registers(17) when (i_S = "10001") else
			registers(18) when (i_S = "10010") else
			registers(19) when (i_S = "10011") else
			registers(20) when (i_S = "10100") else
			registers(21) when (i_S = "10101") else
			registers(22) when (i_S = "10110") else
			registers(23) when (i_S = "10111") else
			registers(24) when (i_S = "11000") else
			registers(25) when (i_S = "11001") else
			registers(26) when (i_S = "11010") else
			registers(27) when (i_S = "11011") else
			registers(28) when (i_S = "11100") else
			registers(29) when (i_S = "11101") else
			registers(30) when (i_S = "11110") else
			registers(31) when (i_S = "11111") else
			x"0000_0000";


end mux32t1;

