LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY dffg IS

  PORT (
    i_CLK : IN STD_LOGIC; -- Clock input
    i_RST : IN STD_LOGIC; -- Reset input
    i_WE : IN STD_LOGIC; -- Write enable input
    i_D : IN STD_LOGIC; -- Data value input
    o_Q : OUT STD_LOGIC); -- Data value output

END dffg;

ARCHITECTURE mixed OF dffg IS
  SIGNAL s_D : STD_LOGIC; -- Multiplexed input to the FF
  SIGNAL s_Q : STD_LOGIC; -- Output of the FF

BEGIN

  -- The output of the FF is fixed to s_Q
  o_Q <= s_Q;

  -- Create a multiplexed input to the FF based on i_WE
  WITH i_WE SELECT
    s_D <= i_D WHEN '1',
    s_Q WHEN OTHERS;

  -- This process handles the asyncrhonous reset and
  -- synchronous write. We want to be able to reset 
  -- our processor's registers so that we minimize
  -- glitchy behavior on startup.
  PROCESS (i_CLK)
  BEGIN
    IF (i_RST = '1' AND rising_edge(i_CLK)) THEN
      s_Q <= '0'; -- Use "(others => '0')" for N-bit values
    ELSIF (rising_edge(i_CLK)) THEN
      s_Q <= s_D;
    END IF;

  END PROCESS;

END mixed;