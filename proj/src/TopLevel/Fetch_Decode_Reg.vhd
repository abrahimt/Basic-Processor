-- Fetch_Decode_Reg

library IEEE;
use IEEE.std_logic_1164.all;

entity Fetch_Decode_Reg is 
    generic(N : integer := 32);                             	-- Generic of type integer for input/output data width. Default value is 32.
    port(
        i_clk		: in std_logic;				-- clk bit
        i_rst		: in std_logic;				-- reset bit
        i_we		: in std_logic;				-- write enable
	i_flush		: in std_logic;				-- flush bit				--Serves as almost a reset
        i_Inst		: in std_logic_vector(31 downto 0);	-- 32 bit instruction register
	i_PC4		: in std_logic_vector(31 downto 0);	-- 32 bit PC + 4 data
        o_PC4Out	: out std_logic_vector(31 downto 0);	-- output of PC4
        o_InstOut	: out std_logic_vector(31 downto 0));	-- output of Inst
end Fetch_Decode_Reg;

architecture structure of Fetch_Decode_Reg is

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

    REG1 : Nbit_dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_Inst,		-- Data bit input
            o_Q		=> o_InstOut);

    REG2 : Nbit_dffg
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- 
            i_D		=> i_PC4,		-- Data bit input
            o_Q		=> o_PC4Out);

    
end structure;