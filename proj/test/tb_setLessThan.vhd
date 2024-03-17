--Benjamin Towle
--9/30/2023
--tb_setLessThan.vhd
--Test bench for the setLessThan.vhd module

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.textio.all;             -- For basic I/O

entity tb_setLessThan is 
end tb_setLessThan;

architecture structure of tb_setLessThan is 


component setLessThan is 
port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end component;

signal s_A  : std_logic_vector(31 downto 0);
signal s_B  : std_logic_vector(31 downto 0);
signal s_F  : std_logic_vector(31 downto 0);

begin
DUT0: setLessThan

port map(i_A => s_A,
	 i_B => s_B,
	 o_F => s_F);

TEST_CASES: process
begin 

s_A <= x"7FFFFFFF";
s_B <= x"00000000";
wait for 50 ns;

s_A <= x"00000000";
s_B <= x"7FFFFFFF";
wait for 50 ns;

s_A <= x"00000001";
s_B <= x"00000004";
wait for 50 ns;

s_A <= x"00000005";
s_B <= x"00000002";
wait for 50 ns;

end process;


end structure;