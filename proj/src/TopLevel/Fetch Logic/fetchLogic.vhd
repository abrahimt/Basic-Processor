 ------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381 
-- Iowa State University 
-- 2/29/2023
------------------------------------------------------------
-- fetchLogic.vhd
------------------------------------------------------------
-- This program implements the basic fetch function (PC + 4)
-- along with the addition of jump and branch instructions.
------------------------------------------------------------

-- Fetch logic takes an instruction from memory (using the PC) and then returns a 32 bit version of the instruction 
-- in other words, the fetch logic disassembles instructions for the control logic to use

--  Non-Control Flow- PC = PC + 4
--  Jump- j ; PC = JumpAddr
--  Jump Register- jr ; PC = R[rs]
--  Jump and Link- jal ; R[31] = PC + 8 ; PC = JumpAddr
--  Branch Equal- beq ;
--  if(R[rs] == R[rt])
--    PC =PC+4+BranchAddr
--  Branch Not Equal- bne ;
--  if(R[rs] != R[rt])
--    PC =PC+4+BranchAddr


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity fetchLogic is 
   port(i_clk      : in std_logic; -- clock input
        i_reset    : in std_logic; -- reset input
        i_j        : in std_logic; -- jump input
        i_jal      : in std_logic; -- jump and link input
        i_jReg     : in std_logic; -- jump register input
        i_jRetReg  : in std_logic_vector(31 downto 0); -- jump return register
        i_brEQ     : in std_logic; -- branch equals input
        i_brNE     : in std_logic; -- branch not equals input
        i_ALU0     : in std_logic; -- ALU zero input
        i_pInst    : in std_logic_vector(31 downto 0); -- program instruction input
        o_nAddr    : out std_logic_vector(31 downto 0)); -- n Adder output
end fetchLogic;

architecture structure of fetchLogic is

    -- Component declarations

    component nBitAdder is
        generic(N : integer := 32); --use generics for a multiple bit input/output
        port(in_A        : in std_logic_vector(N-1 downto 0); -- Input A
             in_B        : in std_logic_vector(N-1 downto 0); -- Input B
             in_C        : in std_logic;                    -- Input C (carry-in)
             out_S       : out std_logic_vector(N-1 downto 0); -- Output sum
             out_C       : out std_logic);                   -- Output carry
    end component;

    component mux2t1_N is
        generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_S          : in std_logic; -- Select input
             i_D0         : in std_logic_vector(N-1 downto 0); -- Input data 0
             i_D1         : in std_logic_vector(N-1 downto 0); -- Input data 1
             o_O          : out std_logic_vector(N-1 downto 0)); -- Output data
    end component; 

    component pcRegister is 
        port(i_clk        : in std_logic;                          -- Clock input
             i_reset      : in std_logic;                          -- Reset input
             i_WE         : in std_logic;                          -- Write enable input
             i_D          : in std_logic_vector(31 downto 0);     -- Data value input
             o_Q          : out std_logic_vector(31 downto 0));   -- Data value output
    end component;

    component extendSign is
        port(i_sign   : in std_logic_vector(15 downto 0); -- Input sign (16-bit)
             o_sign   : out std_logic_vector(31 downto 0)); -- Output sign (32-bit)
    end component; 

    component shift is
        port(i_In     : in std_logic_vector(31 downto 0); -- Input data
             o_Out    : out std_logic_vector(31 downto 0)); -- Output data
    end component; 

    component addToStart is
        port(i_jBits  : in std_logic_vector(27 downto 0); -- Input bits (28-bit)
             i_PCb     : in std_logic_vector(3 downto 0); -- Input PC bits (4-bit)
             o_Out     : out std_logic_vector(31 downto 0)); -- Output data (32-bit)
    end component; 

    component addToEnd is
        port(i_In     : in std_logic_vector(25 downto 0); -- Input data (26-bit)
             o_Out    : out std_logic_vector(27 downto 0)); -- Output data (28-bit)
    end component; 

    -- Signals declaration

    signal s_const4       : std_logic_vector(31 downto 0) := x"00000004"; -- Constant 4
    signal s_const1       : std_logic := '1'; -- Constant 1
    signal s_reset        : std_logic := '0'; -- Reset signal
    signal update, brUpdate     : std_logic_vector(31 downto 0) := x"00000000"; -- Update signals
    signal newAddr, pcIncrement, selAddr : std_logic_vector(31 downto 0); -- Addresses
    signal brFin, brShift, brExt   : std_logic_vector(31 downto 0); -- Branch related signals
    signal leave, brSelect : std_logic; -- Control signals
    signal jSelect      : std_logic; -- Jump control signal
    signal jMUX, jFin   : std_logic_vector(31 downto 0); -- Jump related signals
    signal jAddToEnd   : std_logic_vector(27 downto 0); -- Jump address related signal

begin 

    -- Control logic for selecting between branch and jump addresses
    brSelect <= ((i_ALU0 and i_brEQ) or (i_ALU0 and i_brNE));

    -- Register for storing the program counter value
    PC: pcRegister
        port map(i_clk        => i_clk,
                 i_reset      => i_reset,
                 i_WE         => s_const1,
                 i_D          => selAddr,
                 o_Q          => newAddr);
   
    -- Increment PC by 4
    INCREMENT_PC: nBitAdder
        port map(in_A  => s_const4,
                 in_B  => newAddr,   
                 in_C  => s_reset,   
                 out_S => pcIncrement,  
                 out_C => leave); 

    -- Extend the sign of branch instructions
    BRANCH_EXTEND: extendSign
        port map(i_sign => i_pInst(15 downto 0),
                 o_sign => brExt);

    -- Shift branch instructions
    BRANCH_SHIFT: shift
        port map(i_In  => brExt,
                 o_Out => brShift);

    -- Calculate branch address
    BRANCH_CALCULATE: nBitAdder
        port map(in_A  => brShift,
                 in_B  => pcIncrement,  
                 in_C  => s_reset,   
                 out_S => brFin,  
                 out_C => leave); 

    -- Select between default and branch address
    BRANCH_SELECT: mux2t1_N
        generic map(N => 32)
        port map(i_S  => brSelect,
                 i_D0 => pcIncrement,
                 i_D1 => brFin,
                 o_O  => brUpdate);

    -- Add lower bits of jump instruction to the end of the PC
    JUMP_ADDTOEND: addToEnd
        port map(i_In  => i_pInst(25 downto 0),
                 o_Out => jAddToEnd);

    -- Add upper bits of jump instruction to the start of the PC
    JUMP_ADDTOSTART: addToStart
        port map(i_jBits => jAddToEnd, 
                 i_PCb    => pcIncrement(31 downto 28),
                 o_Out    => jFin);
    
    -- Select between branch and jump address
    JUMP_SELECT: mux2t1_N
        generic map(N => 32)
        port map(i_S  => i_j,
                 i_D0 => brUpdate,
                 i_D1 => jFin,
                 o_O  => jMUX);

    -- Select between jump address and register address
    RA_SELECT: mux2t1_N
        generic map(N => 32)
        port map(i_S  => i_jReg,
                 i_D0 => jMUX,
                 i_D1 => i_jRetReg,
                 o_O  => selAddr);

    -- Output next address
    o_nAddr  <=  newAddr;

end structure;
