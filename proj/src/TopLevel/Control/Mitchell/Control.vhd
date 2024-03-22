-- Control.vhd

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity Control is
   port(i_instruction		: in std_logic_vector(5 downto 0); 	-- Opcode of Instruction [31-26]
	i_function		: in std_logic_vector(5 downto 0); 	-- Function of Instruction [5-0]
	o_RegDst		: out std_logic;			-- Selects Rd or Rt register as destination
	o_Jump			: out std_logic;			-- 1 for jumping, 0 for no jump
	o_Branch		: out std_logic;			-- 1 for branch, 0 for no branch
	o_MemRead		: out std_logic;			-- 1 if reading memory, 0 otherwise
	o_MemtoReg		: out std_logic;			-- 1 if memory to register, 0 otherwise
	o_ALUControl		: out std_logic_vector(3 downto 0);	-- 
	o_MemWrite		: out std_logic;			-- 1 if writing to memory, 0 otherwise
	o_ALUSrc		: out std_logic;			-- 1 if Immediate value is being selected, 0 for B register
	o_RegWrite		: out std_logic);			-- 1 if writing to register, 0 otherwise
end Control;

architecture structural of Control is


  begin

  ---------------------------------------------------------------------------
  -- Level 1: 
  ---------------------------------------------------------------------------

  with i_instruction select
	o_ALUSrc   	<= 	'0' when "000000",	-- B register
		      		'1' when others;	-- immediate

  with i_function select
	o_ALUControl 	 <= 	"0001" when "100101",	-- or
				"1000" when "100100",	-- and
				"0011" when "100110",	-- xor
				"0101" when "100111",	-- nor
				"0111" when "101010",	-- slt
				"0010" when "100000",	-- add
				"0010" when "100001",	-- addu
				"0010" when "100010",	-- sub
				"0010" when "100011",	-- subu
				"0100" when "000000",	-- sll  (function is 000000 for non R-type)
				"0100" when "000010",	-- srl
				"0100" when "000011",	-- sra
				"0100" when "000100",	-- sllv
				"0100" when "000110",	-- srlv
				"0100" when "000111",	-- srav
		      		"0000" when others;

  with i_instruction select
	o_ALUControl 	<= 	"0010" when "001000",	-- addi
				"0010" when "001001",	-- addiu
				"1000" when "001100",	-- andi
				"0111" when "001010",	-- slti
				"0011" when "001110",	-- xori
				"0001" when "001101",	-- ori
		      		"0000" when others;

  with i_instruction select
	o_MemtoReg 	<= 	'1' when "100000",	-- lb
				'1' when "100001",	-- lh
				'1' when "100011",	-- lw
				'1' when "100100",	-- lbu
				'1' when "100101",	-- lhu
		      		'0' when others;	
  with i_instruction select
	o_MemWrite	<=	'1' when "101011",	-- sw
				'0' when others;	
  with i_instruction select
	o_RegWrite	<=	'0' when "000100",	-- beq
				'0' when "000101",	-- bne
				'0' when "100101",	-- sw
				'0' when "000010",	-- j
				'0' when "000011",	-- jal
				'1' when others;
  with i_instruction select
	o_RegDst	<=	'1' when "000000",	-- rd register
				'0' when others;	-- rt register
  with i_instruction select
	o_Jump		<=	'1' when "000010",	-- j
				'1' when "000011",	-- jal
				'1' when "000100",	-- beq
				'1' when "000101",	-- bne
				'0' when others;	
  with i_instruction select
	o_Branch	<=	'1' when "000100",	-- beq
				'1' when "000101",	-- bne
				'0' when others;	
  with i_instruction select
	o_MemRead	<= 	'1' when "101011",	-- sw
				'0' when others;	

end structural;