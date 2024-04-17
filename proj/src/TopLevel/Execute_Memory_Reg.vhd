-- Execute_Memory_Reg

library IEEE;
use IEEE.std_logic_1164.all;

entity Execute_Memory_Reg is 
    generic(N : integer := 32);                             	-- Generic of type integer for input/output data width. Default value is 32.
    port(
        i_clk		: in std_logic;				-- clk bit
        i_rst		: in std_logic;				-- reset bit
        i_we		: in std_logic;				-- write enable
	i_WB		: in std_logic;				-- write back input
	i_M		: in std_logic;				-- Memory input
        i_ALUResult	: in std_logic_vector(31 downto 0);	-- 32 bit ALU Result
	i_DmemAddr	: in std_logic_vector(31 downto 0);	-- 32 bit Dmem Address 
	i_unknown	: in std_logic_vector(4 downto 0);	-- 4 bit RD or Shamt?
	o_unknownOut	: out std_logic_vector(4 downto 0);	-- 4 bit RD or Shamt out?
	o_WBOut		: out std_logic;			-- write back output
	o_MOut		: out std_logic;			-- memory output
        o_ALUResultOut	: out std_logic_vector(31 downto 0);	-- output of ALU Result
        o_DmemAddrOut	: out std_logic_vector(31 downto 0));	-- output of Dmem Addr Input
end Execute_Memory_Reg;

architecture structure of Execute_Memory_Reg is

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

    REG_ALU : Nbit_dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_ALUResult,		-- ALU Result input
            o_Q		=> o_ALUResultOut);

    REG_DMEM : Nbit_dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_DmemAddr,		-- Dmem Addr input
            o_Q		=> o_DmemAddrOut);

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
            i_D		=> i_WB,		-- write back input
            o_Q		=> o_WBOut);

    REG_M : dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_M,			-- memory bit input
            o_Q		=> o_MOut);
    
end structure;