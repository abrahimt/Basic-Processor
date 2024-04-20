-- Memory_WriteBack_Reg

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY Memory_WriteBack_Reg IS
        GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
        PORT (
                i_clk : IN STD_LOGIC; -- clk bit
                i_rst : IN STD_LOGIC; -- reset bit
                i_we : IN STD_LOGIC; -- write enable
                i_jal : IN STD_LOGIC; -- jal for mux
                i_MemToReg : IN STD_LOGIC; -- Goes to Write Back
                i_Dmem : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit Dmem Data 
                i_ALUResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit ALU Result
                i_ra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                i_nextPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                o_nextPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                o_ra : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                o_MemToReg : OUT STD_LOGIC; -- Goes to Write Back
                o_jal : OUT STD_LOGIC;
                o_DmemOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of PC4
                o_ALUResultOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of Inst
END Memory_WriteBack_Reg;

ARCHITECTURE structure OF Memory_WriteBack_Reg IS

        COMPONENT Nbit_dffg
                GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
                PORT (
                        i_CLK : IN STD_LOGIC; -- Clock input
                        i_RST : IN STD_LOGIC; -- Reset input
                        i_WE : IN STD_LOGIC; -- Write enable input
                        i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- 32 bit input
                        o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- 32 bit output
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

        REG_DMEM : Nbit_dffg
        GENERIC MAP(N => 32) -- Generic of type integer for input/output data width. Default value is 32.
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_Dmem, --  input
                o_Q => o_DmemOut);

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