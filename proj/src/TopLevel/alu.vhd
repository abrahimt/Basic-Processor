-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- alu.vhd
-- Used to perform operations based on the particular instruction
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY alu IS
	PORT (
		i_RS, i_RT : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		i_Imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		i_ALUSrc : IN STD_LOGIC;
		i_bne : IN STD_LOGIC;
		i_beq : IN STD_LOGIC;
		i_shiftDir : IN STD_LOGIC;
		i_shiftType : IN STD_LOGIC;
		i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_addSub : IN STD_LOGIC;
		i_signed : IN STD_LOGIC;
		i_lui : IN STD_LOGIC;
		o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		o_overflow : OUT STD_LOGIC;
		o_zero : OUT STD_LOGIC);

END alu;

ARCHITECTURE structure OF alu IS

	COMPONENT nBitAddSub IS
		PORT (
			input_A, input_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			nAdd_Sub : IN STD_LOGIC;
			output_S : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			output_C : OUT STD_LOGIC;
			o_Overflow : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT nBitOr IS
		PORT (
			i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT nBitAnd IS
		PORT (
			i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT nBitNor IS
		PORT (
			i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT nBitXor IS
		PORT (
			i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT setLessThan IS
		PORT (
			i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT branchALU IS
		PORT (
			i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_beq : IN STD_LOGIC;
			i_bne : IN STD_LOGIC;
			o_zero : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT Barrel_Shifter IS
		PORT (
			i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_sign : STD_LOGIC;
			i_leftShift : STD_LOGIC;
			i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT mux2t1_N IS
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT mux2t1_5bit IS
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(4 DOWNTO 0));
	END COMPONENT;

	COMPONENT andg2 IS
		PORT (
			i_A : IN STD_LOGIC;
			i_B : IN STD_LOGIC;
			o_F : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT xorg2 IS
		PORT (
			i_A : IN STD_LOGIC;
			i_B : IN STD_LOGIC;
			o_F : OUT STD_LOGIC);
	END COMPONENT;

	--Driven by the ALUOp control signal, this module will decide what operation is output by ALU
	COMPONENT selectOperation IS
		PORT (
			i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			i_orResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_andResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_xorResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_norResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_sltResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_addSubResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_shiftResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	SIGNAL s_Operand : STD_LOGIC_VECTOR(31 DOWNTO 0); -- either RS or Immediate
	SIGNAL s_orResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_andResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_xorResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_norResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_addSubResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_addSubCarry : STD_LOGIC;
	SIGNAL s_sltResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_shiftResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_barrelShiftSign : STD_LOGIC;
	SIGNAL s_MSB : STD_LOGIC;
	SIGNAL s_overflowDetected : STD_LOGIC;
	SIGNAL s_constShamt : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10000";
	SIGNAL s_shamt : STD_LOGIC_VECTOR(4 DOWNTO 0);
BEGIN
	s_MSB <= s_addSubResult(31);
	PROCESS (i_RT, i_shiftType) --to determined the value of the sign port in the barrel shifter
	BEGIN

		IF i_RT(31) = '1' AND i_shiftType = '1' THEN --used to determine if which sign the barrel shifter will take on based on whether it is logical or arithmetic
			s_barrelShiftSign <= '1';
		ELSE
			s_barrelShiftSign <= '0';
		END IF;

	END PROCESS;

	G_MUX_IMM : mux2t1_N
	PORT MAP(
		i_S => i_ALUSrc,
		i_D0 => i_RT,
		i_D1 => i_Imm,
		o_O => s_Operand);

	G_MUX_LUI : mux2t1_5bit --determines if we shift by shamt (for shift instructions) or by constant 16 for lui instruction
	PORT MAP(
		i_S => i_lui,
		i_D0 => i_shamt,
		i_D1 => s_constShamt,
		o_O => s_shamt);

	G_OR : nBitOr
	PORT MAP(
		i_A => i_RS,
		i_B => s_Operand,
		o_F => s_orResult);

	G_AND : nBitAnd
	PORT MAP(
		i_A => i_RS,
		i_B => s_Operand,
		o_F => s_andResult);

	G_XOR : nBitXor
	PORT MAP(
		i_A => i_RS,
		i_B => s_Operand,
		o_F => s_xorResult);

	G_NOR : nBitNor
	PORT MAP(
		i_A => i_RS,
		i_B => s_Operand,
		o_F => s_norResult);

	G_SLT : setLessThan
	PORT MAP(
		i_A => i_RS,
		i_B => s_Operand,
		o_F => s_sltResult);

	G_ADDSUB : nBitAddSub
	PORT MAP(
		input_A => i_RS,
		input_B => s_Operand,
		nAdd_Sub => i_addSub,
		output_S => s_addSubResult,
		output_C => s_addSubCarry,
		o_Overflow => s_overflowDetected);

	G_OVERFLOWAND : andg2 --only care about overflow flag if and only if the operation is not unsigned
	PORT MAP(
		i_A => s_overflowDetected,
		i_B => i_signed,
		o_F => o_overflow);

	G_SHIFT : Barrel_Shifter
	PORT MAP(
		i_shamt => s_shamt,
		i_sign => s_barrelShiftSign,
		i_leftShift => i_shiftDir,
		i_D => s_Operand,
		o_O => s_shiftResult);

	G_BRANCH : branchALU
	PORT MAP(
		i_A => i_RS,
		i_B => s_Operand,
		i_bne => i_bne,
		i_beq => i_beq,
		o_zero => o_zero);

	G_SELECT : selectOperation
	PORT MAP(
		i_ALUOp => i_ALUOp,
		i_orResult => s_orResult,
		i_andResult => s_andResult,
		i_xorResult => s_xorResult,
		i_norResult => s_norResult,
		i_sltResult => s_sltResult,
		i_addSubResult => s_addSubResult,
		i_shiftResult => s_shiftResult,
		o_result => o_result);

END structure;