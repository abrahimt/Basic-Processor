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
        i_branch : in std_logic; -- branch bit from control
        i_jump : IN STD_LOGIC; -- jump bit from control
        i_jr : IN STD_LOGIC; -- jump return bit from control
        i_jal : IN STD_LOGIC; -- jump and link bit from control
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

    SIGNAL carry1 : STD_LOGIC := '0'; -- Carry bit for first adder
    SIGNAL carry2 : STD_LOGIC := '0'; -- Carry bit for second adder
    SIGNAL RA : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_jPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_jalPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_jrPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_bPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_PC4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_branch : STD_LOGIC;


BEGIN

    -- Instantiate PC register
    PC : pcRegister
    PORT MAP(
        i_CLK => i_clk,
        i_RST => i_rst,
        i_WE => '1',
        i_D => x"00000000", -- 0x00000000
        o_Q => s_PC); -- 0x00400000

    -- Change PC address to the jump address
    JUMP1 : jump
    PORT MAP(
        i_CLK => i_clk,
        i_rst => i_rst,
        i_PC => i_PC,
        i_Data => i_inst,
        o_Q => s_jPC);

    -- Save PC address for jr
    -- Change PC address to the jump address
    G_ADD : nBitAdder
    PORT MAP(
        in_A => i_PC, -- PC Address
        in_B => x"00000008", -- Eight
        in_C => carry1, -- Carry Bit
        out_S => RA, -- PC Address Plus 4
        out_C => carry1); -- Carry Bit Output

    JAL : jump
    PORT MAP(
        i_CLK => i_clk,
        i_rst => i_rst,
        i_PC => i_PC, -- PC Address
        i_Data => i_inst, -- Instruction Address
        o_Q => s_jalPC); -- New PC Address
    -- Change PC address based on branch condition

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
    port map(
        i_A => i_zero,
        i_B => i_branch,
        o_F => s_branch);

    

    PROCESS (i_clk)
    BEGIN
        IF rising_edge(i_clk) THEN
            IF i_rst = '1' THEN
                -- If we are reseting PC should be 0x00400000
                -- Reinstantiate PC register
                o_newPC <= x"00400000";

            ELSE

                -- Handle different instructions

                IF i_jump = '1' THEN
                    o_newPC <= s_jPC;

                ELSIF i_jal = '1' THEN
                    o_ra <= RA;
                    o_newPC <= s_jalPC;

                ELSIF i_jr = '1' THEN --TODO: JR functionality is wrong
                    -- Change PC address to the jump return address
                    o_newPC <= RA; -- o_ra holds the jump return address

                ELSIF s_branch = '1' THEN
                    o_newPC <= s_bPC;

                ELSE
                    o_newPC <= s_PC4;
                END IF;

            END IF;

        END IF;

    END PROCESS;


    
END structural;
