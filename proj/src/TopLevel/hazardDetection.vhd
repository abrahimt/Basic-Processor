-- This VHDL code defines an entity and architecture for a module named detectHazard.
-- The module is intended to detect hazards in a pipelined processor and generate control signals to handle them.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY detectHazard IS
    PORT (
        i_rdEx : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rdMem : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        o_stall : OUT STD_LOGIC); -- 1 when not true 
END detectHazard;

ARCHITECTURE structure OF detectHazard IS

BEGIN

    o_stall <= '1' WHEN (i_rdEx = i_rs) ELSE
        '1' WHEN (i_rdEx = i_rt) ELSE
        '1' WHEN (i_rdMem = i_rs) ELSE
        '1' WHEN (i_rdMem = i_rt) ELSE
        '0';

END structure;