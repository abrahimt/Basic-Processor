-- Memory_WriteBack_Reg

library IEEE;
use IEEE.std_logic_1164.all;

entity Memory_WriteBack_Reg is 
    generic(N : integer := 32);                             	-- Generic of type integer for input/output data width. Default value is 32.
    port(
        i_clk		: in std_logic;				-- clk bit
        i_rst		: in std_logic;				-- reset bit
        i_we		: in std_logic;				-- write enable
	i_WB		: in std_logic;				-- Write Back Bit
        i_Dmem		: in std_logic_vector(31 downto 0);	-- 32 bit Dmem Data 
	i_ALUResult	: in std_logic_vector(31 downto 0);	-- 32 bit ALU Result
	i_unknown	: in std_logic_vector(4 downto 0);	-- 4 bit RD or Shamt?
	o_WBOut		: out std_logic;			-- Write Back Bit Out
	o_unknownOut	: out std_logic_vector(4 downto 0);	-- 4 bit RD or Shamt out?
        o_DmemOut	: out std_logic_vector(31 downto 0);	-- output of PC4
        o_ALUResultOut	: out std_logic_vector(31 downto 0));	-- output of Inst
end Memory_WriteBack_Reg;

architecture structure of Memory_WriteBack_Reg is

    component Nbit_dffg
  	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_CLK    : in std_logic;     			-- Clock input
        i_RST         : in std_logic;     			-- Reset input
        i_WE          : in std_logic;                        	-- Write enable input
        i_D           : in std_logic_vector(N-1 downto 0);	-- 32 bit input
        o_Q           : out std_logic_vector(N-1 downto 0)); 	-- 32 bit output
    end component;

    component dffg
  	port(i_CLK   : in std_logic;     -- Clock input
       	i_RST        : in std_logic;     -- Reset input
       	i_WE         : in std_logic;     -- Write enable input
       	i_D          : in std_logic;     -- Data value input
       	o_Q          : out std_logic);   -- Data value output
    end component;


begin

    REG_DMEM : Nbit_dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_Dmem,		-- Dmem Data input
            o_Q		=> o_DmemOut);

    REG_ALU : Nbit_dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_ALUResult,		-- ALU result input
            o_Q		=> o_ALUResultOut);

    REG_INST : Nbit_dffg
    generic MAP(N => 5) -- Generic of type integer for input/output data width. Default value is 32.
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_unknown,			--  input
            o_Q		=> o_unknownOut);

    REG_WB : dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_WB,		-- write back bit input
            o_Q		=> o_WBOut);

    
end structure;