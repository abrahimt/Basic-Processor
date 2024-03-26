-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- branchALU.vhd
-- Module for comparing two 32-bit vectors and setting a branch flag based on specified conditions.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY branchALU IS
  PORT (
    i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input vector A
    i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input vector B
    i_beq : IN STD_LOGIC; -- Equal comparison control signal
    i_bne : IN STD_LOGIC; -- Not equal comparison control signal
    o_zero : OUT STD_LOGIC -- Output branch flag
  );
END branchALU;

ARCHITECTURE dataflow OF branchALU IS
BEGIN

  PROCESS (i_A, i_B, i_beq, i_bne)
  BEGIN
    IF i_A = i_B AND i_beq = '1' THEN -- Check for equality condition
      o_zero <= '1';
    ELSIF i_A /= i_B AND i_bne = '1' THEN -- Check for inequality condition
      o_zero <= '1';
    ELSE -- Default condition if no match
      o_zero <= '0';
    END IF;
  END PROCESS;

END dataflow;