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
    constant CLOCK_PERIOD : time := 10 ns;
    
    signal clk, reset, j, jal, jReg, brEQ, brNE, ALU0 : std_logic;
    signal pAddr, pInst, nAddr, jRetReg : std_logic_vector(31 downto 0);
    
begin
    uut: entity work.fetchLogic
        port map(
            i_clk => clk,
            i_reset => reset,
            i_j => j,
            i_jal => jal,
            i_jReg => jReg,
            i_jRetReg => jRetReg,
            i_brEQ => brEQ,
            i_brNE => brNE,
            i_ALU0 => ALU0,
            i_pInst => pInst,
            o_nAddr => nAddr
        );

    -- Clock process
    clk_process: process
    begin
        while now < 500 ns loop
            clk <= '0';
            wait for CLOCK_PERIOD / 2;
            clk <= '1';
            wait for CLOCK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_process: process
    begin
        -- Initialize inputs
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Test cases
        wait for CLOCK_PERIOD * 5;
        -- Reset Test
        pAddr <= x"0000000A";  -- Program Counter initial value
        pInst <= x"00000000";  -- No operation (NOP) instruction
        reset <= '1';  -- Reset signal active
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should remain the same after reset
        assert nAddr = pAddr report "Reset test failed" severity error;

        -- Jump test
        pAddr <= x"00000000";  -- Program Counter initial value
        pInst <= x"08000000";  -- Jump instruction
        j <= '1';  -- Jump signal
        jReg <= '0';  -- No jump register signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x08000000
        assert nAddr = x"08000000" report "Jump instruction failed" severity error;

        -- Branch Equal Test
        pAddr <= x"00000000";  -- Program Counter initial value
        pInst <= x"10000005";  -- Branch Equal instruction
        brEQ <= '1';  -- Branch Equal signal
        brNE <= '0';  -- No Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is true)
        assert nAddr = x"00000014" report "Branch Equal instruction failed" severity error;

        -- Branch Not Equal Test
        pAddr <= x"00000000";  -- Program Counter initial value
        pInst <= x"20000005";  -- Branch Not Equal instruction
        brEQ <= '0';  -- No Branch Equal signal
        brNE <= '1';  -- Branch Not Equal signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x00000014 (if condition is false)
        assert nAddr = x"00000014" report "Branch Not Equal instruction failed" severity error;

        -- Jump and Link Test
        pAddr <= x"00000000";  -- Program Counter initial value
        pInst <= x"0C000000";  -- Jump and Link instruction
        jal <= '1';  -- Jump and Link signal
        wait for CLOCK_PERIOD;
        -- Expected result: Next address should be 0x08000000 and jRetReg should be updated
        assert nAddr = x"08000000" and jRetReg = x"00000000" report "Jump and Link instruction failed" severity error;

        wait;
    end process;
end architecture tb;
