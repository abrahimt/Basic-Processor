-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitOr.vhd
-- n-Bit OR module to perform bitwise OR operation on multiple input bits.
-------------------------------------------------------------------------

LIBRARY IEEE; -- Library declaration for IEEE standard
USE IEEE.std_logic_1164.ALL; -- Importing standard logic data types

ENTITY nBitOr IS -- Entity declaration for the nBitOr module
    PORT (
        i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port i_A for first operand
        i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input port i_B for second operand
        o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Output port o_F for result
    );

END nBitOr; -- End of entity declaration

ARCHITECTURE structure OF nBitOr IS -- Architecture declaration for the structural modeling

    COMPONENT org2 IS -- Component declaration for the org2 (OR gate) module
        PORT (
            i_A : IN STD_LOGIC; -- Input port i_A for the OR gate
            i_B : IN STD_LOGIC; -- Input port i_B for the OR gate
            o_F : OUT STD_LOGIC -- Output port o_F for the OR gate result
        );
    END COMPONENT;

BEGIN
    G_NBit_OR : FOR i IN 0 TO 31 GENERATE -- Generate loop for bitwise OR operation on each bit position

        NBitOR : org2 -- Instance of the org2 (OR gate) component for each bit position
        PORT MAP(
            i_A => i_A(i), -- Connecting input bit from i_A
            i_B => i_B(i), -- Connecting input bit from i_B
            o_F => o_F(i) -- Connecting output bit to o_F
        );

    END GENERATE G_NBit_OR; -- End of generate loop

END structure; -- End of architecture declaration