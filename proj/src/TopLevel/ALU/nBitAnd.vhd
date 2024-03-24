--Abrahim Toutoungi
--3/17/2024
--nBitAnd.vhd
--To be used by the ALU for and & andi operations

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY nBitAnd IS
       PORT (
              i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
              i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
              o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END nBitAnd;

ARCHITECTURE structure OF nBitAnd IS

       COMPONENT andg2 IS
              PORT (
                     i_A : IN STD_LOGIC;
                     i_B : IN STD_LOGIC;
                     o_F : OUT STD_LOGIC);
       END COMPONENT;

BEGIN
       G_NBit_AND : FOR i IN 0 TO 31 GENERATE

              NBitAnd : andg2
              PORT MAP(
                     i_A => i_A(i),
                     i_B => i_B(i),
                     o_F => o_F(i));

       END GENERATE G_NBit_AND;