-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
-------------------------------------------------------------------------
-- control.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: --Control logic module
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY control IS
	PORT (
		i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --MIPS instruction
		o_RegDst : OUT STD_LOGIC;
		o_RegWrite : OUT STD_LOGIC;
		o_memToReg : OUT STD_LOGIC;
		o_memWrite : OUT STD_LOGIC;
		o_ALUSrc : OUT STD_LOGIC;
		o_ALUOp : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		o_signed : OUT STD_LOGIC;
		o_addSub : OUT STD_LOGIC;
		o_shiftType : OUT STD_LOGIC;
		o_shiftDir : OUT STD_LOGIC;
		o_bne : OUT STD_LOGIC;
		o_beq : OUT STD_LOGIC;
		o_j : OUT STD_LOGIC;
		o_jr : OUT STD_LOGIC;
		o_jal : OUT STD_LOGIC;
		o_branch : OUT STD_LOGIC;
		o_jump : OUT STD_LOGIC;
		o_lui : OUT STD_LOGIC;
		o_halt : OUT STD_LOGIC;
		o_ctlExt : OUT STD_LOGIC);
END control;

ARCHITECTURE behavioral OF control IS

	SIGNAL s_opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL s_funct : STD_LOGIC_VECTOR(5 DOWNTO 0);
BEGIN

	s_opcode <= i_inst(31 DOWNTO 26);
	s_funct <= i_inst(5 DOWNTO 0);
	PROCESS (s_opcode, s_funct)
	BEGIN
		IF s_opcode = "000000" THEN --Case for R-Type instruction
			IF s_funct = "100000" THEN --add instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0010";
				o_signed <= '1';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "100001" THEN --addu instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0010";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "100100" THEN --and instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0011";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "100111" THEN --nor instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0101";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "100110" THEN --xor instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0110";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "100101" THEN --or instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0111";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "101010" THEN --slt instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "1000";
				o_signed <= '1';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "000000" THEN --sll instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "1001";
				o_signed <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '1';
				o_addSub <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "000010" THEN --srl instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "1001";
				o_signed <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_addSub <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "000011" THEN --sra instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "1001";
				o_signed <= '0';
				o_shiftType <= '1';
				o_shiftDir <= '0';
				o_addSub <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "100010" THEN --sub instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0010";
				o_signed <= '1';
				o_addSub <= '1';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "100011" THEN --subu instruction
				o_RegDst <= '1';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0010";
				o_signed <= '0';
				o_addSub <= '1';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_funct = "001000" THEN --jr instruction
				o_RegDst <= '0';
				o_RegWrite <= '0';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "1011";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jal <= '0';
				o_jr <= '1';
				o_jump <= '1';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSE
				o_RegDst <= '0';
				o_RegWrite <= '0';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0000";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jal <= '0';
				o_jr <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			END IF;
		ELSE --I and J type instructions
			IF s_opcode = "001000" THEN --addi instruction
				o_RegDst <= '0';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '1';
				o_ALUOp <= "0010";
				o_signed <= '1';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '1';
			ELSIF s_opcode = "001001" THEN --addiu instruction
				o_RegDst <= '0';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '1';
				o_ALUOp <= "0010";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '1';
			ELSIF s_opcode = "001100" THEN --andi instruction
				o_RegDst <= '0';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '1';
				o_ALUOp <= "0011";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_opcode = "001111" THEN --lui instruction
				o_RegDst <= '0';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '1';
				o_ALUOp <= "1001";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '1';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '1';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_opcode = "100011" THEN --lw instruction
				o_RegDst <= '0';
				o_RegWrite <= '1';
				o_memToReg <= '1';
				o_memWrite <= '0';
				o_ALUSrc <= '1';
				o_ALUOp <= "0010";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '1';
			ELSIF s_opcode = "001110" THEN --xori instruction
				o_RegDst <= '0';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '1';
				o_ALUOp <= "0110";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_opcode = "001101" THEN --ori instruction
				o_RegDst <= '0';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '1';
				o_ALUOp <= "0111";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_opcode = "001010" THEN --slti instruction
				o_RegDst <= '0';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '1';
				o_ALUOp <= "1000";
				o_signed <= '1';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '1';
			ELSIF s_opcode = "101011" THEN --sw instruction
				o_RegDst <= '0';
				o_RegWrite <= '0';
				o_memToReg <= '0';
				o_memWrite <= '1';
				o_ALUSrc <= '1';
				o_ALUOp <= "0010";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '1';
			ELSIF s_opcode = "000100" THEN --beq instruction
				o_RegDst <= '0';
				o_RegWrite <= '0';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0000";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '1';
				o_branch <= '1';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_opcode = "000101" THEN --bne instruction
				o_RegDst <= '0';
				o_RegWrite <= '0';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0000";
				o_signed <= '0';
				o_bne <= '1';
				o_beq <= '0';
				o_branch <= '1';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_opcode = "000010" THEN --j instruction
				o_RegDst <= '0';
				o_RegWrite <= '0';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "1011";
				o_signed <= '0';
				o_j <= '1';
				o_jal <= '0';
				o_jr <= '0';
				o_jump <= '1';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_opcode = "000011" THEN --jal instruction
				o_RegDst <= '0';
				o_RegWrite <= '1';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "1011";
				o_signed <= '0';
				o_j <= '0';
				o_jal <= '1';
				o_jr <= '0';
				o_jump <= '1';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			ELSIF s_opcode = "010100" THEN --halt instruction 
				o_RegDst <= '0';
				o_RegWrite <= '0';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0000";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '1';
				o_ctlExt <= '0';
			ELSE
				o_RegDst <= '0';
				o_RegWrite <= '0';
				o_memToReg <= '0';
				o_memWrite <= '0';
				o_ALUSrc <= '0';
				o_ALUOp <= "0000";
				o_signed <= '0';
				o_addSub <= '0';
				o_shiftType <= '0';
				o_shiftDir <= '0';
				o_bne <= '0';
				o_beq <= '0';
				o_branch <= '0';
				o_j <= '0';
				o_jr <= '0';
				o_jal <= '0';
				o_jump <= '0';
				o_lui <= '0';
				o_halt <= '0';
				o_ctlExt <= '0';
			END IF;
		END IF;

	END PROCESS;

END behavioral;