-- DESCRIPTION: This file contains an implementation of a 2:1 multiplexer

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is

	port(
		i_S	: in std_logic;
		i_D0	: in std_logic;
		i_D1	: in std_logic;
		o_O	: out std_logic);
end mux2t1;

architecture structural of mux2t1 is

	component andg2
		port(
			i_A	: in std_logic;
			i_B	: in std_logic;
			o_F	: out std_logic
		    );
	end component;


	component invg
		port (
			i_A	: in std_logic;
			o_F	: out std_logic
		     );
	end component;

	component org2
		port (
			i_A	: in std_logic;
			i_B	: in std_logic;
			o_F	: out std_logic
		     );
	end component;

	
	signal s_and1	: std_logic;
	signal s_and2	: std_logic;
	signal s_not	: std_logic;

begin

	g_Not: invg
		port MAP(i_A => i_S,
			o_F => s_not);

	g_And1: andg2
		port MAP(i_A => i_D1,
			i_B => i_S,
			o_F => s_and1);

	g_And2: andg2
		port MAP(i_A => i_D0,
			i_B => s_not,
			o_F => s_and2);

	g_or: org2
		port MAP(i_A => s_and1,
			i_B => s_and2,
			o_F => o_O);

end structural;

