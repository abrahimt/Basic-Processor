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
        i_clk : IN STD_LOGIC;
        i_rst : IN STD_LOGIC;
        i_bne : IN STD_LOGIC;
        i_beq : IN STD_LOGIC;
        i_j : IN STD_LOGIC;
        i_jr : IN STD_LOGIC;
        i_jal : IN STD_LOGIC;
        i_ALUO : IN STD_LOGIC;
        o_pJPC : IN STD_LOGIC;
        o_nAddr : IN STD_LOGIC);

    ARCHITECTURE behavioral OF fetchLogic IS

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

        COMPONENT extendSign IS
            PORT (
                i_sign : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                o_sign : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
        END COMPONENT;

        COMPONENT shift IS
            PORT (
                i_In : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
        END COMPONENT;

        COMPONENT addToStart IS
            PORT (
                i_jBits : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
                i_PCb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
                o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
        END COMPONENT;

        COMPONENT addToEnd IS
            PORT (
                i_In : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
                o_Out : OUT STD_LOGIC_VECTOR(27 DOWNTO 0));
        END COMPONENT;

        SIGNAL const4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000004";
        SIGNAL const1 : STD_LOGIC := '1';
        SIGNAL reset : STD_LOGIC := '0';
        SIGNAL update, brUpdate : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
        SIGNAL newAddr, pcIncrement, selAddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL brFin, brShift, brExt : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL leave, brSelect : STD_LOGIC;
        SIGNAL jSelect : STD_LOGIC;
        SIGNAL jMUX, jFin : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL jAddToEnd : STD_LOGIC_VECTOR(27 DOWNTO 0);

    BEGIN

        -- Instantiate PC register
        PC : pcRegister
        PORT MAP(
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => const1,
            i_D => selAddr,
            o_Q => newAddr);

        PROCESS (i_clk)
        BEGIN
            IF rising_edge(i_clk) THEN
                IF reset = '1' THEN
                    -- Reinstantiate PC register
                    PC : pcRegister
                    PORT MAP(
                        i_CLK => i_clk,
                        i_RST => i_rst,
                        i_WE => const1,
                        i_D => selAddr,
                        o_Q => newAddr
                    );
                ELSE
                    -- Calculate branch selection
                    brSelect <= (i_brEQ OR i_ALUO);

                    -- Handle different instructions
                    IF i_j = '1' THEN
                        -- Change PC address to the jump address
                    
                    ELSIF i_jal = '1' THEN
                        
                        o_pJPC <= o_pJPC + 8; -- PC + 8 for jal instruction
                    ELSIF i_jr = '1' THEN
                        -- Change PC address to the jump return address
                        o_nAddr <= o_pJPC; -- o_pJPC holds the jump return address
                    ELSIF i_bne = '1' THEN
                        -- Change PC address based on branch condition
                        o_nAddr <= brUpdate; -- Assuming brUpdate holds the branch address
                    ELSIF i_beq = '1' THEN
                        -- Change PC address based on branch condition
                        o_nAddr <= brUpdate; -- Assuming brUpdate holds the branch address
                    ELSE
                        -- Default behavior: Increment PC by 4
                        INCREMENT_PC : nBitAdder
                        PORT MAP(
                            in_A => const4,
                            in_B => newAddr,
                            in_C => reset,
                            out_S => pcIncrement,
                            out_C => leave
                        );
                        o_nAddr <= pcIncrement;
                        o_pJPC <= o_pJPC; -- No change in PC + 4 for non-branch instructions
                    END IF;
                END IF;
            END IF;
        END PROCESS;

    END PROCESS;