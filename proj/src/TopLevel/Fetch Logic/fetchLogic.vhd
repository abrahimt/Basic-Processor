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
        i_bne : IN STD_LOGIC; -- branch not equal bit
        i_beq : IN STD_LOGIC; -- branch equal bit
        i_j : IN STD_LOGIC; -- jump bit
        i_jr : IN STD_LOGIC; -- jump return bit
        i_jal : IN STD_LOGIC; -- jump and link bit
        i_ALUO : IN STD_LOGIC; -- 
        o_pJPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output for $ra Address
        o_newPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Output for PC Address
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

    COMPONENT mux2t1_N IS
        GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
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

    SIGNAL carry1 : STD_LOGIC := '0'; -- Carry bit for first adder
    SIGNAL carry2 : STD_LOGIC := '0'; -- Carry bit for second adder
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL update, brUpdate : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL newAddr, selAddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL brFin, brShift, brExt : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL brSelect : STD_LOGIC;
    SIGNAL jSelect : STD_LOGIC;
    SIGNAL jMUX, jFin : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL jAddToEnd : STD_LOGIC_VECTOR(27 DOWNTO 0);

BEGIN

    -- Instantiate PC register
    PC : pcRegister
    PORT MAP(
        i_CLK => i_clk,
        i_RST => i_rst,
        i_WE => '1',
        i_D => x"00000000", -- 0x00000000
        o_Q => o_newPC); -- 0x00400000

    PROCESS (i_clk)
    BEGIN
        IF rising_edge(i_clk) THEN
            IF reset = '1' THEN
                -- If we are reseting PC should be 0x00400000
                -- Reinstantiate PC register
                PC : pcRegister
                PORT MAP(
                    i_CLK => i_clk,
                    i_RST => i_rst,
                    i_WE => '1',
                    i_D => x"00000000", -- 0x00000000,
                    o_Q => o_newPC); -- 0x00400000

            ELSE
                -- TODO
                -- Calculate branch selection
                brSelect <= (i_brEQ OR i_ALUO);

                -- Handle different instructions

                IF i_j = '1' THEN
                    -- Change PC address to the jump address
                    JUMP : jump
                    PORT MAP(
                        i_CLK => i_clk,
                        i_rst => i_rst,
                        i_PC => i_PC,
                        i_Data => i_inst,
                        o_Q => o_newPC);

                ELSIF i_jal = '1' THEN
                    -- Save PC address for jr
                    -- Change PC address to the jump address
                    G_ADD : nBitAdder
                    PORT MAP(
                        in_A => i_PC, -- PC Address
                        in_B => x"00000008", -- Eight
                        in_C => carry1, -- Carry Bit
                        out_S => o_pJPC, -- PC Address Plus 4
                        out_C => carry1); -- Carry Bit Output
                    JAL : jump
                    PORT MAP(
                        i_CLK => i_clk,
                        i_rst => i_rst,
                        i_PC => i_PC, -- PC Address
                        i_Data => i_inst, -- Instruction Address
                        o_Q => o_newPC); -- New PC Address

                ELSIF i_jr = '1' THEN
                    -- Change PC address to the jump return address
                    o_newPC <= o_pJPC; -- o_pJPC holds the jump return address

                ELSIF i_bne = '1' THEN
                    -- TODO
                    -- Change PC address based on branch condition
                    BNE : branch
                    PORT MAP(
                        i_CLK => i_clk,
                        i_rst => i_rst,
                        i_PC => i_PC, -- PC Address
                        i_Data => i_inst, -- Instruction Address
                        o_Q => o_newPC); -- New PC Address

                ELSIF i_beq = '1' THEN
                    -- TODO
                    -- Change PC address based on branch condition
                    BEQ : branch
                    PORT MAP(
                        i_CLK => i_clk,
                        i_rst => i_rst,
                        i_PC => i_PC, -- PC Address
                        i_Data => i_inst, -- Instruction Address
                        o_Q => o_newPC); -- New PC Address

                ELSE
                    -- Default behavior: Increment PC by 4
                    INCREMENT_PC : nBitAdder
                    PORT MAP(
                        in_A => x"00000004", -- Four
                        in_B => i_PC, -- PC Address
                        in_C => carry2, -- carry in
                        out_S => o_newPC, -- PC + 4
                        out_C => carry2); -- carry out
                END IF;

            END IF;

        END IF;

    END PROCESS;

END structural;