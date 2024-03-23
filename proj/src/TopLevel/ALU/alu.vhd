-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- alu.vhd
-- Used to perform operations based on the particular instruction
-------------------------------------------------------------------------

LIBRARY IEEE; -- Library declaration for IEEE standard
USE IEEE.std_logic_1164.ALL; -- Importing standard logic data types

ENTITY alu IS -- Entity declaration for the ALU module
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
END alu; -- End of entity declaration

ARCHITECTURE structure OF alu IS -- Architecture declaration for the structural modeling

    -- Component declarations for various submodules used in the ALU

    COMPONENT nBitAddSub IS
        PORT (
            input_A, input_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input ports for operands A and B
            nAdd_Sub : IN STD_LOGIC; -- Input port for add/subtract operation
            output_S : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output port for result
            output_C : OUT STD_LOGIC; -- Output port for carry-out
            o_Overflow : OUT STD_LOGIC -- Output port for overflow flag
        );
    END COMPONENT;

    COMPONENT nBitOr IS
        PORT (
            i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand A
            i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand B
            o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port for result
        );
    END COMPONENT;

    COMPONENT nBitAnd IS
        PORT (
            i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand A
            i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand B
            o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port for result
        );
    END COMPONENT;

    COMPONENT nBitNor IS
        PORT (
            i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand A
            i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand B
            o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port for result
        );
    END COMPONENT;

    COMPONENT nBitXor IS
        PORT (
            i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand A
            i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand B
            o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port for result
        );
    END COMPONENT;

    COMPONENT setLessThan IS
        PORT (
            i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand A
            i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand B
            o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port for result
        );
    END COMPONENT;

    COMPONENT branch IS
        PORT (
            i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand A
            i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for operand B
            i_beq : IN STD_LOGIC; -- Input port for branch if equal
            i_bne : IN STD_LOGIC; -- Input port for branch if not equal
            o_branchFlag : OUT STD_LOGIC -- Output port for branch flag
        );
    END COMPONENT;

    COMPONENT Barrel_Shifter IS
        PORT (
            i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Input port for shift amount
            i_sign : IN STD_LOGIC; -- Input port for sign bit
            i_leftShift : IN STD_LOGIC; -- Input port for left shift operation
            i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for data to be shifted
            o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port for shifted data
        );
    END COMPONENT;

    COMPONENT mux2t1_N IS
        PORT (
            i_S : IN STD_LOGIC; -- Input port for select signal
            i_D0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for data 0
            i_D1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for data 1
            o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port for selected data
        );
    END COMPONENT;

    COMPONENT mux2t1_5bit IS
        PORT (
            i_S : IN STD_LOGIC; -- Input port for select signal
            i_D0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Input port for data 0 (5 bits)
            i_D1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Input port for data 1 (5 bits)
            o_O : OUT STD_LOGIC_VECTOR(4 DOWNTO 0) -- Output port for selected data (5 bits)
        );
    END COMPONENT;

    COMPONENT andg2 IS
        PORT (
            i_A : IN STD_LOGIC; -- Input port A for AND gate
            i_B : IN STD_LOGIC; -- Input port B for AND gate
            o_F : OUT STD_LOGIC -- Output port for result
        );
    END COMPONENT;

    COMPONENT xorg2 IS
        PORT (
            i_A : IN STD_LOGIC; -- Input port A for XOR gate
            i_B : IN STD_LOGIC; -- Input port B for XOR gate
            o_F : OUT STD_LOGIC -- Output port for result
        );
    END COMPONENT;

    -- Driven by the ALUOp control signal, this module will decide what operation is output by ALU
    COMPONENT selectOperation IS
        PORT (
            i_ALUOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input port for ALU operation code
            i_orResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for OR operation result
            i_andResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for AND operation result
            i_xorResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for XOR operation result
            i_norResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for NOR operation result
            i_sltResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for SLT operation result
            i_addSubResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for ADD/SUB operation result
            i_shiftResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port for shift operation result
            o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port for ALU result
        );
    END COMPONENT;

    -- Signals Declaration
    SIGNAL s_Operand : STD_LOGIC_VECTOR(31 DOWNTO 0); -- either RS or Immediate
    SIGNAL s_orResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_andResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_xorResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_norResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_addSubResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_addSubCarry : STD_LOGIC;
    SIGNAL s_sltResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_shiftResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_barrelShiftSign : STD_LOGIC;
    SIGNAL s_MSB : STD_LOGIC;
    SIGNAL s_overflowDetected : STD_LOGIC;
    SIGNAL s_constShamt : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10000";
    SIGNAL s_shamt : STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN
    s_MSB <= s_addSubResult(31);

    -- Process to determine the value of the sign port in the barrel shifter
    PROCESS (i_RT, i_shiftType)
    BEGIN
        IF i_RT(31) = '1' AND i_shiftType = '1' THEN
            s_barrelShiftSign <= '1'; -- Set the barrel shifter sign to 1 for arithmetic shift
        ELSE
            s_barrelShiftSign <= '0'; -- Set the barrel shifter sign to 0 for logical shift
        END IF;
    END PROCESS;

    -- Multiplexers and Submodules Instantiation

    -- Mux to select between ALUSrc and RT/Immediate
    G_MUX_IMM : mux2t1_N
    PORT MAP(
        i_S => i_ALUSrc, -- ALUSrc control signal
        i_D0 => i_RT, -- RT input
        i_D1 => i_Imm, -- Immediate input
        o_O => s_Operand); -- Output selected operand

    -- Mux to select between LUI Shift Amount and Constant Shift Amount
    G_MUX_LUI : mux2t1_5bit
    PORT MAP(
        i_S => i_lui, -- LUI control signal
        i_D0 => i_shamt, -- Shift amount for LUI instruction
        i_D1 => s_constShamt, -- Constant shift amount for other instructions
        o_O => s_shamt); -- Output selected shift amount

    -- OR gate operation
    G_OR : nBitOr
    PORT MAP(
        i_A => i_RS, -- Input A for OR gate
        i_B => s_Operand, -- Input B for OR gate
        o_F => s_orResult); -- Output of the OR gate

    -- AND gate operation
    G_AND : nBitAnd
    PORT MAP(
        i_A => i_RS, -- Input A for AND gate
        i_B => s_Operand, -- Input B for AND gate
        o_F => s_andResult); -- Output of the AND gate

    -- XOR gate operation
    G_XOR : nBitXor
    PORT MAP(
        i_A => i_RS, -- Input A for XOR gate
        i_B => s_Operand, -- Input B for XOR gate
        o_F => s_xorResult); -- Output of the XOR gate  (RT) 

    -- NOR gate operation
    G_NOR : nBitNor
    PORT MAP(
        i_A => i_RS, -- Input A for NOR gate
        i_B => s_Operand, -- Input B for NOR gate
        o_F => s_norResult); -- Output of the NOR gate

    -- SLT (Set Less Than) operation
    G_SLT : setLessThan
    PORT MAP(
        i_A => i_RS, -- Input A for SLT operation
        i_B => s_Operand, -- Input B for SLT operation
        o_F => s_sltResult); -- Output of the SLT operation

    -- Add/Subtract operation
    G_ADDSUB : nBitAddSub
    PORT MAP(
        input_A => i_RS, -- Input A for Add/Subtract operation
        input_B => s_Operand, -- Input B for Add/Subtract operation
        nAdd_Sub => i_addSub, -- Control signal for Add/Subtract
        output_S => s_addSubResult, -- Output of Add/Subtract operation
        output_C => s_addSubCarry, -- Carry output of Add/Subtract operation
        o_Overflow => s_overflowDetected); -- Overflow signal from Add/Subtract operation

    -- Overflow detection and setting the overflow output
    G_OVERFLOWAND : andg2
    PORT MAP(
        i_A => s_overflowDetected, -- Overflow detected signal
        i_B => i_signed, -- Signed operation control signal
        o_F => o_overflow); -- Output overflow signal

    -- Barrel shifter operation
    G_SHIFT : Barrel_Shifter
    PORT MAP(
        i_shamt => s_shamt, -- Shift amount input to barrel shifter
        i_sign => s_barrelShiftSign, -- Sign input to barrel shifter
        i_leftShift => i_shiftDir, -- Direction of shift (left or right)
        i_D => s_Operand, -- Data input to barrel shifter
        o_O => s_shiftResult); -- Output of barrel shifter operation

    -- Branch operation
    G_BRANCH : branch
    PORT MAP(
        i_A => i_RS, -- Input A for branch operation
        i_B => s_Operand, -- Input B for branch operation
        i_bne => i_bne, -- Control signal for branch not equal
        i_beq => i_beq, -- Control signal for branch equal
        o_branchFlag => o_branch); -- Output branch flag

    -- Selecting the ALU operation based on the ALUOp control signal
    G_SELECT : selectOperation
    PORT MAP(
        i_ALUOp => i_ALUOp, -- ALU operation code
        i_orResult => s_orResult, -- OR operation result
        i_andResult => s_andResult, -- AND operation result
        i_xorResult => s_xorResult, -- XOR operation result
        i_norResult => s_norResult, -- NOR operation result
        i_sltResult => s_sltResult, -- SLT operation result
        i_addSubResult => s_addSubResult, -- Add/Subtract operation result
        i_shiftResult => s_shiftResult, -- Shift operation result
        o_result => o_result); -- ALU output result	    
END structure;