------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381
-- Iowa State University
-- 3/14/24
------------------------------------------------------------
-- fetchLogic.vhd
------------------------------------------------------------
-- This program implements the basic fetch function (PC + 4)
-- that we used in the original fetch.vhd file along with
-- the addition of jump and branch instructions

-- Unlike the old version this one uses if else statements
-- to make it easier to understand
------------------------------------------------------------

-- Non-Control Flow: In this scenario, the program counter (PC) is incremented by 4, indicating sequential execution of instructions.
-- Jump (j): The PC is set to the value specified by JumpAddr, which is calculated as { PC+4[31:28], address, 2’b0 }.
-- Jump Register (jr): The PC is set to the value stored in register R[rs].
-- Jump and Link (jal): This instruction involves two steps:
-- R[31] is set to PC + 8.
-- PC is set to the value specified by JumpAddr.
-- Branch on Equal (beq): If the contents of registers R[rs] and R[rt] are equal, the PC is updated using the formula PC = PC + 4 + BranchAddr.
-- Branch Not Equal (bne): If the contents of registers R[rs] and R[rt] are not equal, the PC is updated using the formula PC = PC + 4 + BranchAddr.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY fetchLogic IS
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
END ENTITY fetchLogic;

ARCHITECTURE structural OF fetchLogic IS

    COMPONENT nBitAdder IS
        GENERIC (N : INTEGER := 32); -- use generics for a multiple bit input/output
        PORT (
            in_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            in_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            in_C : IN STD_LOGIC;
            out_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            out_C : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT pcRegister IS
        PORT (
            i_CLK : IN STD_LOGIC; -- Clock input
            i_RST : IN STD_LOGIC; -- Reset input
            i_WE : IN STD_LOGIC; -- Write enable input
            i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data value input
            o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Data value output
    END COMPONENT;

    COMPONENT jump IS
        PORT (
            i_CLK : IN STD_LOGIC; -- Clock input
            i_rst : IN STD_LOGIC; -- Reset input
            i_jr : IN STD_LOGIC; -- Jump Register input
            i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- RS Register data
            i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- PC + 4 [31 - 28]
            i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Jump Instruction Input
            o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Jump Address Output
    END COMPONENT;

    COMPONENT branch IS
        PORT (
            i_CLK : IN STD_LOGIC; -- Clock input
            i_rst : IN STD_LOGIC; -- Reset input
            i_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- PC + 4 [31 - 28]
            i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- branch Instruction Input
            o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- branch Address Output
    END COMPONENT;

    COMPONENT andg2 IS
        PORT (
            i_A : IN STD_LOGIC;
            i_B : IN STD_LOGIC;
            o_F : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT mux2t1_N IS
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_D1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    SIGNAL carry1 : STD_LOGIC := '0'; -- Carry bit for first adder
    SIGNAL carry2 : STD_LOGIC := '0'; -- Carry bit for second adder
    SIGNAL RA : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_rPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_jPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_bPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_PC4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_muxBranch : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_muxJump : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_muxJAL : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_muxJR : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_branch : STD_LOGIC;
BEGIN

    RESET : pcRegister
	port map(
		i_CLK => i_CLK,   -- Clock input
         	i_rst => i_rst,   -- Reset input
        	i_WE =>  '0',     -- Write enable input
         	i_D => i_PC,      -- Data value input
         	o_Q => s_rPC);    -- Data value output

    -- Change PC address to the jump address
    JUMP1 : jump
    PORT MAP(
        i_CLK => i_clk,
        i_rst => i_rst,
        i_jr => i_jr,
        i_rs => i_rs,
        i_PC => i_PC,
        i_Data => i_inst,
        o_Q => s_jPC);

    -- Save PC address for jr
    -- Change PC address to the jump address
    G_ADD : nBitAdder
    PORT MAP(
        in_A => i_PC, -- PC Address
        in_B => x"00000004", -- four
        in_C => carry1, -- Carry Bit
        out_S => RA, -- PC Address Plus 4
        out_C => carry1); -- Carry Bit Output

    G_BRANCH : branch
    PORT MAP(
        i_CLK => i_clk,
        i_rst => i_rst,
        i_PC => i_PC, -- PC Address
        i_Data => i_inst, -- Instruction Address
        o_Q => s_bPC); -- New PC Address

    -- Default behavior: Increment PC by 4
    INCREMENT_PC : nBitAdder
    PORT MAP(
        in_A => x"00000004", -- Four
        in_B => i_PC, -- PC Address
        in_C => carry2, -- carry in
        out_S => s_PC4, -- PC + 4
        out_C => carry2); -- carry out

    G_AND : andg2
    PORT MAP(
        i_A => i_zero,
        i_B => i_branch,
        o_F => s_branch);

    -- Handle different instructions

    G_MUX_BRANCH : mux2t1_N
    PORT MAP(
        i_S => i_branch,
        i_D0 => s_PC4,
        i_D1 => s_bPC,
        o_O => s_muxBranch); -- outputs PC + 4 or branch address

    G_MUX_JUMP : mux2t1_N
    PORT MAP(
        i_S => i_jump,
        i_D0 => s_muxBranch,
        i_D1 => s_jPC,
        o_O => s_muxJump); -- outputs PC + 4 or branch address or jump address

    G_MUX_JAL1 : mux2t1_N
    PORT MAP(
        i_S => i_jal,
        i_D0 => s_muxJump,
        i_D1 => s_jPC,
        o_O => s_muxJAL); -- outputs PC + 4 or branch address or jump address or JAL address

    G_MUX_JR : mux2t1_N
    PORT MAP(
        i_S => i_jr,
        i_D0 => s_muxJAL,
        i_D1 => s_jPC,
        o_O => s_muxJR); -- outputs PC + 4 or branch address or jump address or JAL address or JR address

    G_MUX_RESET : mux2t1_N
    PORT MAP(
        i_S => i_rst,
        i_D0 => s_muxJR,
        i_D1 => s_rPC,
        o_O => o_newPC); -- outputs PC + 4 or branch address or jump address or JAL address or JR address or resets if rst = 1

    G_MUX_JAL2 : mux2t1_N
    PORT MAP(
        i_S => i_jal,
        i_D0 => RA,
        i_D1 => x"00000000",
        o_O => o_ra); -- outputs PC + 4 or branch address or jump address or resets if rst = 1
END structural;