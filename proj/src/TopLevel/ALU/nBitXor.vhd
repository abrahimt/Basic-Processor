-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitXor.vhd
-- n-Bit XOR module to perform bitwise XOR operation on multiple input bits.
-------------------------------------------------------------------------

LIBRARY IEEE; -- Library declaration for IEEE standard
USE IEEE.std_logic_1164.ALL; -- Importing standard logic data types

ENTITY nBitXor IS -- Entity declaration for the nBitXor module
    PORT (
        i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port i_A for first operand
        i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port i_B for second operand
        o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port o_F for result
    );

END nBitXor; -- End of entity declaration

ARCHITECTURE structure OF nBitXor IS -- Architecture declaration for the structural modeling

    COMPONENT xorg2 IS -- Component declaration for the xorg2 (XOR gate) module
        PORT (
            i_A : IN STD_LOGIC; -- Input port i_A for the XOR gate
            i_B : IN STD_LOGIC; -- Input port i_B for the XOR gate
            o_F : OUT STD_LOGIC -- Output port o_F for the XOR gate result
        );
    END COMPONENT;

BEGIN
    G_NBit_XOR : FOR i IN 0 TO 31 GENERATE -- Generate loop for bitwise XOR operation on each bit position

        NBitXor : xorg2 -- Instance of the xorg2 (XOR gate) component for each bit position
        PORT MAP(
            i_A => i_A(i), -- Connecting input bit from i_A
            i_B => i_B(i), -- Connecting input bit from i_B
            o_F => o_F(i) -- Connecting output bit to o_F
        );

    END GENERATE G_NBit_XOR; -- End of generate loop

END structure; -- End of architecture declaration