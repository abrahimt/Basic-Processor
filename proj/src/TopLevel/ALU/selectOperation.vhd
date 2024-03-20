-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- selectOperation.vhd
-- Module to select the ALU operation based on the ALUOp control signal.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity selectOperation is 
    port(
        i_ALUOp       : in std_logic_vector(3 downto 0); -- Input port for ALU operation code
	    i_orResult    : in std_logic_vector(31 downto 0); -- Input port for OR operation result
	    i_andResult   : in std_logic_vector(31 downto 0); -- Input port for AND operation result
 	    i_xorResult   : in std_logic_vector(31 downto 0); -- Input port for XOR operation result
 	    i_norResult   : in std_logic_vector(31 downto 0); -- Input port for NOR operation result
 	    i_sltResult   : in std_logic_vector(31 downto 0); -- Input port for SLT operation result
 	    i_addSubResult: in std_logic_vector(31 downto 0); -- Input port for ADD/SUB operation result
 	    i_shiftResult : in std_logic_vector(31 downto 0); -- Input port for shift operation result
 	    o_result      : out std_logic_vector(31 downto 0) -- Output port for ALU result
    );
end selectOperation;

architecture dataflow of selectOperation is 
begin
    -- Selecting the ALU operation based on the ALUOp control signal
    o_result   <=   i_orResult       when (i_ALUOp = "0001") else
                    i_andResult      when (i_ALUOp = "1000") else 
	            i_xorResult      when (i_ALUOp = "0011") else 
	            i_norResult      when (i_ALUOp = "0101") else 
	            i_sltResult      when (i_ALUOp = "0111") else 
	            i_addSubResult   when (i_ALUOp = "0010") else
--	            i_subResult      when (i_ALUOp = "0110") else 
	            i_shiftResult    when (i_ALUOp = "0100") else 
	            x"00000000"; -- Default output when ALUOp is not recognized
end dataflow;
