-- This VHDL code defines an entity and architecture for a module named detectHazard.
-- The module is intended to detect hazards in a pipelined processor and generate control signals to handle them.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY detectHazard IS
    PORT (
        i_rdEx : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rdMem : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rdWB : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rtEx : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rtMem : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rtWB : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_regDstEx : IN STD_LOGIC;  --rd is 1, rt is 0
        i_regDstMem : IN STD_LOGIC;  --rd is 1, rt is 0
        i_regDstWB : IN STD_LOGIC;  --rd is 1, rt is 0
        i_writeEnableEx : IN STD_LOGIC;
        i_writeEnableMem : IN STD_LOGIC;
        i_writeEnableWB : IN STD_LOGIC;
        i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_branch : IN STD_LOGIC;
        i_lw : in std_logic;
        i_sw : in std_logic;
        o_stall : OUT STD_LOGIC); --  
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

    o_stall <= '1' WHEN (i_rdEx = i_rs and i_regDstEx = '1' and i_branch = '1' and i_writeEnableEx = '1') ELSE -- Reg Dst is rd
        '1' WHEN (i_rdEx = i_rt and i_regDstEx = '1' and i_branch = '1' and i_writeEnableEx = '1') ELSE
        '1' WHEN (i_rdMem = i_rs and i_regDstMem = '1' and i_branch = '1' and i_writeEnableMem = '1') ELSE
        '1' WHEN (i_rdMem = i_rt and i_regDstMem = '1' and i_branch = '1' and i_writeEnableMem = '1') ELSE
        '1' WHEN (i_rdWB = i_rs and i_regDstWB = '1' and i_branch = '1' and i_writeEnableWB = '1') ELSE
        '1' WHEN (i_rdWB = i_rt and i_regDstWB = '1' and i_branch = '1' and i_writeEnableWB = '1') ELSE
        '1' WHEN (i_rtEx = i_rs and i_regDstEx = '0' and i_branch = '1' and i_writeEnableEx = '1') ELSE  -- Reg Dst is rt 
        '1' WHEN (i_rtEx = i_rt and i_regDstEx = '0' and i_branch = '1' and i_writeEnableEx = '1') ELSE
        '1' WHEN (i_rtMem = i_rs and i_regDstMem = '0' and i_branch = '1' and i_writeEnableMem = '1') ELSE
        '1' WHEN (i_rtMem = i_rt and i_regDstMem = '0' and i_branch = '1' and i_writeEnableMem = '1') ELSE
        '1' WHEN (i_rtWB = i_rs and i_regDstWB = '0' and i_branch = '1' and i_writeEnableWB = '1') ELSE
        '1' WHEN (i_rtWB = i_rt and i_regDstWB = '0' and i_branch = '1' and i_writeEnableWB = '1') ELSE

        '1' WHEN (i_rdEx = i_rs and i_regDstEx = '1' and i_lw = '1' and i_writeEnableEx = '1') ELSE -- LW
        '1' WHEN (i_rdEx = i_rt and i_regDstEx = '1' and i_lw = '1' and i_writeEnableEx = '1') ELSE
        '1' WHEN (i_rtEx = i_rs and i_regDstEx = '0' and i_lw = '1' and i_writeEnableEx = '1') ELSE  -- Reg Dst is rt 
        '1' WHEN (i_rtEx = i_rt and i_regDstEx = '0' and i_lw = '1' and i_writeEnableEx = '1') ELSE

        '1' WHEN (i_rdEx = i_rs and i_regDstEx = '1' and i_sw = '1' and i_writeEnableEx = '1') ELSE -- LW
        '1' WHEN (i_rdEx = i_rt and i_regDstEx = '1' and i_sw = '1' and i_writeEnableEx = '1') ELSE
        '1' WHEN (i_rtEx = i_rs and i_regDstEx = '0' and i_sw = '1' and i_writeEnableEx = '1') ELSE  -- Reg Dst is rt 
        '1' WHEN (i_rtEx = i_rt and i_regDstEx = '0' and i_sw = '1' and i_writeEnableEx = '1') ELSE
        '1' WHEN (i_rdMem = i_rs and i_regDstEx = '1' and i_sw = '1' and i_writeEnableMem = '1') ELSE -- LW
        '1' WHEN (i_rdMem = i_rt and i_regDstEx = '1' and i_sw = '1' and i_writeEnableMem = '1') ELSE
        '1' WHEN (i_rtMem = i_rs and i_regDstEx = '0' and i_sw = '1' and i_writeEnableMem = '1') ELSE  -- Reg Dst is rt 
        '1' WHEN (i_rtMem = i_rt and i_regDstEx = '0' and i_sw = '1' and i_writeEnableMem = '1') ELSE
        -- '1' WHEN (i_rdWB = i_rt and i_result /= x"00000000" and i_regDstEx = '1') ELSE
        -- '1' WHEN (i_rdWB = i_rs and i_result /= x"00000000" and i_regDstEx = '1') ELSE
        -- '1' WHEN (i_rtWB = i_rt and i_result /= x"00000000" and i_regDstEx = '0') ELSE
        -- '1' WHEN (i_rtWB = i_rs and i_result /= x"00000000" and i_regDstEx = '0') ELSE
        '0'; -- Other Case

    -- G_AND : andg2
    -- PORT MAP(
    --     i_A => i_branch,
    --     i_B => s_stall,
    --     o_F => o_stall
    -- );

END structure;