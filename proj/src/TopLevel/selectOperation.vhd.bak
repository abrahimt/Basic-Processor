-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- selectOperation.vhd
-- Module to select the ALU operation based on the ALUOp control signal.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY selectOperation IS
	PORT (
		i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input port for ALU operation code
		i_orResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for OR operation result
		i_andResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for AND operation result
		i_xorResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for XOR operation result
		i_norResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for NOR operation result
		i_sltResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for SLT operation result
		i_addSubResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for ADD/SUB operation result
		i_shiftResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for shift operation result
		o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port for ALU result
	);
END selectOperation;

ARCHITECTURE dataflow OF selectOperation IS
BEGIN
	-- Selecting the ALU operation based on the ALUOp control signal
	o_result <= i_orResult WHEN (i_ALUOp = "0111") ELSE
		i_andResult WHEN (i_ALUOp = "0011") ELSE
		i_xorResult WHEN (i_ALUOp = "0110") ELSE
		i_norResult WHEN (i_ALUOp = "0101") ELSE
		i_sltResult WHEN (i_ALUOp = "1000") ELSE
		i_addSubResult WHEN (i_ALUOp = "0010") ELSE
		--	            i_subResult      when (i_ALUOp = "0110") else 
		i_shiftResult WHEN (i_ALUOp = "1001") ELSE
		x"00000000"; -- Default output when ALUOp is not recognized
END dataflow;