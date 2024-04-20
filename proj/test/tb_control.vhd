-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
-------------------------------------------------------------------------
-- tb_control.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Testbench for the control module.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.textio.ALL; -- For basic I/O

ENTITY tb_control IS
END tb_control;

ARCHITECTURE structure OF tb_control IS

  CONSTANT CLOCK_PERIOD : TIME := 20 ns;

  COMPONENT control IS
    PORT (
      i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --MIPS instruction
      o_RegDst : OUT STD_LOGIC;
      o_RegWrite : OUT STD_LOGIC;
      o_memToReg : OUT STD_LOGIC;
      o_memWrite : OUT STD_LOGIC;
      o_ALUSrc : OUT STD_LOGIC;
      o_ALUOp : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      o_signed : OUT STD_LOGIC;
      o_addSub : OUT STD_LOGIC;
      o_shiftType : OUT STD_LOGIC;
      o_shiftDir : OUT STD_LOGIC;
      o_bne : OUT STD_LOGIC;
      o_beq : OUT STD_LOGIC;
      o_j : OUT STD_LOGIC;
      o_jr : OUT STD_LOGIC;
      o_jal : OUT STD_LOGIC;
      o_jump : OUT STD_LOGIC;
      o_branch : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL s_inst : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_RegDst : STD_LOGIC;
  SIGNAL s_RegWrite : STD_LOGIC;
  SIGNAL s_memToReg : STD_LOGIC;
  SIGNAL s_memWrite : STD_LOGIC;
  SIGNAL s_ALUSrc : STD_LOGIC;
  SIGNAL s_signed : STD_LOGIC;
  SIGNAL s_ALUOp : STD_LOGIC_VECTOR(3 DOWNTO 0);

  SIGNAL s_addSub : STD_LOGIC;
  SIGNAL s_shiftType : STD_LOGIC;
  SIGNAL s_shiftDir : STD_LOGIC;
  SIGNAL s_bne : STD_LOGIC;
  SIGNAL s_beq : STD_LOGIC;
  SIGNAL s_j : STD_LOGIC;
  SIGNAL s_jal : STD_LOGIC;
  SIGNAL s_jr : STD_LOGIC;
  SIGNAL s_branch : STD_LOGIC;
  SIGNAL s_jump : STD_LOGIC;

BEGIN
  DUT0 : control

  PORT MAP(
    i_inst => s_inst,
    o_RegDst => s_RegDst,
    o_RegWrite => s_RegWrite,
    o_memToReg => s_memToReg,
    o_memWrite => s_memWrite,
    o_ALUSrc => s_ALUSrc,
    o_signed => s_signed,
    o_ALUOp => s_ALUOp,

    o_addSub => s_addSub,
    o_shiftType => s_shiftType,
    o_shiftDir => s_shiftDir,
    o_bne => s_bne,
    o_beq => s_beq,
    o_j => s_j,
    o_jal => s_jal,
    o_jr => s_jr,
    o_jump => s_jump,
    o_branch => s_branch);
  TEST_CASES : PROCESS
  BEGIN

    s_inst <= x"00000020";
    WAIT FOR CLOCK_PERIOD; --add instruction
    ASSERT s_ALUOp = b"0010" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000021";
    WAIT FOR CLOCK_PERIOD; --addu instruction
    ASSERT s_ALUOp = b"0010" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000024";
    WAIT FOR CLOCK_PERIOD; --and instruction
    ASSERT s_ALUOp = b"0011" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000027";
    WAIT FOR CLOCK_PERIOD; --nor instruction
    ASSERT s_ALUOp = b"0101" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000026";
    WAIT FOR CLOCK_PERIOD; --xor instruction
    ASSERT s_ALUOp = b"0110" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000025";
    WAIT FOR CLOCK_PERIOD; --or instruction
    ASSERT s_ALUOp = b"0111" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"0000002a";
    WAIT FOR CLOCK_PERIOD; --slt instruction
    ASSERT s_ALUOp = b"1000" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000000";
    WAIT FOR CLOCK_PERIOD; --sll instruction
    ASSERT s_ALUOp = b"1001" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000002";
    WAIT FOR CLOCK_PERIOD; --srl instruction
    ASSERT s_ALUOp = b"1001" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000003";
    WAIT FOR CLOCK_PERIOD; --sra instruction
    ASSERT s_ALUOp = b"1001" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000022";
    WAIT FOR CLOCK_PERIOD; --sub instruction
    ASSERT s_ALUOp = b"0010" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000023";
    WAIT FOR CLOCK_PERIOD; --subu instruction
    ASSERT s_ALUOp = b"0010" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"00000008";
    WAIT FOR CLOCK_PERIOD; --jr instruction
    ASSERT s_ALUOp = b"1011" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"20000000";
    WAIT FOR CLOCK_PERIOD; --addi instruction
    ASSERT s_ALUOp = b"0010" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"24000000";
    WAIT FOR CLOCK_PERIOD; --addiu instruction
    ASSERT s_ALUOp = b"0010" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"30000000";
    WAIT FOR CLOCK_PERIOD; --andi instruction
    ASSERT s_ALUOp = b"0011" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"3c000000";
    WAIT FOR CLOCK_PERIOD; --lui instruction
    ASSERT s_ALUOp = b"1001" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"8c000000";
    WAIT FOR CLOCK_PERIOD; --lw instruction
    ASSERT s_ALUOp = b"0010" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"38000000";
    WAIT FOR CLOCK_PERIOD; --xori instruction
    ASSERT s_ALUOp = b"0110" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"34000000";
    WAIT FOR CLOCK_PERIOD; --ori instruction
    ASSERT s_ALUOp = b"0111" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"28000000";
    WAIT FOR CLOCK_PERIOD; --slti instruction
    ASSERT s_ALUOp = b"1000" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"ac000000";
    WAIT FOR CLOCK_PERIOD; --sw instruction
    ASSERT s_ALUOp = b"0010" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"10000000";
    WAIT FOR CLOCK_PERIOD; --beq instruction
    ASSERT s_ALUOp = b"0000" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"14000000";
    WAIT FOR CLOCK_PERIOD; --bne instruction
    ASSERT s_ALUOp = b"0000" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"08000000";
    WAIT FOR CLOCK_PERIOD; --j instruction
    ASSERT s_ALUOp = b"1011" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"0a000000";
    WAIT FOR CLOCK_PERIOD; --jal instruction
    ASSERT s_ALUOp = b"1011" REPORT "Wrong ALUOp" SEVERITY error;

    s_inst <= x"50000000";
    WAIT FOR CLOCK_PERIOD; --halt instruction
    ASSERT s_ALUOp = b"0000" REPORT "Wrong ALUOp" SEVERITY error;

    WAIT;
  END PROCESS;

END structure;