-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitAnd.vhd
-- To be used by the ALU for and & andi operations
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY nBitAnd IS
       PORT (
              i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input A, 32-bit vector
              i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input B, 32-bit vector
              o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Output F, 32-bit vector
END nBitAnd;

ARCHITECTURE structure OF nBitAnd IS

       -- Declare a component named andg2
       COMPONENT andg2 IS
              PORT (
                     i_A : IN STD_LOGIC; -- Input A, single bit
                     i_B : IN STD_LOGIC; -- Input B, single bit
                     o_F : OUT STD_LOGIC); -- Output F, single bit
       END COMPONENT;

BEGIN
       -- Generate logic for 32-bit AND operation
       G_NBit_AND : FOR i IN 0 TO 31 GENERATE

              -- Instantiate andg2 component for each bit
              NBitAnd : andg2
              PORT MAP(
                     i_A => i_A(i), -- Connect the i-th bit of input A
                     i_B => i_B(i), -- Connect the i-th bit of input B
                     o_F => o_F(i)); -- Connect the i-th bit of output F

       END GENERATE G_NBit_AND;

END structure;