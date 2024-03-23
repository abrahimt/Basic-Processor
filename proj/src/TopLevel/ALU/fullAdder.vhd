-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- fullAdder.vhd
-- Full Adder module to compute the sum and carry-out for three input bits.
-------------------------------------------------------------------------

LIBRARY IEEE; -- Library declaration for IEEE standard
USE IEEE.std_logic_1164.ALL; -- Importing standard logic data types

ENTITY fullAdder IS -- Entity declaration for the full adder module
    PORT (
        A, B, C : IN STD_LOGIC; -- Input ports A, B, and C (carry-in)
        o_S, o_C : OUT STD_LOGIC -- Output ports o_S (sum) and o_C (carry-out)
    );

END fullAdder; -- End of entity declaration

ARCHITECTURE structure OF fullAdder IS

    COMPONENT andg2
        PORT (
            i_A : IN STD_LOGIC; -- Input A for AND gate
            i_B : IN STD_LOGIC; -- Input B for AND gate
            o_F : OUT STD_LOGIC -- Output F of the AND gate
        );
    END COMPONENT;

    COMPONENT org2
        PORT (
            i_A : IN STD_LOGIC; -- Input A for OR gate
            i_B : IN STD_LOGIC; -- Input B for OR gate
            o_F : OUT STD_LOGIC -- Output F of the OR gate
        );
    END COMPONENT;

    COMPONENT xorg2
        PORT (
            i_A : IN STD_LOGIC; -- Input A for XOR gate
            i_B : IN STD_LOGIC; -- Input B for XOR gate
            o_F : OUT STD_LOGIC -- Output F of the XOR gate
        );
    END COMPONENT;

    -- signals for internal gate outputs
    SIGNAL a_xor_b, a_and_b, c_and_a_xor_b : STD_LOGIC; -- Internal signals for XOR, AND, and OR gate outputs

BEGIN

    --To compute the sum value
    XOR1 : xorg2
    PORT MAP(
        i_A => A, -- Connect input A to the first XOR gate
        i_B => B, -- Connect input B to the first XOR gate
        o_F => a_xor_b); -- Connect output of the first XOR gate to a_xor_b signal

    XOR2 : xorg2
    PORT MAP(
        i_A => a_xor_b, -- Connect output of first XOR gate to second XOR gate
        i_B => C, -- Connect input C (carry-in) to the second XOR gate
        o_F => o_S); -- Connect output of the second XOR gate to the sum output port o_S

    --To compute the carry-out value
    AND1 : andg2
    PORT MAP(
        i_A => A, -- Connect input A to the first AND gate
        i_B => B, -- Connect input B to the first AND gate
        o_F => a_and_b); -- Connect output of the first AND gate to a_and_b signal

    AND2 : andg2
    PORT MAP(
        i_A => C, -- Connect input C (carry-in) to the second AND gate
        i_B => a_xor_b, -- Connect output of first XOR gate to second AND gate
        o_F => c_and_a_xor_b); -- Connect output of the second AND gate to c_and_a_xor_b signal

    OR1 : org2
    PORT MAP(
        i_A => a_and_b, -- Connect output of first AND gate to OR gate
        i_B => c_and_a_xor_b, -- Connect output of second AND gate to OR gate
        o_F => o_C); -- Connect output of the OR gate to the carry-out output port o_C

END structure;