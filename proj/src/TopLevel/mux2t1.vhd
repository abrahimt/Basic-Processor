-- DESCRIPTION: This file contains an implementation of a 2:1 multiplexer

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux2t1 IS

	PORT (
		i_S : IN STD_LOGIC;
		i_D0 : IN STD_LOGIC;
		i_D1 : IN STD_LOGIC;
		o_O : OUT STD_LOGIC);
END mux2t1;

ARCHITECTURE structural OF mux2t1 IS

	COMPONENT andg2
		PORT (
			i_A : IN STD_LOGIC;
			i_B : IN STD_LOGIC;
			o_F : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT invg
		PORT (
			i_A : IN STD_LOGIC;
			o_F : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT org2
		PORT (
			i_A : IN STD_LOGIC;
			i_B : IN STD_LOGIC;
			o_F : OUT STD_LOGIC
		);
	END COMPONENT;
	SIGNAL s_and1 : STD_LOGIC;
	SIGNAL s_and2 : STD_LOGIC;
	SIGNAL s_not : STD_LOGIC;

BEGIN

	g_Not : invg
	PORT MAP(
		i_A => i_S,
		o_F => s_not);

	g_And1 : andg2
	PORT MAP(
		i_A => i_D1,
		i_B => i_S,
		o_F => s_and1);

	g_And2 : andg2
	PORT MAP(
		i_A => i_D0,
		i_B => s_not,
		o_F => s_and2);

	g_or : org2
	PORT MAP(
		i_A => s_and1,
		i_B => s_and2,
		o_F => o_O);

END structural;