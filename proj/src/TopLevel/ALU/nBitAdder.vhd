-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitAdder.vhd
-- n-Bit Adder module to compute the sum and carry-out for multiple input bits.
-------------------------------------------------------------------------

LIBRARY IEEE; -- Library declaration for IEEE standard
USE IEEE.std_logic_1164.ALL; -- Importing standard logic data types

ENTITY nBitAdder IS -- Entity declaration for the nBitAdder module
  GENERIC (
    N : INTEGER := 32 -- Generic parameter for the number of bits in the input/output
  );

  PORT (
    in_A, in_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Input ports in_A and in_B
    in_C : IN STD_LOGIC; -- Input port in_C for carry-in
    out_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Output port out_S for sum
    out_C : OUT STD_LOGIC; -- Output port out_C for carry-out
    o_Overflow : OUT STD_LOGIC -- Output port o_Overflow for overflow detection
  );

END nBitAdder; -- End of entity declaration

ARCHITECTURE structure OF nBitAdder IS -- Architecture declaration for the structural modeling

  COMPONENT fullAdder -- Component declaration for the fullAdder module
    PORT (
      A : IN STD_LOGIC; -- Input port A for the full adder
      B : IN STD_LOGIC; -- Input port B for the full adder
      C : IN STD_LOGIC; -- Input port C for the full adder
      o_C : OUT STD_LOGIC; -- Output port o_C for carry-out
      o_S : OUT STD_LOGIC -- Output port o_S for sum
    );
  END COMPONENT;

  -- Signals for carry-in and carry-out values
  SIGNAL s_Carry : STD_LOGIC_VECTOR(N - 1 DOWNTO 1); -- Signal for internal carry propagation

BEGIN
  -- Overflow detection logic based on the MSB of inputs and carry-out
  o_Overflow <= (in_A(N - 1) AND in_B(N - 1) AND NOT(s_Carry(N - 1))) OR
    ((NOT in_A(N - 1)) AND (NOT in_B(N - 1)) AND s_Carry(N - 1));

  -- Separate fullAdder instance for the first bit to utilize the carry-in input
  ADDI : fullAdder PORT MAP(
    A => in_A(0),
    B => in_B(0),
    C => in_C,
    o_C => s_Carry(1),
    o_S => out_S(0));

  -- Generate n-2 fullAdder instances for the remaining bits
  G_NBit_Adder : FOR i IN 1 TO N - 2 GENERATE
    ADDI1 : fullAdder PORT MAP(
      A => in_A(i),
      B => in_B(i),
      C => s_Carry(i),
      o_C => s_Carry(i + 1),
      o_S => out_S(i));
  END GENERATE G_NBit_Adder;

  -- Separate fullAdder instance for the final bit to utilize the carry-out output
  ADDI2 : fullAdder PORT MAP(
    A => in_A(N - 1),
    B => in_B(N - 1),
    C => s_Carry(N - 1),
    o_C => out_C,
    o_S => out_S(N - 1));

END structure; -- End of architecture declaration