-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;
USE work.MIPS_types.ALL;

ENTITY MIPS_Processor IS
  GENERIC (N : INTEGER := DATA_WIDTH);
  PORT (
    iCLK : IN STD_LOGIC;
    iRST : IN STD_LOGIC;
    iInstLd : IN STD_LOGIC;
    iInstAddr : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    iInstExt : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    oALUOut : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

END MIPS_Processor;
ARCHITECTURE structure OF MIPS_Processor IS

  -- Required data memory signals
  SIGNAL s_DMemWr : STD_LOGIC; -- TODO: use this signal as the final active high data memory write enable signal
  SIGNAL s_DMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the final data memory address input
  SIGNAL s_DMemData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the final data memory data input
  SIGNAL s_DMemOut : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the data memory output

  -- Required register file signals 
  SIGNAL s_RegWr : STD_LOGIC; -- TODO: use this signal as the final active high write enable input to the register file
  SIGNAL s_RegWrAddr : STD_LOGIC_VECTOR(4 DOWNTO 0); -- TODO: use this signal as the final destination register address input
  SIGNAL s_RegWrData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  SIGNAL s_IMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  SIGNAL s_NextInstAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as your intended final instruction memory address input.
  SIGNAL s_Inst : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  SIGNAL s_Halt : STD_LOGIC; -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  SIGNAL s_Ovfl : STD_LOGIC; -- TODO: this signal indicates an overflow exception would have been initiated

  COMPONENT mem IS
    GENERIC (
      ADDR_WIDTH : INTEGER;
      DATA_WIDTH : INTEGER);
    PORT (
      clk : IN STD_LOGIC;
      addr : IN STD_LOGIC_VECTOR((ADDR_WIDTH - 1) DOWNTO 0);
      data : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
      we : IN STD_LOGIC := '1';
      q : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0));
  END COMPONENT;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment
  COMPONENT fetchLogic IS
    PORT (
      i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Instruction input
      i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- PC Address input
      i_clk : IN STD_LOGIC; -- clock bit
      i_rst : IN STD_LOGIC; -- reset bit
      i_bne : IN STD_LOGIC; -- branch not equal bit
      i_beq : IN STD_LOGIC; -- branch equal bit
      i_j : IN STD_LOGIC; -- jump bit
      i_jr : IN STD_LOGIC; -- jump return bit
      i_jal : IN STD_LOGIC; -- jump and link bit
      o_ra : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output for $ra Address
      o_newPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Output for PC Address
  END COMPONENT;

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
      o_branch : OUT STD_LOGIC;
      o_jump : OUT STD_LOGIC;
      o_lui : OUT STD_LOGIC;
      o_halt : OUT STD_LOGIC;
      o_ctlExt : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT alu IS
    PORT (
      i_RS, i_RT : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input ports for operands
      i_Imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for immediate value
      i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input port for ALU operation code
      i_ALUSrc : IN STD_LOGIC; -- Input port for ALU source selection
      i_bne : IN STD_LOGIC; -- Input port for branch if not equal
      i_beq : IN STD_LOGIC; -- Input port for branch if equal
      i_shiftDir : IN STD_LOGIC; -- Input port for shift direction
      i_shiftType : IN STD_LOGIC; -- Input port for shift type
      i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Input port for shift amount
      i_addSub : IN STD_LOGIC; -- Input port for add/subtract operation
      i_signed : IN STD_LOGIC; -- Input port for signed operation
      i_lui : IN STD_LOGIC; -- Input port for load upper immediate
      o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output port for result
      o_overflow : OUT STD_LOGIC; -- Output port for overflow flag
      o_branch : OUT STD_LOGIC -- Output port for branch signal
    );
  END COMPONENT;

BEGIN

  -- TODO: This is required to be your final input to your instruction memory. 
  -- This provides a feasible method to externally load the memory module which 
  -- means that the synthesis tool must assume it knows nothing about the values 
  -- stored in the instruction memory. If this is not included, much, if not all 
  -- of the design is optimized out because the synthesis tool will believe the 
  -- memory to be all zeros.
  WITH iInstLd SELECT
    s_IMemAddr <= s_NextInstAddr WHEN '0',
    iInstAddr WHEN OTHERS;
  IMem : mem
  GENERIC MAP(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  PORT MAP(
    clk => iCLK,
    addr => s_IMemAddr(11 DOWNTO 2),
    data => iInstExt,
    we => iInstLd,
    q => s_Inst);

  DMem : mem
  GENERIC MAP(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  PORT MAP(
    clk => iCLK,
    addr => s_DMemAddr(11 DOWNTO 2),
    data => s_DMemData,
    we => s_DMemWr,
    q => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from 
  -- decoding the Halt instruction (Opcode: 01 0100)

  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 
  G_CONTROL : control
  PORT MAP(
    i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --MIPS instruction 
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
    o_branch : OUT STD_LOGIC;
    o_jump : OUT STD_LOGIC;
    o_lui : OUT STD_LOGIC;
    o_halt : OUT STD_LOGIC;
    o_ctlExt : OUT STD_LOGIC);

  G_ALU : alu
  PORT MAP(
    i_RS, i_RT : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input ports for operands
    i_Imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for immediate value
    i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input port for ALU operation code
    i_ALUSrc : IN STD_LOGIC; -- Input port for ALU source selection
    i_bne : IN STD_LOGIC; -- Input port for branch if not equal
    i_beq : IN STD_LOGIC; -- Input port for branch if equal
    i_shiftDir : IN STD_LOGIC; -- Input port for shift direction
    i_shiftType : IN STD_LOGIC; -- Input port for shift type
    i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Input port for shift amount
    i_addSub : IN STD_LOGIC; -- Input port for add/subtract operation
    i_signed : IN STD_LOGIC; -- Input port for signed operation
    i_lui : IN STD_LOGIC; -- Input port for load upper immediate
    o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output port for result
    o_overflow : OUT STD_LOGIC; -- Output port for overflow flag
    o_branch : OUT STD_LOGIC -- Output port for branch signal
  );

  G_FETCHLOGIC : fetchLogic
  PORT MAP(
    i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Instruction input
    i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- PC Address input
    i_clk : IN STD_LOGIC; -- clock bit
    i_rst : IN STD_LOGIC; -- reset bit
    i_bne : IN STD_LOGIC; -- branch not equal bit
    i_beq : IN STD_LOGIC; -- branch equal bit
    i_j : IN STD_LOGIC; -- jump bit
    i_jr : IN STD_LOGIC; -- jump return bit
    i_jal : IN STD_LOGIC; -- jump and link bit
    o_ra : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output for $ra Address
    o_newPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Output for PC Address

END structure;