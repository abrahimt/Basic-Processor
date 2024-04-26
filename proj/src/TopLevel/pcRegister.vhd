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

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pcRegister IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
        i_clk : IN STD_LOGIC; -- clk bit
        i_rst : IN STD_LOGIC; -- reset bit
        i_we : IN STD_LOGIC; -- write enable
        i_stall : IN STD_LOGIC; -- write enable
        i_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bits of data for register
        o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of write
END pcRegister;

ARCHITECTURE structure OF pcRegister IS

    COMPONENT Nbit_reg_PC
        GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
        PORT (
            i_CLK : IN STD_LOGIC; -- Clock input
            i_RST : IN STD_LOGIC; -- Reset input
            i_WE : IN STD_LOGIC; -- Write enable input
            i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- 32 bit input
            o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- 32 bit output
    END COMPONENT;

    COMPONENT andg2 IS
        PORT (
            i_A : IN STD_LOGIC;
            i_B : IN STD_LOGIC;
            o_F : OUT STD_LOGIC);
    END COMPONENT;

    signal s_we : std_logic;

BEGIN

    G_AND1 : andg2
    PORT MAP(
        i_A => i_we,
        i_B => NOT i_stall,
        o_F => s_we);

    REG : Nbit_reg_PC
    PORT MAP(
        i_CLK => i_clk, -- Clock bit input
        i_RST => i_rst, -- Reset bit input
        i_WE => s_we, -- Should be selecting 1 bit from decoder for each register; ex) 0000 1000 would be register $3
        i_D => i_data, -- Data bit input
        o_Q => o_out);

END structure;