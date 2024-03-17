library IEEE;
use IEEE.std_logic_1164.all;

entity selectOperation is 
    port(i_ALUOp   : in std_logic_vector(3 downto 0);
	 i_orResult : in std_logic_vector(31 downto 0);
	 i_andResult : in std_logic_vector(31 downto 0);
 	 i_xorResult : in std_logic_vector(31 downto 0);
 	 i_norResult : in std_logic_vector(31 downto 0);
 	 i_sltResult : in std_logic_vector(31 downto 0);
 	 i_addSubResult : in std_logic_vector(31 downto 0);
 	 i_shiftResult : in std_logic_vector(31 downto 0);
 	 o_result : out std_logic_vector(31 downto 0));
	 
end selectOperation;

architecture dataflow of selectOperation is 
begin
o_result <= i_orResult     when (i_ALUOp = "0111") else
            i_andResult    when (i_ALUOp = "0011") else 
	    i_xorResult    when (i_ALUOp = "0110") else 
	    i_norResult    when (i_ALUOp = "0101") else 
	    i_sltResult    when (i_ALUOp = "1000") else 
	    i_addSubResult when (i_ALUOp = "0010") else 
	    i_shiftResult  when (i_ALUOp = "1001") else 
	    x"00000000";

end dataflow;