-- Fetch_Decode_Reg

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY Fetch_Decode_Reg IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
        i_clk : IN STD_LOGIC; -- clk bit
        i_rst : IN STD_LOGIC; -- reset bit
        i_branch : IN STD_LOGIC;
        i_jump : IN STD_LOGIC;
        i_we : IN STD_LOGIC; -- write enable
        i_stall : IN STD_LOGIC;
        i_Inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit instruction register
        i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC data
        i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);-- 5 bits (inst 20-16)
        i_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 15-11)
        i_PC4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_PC4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_rtOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 20-16) out
        o_rdOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        o_PCOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of PC4
        o_InstOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of Inst
END Fetch_Decode_Reg;

ARCHITECTURE structure OF Fetch_Decode_Reg IS

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

    COMPONENT andg2 IS
        PORT (
            i_A : IN STD_LOGIC;
            i_B : IN STD_LOGIC;
            o_F : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT org2 IS
        PORT (
            i_A : IN STD_LOGIC;
            i_B : IN STD_LOGIC;
            o_F : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL s_we : STD_LOGIC;
    SIGNAL s_flush : STD_LOGIC;
    SIGNAL s_branch_rst : STD_LOGIC;
    SIGNAL s_jump_rst : STD_LOGIC;

BEGIN

    G_OR1 : org2
    PORT MAP(
        i_A => i_rst,
        i_B => i_branch,
        o_F => s_branch_rst);

    G_OR2 : org2
    PORT MAP(
        i_A => i_rst,
        i_B => i_jump,
        o_F => s_jump_rst);

    G_AND1 : andg2
    PORT MAP(
        i_A => i_we,
        i_B => NOT i_stall,
        o_F => s_we);

    G_OR3 : org2
    PORT MAP(
        i_A => s_branch_rst,
        i_B => s_jump_rst,
        o_F => s_flush);

    REG_INST1 : Nbit_dffg
    Generic map (N => 5)
    PORT MAP(
        i_CLK => i_clk, -- Clock bit input
        i_RST => s_flush, -- Reset bit input
        i_WE => s_we, -- 
        i_D => i_rt, --  input
        o_Q => o_rtOut);

    REG_INST2 : Nbit_dffg
    Generic map (N => 5)
    PORT MAP(
        i_CLK => i_clk, -- Clock bit input
        i_RST => s_flush, -- Reset bit input
        i_WE => s_we, -- 
        i_D => i_rd, --  input
        o_Q => o_rdOut);

    REG0 : Nbit_dffg
    PORT MAP(
        i_CLK => i_clk, -- Clock bit input
        i_RST => s_flush, -- Reset bit input
        i_WE => s_we, -- 
        i_D => i_PC4, -- Data bit input
        o_Q => o_PC4);

    REG1 : Nbit_dffg
    PORT MAP(
        i_CLK => i_clk, -- Clock bit input
        i_RST => s_flush, -- Reset bit input
        i_WE => s_we, -- 
        i_D => i_Inst, -- Data bit input
        o_Q => o_InstOut);

    REG2 : Nbit_dffg
    PORT MAP(
        i_CLK => i_clk, -- Clock bit input
        i_RST => s_flush, -- Reset bit input
        i_WE => s_we, -- 
        i_D => i_PC, -- Data bit input
        o_Q => o_PCOut);

END structure;