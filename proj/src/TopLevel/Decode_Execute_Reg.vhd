-- Decode_Execute_Reg

library IEEE;
use IEEE.std_logic_1164.all;

entity Decode_Execute_Reg is 
    generic(N : integer := 32);                             -- Generic of type integer for input/output data width. Default value is 32.
    port(
        i_clk		: in std_logic;				-- clk bit
        i_rst		: in std_logic;				-- reset bit
        i_we		: in std_logic;				-- write enable
	i_WB		: in std_logic;				-- write back bit
	i_M		: in std_logic;				-- Memory bit		
        i_ALUOp         : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        i_ALUSrc        : IN STD_LOGIC;
        i_bne           : IN STD_LOGIC;
        i_beq           : IN STD_LOGIC;
        i_shiftDir      : IN STD_LOGIC;
        i_shiftType     : IN STD_LOGIC;
        i_addSub        : IN STD_LOGIC;
        i_signed        : IN STD_LOGIC;
        i_lui           : IN STD_LOGIC;
        i_RSReg		: in std_logic_vector(31 downto 0);	-- 32 bit instruction register
	i_RTReg		: in std_logic_vector(31 downto 0);	-- 32 bit PC + 4 data
	i_Imm		: in std_logic_vector(31 downto 0);	-- 32 bit PC + 4 data
	i_rs		: in std_logic_vector(4 downto 0);	-- 5 bits (inst 25-21)
	i_rt		: in std_logic_vector(4 downto 0);	-- 5 bits (inst 20-16)
	i_rd		: in std_logic_vector(4 downto 0);	-- 5 bits (inst 15-11)
	i_shamt		: in std_logic_vector(4 downto 0);	-- 5 bits (inst 10-6)
	o_WBOut		: out std_logic;			-- write back bit out
	o_MOut		: out std_logic;			-- Memory bit out
        o_ALUOp         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_ALUSrc        : OUT STD_LOGIC;
        o_bne           : OUT STD_LOGIC;
        o_beq           : OUT STD_LOGIC;
        o_shiftDir      : OUT STD_LOGIC;
        o_shiftType     : OUT STD_LOGIC;
        o_addSub        : OUT STD_LOGIC;
        o_signed        : OUT STD_LOGIC;
        o_lui           : OUT STD_LOGIC;
        o_RSDataOut	: out std_logic_vector(31 downto 0);	-- 32 bit instruction register out
	o_RTDataOut	: out std_logic_vector(31 downto 0);	-- 32 bit PC + 4 data out 
	o_ImmOut	: out std_logic_vector(31 downto 0);	-- 32 bit PC + 4 data out
	o_rsOut		: out std_logic_vector(4 downto 0);	-- 5 bits (inst 25-21) out
	o_rtOut		: out std_logic_vector(4 downto 0);	-- 5 bits (inst 20-16) out
	o_rdOut		: out std_logic_vector(4 downto 0);	-- 5 bits (inst 15-11) out
	o_shamtOut	: out std_logic_vector(4 downto 0));	-- 5 bits (inst 10-6) out
end Decode_Execute_Reg;

architecture structure of Decode_Execute_Reg is

    component Nbit_dffg
  	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_CLK    : in std_logic;     		     -- Clock input
        i_RST         : in std_logic;     		     -- Reset input
        i_WE          : in std_logic;                        -- Write enable input
        i_D           : in std_logic_vector(N-1 downto 0);    -- 32 bit input
        o_Q           : out std_logic_vector(N-1 downto 0));  -- 32 bit output
    end component;

    component dffg
  	port(i_CLK   : in std_logic;     -- Clock input
       	i_RST        : in std_logic;     -- Reset input
       	i_WE         : in std_logic;     -- Write enable input
       	i_D          : in std_logic;     -- Data value input
       	o_Q          : out std_logic);   -- Data value output
    end component;


begin

    REG_RS : Nbit_dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_RSReg,		-- Data bit input
            o_Q		=> o_RSRegOut);

    REG_RT : Nbit_dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_RTReg,		-- Data bit input
            o_Q		=> o_RTRegOut);

    REG_IMM : Nbit_dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_Imm,		-- Data bit input
            o_Q		=> o_ImmOut);

    REG_INST1 : Nbit_dffg
    generic MAP(N => 5) -- Generic of type integer for input/output data width. Default value is 32.
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_rs,		--  input
            o_Q		=> o_rsOut);

    REG_INST2 : Nbit_dffg
    generic MAP(N => 5) -- Generic of type integer for input/output data width. Default value is 32.
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_rt,		--  input
            o_Q		=> o_rtOut);

    REG_INST3 : Nbit_dffg
    generic MAP(N => 5) -- Generic of type integer for input/output data width. Default value is 32.
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_rd,		--  input
            o_Q		=> o_rdOut);


    REG_INST4 : Nbit_dffg
    generic MAP(N => 5) -- Generic of type integer for input/output data width. Default value is 32.
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_shamt,		--  input
            o_Q		=> o_shamtOut);

    REG_WB : dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_WB,		-- Data bit input
            o_Q		=> o_WBOut);

    REG_M : dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_M,			-- Data bit input
            o_Q		=> o_MOut);

    REG_EX : dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_EX,		-- Data bit input
            o_Q		=> o_EXOut);


    
end structure; 