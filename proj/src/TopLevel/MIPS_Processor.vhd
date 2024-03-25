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
    iInstLd : IN STD_LOGIC; -- Whether we load an instruction?
    iInstAddr : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Instruction Address input
    iInstExt : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- No Idea what this is for
    oALUOut : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- TODO: Hook this up to the output of the ALU. 
  -- It is important for synthesis that you have 
  -- this output that can effectively be impacted by 
  -- all other components so they are not optimized away.

END MIPS_Processor;

ARCHITECTURE structure OF MIPS_Processor IS

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
      i_zero : IN STD_LOGIC; -- zero bit from ALU
      i_branch : IN STD_LOGIC; -- branch bit from control
      i_jump : IN STD_LOGIC; -- jump bit from control
      i_jr : IN STD_LOGIC; -- jump return bit from control
      i_jal : IN STD_LOGIC; -- jump and link bit from control
      i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- RS register value
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

  COMPONENT MIPSregister IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_SEL : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- selection bits
      i_clk : IN STD_LOGIC; -- clk bit
      i_rst : IN STD_LOGIC; -- reset bit
      i_we : IN STD_LOGIC; -- write enable
      i_d : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bits of data for register
      i_rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- read selction bit for mux
      i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- read selction bit for mux
      o_OUT1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of write
      o_OUT2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of write
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

  --Register Signals
  SIGNAL s_rt : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_rs : STD_LOGIC_VECTOR(4 DOWNTO 0);

  --CONTROL SIGNALS
  SIGNAL s_bne : STD_LOGIC;
  SIGNAL s_beq : STD_LOGIC;
  SIGNAL s_j : STD_LOGIC;
  SIGNAL s_jump : STD_LOGIC;
  SIGNAL s_jal : STD_LOGIC;
  SIGNAL s_jr : STD_LOGIC;
  SIGNAL s_RegDst : STD_LOGIC;
  SIGNAL s_RegWrite : STD_LOGIC;
  SIGNAL s_memToReg : STD_LOGIC;
  SIGNAL s_ALUSrc : STD_LOGIC;
  SIGNAL s_ALUOp : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL s_signed : STD_LOGIC;
  SIGNAL s_addSub : STD_LOGIC;
  SIGNAL s_shiftType : STD_LOGIC;
  SIGNAL s_shiftDir : STD_LOGIC;
  SIGNAL s_branch : STD_LOGIC;
  SIGNAL s_lui : STD_LOGIC;
  SIGNAL s_ctlExt : STD_LOGIC;

  --ALU SIGNALS
  SIGNAL s_zero : STD_LOGIC;
  SIGNAL s_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_ALUBranch : STD_LOGIC;

  --FetchLogic Signals
  SIGNAL s_ra : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_nextPC : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00400000"; -- Starts at 0x00400000

  --MEM SIGNALS
  SIGNAL s_memResult : STD_LOGIC;

  --AND SIGNALS
  SIGNAL s_branchAnd : STD_LOGIC;

  --MUX SIGNALS
  SIGNAL s_branchMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_jumpMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_RegDMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_ALUMemMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
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
    addr => s_IMemAddr(11 DOWNTO 2), -- Address to write data
    data => iInstExt, -- Input Data
    we => iInstLd, -- Instruction Write Enable
    q => s_Inst); -- Next Instruction

  DMem : mem
  GENERIC MAP(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  PORT MAP(
    clk => iCLK,
    addr => s_DMemAddr(11 DOWNTO 2), -- from alu
    data => s_DMemData, -- from register
    we => s_DMemWr, -- from control
    q => s_DMemOut);
  -- TODO: Implement the rest of your processor below this comment!
  G_MUX_REGDST : mux2t1_N
  PORT MAP(
    i_S => s_RegDst, -- RegDst bit from Control
    i_D0 => s_Inst(20 DOWNTO 16),
    i_D1 => s_Inst(15 DOWNTO 11),
    o_O => s_RegWrAddr); -- 

  G_REG : MIPSregister
  GENERIC MAP(N => 32) -- Generic of type integer for input/output data width. Default value is 32.
  PORT MAP(
    i_SEL => s_RegWrAddr, -- selection bits from RegDst MUX -- TODO ()
    i_clk => iCLK, -- clk bit
    i_rst => iRST, -- reset bit
    i_we => s_RegWr, -- write enable from Control
    i_d => s_RegWrData, -- 32 bits of data for register from Memory/ALU MUX
    i_rs => s_Inst(25 DOWNTO 21), -- read selction bit for mux
    i_rt => s_Inst(20 DOWNTO 16), -- read selction bit for mux
    o_OUT1 => s_rs, -- output of write
    o_OUT2 => s_rt); -- output of write

  s_DMemData <= s_rt;

  G_CTL : control
  PORT MAP(
    i_inst => iInstAddr, -- TODO (I think this is wrong, should we set s_Inst to start equal to iInstAddr)
    o_RegWrite => s_RegWr,
    o_memToReg => s_memToReg,
    o_memWrite => s_DMemWr,
    o_ALUSrc => s_ALUSrc,
    o_ALUOp => s_ALUOp,
    o_signed => s_signed,
    o_addSub => s_addSub,
    o_shiftType => s_shiftType,
    o_shiftDir => s_shiftDir,
    o_bne => s_bne,
    o_beq => s_beq,
    o_j => s_j,
    o_jr => s_jr,
    o_jal => s_jal,
    o_branch => s_branch,
    o_jump => s_jump,
    o_lui => s_lui,
    o_halt => s_Halt,
    o_ctlExt => s_ctlExt);

  G_ALU : alu
  PORT MAP(
    i_RS => s_rs,
    i_RT => s_rt,
    i_Imm => s_Inst(15 DOWNTO 0),
    i_ALUOp => s_ALUOp,
    i_ALUSrc => s_ALUSrc,
    i_bne => s_bne,
    i_beq => s_beq,
    i_shiftDir => s_shiftDir,
    i_shiftType => s_shiftType,
    i_shamt => s_Inst(10 DOWNTO 6),
    i_addSub => s_addSub,
    i_signed => s_signed,
    i_lui => s_lui,
    o_result => oALUOut, -- Intructions say to connect this here  -- TODO 
    o_overflow => s_Ovfl,
    o_branch => s_ALUBranch);

  s_result <= oALUOut; -- ALU result signal that is used for other components
  s_DMemAddr <= oALUOut;

  G_FETCHLOGIC : fetchLogic
  PORT MAP(
    i_inst => s_Inst, -- Instruction input                 -- TODO
    i_PC => s_nextPC, -- PC Address input
    i_clk => iCLK, -- clock bit
    i_rst => iRST, -- reset bit
    i_zero => s_zero, -- zero bit from ALU
    i_branch => s_branch, -- branch bit from control
    i_jump => s_jump, -- jump bit from ALU
    i_jr => s_jr, -- jump return bit from ALU
    i_jal => s_jal, -- jump and link bit from ALU
    o_ra => s_ra, -- Output for $ra Address                
    o_newPC => s_nextPC); -- Output for PC Address    

  G_MUX_ALU_MEM : mux2t1_N
  PORT MAP(
    i_S => s_memToReg, -- selection bit from Control
    i_D0 => s_memResult, -- Memory data from MEM
    i_D1 => s_result, -- ALU data from ALU
    o_O => s_RegWrData); -- Data output to Register Data Input

  oALUOut <= s_DMemAddr; -- final assignment

END structure;