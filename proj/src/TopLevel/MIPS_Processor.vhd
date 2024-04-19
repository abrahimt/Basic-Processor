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
      o_extendBy : OUT STD_LOGIC;
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
      o_zero : OUT STD_LOGIC -- Output port for branch signal
    );
  END COMPONENT;

  COMPONENT MIPSregister
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
  COMPONENT Extender IS
    PORT (
      i_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      i_S : IN STD_LOGIC;
      o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
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

  COMPONENT pcRegister IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_clk : IN STD_LOGIC; -- clk bit
      i_rst : IN STD_LOGIC; -- reset bit
      i_we : IN STD_LOGIC; -- write enable
      i_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bits of data for register
      o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of write
  END COMPONENT;

  -- NEW FOR PIPELINE --

  COMPONENT Fetch_Decode_Reg IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_clk : IN STD_LOGIC; -- clk bit
      i_rst : IN STD_LOGIC; -- reset bit
      i_we : IN STD_LOGIC; -- write enable
      i_Inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit instruction register
      i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC + 4 data
      o_PCOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of PC4
      o_InstOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of Inst
  END COMPONENT;

  COMPONENT Decode_Execute_Reg IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_clk : IN STD_LOGIC; -- clk bit
      i_rst : IN STD_LOGIC; -- reset bit
      i_we : IN STD_LOGIC; -- write enable
      i_memWrite : IN STD_LOGIC; -- Goes to Dmem
      i_MemToReg : IN STD_LOGIC; -- Goes to Write Back		
      i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Goes to ALU
      i_ALUSrc : IN STD_LOGIC; -- Goes to ALU
      i_bne : IN STD_LOGIC; -- Goes to ALU
      i_beq : IN STD_LOGIC; -- Goes to ALU
      i_shiftDir : IN STD_LOGIC; -- Goes to ALU
      i_shiftType : IN STD_LOGIC; -- Goes to ALU
      i_addSub : IN STD_LOGIC; -- Goes to ALU
      i_signed : IN STD_LOGIC; -- Goes to ALU
      i_lui : IN STD_LOGIC; -- Goes to ALU
      i_jump : IN STD_LOGIC; -- Goes to Fetch
      i_jal : IN STD_LOGIC; -- Goes to Write Back
      i_jr : IN STD_LOGIC; -- Goes to Fetch
      i_branch : IN STD_LOGIC; -- Goes to Fetch
      i_RSReg : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit instruction register
      i_RTReg : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC + 4 data
      i_Imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC + 4 data
      i_rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 25-21)
      i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 20-16)
      i_rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 15-11)
      i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 10-6)
      i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_memWrite : OUT STD_LOGIC; -- Goes to Dmem
      o_MemToReg : OUT STD_LOGIC; -- Goes to Write Back	
      o_ALUOp : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      o_ALUSrc : OUT STD_LOGIC;
      o_bne : OUT STD_LOGIC;
      o_beq : OUT STD_LOGIC;
      o_shiftDir : OUT STD_LOGIC;
      o_shiftType : OUT STD_LOGIC;
      o_addSub : OUT STD_LOGIC;
      o_signed : OUT STD_LOGIC;
      o_lui : OUT STD_LOGIC;
      o_jump : OUT STD_LOGIC; -- Goes to Fetch
      o_jal : OUT STD_LOGIC; -- Goes to Write Back
      o_jr : OUT STD_LOGIC; -- Goes to Fetch
      o_branch : OUT STD_LOGIC; -- Goes to Fetch
      o_RSDataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit instruction register out
      o_RTDataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC + 4 data out 
      o_ImmOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit PC + 4 data out
      o_rsOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 25-21) out
      o_rtOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 20-16) out
      o_rdOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bits (inst 15-11) out
      o_shamt : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)); -- 5 bits (inst 10-6) out
  END COMPONENT;

  COMPONENT Execute_Memory_Reg IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_clk : IN STD_LOGIC; -- clk bit
      i_rst : IN STD_LOGIC; -- reset bit
      i_we : IN STD_LOGIC; -- write enable
      i_memWrite : IN STD_LOGIC; -- Goes to Dmem
      i_jal : IN STD_LOGIC; -- Goes to Write Back
      i_MemToReg : IN STD_LOGIC; -- Goes to Write Back
      i_ALUResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit ALU Result
      i_DmemData : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit Dmem Data
      i_ra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_nextPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_nextPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_ra : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_memWrite : OUT STD_LOGIC; -- Goes to Dmem
      o_jal : OUT STD_LOGIC; -- Goes to Write Back
      o_MemToReg : OUT STD_LOGIC; -- Goes to Write Back
      o_ALUResultOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of ALU Result
      o_DmemDataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of Dmem Data Input
  END COMPONENT;

  COMPONENT Memory_WriteBack_Reg IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_clk : IN STD_LOGIC; -- clk bit
      i_rst : IN STD_LOGIC; -- reset bit
      i_we : IN STD_LOGIC; -- write enable
      i_jal : IN STD_LOGIC; -- jal for mux
      i_MemToReg : IN STD_LOGIC; -- Goes to Write Back
      i_Dmem : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit Dmem Data 
      i_ALUResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bit ALU Result
      i_ra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_nextPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_nextPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_ra : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_MemToReg : OUT STD_LOGIC; -- Goes to Write Back
      o_jal : OUT STD_LOGIC;
      o_DmemOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of PC4
      o_ALUResultOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of Inst
  END COMPONENT;

  COMPONENT mux3t1 IS
    PORT (
      i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_select : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
  END COMPONENT;

  COMPONENT nBitAdder IS
    GENERIC (N : INTEGER := 32); -- use generics for a multiple bit input/output
    PORT (
      in_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      in_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      in_C : IN STD_LOGIC;
      out_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      out_C : OUT STD_LOGIC);
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
  SIGNAL s_NextInstAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- (PC Address that goes from PC register into Instruction Memory)
  SIGNAL s_Inst : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- (Instruction Address that goes from Instruction Memory out)

  -- Required halt signal -- for simulation
  SIGNAL s_Halt : STD_LOGIC; -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal for overflow exception detection
  SIGNAL s_Ovfl : STD_LOGIC; -- TODO: this signal indicates an overflow exception would have been initiated

  -- OUR SIGNALS

  --Register Signals
  SIGNAL s_rt : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_rs : STD_LOGIC_VECTOR(31 DOWNTO 0);

  --CONTROL SIGNALS
  SIGNAL s_bne : STD_LOGIC; -- goes to ALU
  SIGNAL s_beq : STD_LOGIC; -- goes to ALU
  SIGNAL s_jump : STD_LOGIC; -- goes to ALU
  SIGNAL s_j : STD_LOGIC; -- goes to ALU
  SIGNAL s_jal : STD_LOGIC; -- goes to ALU
  SIGNAL s_jr : STD_LOGIC; -- goes to ALU
  SIGNAL s_ALUSrc : STD_LOGIC; -- goes to ALU
  SIGNAL s_ALUOp : STD_LOGIC_VECTOR(3 DOWNTO 0); -- goes to ALU
  SIGNAL s_signed : STD_LOGIC; -- goes to ALU
  SIGNAL s_addSub : STD_LOGIC; -- goes to ALU
  SIGNAL s_lui : STD_LOGIC; -- goes to ALU
  SIGNAL s_shiftType : STD_LOGIC; -- goes to ALU
  SIGNAL s_shiftDir : STD_LOGIC; -- goes to ALU
  SIGNAL s_RegDst : STD_LOGIC; -- goes to Register File MUX
  SIGNAL s_RegWrite : STD_LOGIC; -- goes to Register File
  SIGNAL s_memToReg : STD_LOGIC; -- goes to Dmem
  SIGNAL s_memWrite : STD_LOGIC; -- goes to Dmem
  SIGNAL s_branch : STD_LOGIC; -- goes to fetch logic
  SIGNAL s_ctlExt : STD_LOGIC; -- 
  SIGNAL s_extendBy : STD_LOGIC; -- goes to extender

  -- Fetch Stage Signals
  SIGNAL s_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_PCDec : STD_LOGIC_VECTOR(31 DOWNTO 0); -- PC address from Fetch Register
  SIGNAL s_InstDec : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Instruction Address from Fetch Register
  SIGNAL s_nextInstAddrDec : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Next PC Address from Fetch Register
  SIGNAL carry1 : STD_LOGIC := '0'; -- CAUTIO

  --DECODE/EXECUTE REG SIGNALS
  SIGNAL s_ALUOpEx : STD_LOGIC_VECTOR(3 DOWNTO 0); -- goes to Execute from ID/EX register
  SIGNAL s_bneEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_beqEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_jumpEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_jalEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_jrEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_ALUSrcEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_signedEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_addSubEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_luiEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_shiftTypeEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_shiftDirEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_nextInstAddrEx : STD_LOGIC_VECTOR(31 DOWNTO 0); -- goes to Execute from ID/EX register
  SIGNAL s_memWriteEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_MemToRegEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_branchEx : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_rtEx : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_rsEx : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_shamtEx : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_rdEx : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_RSDataOut : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_RTDataOut : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_Imm32Ex : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_InstEx : STD_LOGIC_VECTOR(31 DOWNTO 0);

  --EXECUTE/MEMORY REG SIGNALS
  SIGNAL s_jalMem : STD_LOGIC;
  SIGNAL s_memWriteMem : STD_LOGIC;
  SIGNAL s_MemToRegMem : STD_LOGIC;
  SIGNAL s_resultMem : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_DmemDataOut : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_nextPCMem : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_raMem : STD_LOGIC_VECTOR(31 DOWNTO 0);

  --MEMORY/WRITEBACK REG SIGNALS
  SIGNAL s_MemToRegWB : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_jalWB : STD_LOGIC; -- goes to Execute from ID/EX register
  SIGNAL s_DmemOutWB : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_ALUResultOutWB : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_nextPCWB : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_raWB : STD_LOGIC_VECTOR(31 DOWNTO 0);

  --ALU SIGNALS
  SIGNAL s_zero : STD_LOGIC;
  SIGNAL s_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_ALUBranch : STD_LOGIC;

  --FetchLogic Signals
  SIGNAL s_ra : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_nextPC : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00400000"; -- Starts at 0x00400000
  SIGNAL s_Imm32 : STD_LOGIC_VECTOR(31 DOWNTO 0);

  --AND SIGNALS
  SIGNAL s_branchAnd : STD_LOGIC;

  --MUX SIGNALS
  SIGNAL s_branchMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_jumpMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_RegDMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_ALUMEMMUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_RegDstOrg : STD_LOGIC_VECTOR(4 DOWNTO 0);

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
    q => s_Inst); -- Next Instruction Data

  DMem : mem
  GENERIC MAP(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  PORT MAP(
    clk => iCLK,
    addr => s_DMemAddr(11 DOWNTO 2), -- from alu
    data => s_DMemData, -- from register
    we => s_DMemWr, -- from control or Ex/Mem Register
    q => s_DMemOut);
  -- TODO: Implement the rest of your processor below this comment

  -- Fetch Stage --

  -- TODO HW
  -- mux before PC Register

  PC_REG : pcRegister
  PORT MAP(
    i_clk => iCLK, -- clk bit
    i_rst => iRST, -- reset bit
    i_we => '1', -- TODO (When should write the new PC address into register)
    i_data => s_nextPC, -- Next PC Address
    o_out => s_nextInstAddr); -- Output from PC Register of Next PC Address

  -- -- Default behavior: Increment PC by 4
  -- INCREMENT_PC : nBitAdder
  -- PORT MAP(
  --     in_A => x"00000004", -- Four
  --     in_B => s_nextInstAddr, -- PC Address
  --     in_C => carry1, -- carry in
  --     out_S => s_PC4, -- PC + 4
  --     out_C => carry1); -- carry out

  IF_D : Fetch_Decode_Reg
  GENERIC MAP(N => 32) -- Generic of type integer for input/output data width. Default value is 32.
  PORT MAP(
    i_clk => iCLK, -- clk bit
    i_rst => iRST, -- reset bit
    i_we => '1', -- write enable
    i_Inst => s_Inst, -- 32 bit instruction register
    i_PC => s_nextInstAddr, -- 32 bit PC Address
    o_PCOut => s_nextInstAddrDec, -- output of PC Address
    o_InstOut => s_InstDec); -- output of Instruction Address

  -- Decode Stage --

  -- TODO
  -- Hazard Detection
  -- Additional Control Signals
  -- rs = rt
  -- implement fetchlogic correctly  

  -- G_MUX_CONTROL : mux2t1
  -- PORT MAP(
  --   i_S => , -- TODO Comes from hazard detection
  --   i_D0 => , -- TODO Comes from Control
  --   i_D1 => '0', -- TODO should be 0 but needs to be correct size
  --   o_O => s_controlMux);

  G_MUX_REGDST : mux2t1_5bit
  PORT MAP(
    i_S => s_RegDst, -- RegDst bit from Control
    i_D0 => s_InstDec(20 DOWNTO 16),
    i_D1 => s_InstDec(15 DOWNTO 11),
    o_O => s_RegDstOrg); -- 

  G_MUX_REGDST2 : mux2t1_5bit
  PORT MAP(
    i_S => s_jal, -- RegDst bit from Control
    i_D0 => s_RegDstOrg,
    i_D1 => "11111", --31
    o_O => s_RegWrAddr); -- 

  G_REG : MIPSregister
  GENERIC MAP(N => 32) -- Generic of type integer for input/output data width. Default value is 32.
  PORT MAP(
    i_SEL => s_RegWrAddr, -- Register selection bit
    i_clk => iCLK, --
    i_rst => iRST, -- 
    i_d => s_RegWrData, -- Data being written into register
    i_we => s_RegWr, -- Write Enable
    i_rs => s_InstDec(25 DOWNTO 21),
    i_rt => s_InstDec(20 DOWNTO 16),
    o_OUT1 => s_rs, -- Read 1 out
    o_OUT2 => s_rt); -- Read 2 out

  EXTEND : Extender
  PORT MAP(
    i_data => s_InstDec(15 DOWNTO 0),
    i_S => s_extendBy,
    o_out => s_Imm32);

  G_CTL : control
  PORT MAP(
    i_inst => s_InstDec,
    o_RegDst => s_RegDst,
    o_RegWrite => s_RegWr,
    o_memToReg => s_memToReg,
    o_memWrite => s_memWrite,
    o_ALUSrc => s_ALUSrc,
    o_ALUOp => s_ALUOp,
    o_signed => s_signed,
    o_extendBy => s_extendBy,
    o_addSub => s_addSub,
    o_shiftType => s_shiftType,
    o_shiftDir => s_shiftDir,
    o_bne => s_bne,
    o_beq => s_beq,
    o_j => s_j, -- DELETE THIS WE DONT USE IT -- Needs deleted from Control Module as well
    o_jr => s_jr,
    o_jal => s_jal,
    o_branch => s_branch,
    o_jump => s_jump,
    o_lui => s_lui,
    o_halt => s_Halt,
    o_ctlExt => s_ctlExt);

  D_EX : Decode_Execute_Reg
  PORT MAP(
    i_clk => iCLK, -- clk bit
    i_rst => iRST, -- reset bit
    i_we => '1', -- write enable  --TODO
    i_memWrite => s_memWrite, -- Goes to Dmem
    i_MemToReg => s_MemToReg, -- Goes to Write Back	
    i_ALUOp => s_ALUOp,
    i_ALUSrc => s_ALUSrc,
    i_bne => s_bne,
    i_beq => s_beq,
    i_shiftDir => s_shiftDir,
    i_shiftType => s_shiftType,
    i_addSub => s_addSub,
    i_signed => s_signed,
    i_lui => s_lui,
    i_jump => s_jump,
    i_jr => s_jr,
    i_jal => s_jal,
    i_branch => s_branch,
    i_RSReg => s_rs, -- 32 bit rs
    i_RTReg => s_rt, -- 32 bit rt
    i_Imm => s_Imm32, -- 32 bit PC + 4 data
    i_rs => s_InstDec(25 DOWNTO 21), -- 5 bits (inst 25-21)
    i_rt => s_InstDec(20 DOWNTO 16), -- 5 bits (inst 20-16)
    i_rd => s_InstDec(15 DOWNTO 11), -- 5 bits (inst 15-11)
    i_shamt => s_InstDec(10 DOWNTO 6), -- 5 bits (inst 10-6)
    i_PC => s_nextInstAddrDec, -- PC Address for Fetch Logic
    i_inst => s_InstDec,
    o_inst => s_InstEx,
    o_PC => s_nextInstAddrEx,
    o_ALUOp => s_ALUOpEx,
    o_ALUSrc => s_ALUSrcEx,
    o_bne => s_bneEx,
    o_beq => s_beqEx,
    o_shiftDir => s_shiftDirEx,
    o_shiftType => s_shiftTypeEx,
    o_addSub => s_addSubEx,
    o_signed => s_signedEx,
    o_lui => s_luiEx,
    o_memWrite => s_memWriteEx,
    o_MemToReg => s_MemToRegEx,
    o_jump => s_jumpEx,
    o_jal => s_jalEx,
    o_jr => s_jrEx,
    o_branch => s_branchEx,
    o_RSDataOut => s_RSDataOut, -- 32 bit instruction register out
    o_RTDataOut => s_RTDataOut, -- 32 bit PC + 4 data out 
    o_ImmOut => s_Imm32Ex, -- 32 bit PC + 4 data out
    o_rsOut => s_rsEX, -- 5 bits (inst 25-21) out
    o_rtOut => s_rtEX, -- 5 bits (inst 20-16) out
    o_rdOut => s_rdEx,
    o_shamt => s_shamtEx); -- 5 bits (inst 15-11) out

  -- EXCUTE STAGE

  -- TODO
  -- 2:1 MUX for rd & shamt
  -- install Forwarding Unit

  --  MUX1 : mux3t1
  --  port(
  --    i_A => s_RSDataOutReg,  -- id/ex rs register data
  --    i_B => s_RegWrData, -- register write back data
  --    i_C => s_result,-- ex/mem reg alu result
  --    i_select => , -- TODO from forwarding Unit
  --    o_O => s_mux1Data); -- ALU A input

  --  MUX2 : mux3t1
  --  port(
  --    i_A => s_RTDataOutReg,  -- id/ex rt register data
  --    i_B => s_RegWrData,  -- register write back data
  --    i_C => s_result,  -- ex/mem reg alu result
  --    i_select => , -- TODO from forwarding Unit
  --    o_O => s_mux2Data); -- ALU B input, also Dmem address

  G_FETCHLOGIC : fetchLogic
  PORT MAP(
    i_inst => s_InstEx, -- Instruction input from Decode Register
    i_PC => s_nextInstAddrEx, -- PC Address input from Decode Register
    i_clk => iCLK, -- clock bit
    i_rst => iRST, -- reset bit
    i_zero => s_zero, -- zero bit from ALU
    i_branch => s_branchEx, -- branch bit from control
    i_jump => s_jumpEx, -- jump bit from ALU
    i_jr => s_jrEx, -- jump return bit from ALU
    i_jal => s_jalEx, -- jump and link bit from ALU
    i_rs => s_RSDataOut, -- RS register value
    o_ra => s_ra, -- Output for $ra Address   
    o_newPC => s_nextPC); -- Output for PC Address   todo

  G_ALU : alu
  PORT MAP(
    i_RS => s_RSDataOut,
    i_RT => s_RTDataOut,
    i_Imm => s_Imm32Ex, -- 32 bit immediate value from id/ex register
    i_ALUOp => s_ALUOpEx, -- control signal from id/ex register
    i_ALUSrc => s_ALUSrcEx, -- control signal from id/ex register
    i_bne => s_bneEx, -- control signal from id/ex register
    i_beq => s_beqEx, -- control signal from id/ex register
    i_shiftDir => s_shiftDirEx, -- control signal from id/ex register
    i_shiftType => s_shiftTypeEx, -- control signal from id/ex register
    i_addSub => s_addSubEx, -- control signal from id/ex register
    i_signed => s_signedEx, -- control signal from id/ex register
    i_lui => s_luiEx, -- control signal from id/ex register
    i_shamt => s_shamtEx, -- shamt from id/ex register
    o_result => s_result, -- Intructions say to connect this here
    o_overflow => s_Ovfl,
    o_zero => s_zero);

    oALUOut <= s_result; -- ALU result signal that is used for other components

  EX_MEM : Execute_Memory_Reg
  PORT MAP(
    i_clk => iCLK, -- clk bit
    i_rst => iRST, -- reset bit
    i_we => '1', -- write enable
    i_memWrite => s_memWriteEx, -- write back input
    i_jal => s_jalEx, -- write back input
    i_MemToReg => s_MemToRegEx, -- write back input
    i_ALUResult => s_result, -- 32 bit ALU Result
    i_DmemData => s_RTDataOut, -- 32 bit Dmem Address
    i_ra => s_ra,
    i_nextPC => s_nextPC,
    o_nextPC => s_nextPCMem,
    o_ra => s_raMem,
    o_memWrite => s_memWriteMem,
    o_jal => s_jalMem, -- write back output
    o_MemToReg => s_MemToRegMem,
    o_ALUResultOut => s_resultMem, -- output of ALU Result
    o_DmemDataOut => s_DmemDataOut); -- output of Dmem Data Input

  -- MEMORY STAGE

  s_DMemWr <= s_memWriteMem; -- Write Enable for Dmem from Control
  s_DMemData <= s_DmemDataOut; -- RT Register is Dmem Data
  s_DMemAddr <= s_resultMem; -- ALU result is Data Memory Address

  MEM_WB : Memory_WriteBack_Reg
  PORT MAP(
    i_clk => iCLK, -- clk bit
    i_rst => iRST, -- reset bit
    i_we => '1', -- write enable
    i_jal => s_jalMem, -- jal for mux
    i_MemToReg => s_MemToRegMem, -- Goes to Write Back
    i_Dmem => s_DMemOut, -- 32 bit Dmem Data input
    i_ALUResult => s_resultMem, -- input of ALU result
    i_ra => s_raMem,
    i_nextPC => s_nextPCMem,
    o_nextPC => s_nextPCWB,
    o_ra => s_raWB,
    o_MemToReg => s_MemToRegWB, -- Signal for mux
    o_jal => s_jalWB, -- jal for mux
    o_DmemOut => s_DmemOutWB, -- output of Dmem Data
    o_ALUResultOut => s_ALUResultOutWB); -- output of ALU Result

  -- WRITE BACK STAGE

  G_MUX_ALU_MEM : mux2t1_N
  PORT MAP(
    i_S => s_memToReg, -- selection bit from Control
    i_D0 => s_ALUResultOutWB, -- ALU data from ALU
    i_D1 => s_DmemOutWB, -- Memory data from MEM
    o_O => s_ALUMEMMUX); -- Data output to Register Data Input

  G_MUX_JAL : mux2t1_N
  PORT MAP(
    i_S => s_jalWB, -- selection bit from Control
    i_D0 => s_ALUMEMMUX, -- ALU data from ALU
    i_D1 => s_raWB, -- Memory data from MEM
    o_O => s_RegWrData); -- Data output to Register Data Input
END structure;