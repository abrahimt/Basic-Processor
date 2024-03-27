------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
------------------------------------------------------------
-- pcRegister.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Structural VHDL file of a 32-bit register bank with set functionality.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity pcRegister is 
    generic(N : integer := 32);                             -- Generic of type integer for input/output data width. Default value is 32.
    port(
        i_clk		: in std_logic;				            -- clk bit
        i_rst		: in std_logic;				            -- reset bit
        i_we		: in std_logic;				            -- write enable
        i_data		: in std_logic_vector(31 downto 0);	    -- 32 bits of data for register
        o_out		: out std_logic_vector(31 downto 0));	-- output of write
end pcRegister;

architecture structure of pcRegister is

    component Nbit_reg_PC
        generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_CLK        : in std_logic;     			 -- Clock input
            i_RST         : in std_logic;     			 -- Reset input
            i_WE          : in std_logic;                        -- Write enable input
            i_D           : in std_logic_vector(N-1 downto 0);	 -- 32 bit input
            o_Q           : out std_logic_vector(N-1 downto 0)); -- 32 bit output
    end component;


begin

	REG : Nbit_reg_PC
    port MAP(
            i_CLK	=> i_clk,		-- Clock bit input
            i_RST	=> i_rst,		-- Reset bit input
            i_WE	=> i_we,		-- Should be selecting 1 bit from decoder for each register; ex) 0000 1000 would be register $3
            i_D		=> i_data,		-- Data bit input
            o_Q		=> o_out);
    
end structure;