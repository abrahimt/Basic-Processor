------------------------------------------------------------
-- Mitchell Driscoll
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
------------------------------------------------------------
-- jump.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY PipelineShift IS
    PORT (
        i_clk : IN STD_LOGIC; -- Clock input
        i_rst : IN STD_LOGIC; -- Reset input
        i_PC4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- PC + 4 [31 - 0]
        i_imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Branch Instruction Input [15-0]
        o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Jump Address Output
END PipelineShift;

ARCHITECTURE structural OF PipelineShift IS

    COMPONENT nBitAdder IS
        GENERIC (N : INTEGER := 32); -- use generics for a multiple bit input/output
        PORT (
            in_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            in_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            in_C : IN STD_LOGIC;
            out_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            out_C : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT shift IS
        PORT (
            i_In : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    SIGNAL s_immShifted : STD_LOGIC_VECTOR(31 DOWNTO 0); -- i_Data [15-0]
    SIGNAL carry1 : STD_LOGIC; -- signal for carry of adder

BEGIN

    G_SHIFT : shift
    PORT MAP(
        i_IN => i_imm, -- Sign Extended branch address
        o_Out => s_immShifted); -- Shifted left 2 branch address

    G_ADD2 : nbitAdder
    PORT MAP(
    in_A => i_PC4,
    in_B => s_immShifted,
    in_C => '0',
    out_S => o_Q,
    out_C => carry1);

END structural;