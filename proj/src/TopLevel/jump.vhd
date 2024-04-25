------------------------------------------------------------
-- Mitchell Driscoll
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
------------------------------------------------------------
-- jump.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY jump IS
	PORT (
		i_CLK : IN STD_LOGIC; -- Clock input
		i_rst : IN STD_LOGIC; -- Reset input
		i_jr : IN STD_LOGIC; -- Jump Register input
		i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- RS Register data
		i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- PC + 4 [31 - 28]
		i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Jump Instruction Input
		o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Jump Address Output
END jump;

ARCHITECTURE structural OF jump IS

	COMPONENT nBitAdder IS
		GENERIC (N : INTEGER := 32); -- use generics for a multiple bit input/output
		PORT (
			in_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			in_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			in_C : IN STD_LOGIC;
			out_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			out_C : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT shift IS
		PORT (
			i_In : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT Barrel_Shifter IS
		PORT (
			i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Shift amount
			i_sign : IN STD_LOGIC; -- Shift direction control (left or right)
			i_leftShift : IN STD_LOGIC; -- Logical shift direction control
			i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input vector to be shifted
			o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Output vector after shifting
	END COMPONENT;

	COMPONENT mux2t1_N IS
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;
	SIGNAL LS_jump_addr : STD_LOGIC_VECTOR(31 DOWNTO 0); -- i_Data [25-0]
	SIGNAL RS_jump_addr : STD_LOGIC_VECTOR(31 DOWNTO 0); -- i_Data [25-0]
	SIGNAL PC_4 : STD_LOGIC_VECTOR(31 DOWNTO 0); -- i_PC + 4
	SIGNAL RS_PC_4 : STD_LOGIC_VECTOR(31 DOWNTO 0); -- right shifted PC + 4
	SIGNAL LS_PC_4 : STD_LOGIC_VECTOR(31 DOWNTO 0); -- left shifted PC + 4
	SIGNAL carry1 : STD_LOGIC := '0'; -- signal for carry of adder
	SIGNAL carry2 : STD_LOGIC := '0'; -- signal for carry of adder
	SIGNAL s_j : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

	G_LEFT_SHIFT : Barrel_Shifter
	PORT MAP(
		i_shamt => "00110", -- shift by 6
		i_sign => '0', -- shift left
		i_leftShift => '1', -- logical shift
		i_D => i_Data, -- Jump Instrcution
		o_O => LS_jump_addr); -- Shifted Jump Address

	G_RIGHT_SHIFT : Barrel_Shifter
	PORT MAP(
		i_shamt => "00100", -- shift by 4
		i_sign => '0', -- shift right
		i_leftShift => '0', -- logical shift
		i_D => LS_jump_addr, -- Shifted Jump Address
		o_O => RS_jump_addr); -- Final Shifted Jump Address

	G_ADD : nBitAdder
	PORT MAP(
		in_A => i_PC, -- PC Address
		in_B => x"00000004", -- Four
		in_C => carry1, -- Carry Bit
		out_S => PC_4, -- PC Address Plus 4
		out_C => carry1); -- Carry Bit Output

	G_RIGHT_SHIFT_PC : Barrel_Shifter
	PORT MAP(
		i_shamt => "11100", -- shift by 28
		i_sign => '0', -- shift right
		i_leftShift => '0', -- logical shift
		i_D => PC_4, -- PC Address
		o_O => RS_PC_4); -- Shifted PC Address

	G_LEFT_SHIFT_PC : Barrel_Shifter
	PORT MAP(
		i_shamt => "11100", -- shift by 28
		i_sign => '0', -- shift left
		i_leftShift => '1', -- logical shift
		i_D => RS_PC_4, -- Jump Instrcution
		o_O => LS_PC_4); -- Shifted PC Address

	G_ADD2 : nBitAdder
	PORT MAP(
		in_A => RS_jump_addr,
		in_B => LS_PC_4,
		in_C => carry2,
		out_S => s_j,
		out_C => carry2);

	G_MUX : mux2t1_N
	PORT MAP(
		i_S => i_jr,
		i_D0 => s_j,
		i_D1 => i_rs,
		o_O => o_Q);
END structural;