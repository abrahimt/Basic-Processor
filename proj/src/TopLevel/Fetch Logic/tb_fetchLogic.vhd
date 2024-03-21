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
        i_pInst <= x"0000000A";  -- Program Counter initial value
        i_jRetReg <= x"00000000";  -- No operation (NOP) instruction
        i_rst <= '1';  -- Reset signal active
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert o_nAddr = i_pInst report "Reset test failed" severity error;

        -- Jump test
        i_pInst <= x"08000000";  -- Jump instruction
        i_j <= '1';  -- Jump signal
        i_jReg <= '0';  -- No jump register signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x08000000
        assert o_nAddr = x"08000000" report "Jump instruction failed" severity error;

        -- Branch Equal Test
        i_pInst <= x"10000005";  -- Branch Equal instruction
        i_brEQ <= '1';  -- Branch Equal signal
        i_brNE <= '0';  -- No Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert o_nAddr = x"00000014" report "Branch Equal instruction failed" severity error;

        -- Branch Not Equal Test
        i_pInst <= x"20000005";  -- Branch Not Equal instruction
        i_brEQ <= '0';  -- No Branch Equal signal
        i_brNE <= '1';  -- Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is false)
        assert o_nAddr = x"00000014" report "Branch Not Equal instruction failed" severity error;

        -- Jump and Link Test
        i_pInst <= x"0C000000";  -- Jump and Link instruction
        i_jal <= '1';  -- Jump and Link signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x08000000 and o_pJPC should be updated
        assert o_nAddr = x"08000000" and o_pJPC = x"00000000" report "Jump and Link instruction failed" severity error;

        wait;
    end process;
end architecture tb;
