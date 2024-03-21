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
    
    signal i_clk, i_rst, i_j, i_jal, i_jReg, i_brEQ, i_brNE, i_ALU0 : std_logic;
    signal i_pInst, o_nAddr, o_pJPC, i_jRetReg : std_logic_vector(31 downto 0);
    
begin
    uut: entity work.fetchLogic
        port map(
            i_clk => i_clk,
            i_rst => i_rst,
            i_j => i_j,
            i_jal => i_jal,
            i_jReg => i_jReg,
            i_jRetReg => i_jRetReg,
            i_brEQ => i_brEQ,
            i_brNE => i_brNE,
            i_ALU0 => i_ALU0,
            i_pInst => i_pInst,
            o_nAddr => o_nAddr,
            o_pJPC => o_pJPC
        );

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
        i_rst <= '1';
        wait for 20 ns;
        i_rst <= '0';

	-- Reset Test
        i_pInst <= x"00000000";  -- Program Counter initial value
        i_jRetReg <= x"00000000";  -- No operation (NOP) instruction
        i_rst <= '1';  -- Reset signal active
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert o_nAddr = x"00400000" report "Reset test failed" severity error;

        -- addi Test
        i_pInst <= x"20090032";  -- addi instruction
        i_jRetReg <= x"00000000";  -- No operation (NOP) instruction
        i_rst <= '0';  -- Reset signal active
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert o_nAddr = x"00400004" report "Reset test failed" severity error;

        -- Jump test
        i_pInst <= x"08100008";  -- Jump instruction
        i_j <= '1';  		 -- Jump signal
        i_jReg <= '0';  	 -- No jump register signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x08000000
        assert o_nAddr = x"00400020" report "Jump instruction failed" severity error;

        -- addi Test
        i_pInst <= x"200a0032";   -- addi instruction
        i_jRetReg <= x"00000000"; -- No operation (NOP) instruction
        i_rst <= '0';  		  -- Reset signal active
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert o_nAddr = x"00400024" report "Reset test failed" severity error;

        -- Branch Equal Test
        i_pInst <= x"116c0001";  -- Branch Equal instruction
        i_brEQ <= '1';  	-- Branch Equal signal
        i_brNE <= '0';  	-- Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x0040002c (if condition is true)
        assert o_nAddr = x"0040002c" report "Branch Equal instruction failed" severity error;

	-- sub Test
        i_pInst <= x"01ad6822";  -- Sub instruction
        i_brEQ <= '0';  	 -- Branch Equal signal
        i_brNE <= '0';  	 -- No Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert o_nAddr = x"00400030" report "Branch Equal instruction failed" severity error;

	-- Branch Not Equal Test
        i_pInst <= x"158d0001";  -- Branch Not Equal instruction
        i_brEQ <= '0';		 -- Branch Equal signal
        i_brNE <= '1';  	 -- Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert o_nAddr = x"00400038" report "Branch Equal instruction failed" severity error;

	-- jal Test
        i_pInst <= x"0c100011";  -- jal instruction
        i_brEQ <= '0';  	 -- Branch Equal signal
        i_brNE <= '0';  	 -- No Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert o_nAddr = x"00400044" report "Branch Equal instruction failed" severity error;

	-- jr Test
        i_pInst <= x"03e00008";  -- jr instruction
        i_brEQ <= '0';  	 -- Branch Equal signal
        i_brNE <= '0';  	 -- No Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert o_nAddr = x"0040003c" report "Branch Equal instruction failed" severity error;

        -- addi Test
        i_pInst <= x"200d0032";    -- addi instruction
        i_jRetReg <= x"00000000";  -- No operation (NOP) instruction
        i_rst <= '0';  		   -- Reset signal low
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert o_nAddr = x"00400040" report "Reset test failed" severity error;


	wait;
    end process;
end architecture tb;
