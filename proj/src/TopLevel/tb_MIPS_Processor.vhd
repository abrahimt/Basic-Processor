-------------------------------------------------------------------------
-- Mitchell
-- 3/26/2024
-- tb_MIPS_Processor.vhd
-- Testbench for the ALU (Arithmetic Logic Unit) component used in a 
-- processor.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.textio.ALL; -- For basic I/O

ENTITY tb_MIPS_Processor IS
	GENERIC (gCLK_HPER : TIME := 10 ns; N : INTEGER := 32); -- Generic for half of the clock cycle period
END tb_MIPS_Processor;

ARCHITECTURE structure OF tb_MIPS_Processor IS

	-- Define the total clock period time
	CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

	COMPONENT MIPS_Processor IS
		GENERIC (N : INTEGER := 32);
		PORT (
		iCLK : IN STD_LOGIC;
		iRST : IN STD_LOGIC;
		iInstLd : IN STD_LOGIC; -- Whether we load an instruction?
		iInstAddr : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Instruction Address input
		iInstExt : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- No Idea what this is for
		oALUOut : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- TODO: Hook this up to the output of the ALU. 
		-- It is important for synthesis that you have 
		-- this output that can effectively be impacted by 
		-- all other components so they are not optimized away.
	END COMPONENT;

	SIGNAL s_CLK, s_RST, s_InstLd : STD_LOGIC;
	SIGNAL s_InstAddr, s_InstExt, s_ALUOut : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
BEGIN

	DUT0 : MIPS_Processor
	PORT MAP(
		iCLK => s_CLK,
		iRST => s_RST,
		iInstLd => s_InstLd,
		iInstAddr => s_InstAddr,
		iInstExt => s_InstExt,
		oALUOut => s_ALUOut);


	-- This process sets the clock value (low for gCLK_HPER, then high
	-- for gCLK_HPER). Absent a "wait" command, processes restart 
	-- at the beginning once they have reached the final statement.
	P_CLK : PROCESS
	BEGIN
		s_CLK <= '0';
		WAIT FOR gCLK_HPER;
		s_CLK <= '1';
		WAIT FOR gCLK_HPER;
	END PROCESS;
	TEST_CASES : PROCESS
	BEGIN

		-- There are a total of ... tests (each one waits a clock cycle)

		--addi
		s_InstAddr <= x"20010001";
		s_InstLd <= '1';
		WAIT FOR gCLK_HPER * 2;
		ASSERT s_ALUOut = x"0007FFFF" REPORT "Error: result mismatch" SEVERITY error; --Expect result = x"00000004"



	END PROCESS;

END structure;