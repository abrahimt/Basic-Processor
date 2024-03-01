-- Control.vhd

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity Control is
   port(i_instruction		: in std_logic_vector(5 downto 0); 	-- Opcode of Instruction [31-26]
	o_RegDst		: out std_logic;			-- Selects Rd or Rt register as destination
	o_Jump			: out std_logic;			-- 1 for jumping, 0 for no jump
	o_Branch		: out std_logic;			-- 1 for branch, 0 for no branch
	o_MemRead		: out std_logic;			-- 1 if reading memory, 0 otherwise
	o_MemtoReg		: out std_logic;			-- 1 if memory to register, 0 otherwise
	o_ALUControl		: out std_logic_vector(5 downto 0);	-- Input to ALUControl, 1 for R type, 0 otherwise
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
  with i_instruction select
	o_ALUOp    	<= 	'1' when "000000",	-- R type
		      		'0' when others;	-- I or J type
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