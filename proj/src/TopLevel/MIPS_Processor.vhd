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
    oALUOut : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- TODO: Hook this up to the output of the ALU. 
  -- It is important for synthesis that you have 
  -- this output that can effectively be impacted by 
  -- all other components so they are not optimized away.

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

  -- Required overflow signal for overflow exception detection
  SIGNAL s_Ovfl : STD_LOGIC; -- TODO: this signal indicates an overflow exception would have been initiated

  -- OUR SIGNALS

  --CONTROL SIGNALS
  SIGNAL s_bne : STD_LOGIC;
  SIGNAL s_beq : STD_LOGIC;
  SIGNAL s_j : STD_LOGIC;
  SIGNAL s_jump : STD_LOGIC;
  SIGNAL s_jal : STD_LOGIC;
  SIGNAL s_jr : STD_LOGIC;
  SIGNAL s_halt : STD_LOGIC;
  SIGNAL s_RegDst : STD_LOGIC;
  SIGNAL s_RegWrite : STD_LOGIC;
  SIGNAL s_memToReg : STD_LOGIC;
  SIGNAL s_memWrite : STD_LOGIC;
  SIGNAL s_ALUSrc : STD_LOGIC;
  SIGNAL s_ALUOp : STD_LOGIC;
  SIGNAL s_signed : STD_LOGIC;
  SIGNAL s_addSub : STD_LOGIC;
  SIGNAL s_shiftType : STD_LOGIC;
  SIGNAL s_shiftDir : STD_LOGIC;
  SIGNAL s_branch : STD_LOGIC;
  SIGNAL s_lui : STD_LOGIC;
  SIGNAL s_ctlExt : STD_LOGIC;

  --ALU SIGNALS
  SIGNAL s_branchALU : STD_LOGIC;
  SIGNAL s_result : STD_LOGIC_VECTOR(31 DOWNTO 0);

  --AND SIGNALS
  SIGNAL s_branchAnd : STD_LOGIC;

  --MUX SIGNALS
  SIGNAL s_branchMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_jumpMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_RegDMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_RegEMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_ALUMemMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);

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

  COMPONENT andg2 IS
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  --Sign/Zero Extension
  COMPONENT bit_width_extender IS
    PORT (
      i_Imm16 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      i_ctl : IN STD_LOGIC;
      o_Imm32 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

  END COMPONENT;

  -- 32 bit mux to determine whether the memory output or alu output is writtent desired register
  COMPONENT mux2t1_N IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_S : IN STD_LOGIC;
      i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
  END COMPONENT;

  -- 5 bit mux to determine which address is being written to 
  COMPONENT mux2t1_5bit IS
    PORT (
      i_S : IN STD_LOGIC;
      i_D0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      i_D1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      o_O : OUT STD_LOGIC_VECTOR(4 DOWNTO 0));
  END COMPONENT;

  COMPONENT mux3t1_N IS
    GENERIC (N : INTEGER := 5); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_S : IN STD_LOGIC;
      i_jal : IN STD_LOGIC;
      i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_D2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
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
  G_CTL : control
  PORT MAP(
    i_inst => iInstAddr, -- TODO --MIPS instruction address
    o_RegWrite => s_RegWrite,
    o_memToReg => s_memToReg,
    o_memWrite => s_memWrite,
    o_ALUSrc => s_ALUSrc,
    o_ALUOp => s_ALUOp,
    o_signed => s_signed,
    o_addSub => s_addSub,
    o_shiftType => s_shiftType,
    o_shiftDir => shiftDir,
    o_bne => s_bne,
    o_beq => s_beq,
    o_j => s_j,
    o_jr => s_jr,
    o_jal => s_jal,
    o_branch => s_branch,
    o_jump => s_jump, -- TODO  (is this the same as s_j) -abe: no I think we need a different one that's s_jump
    o_lui => s_lui,
    o_halt => s_halt,
    o_ctlExt => s_ctlExt);

  G_ALU : alu
  PORT MAP(
    i_RS = >, -- TODO  
    i_RT = >, -- TODO
    i_Imm = >, -- TODO
    i_ALUOp => s_ALUOp,
    i_ALUSrc => s_ALUSrc,
    i_bne => s_bne,
    i_beq => s_beq,
    i_shiftDir => s_shiftDir,
    i_shiftType => s_shiftType,
    i_shamt => s_Inst(10 DOWNTO 6), -- TODO - abe added this
    i_addSub => s_addSub,
    i_signed => s_signed,
    i_lui => s_lui,
    o_result => s_result,
    o_overflow => s_Ovfl,
    o_branch => s_branchALU);

  G_FETCHLOGIC : fetchLogic
  PORT MAP(
    i_inst => s_Inst, -- Instruction input                 -- TODO
    i_PC = >, -- PC Address input
    i_clk => iCLK, -- clock bit  -abe
    i_rst => iRST, -- reset bit  -abe
    i_bne => s_bne, -- branch not equal bit
    i_beq => s_beq, -- branch equal bit
    i_j => s_jump, -- jump bit    -abe changed this from s_j to s_jump
    i_jr => s_jr, -- jump return bit
    i_jal => s_jal, -- jump and link bit
    o_ra => s_ra, -- Output for $ra Address                 -- TODO
    o_newPC => s_NextInstAddr); -- Output for PC Address    -- TODO 

  G_AND : andg2
  PORT MAP(
    i_A => s_branchALU,
    i_B => s_branch,
    o_F => s_branchAnd);

  G_MUX_BRANCH : mux2t1_N
  PORT MAP(
    i_S => s_branchAnd,
    i_D0 => s_PC4, -- TODO
    i_D1 => s_NextInstAddr,
    o_O => s_branchMUX);

  G_MUX_JUMP : mux2t1_N
  PORT MAP(
    i_S => s_j,
    i_D0 => s_PC4, -- TODO
    i_D1 => s_branchMUX,
    o_O => s_jumpMUX);

  G_MUX_ALU_MEM : mux2t1_N
  PORT MAP(
    i_S => s_memToReg,
    i_D0 => s_, -- TODO
    i_D1 => s_result,
    o_O => s_ALUMemMUX);

  G_MUX_REGDST : mux2t1_N
  PORT MAP(
    i_S => s_RegDst,
    i_D0 => s_Inst(20 DOWNTO 16), -- TODO (instruction [20-16])  -abe just put that in
    i_D1 => s_Inst(15 DOWNTO 11), -- TODO (instruction [15-11]) - abe
    o_O => s_RegDMUX);

  G_MUX_REGE : mux2t1_N
  PORT MAP(
    i_S => s_branchAnd,
    i_D0 => s_, -- TODO (Read Data 2)
    i_D1 => s_, -- TODO (Sign-Extended Immediate)
    o_O => s_RegEMUX);

  oALUOut <= s_DMemAddr; --abe added this

END structure;