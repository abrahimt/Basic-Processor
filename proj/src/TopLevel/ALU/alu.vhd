-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- alu.vhd
-- Used to perform operations based on the particular instruction
-------------------------------------------------------------------------

library IEEE; -- Library declaration for IEEE standard
use IEEE.std_logic_1164.all; -- Importing standard logic data types

entity alu is -- Entity declaration for the ALU module
   port(
      i_RS, i_RT     : in std_logic_vector(31 downto 0); -- Input ports for operands
      i_Imm          : in std_logic_vector(31 downto 0); -- Input port for immediate value
      i_ALUOp        : in std_logic_vector(3 downto 0);  -- Input port for ALU operation code
      i_ALUSrc       : in std_logic;                     -- Input port for ALU source selection
      i_bne          : in std_logic;                     -- Input port for branch if not equal
      i_beq          : in std_logic;                     -- Input port for branch if equal
      i_shiftDir     : in std_logic;                     -- Input port for shift direction
      i_shiftType    : in std_logic;                     -- Input port for shift type
      i_shamt        : in std_logic_vector(4 downto 0);  -- Input port for shift amount
      i_addSub       : in std_logic;                     -- Input port for add/subtract operation
      i_signed       : in std_logic;                     -- Input port for signed operation
      i_lui          : in std_logic;                     -- Input port for load upper immediate
      o_result       : out std_logic_vector(31 downto 0); -- Output port for result
      o_overflow     : out std_logic;                     -- Output port for overflow flag
      o_branch       : out std_logic                      -- Output port for branch signal
   );  
end alu; -- End of entity declaration

architecture structure of alu is -- Architecture declaration for the structural modeling

-- Component declarations for various submodules used in the ALU

component nBitAddSub is 
  port(
      input_A, input_B  : in std_logic_vector(31 downto 0); -- Input ports for operands A and B
      nAdd_Sub         : in std_logic;                    -- Input port for add/subtract operation
      output_S         : out std_logic_vector(31 downto 0); -- Output port for result
      output_C         : out std_logic;                    -- Output port for carry-out
      o_Overflow       : out std_logic                     -- Output port for overflow flag
   );
end component;

component nBitOr is 
  port(
      i_A          : in std_logic_vector(31 downto 0); -- Input port for operand A
      i_B          : in std_logic_vector(31 downto 0); -- Input port for operand B
      o_F          : out std_logic_vector(31 downto 0) -- Output port for result
   );
end component;

component nBitAnd is 
  port(
      i_A          : in std_logic_vector(31 downto 0); -- Input port for operand A
      i_B          : in std_logic_vector(31 downto 0); -- Input port for operand B
      o_F          : out std_logic_vector(31 downto 0) -- Output port for result
   );
end component;

component nBitNor is 
  port(
      i_A          : in std_logic_vector(31 downto 0); -- Input port for operand A
      i_B          : in std_logic_vector(31 downto 0); -- Input port for operand B
      o_F          : out std_logic_vector(31 downto 0) -- Output port for result
   );
end component;

component nBitXor is 
  port(
      i_A          : in std_logic_vector(31 downto 0); -- Input port for operand A
      i_B          : in std_logic_vector(31 downto 0); -- Input port for operand B
      o_F          : out std_logic_vector(31 downto 0) -- Output port for result
   );
end component;

component setLessThan is 
  port(
      i_A          : in std_logic_vector(31 downto 0); -- Input port for operand A
      i_B          : in std_logic_vector(31 downto 0); -- Input port for operand B
      o_F          : out std_logic_vector(31 downto 0) -- Output port for result
   );
end component;

component branch is 
  port(
      i_A          : in std_logic_vector(31 downto 0); -- Input port for operand A
      i_B          : in std_logic_vector(31 downto 0); -- Input port for operand B
      i_beq        : in std_logic;                    -- Input port for branch if equal
      i_bne        : in std_logic;                    -- Input port for branch if not equal
      o_branchFlag : out std_logic                     -- Output port for branch flag
   );
end component;

component Barrel_Shifter is 
  port(
      i_shamt     : in std_logic_vector(4 downto 0); -- Input port for shift amount
      i_sign      : in std_logic;                    -- Input port for sign bit
      i_leftShift : in std_logic;                    -- Input port for left shift operation
      i_D         : in std_logic_vector(31 downto 0); -- Input port for data to be shifted
      o_O         : out std_logic_vector(31 downto 0) -- Output port for shifted data
   );
end component;

component mux2t1_N is 
  port(
      i_S          : in std_logic;                    -- Input port for select signal
      i_D0         : in std_logic_vector(31 downto 0); -- Input port for data 0
      i_D1         : in std_logic_vector(31 downto 0); -- Input port for data 1
      o_O          : out std_logic_vector(31 downto 0) -- Output port for selected data
   );
end component;

component mux2t1_5bit is 
  port(
      i_S          : in std_logic;                    -- Input port for select signal
      i_D0         : in std_logic_vector(4 downto 0); -- Input port for data 0 (5 bits)
      i_D1         : in std_logic_vector(4 downto 0); -- Input port for data 1 (5 bits)
      o_O          : out std_logic_vector(4 downto 0) -- Output port for selected data (5 bits)
   );
end component;

component andg2 is 
  port(
      i_A          : in std_logic;                    -- Input port A for AND gate
      i_B          : in std_logic;                    -- Input port B for AND gate
      o_F          : out std_logic                   -- Output port for result
   );
end component;

component xorg2 is 
  port(
      i_A          : in std_logic;                    -- Input port A for XOR gate
      i_B          : in std_logic;                    -- Input port B for XOR gate
      o_F          : out std_logic                   -- Output port for result
   );
end component;

-- Driven by the ALUOp control signal, this module will decide what operation is output by ALU
component selectOperation is 
    port(
        i_ALUOp         : in std_logic_vector(3 downto 0); -- Input port for ALU operation code
	i_orResult      : in std_logic_vector(31 downto 0); -- Input port for OR operation result
	i_andResult     : in std_logic_vector(31 downto 0); -- Input port for AND operation result
 	i_xorResult     : in std_logic_vector(31 downto 0); -- Input port for XOR operation result
 	i_norResult     : in std_logic_vector(31 downto 0); -- Input port for NOR operation result
 	i_sltResult     : in std_logic_vector(31 downto 0); -- Input port for SLT operation result
 	i_addSubResult  : in std_logic_vector(31 downto 0); -- Input port for ADD/SUB operation result
 	i_shiftResult   : in std_logic_vector(31 downto 0); -- Input port for shift operation result
 	o_result        : out std_logic_vector(31 downto 0) -- Output port for ALU result
    );
end component;

-- Signals Declaration
signal s_Operand          : std_logic_vector(31 downto 0); -- either RS or Immediate
signal s_orResult         : std_logic_vector(31 downto 0);
signal s_andResult        : std_logic_vector(31 downto 0);
signal s_xorResult        : std_logic_vector(31 downto 0);
signal s_norResult        : std_logic_vector(31 downto 0);
signal s_addSubResult     : std_logic_vector(31 downto 0);
signal s_addSubCarry      : std_logic;
signal s_sltResult        : std_logic_vector(31 downto 0);
signal s_shiftResult      : std_logic_vector(31 downto 0);
signal s_barrelShiftSign  : std_logic;
signal s_MSB              : std_logic;
signal s_overflowDetected : std_logic;
signal s_constShamt       : std_logic_vector(4 downto 0)   := "10000";
signal s_shamt            : std_logic_vector(4 downto 0);

begin 
s_MSB <=  s_addSubResult(31);

-- Process to determine the value of the sign port in the barrel shifter
process(i_RT, i_shiftType)
begin
    if i_RT(31) = '1' and i_shiftType = '1' then
        s_barrelShiftSign <= '1'; 		-- Set the barrel shifter sign to 1 for arithmetic shift
    else 
        s_barrelShiftSign <= '0'; 		-- Set the barrel shifter sign to 0 for logical shift
    end if;
end process;



-- Multiplexers and Submodules Instantiation

-- Mux to select between ALUSrc and RT/Immediate
G_MUX_IMM: mux2t1_N
    port map(i_S   => i_ALUSrc, 		-- ALUSrc control signal
	     i_D0  => i_RT, 			-- RT input
	     i_D1  => i_Imm, 			-- Immediate input
	     o_O   => s_Operand); 		-- Output selected operand

-- Mux to select between LUI Shift Amount and Constant Shift Amount
G_MUX_LUI: mux2t1_5bit
    port map(i_S   => i_lui, 			-- LUI control signal
	     i_D0  => i_shamt, 			-- Shift amount for LUI instruction
	     i_D1  => s_constShamt,		-- Constant shift amount for other instructions
	     o_O   => s_shamt); 		-- Output selected shift amount

-- OR gate operation
G_OR: nBitOr
    port map(i_A   => i_RS, 			-- Input A for OR gate
	     i_B   => s_Operand, 		-- Input B for OR gate
	     o_F   => s_orResult); 		-- Output of the OR gate

-- AND gate operation
G_AND: nBitAnd
    port map(i_A   => i_RS, 			-- Input A for AND gate
	     i_B   => s_Operand, 		-- Input B for AND gate
	     o_F   => s_andResult); 		-- Output of the AND gate

-- XOR gate operation
G_XOR: nBitXor
    port map(i_A   => i_RS, 			-- Input A for XOR gate
	     i_B   => s_Operand, 		-- Input B for XOR gate
	     o_F   => s_xorResult); 		-- Output of the XOR gate  (RT) 

-- NOR gate operation
G_NOR: nBitNor
    port map(i_A   => i_RS, 			-- Input A for NOR gate
	     i_B   => s_Operand, 		-- Input B for NOR gate
	     o_F   => s_norResult);		-- Output of the NOR gate

-- SLT (Set Less Than) operation
G_SLT: setLessThan
    port map(i_A   => i_RS, 			-- Input A for SLT operation
	     i_B   => s_Operand, 		-- Input B for SLT operation
	     o_F   => s_sltResult); 		-- Output of the SLT operation

-- Add/Subtract operation
G_ADDSUB: nBitAddSub
    port map(input_A   => i_RS, 		-- Input A for Add/Subtract operation
	     input_B   => s_Operand, 		-- Input B for Add/Subtract operation
	     nAdd_Sub  => i_addSub, 		-- Control signal for Add/Subtract
	     output_S  => s_addSubResult, 	-- Output of Add/Subtract operation
	     output_C  => s_addSubCarry, 	-- Carry output of Add/Subtract operation
	    o_Overflow => s_overflowDetected); 	-- Overflow signal from Add/Subtract operation

-- Overflow detection and setting the overflow output
G_OVERFLOWAND: andg2
    port map(i_A  => s_overflowDetected, 	-- Overflow detected signal
	     i_B  => i_signed, 			-- Signed operation control signal
	     o_F  => o_overflow); 		-- Output overflow signal

-- Barrel shifter operation
G_SHIFT: Barrel_Shifter
    port map(i_shamt      => s_shamt, 		-- Shift amount input to barrel shifter
	     i_sign       => s_barrelShiftSign, -- Sign input to barrel shifter
	     i_leftShift  => i_shiftDir, 	-- Direction of shift (left or right)
	     i_D          => s_Operand, 	-- Data input to barrel shifter
	     o_O          => s_shiftResult); 	-- Output of barrel shifter operation

-- Branch operation
G_BRANCH: branch 
    port map(i_A  	   => i_RS, 		-- Input A for branch operation
	     i_B  	   => s_Operand, 	-- Input B for branch operation
	     i_bne  	   => i_bne, 		-- Control signal for branch not equal
	     i_beq  	   => i_beq, 		-- Control signal for branch equal
	     o_branchFlag  => o_branch); 	-- Output branch flag

-- Selecting the ALU operation based on the ALUOp control signal
G_SELECT: selectOperation
    port map(i_ALUOp        => i_ALUOp, 	-- ALU operation code
	     i_orResult     => s_orResult, 	-- OR operation result
	     i_andResult    => s_andResult, 	-- AND operation result
	     i_xorResult    => s_xorResult, 	-- XOR operation result
	     i_norResult    => s_norResult, 	-- NOR operation result
	     i_sltResult    => s_sltResult, 	-- SLT operation result
	     i_addSubResult => s_addSubResult, 	-- Add/Subtract operation result
	     i_shiftResult  => s_shiftResult, 	-- Shift operation result
	     o_result       => o_result); 	-- ALU output result	    
end structure;
