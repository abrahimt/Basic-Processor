-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
-------------------------------------------------------------------------
-- fetchLogic_tb.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Testbench for the fetchLogic module.
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
-------------------------------------------------------------------------
-- fetchLogic_tb.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Testbench for the fetchLogic module.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity fetchLogic_tb is
end entity fetchLogic_tb;

architecture tb of fetchLogic_tb is
    constant CLOCK_PERIOD : time := 20 ns;
    
component fetchLogic is
    port(
	i_inst  : in std_logic_vector(31 downto 0);	-- Instruction input
	i_PC	: in std_logic_vector(31 downto 0);	-- PC Address input
        i_clk 	: in std_logic;				-- clock bit
        i_rst 	: in std_logic;				-- reset bit
        i_bne 	: in std_logic;				-- branch not equal bit
        i_beq 	: in std_logic;				-- branch equal bit
        i_j 	: in std_logic;				-- jump bit
        i_jr 	: in std_logic;				-- jump return bit
        i_jal 	: in std_logic;				-- jump and link bit
        i_ALUO 	: in std_logic;				-- 
        o_ra 	: in std_logic_vector(31 downto 0);	-- Output for $ra Address
        o_newPC : in std_logic_vector(31 downto 0));	-- Output for PC Address
end component;

    signal i_clk, i_rst, i_j, i_jal, i_jr, i_beq, i_bne, i_ALUO : std_logic;
    signal i_inst, i_PC, o_newPC, o_ra : std_logic_vector(31 downto 0) := (others => '0');
    
begin

    DUT0: fetchLogic
        port map(
            i_clk 	=> i_clk,
            i_rst 	=> i_rst,
            i_j		=> i_j,
	    i_jr	=> i_jr,
            i_jal 	=> i_jal,
            i_beq	=> i_beq,
            i_bne 	=> i_bne,
            i_ALUO 	=> i_ALUO,
            i_inst 	=> i_inst,
	    i_PC	=> i_PC,
            o_newPC 	=> o_newPC,
            o_ra 	=> o_ra);

    -- Clock process
    clk_process: process
    begin
        i_clk <= '0';
        wait for CLOCK_PERIOD / 2;
        i_clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    -- Stimulus process
    stim_process: process
    begin
        -- Initialize inputs
        i_rst 	<= '1';
	i_j	<= '0'; 
	i_jal	<= '0';  
	i_beq	<= '0';  
	i_bne	<= '0';  
	i_ALUO  <= '0'; 
        wait for 20 ns;
        i_rst 	<= '0';

	-- Reset Test
        i_inst <= x"00000000";  -- Program Counter initial value
	i_PC   <= o_newPC;	-- Current PC Address
        i_rst  <= '1';  	-- Reset signal active
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert o_newPC = x"00400000" report "Reset test failed" severity error;

        -- addi Test
        i_inst <= x"20090032";  -- addi instruction
	i_PC   <= o_newPC;	-- Current PC Address
        i_rst <= '0';  		-- Reset signal active
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert o_newPC = x"00400004" report "Reset test failed" severity error;

        -- Jump test
        i_inst <= x"08100008";  -- Jump instruction
	i_PC   <= o_newPC;	-- Current PC Address
        i_j    <= '1';  	-- Jump signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x08000000
        assert o_newPC = x"00400020" report "Jump instruction failed" severity error;

        -- addi Test
        i_inst <= x"200a0032";  -- addi instruction
	i_PC   <= o_newPC;	-- Current PC Address
        i_j    <= '0';  	-- Jump signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert o_newPC = x"00400024" report "Reset test failed" severity error;

        -- Branch Equal Test
        i_inst <= x"116c0001";  -- Branch Equal instruction
	i_PC   <= o_newPC;	-- Current PC Address
        i_beq  <= '1';  	-- Branch Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x0040002c (if condition is true)
        assert o_newPC = x"0040002c" report "Branch Equal instruction failed" severity error;

	-- sub Test
        i_inst <= x"01ad6822";  -- Sub instruction
	i_PC    <= o_newPC;	-- Current PC Address
        i_beq   <= '0';  	-- Branch Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert o_newPC = x"00400030" report "Branch Equal instruction failed" severity error;

	-- Branch Not Equal Test
        i_inst <= x"158d0001";  -- Branch Not Equal instruction
	i_PC   <= o_newPC;	-- Current PC Address
        i_bne  <= '1';  	-- Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert o_newPC = x"00400038" report "Branch Equal instruction failed" severity error;

	-- jal Test
        i_inst  <= x"0c100011"; -- jal instruction
	i_PC    <= o_newPC;	-- Current PC Address
        i_bne   <= '0';  	-- Branch Not Equal signal
	i_jal	<= '1';		-- jal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert o_newPC = x"00400044" report "Branch Equal instruction failed" severity error;

	-- jr Test
        i_inst  <= x"03e00008"; -- jr instruction
	i_PC   <= o_newPC;	-- Current PC Address
	i_jr    <= '1';		-- jr signal
	i_jal	<= '0';		-- jal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert o_newPC = x"0040003c" report "Branch Equal instruction failed" severity error;

        -- addi Test
        i_inst  <= x"200d0032"; -- addi instruction
	i_PC   <= o_newPC;	-- Current PC Address
	i_jr    <= '0';		-- jr signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert o_newPC = x"00400040" report "Reset test failed" severity error;


	wait;
    end process;
end architecture tb;
