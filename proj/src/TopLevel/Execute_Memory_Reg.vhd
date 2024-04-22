-- Execute_Memory_Reg

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY Execute_Memory_Reg IS
        GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
        PORT (
                i_clk : IN STD_LOGIC; -- clk bit
                i_rst : IN STD_LOGIC; -- reset bit
                i_we : IN STD_LOGIC; -- write enable
                i_memWrite : IN STD_LOGIC; -- Goes to Dmem
                i_jal : IN STD_LOGIC; -- Goes to Write Back
                i_MemToReg : IN STD_LOGIC; -- Goes to Write Back
                i_ALUResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit ALU Result
                i_DmemData : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit Dmem Data
                i_ra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                i_nextPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);-- 5 bits (inst 20-16)
                i_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 15-11)
                i_regDst : IN STD_LOGIC; -- Goes to Write Back
                o_RegDst : OUT STD_LOGIC; -- Goes to Write Back
                o_rtOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 20-16) out
                o_rdOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
                o_nextPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                o_ra : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                o_memWrite : OUT STD_LOGIC; -- Goes to Dmem
                o_jal : OUT STD_LOGIC; -- Goes to Write Back
                o_MemToReg : OUT STD_LOGIC; -- Goes to Write Back
                o_ALUResultOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of ALU Result
                o_DmemDataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of Dmem Data Input
END Execute_Memory_Reg;

ARCHITECTURE structure OF Execute_Memory_Reg IS

        COMPONENT Nbit_dffg
                GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
                PORT (
                        i_CLK : IN STD_LOGIC; -- Clock input
                        i_RST : IN STD_LOGIC; -- Reset input
                        i_WE : IN STD_LOGIC; -- Write enable input
                        i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- 32 bit input
                        o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- 32 bit output
        END COMPONENT;

        COMPONENT Fivebit_dffg IS
                GENERIC (N : INTEGER := 5); -- Generic of type integer for input/output data width. Default value is 32.
                PORT (
                        i_CLK : IN STD_LOGIC; -- Clock input
                        i_RST : IN STD_LOGIC; -- Reset input
                        i_WE : IN STD_LOGIC; -- Write enable input
                        i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Data value input
                        o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- Data value output

        END COMPONENT;

        COMPONENT dffg
                PORT (
                        i_CLK : IN STD_LOGIC; -- Clock input
                        i_RST : IN STD_LOGIC; -- Reset input
                        i_WE : IN STD_LOGIC; -- Write enable input
                        i_D : IN STD_LOGIC; -- Data value input
                        o_Q : OUT STD_LOGIC); -- Data value output
        END COMPONENT;

BEGIN

        REG_INST1 : FIVEbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_rt, --  input
                o_Q => o_rtOut);

        REG_INST2 : FIVEbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_rd, --  input
                o_Q => o_rdOut);

        REG_nextPC : Nbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_nextPC, -- ALU Result input
                o_Q => o_nextPC);

        REG_RA : Nbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_ra, -- Dmem Addr input
                o_Q => o_ra);

        REG_ALURESULT : Nbit_dffg
        GENERIC MAP(N => 32) -- Generic of type integer for input/output data width. Default value is 32.
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_ALUResult, --  input
                o_Q => o_ALUResultOut);

        REG_DMEMDATA : Nbit_dffg
        GENERIC MAP(N => 32) -- Generic of type integer for input/output data width. Default value is 32.
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_DmemData, --  input
                o_Q => o_DmemDataOut);

        REG_MEMWR : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_memWrite, -- write back input
                o_Q => o_memWrite);

        REG_RegDst : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_regDst, -- write back input
                o_Q => o_RegDst);

        REG_JAL : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_jal, -- memory bit input
                o_Q => o_jal);

        REG_MEMTOREG : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_MemToReg, -- memory bit input
                o_Q => o_MemToReg);

END structure;