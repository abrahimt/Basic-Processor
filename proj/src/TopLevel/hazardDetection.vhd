-- This VHDL code defines an entity and architecture for a module named detectHazard.
-- The module is intended to detect hazards in a pipelined processor and generate control signals to handle them.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY detectHazard IS
    PORT (
        i_rdEx : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rdMem : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rdWB : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_branch : IN STD_LOGIC;
        o_stall : OUT STD_LOGIC); -- 1 when not true 
END detectHazard;

ARCHITECTURE structure OF detectHazard IS

    SIGNAL s_stall : STD_LOGIC;

    COMPONENT andg2 IS
        PORT (
            i_A : IN STD_LOGIC;
            i_B : IN STD_LOGIC;
            o_F : OUT STD_LOGIC);
    END COMPONENT;

BEGIN

    s_stall <= '1' WHEN (i_rdEx = i_rs) ELSE
        '1' WHEN (i_rdEx = i_rt) ELSE
        '1' WHEN (i_rdMem = i_rs) ELSE
        '1' WHEN (i_rdMem = i_rt) ELSE
        '1' WHEN (i_rdWB = i_rt) ELSE
        '1' WHEN (i_rdWB = i_rs) ELSE
        '0';

    G_AND : andg2
    PORT MAP(
        i_A => i_branch,
        i_B => s_stall,
        o_F => o_stall
    );

END structure;