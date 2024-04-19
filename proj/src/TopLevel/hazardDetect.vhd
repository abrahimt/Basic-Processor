-- This VHDL code defines an entity and architecture for a module named detectHazard.
-- The module is intended to detect hazards in a pipelined processor and generate control signals to handle them.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY detectHazard IS
  PORT (
    -- Inputs representing register values from different stages of the pipeline
    i_RS_IDEX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    i_RT_IDEX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    i_RT_IFID : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    i_RS_IFID : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    i_RD_EXMEM : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    i_RD_MEMWB : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    i_RD_IDEX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- Control signals from different stages of the pipeline
    i_RegWrEXMEM : IN STD_LOGIC;
    i_RegWrMEMWB : IN STD_LOGIC;
    i_RegWrIDEX : IN STD_LOGIC;
    i_ALUBranch : IN STD_LOGIC;
    i_jump : IN STD_LOGIC;

    -- Output signals indicating stall and flush conditions for each stage of the pipeline
    o_IFID_stall : OUT STD_LOGIC;
    o_IDEX_stall : OUT STD_LOGIC;
    o_EXMEM_stall : OUT STD_LOGIC;
    o_MEMWB_stall : OUT STD_LOGIC;

    o_IFID_flush : OUT STD_LOGIC;
    o_IDEX_flush : OUT STD_LOGIC;
    o_EXMEM_flush : OUT STD_LOGIC;
    o_MEMWB_flush : OUT STD_LOGIC);
END detectHazard;

ARCHITECTURE mixed OF detectHazard IS
BEGIN
  -- Stall signals assuming forwarding
  o_IFID_stall <= '1' WHEN (
    -- Stall IFID stage if there's a data hazard in the ID/EX stage
    (i_RegWrIDEX = '1' AND i_RD_IDEX /= "00000" AND (i_RD_IDEX = i_RT_IFID OR i_RD_IDEX = i_RS_IFID)) OR
    -- Stall IFID stage if there's a data hazard in the EX/MEM stage
    (i_RegWrEXMEM = '1' AND i_RD_EXMEM /= "00000" AND (i_RD_EXMEM = i_RS_IFID OR i_RD_EXMEM = i_RT_IFID))
    ) ELSE
    '0';

  -- Flush signals assuming forwarding
  o_IDEX_flush <= '1' WHEN (
    -- Flush IDEX stage if there's a data hazard in the ID/EX stage
    (i_RegWrIDEX = '1' AND i_RD_IDEX /= "00000" AND (i_RD_IDEX = i_RT_IFID OR i_RD_IDEX = i_RS_IFID)) OR
    -- Flush IDEX stage if there's a data hazard in the EX/MEM stage
    (i_RegWrEXMEM = '1' AND i_RD_EXMEM /= "00000" AND (i_RD_EXMEM = i_RS_IFID OR i_RD_EXMEM = i_RT_IFID))
    ) ELSE
    '0';

  -- Step signals 
  o_EXMEM_stall <= '0';
  o_MEMWB_stall <= '0';
  o_IDEX_stall <= '0';
  o_EXMEM_flush <= '0';
  o_MEMWB_flush <= '0';

  -- Control hazard case for flush
  -- Flush IFID stage if there's a jump or ALU branch instruction
  o_IFID_flush <= '1' WHEN (i_jump = '1' OR i_ALUBranch = '1') ELSE
    '0';
END mixed;