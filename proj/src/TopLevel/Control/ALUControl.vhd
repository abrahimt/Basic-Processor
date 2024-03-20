
library IEEE;
use IEEE.std_logic_1164.all;

entity ALUControl is 
    port(
        i_ALUOp       	: in std_logic_vector(1 downto 0);  -- Input port for ALU operation code
	i_opcode	: in std_logic_vector(5 downto 0);  -- Input port for opcode
	i_function   	: in std_logic_vector(5 downto 0);  -- Input port for function
 	o_ALUControl    : out std_logic_vector(3 downto 0) -- Output port for ALUControl result
    );
end ALUControl;

architecture dataflow of ALUControl is 
begin

	o_ALUControl 	 <= 	"0001" when i_function = "100101" else	-- or
				"1000" when i_function = "100100" else	-- and
				"0011" when i_function = "100110" else	-- xor
				"0101" when i_function = "100111" else	-- nor
				"0111" when i_function = "101010" else	-- slt
				"0010" when i_function = "100000" else	-- add
				"0010" when i_function = "100001" else	-- addu
				"0010" when i_function = "100010" else	-- sub
				"0010" when i_function = "100011" else	-- subu
				"0100" when i_function = "000000" else	-- sll  (function is 000000 for non R-type)
				"0100" when i_function = "000010" else	-- srl
				"0100" when i_function = "000011" else	-- sra
				"0100" when i_function = "000100" else	-- sllv
				"0100" when i_function = "000110" else	-- srlv
				"0100" when i_function = "000111" else	-- srav
		      		"0000" when i_finction = others;

  with i_opcode select
	o_ALUControl 	<= 	"0010" when "001000",	-- addi
				"0010" when "001001",	-- addiu
				"1000" when "001100",	-- andi
				"0111" when "001010",	-- slti
				"0011" when "001110",	-- xori
				"0001" when "001101",	-- ori
		      		"0000" when others;
end if;
    
end dataflow;