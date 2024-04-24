-- Decode_Execute_Reg

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY Decode_Execute_Reg IS
        GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
        PORT (
                i_clk : IN STD_LOGIC; -- clk bit
                i_rst : IN STD_LOGIC; -- reset bit
                i_we : IN STD_LOGIC; -- write enable
                i_memWrite : IN STD_LOGIC; -- Goes to Dmem
                i_MemToReg : IN STD_LOGIC; -- Goes to Write Back		
                i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Goes to ALU
                i_ALUSrc : IN STD_LOGIC; -- Goes to ALU
                i_bne : IN STD_LOGIC; -- Goes to ALU
                i_beq : IN STD_LOGIC; -- Goes to ALU
                i_shiftDir : IN STD_LOGIC; -- Goes to ALU
                i_shiftType : IN STD_LOGIC; -- Goes to ALU
                i_addSub : IN STD_LOGIC; -- Goes to ALU
                i_signed : IN STD_LOGIC; -- Goes to ALU
                i_lui : IN STD_LOGIC; -- Goes to ALU
                i_jump : IN STD_LOGIC; -- Goes to Fetch
                i_jal : IN STD_LOGIC; -- Goes to Write Back
                i_jr : IN STD_LOGIC; -- Goes to Fetch
                i_branch : IN STD_LOGIC; -- Goes to Fetch
                i_RSReg : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit instruction register
                i_RTReg : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC + 4 data
                i_Imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC + 4 data
                i_rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 25-21)
                i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 20-16)
                i_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 15-11)
                i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 10-6)
                i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                i_regDst : IN STD_LOGIC; -- Goes to Write Back
                i_regWr : IN STD_LOGIC; -- 
                i_halt : IN STD_LOGIC; -- 
                o_halt : OUT STD_LOGIC; -- 
                o_regWr : OUT STD_LOGIC; -- 
                o_RegDst : OUT STD_LOGIC; -- Goes to Write Back
                o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                o_inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                o_memWrite : OUT STD_LOGIC; -- Goes to Dmem
                o_MemToReg : OUT STD_LOGIC; -- Goes to Write Back	
                o_ALUOp : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
                o_ALUSrc : OUT STD_LOGIC;
                o_bne : OUT STD_LOGIC;
                o_beq : OUT STD_LOGIC;
                o_shiftDir : OUT STD_LOGIC;
                o_shiftType : OUT STD_LOGIC;
                o_addSub : OUT STD_LOGIC;
                o_signed : OUT STD_LOGIC;
                o_lui : OUT STD_LOGIC;
                o_jump : OUT STD_LOGIC; -- Goes to Fetch
                o_jal : OUT STD_LOGIC; -- Goes to Write Back
                o_jr : OUT STD_LOGIC; -- Goes to Fetch
                o_branch : OUT STD_LOGIC; -- Goes to Fetch
                o_RSDataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit instruction register out
                o_RTDataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC + 4 data out 
                o_ImmOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC + 4 data out
                o_rsOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 25-21) out
                o_rtOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 20-16) out
                o_rdOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 15-11) out
                o_shamt : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)); -- 5 bits (inst 10-6) out
END Decode_Execute_Reg;

ARCHITECTURE structure OF Decode_Execute_Reg IS

        COMPONENT Nbit_dffg
                GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
                PORT (
                        i_CLK : IN STD_LOGIC; -- Clock input
                        i_RST : IN STD_LOGIC; -- Reset input
                        i_WE : IN STD_LOGIC; -- Write enable input
                        i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- 32 bit input
                        o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- 32 bit output
        END COMPONENT;

        COMPONENT FOURbit_dffg
                GENERIC (N : INTEGER := 4); -- Generic of type integer for input/output data width. Default value is 32.
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

        REG_RS : Nbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_RSReg, -- Data bit input
                o_Q => o_RSDataOut);

        REG_RT : Nbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_RTReg, -- Data bit input
                o_Q => o_RTDataOut);

        REG_IMM : Nbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_Imm, -- Data bit input
                o_Q => o_ImmOut);

        REG_INST1 : FIVEbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_rs, --  input
                o_Q => o_rsOut);

        REG_INST2 : FIVEbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_rt, --  input
                o_Q => o_rtOut);

        REG_INST3 : FIVEbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_rd, --  input
                o_Q => o_rdOut);

        REG_INST4 : FIVEbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_shamt, --  input
                o_Q => o_shamt);

        REG_inst : Nbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_inst, -- Data bit input
                o_Q => o_inst);

        REG_PC : Nbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_PC, -- Data bit input
                o_Q => o_PC);

        REG_Op : FOURbit_dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_ALUop, -- Data bit input
                o_Q => o_ALUop);

        REG_REGWR : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_regWr, -- Data bit input
                o_Q => o_regWr);

        REG_REGDST : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_regDst, -- Data bit input
                o_Q => o_RegDst);

        REG_Src : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_ALUSrc, -- Data bit input
                o_Q => o_ALUSrc);

        REG_bne : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_bne, -- Data bit input
                o_Q => o_bne);

        REG_beq : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_beq, -- Data bit input
                o_Q => o_beq);

        REG_shiftDir : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_shiftDir, -- Data bit input
                o_Q => o_shiftDir);

        REG_shiftType : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_shiftType, -- Data bit input
                o_Q => o_shiftType);

        REG_addSub : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_addSub, -- Data bit input
                o_Q => o_addSub);

        REG_signed : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_signed, -- Data bit input
                o_Q => o_signed);

        REG_LUI : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_lui, -- Data bit input
                o_Q => o_lui);

        REG_MEMWR : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_memWrite, -- Data bit input
                o_Q => o_memWrite);

        REG_MEMTOREG : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_MemToReg, -- Data bit input
                o_Q => o_MemToReg);

        REG_Jump : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_jump, -- Data bit input
                o_Q => o_jump);

        REG_JAL : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_jal, -- Data bit input
                o_Q => o_jal);

        REG_JR : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_jr, -- Data bit input
                o_Q => o_jr);

        REG_BRANCH : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_branch, -- Data bit input
                o_Q => o_branch);


        REG_HALT : dffg
        PORT MAP(
                i_CLK => i_clk, -- Clock bit input
                i_RST => i_rst, -- Reset bit input
                i_WE => i_we, -- 
                i_D => i_halt, -- Data bit input
                o_Q => o_halt);

END structure;