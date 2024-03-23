-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitAddSub.vhd
-- Module for performing n-bit addition/subtraction with overflow detection.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY nBitAddSub IS
  GENERIC (
    N : INTEGER := 32 -- Default value for the input/output data width is 32
  );
  PORT (
    input_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Input vector A
    input_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Input vector B
    nAdd_Sub : IN STD_LOGIC; -- Control signal for addition/subtraction
    output_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Output vector for sum/difference
    output_C : OUT STD_LOGIC; -- Output carry for addition
    o_Overflow : OUT STD_LOGIC -- Overflow flag for addition/subtraction
  );
END nBitAddSub;

ARCHITECTURE structure OF nBitAddSub IS
  COMPONENT mux2t1_N IS
    PORT (
      i_S : IN STD_LOGIC;
      i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT onesComp IS
    PORT (
      i_Num : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_Num : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT nBitAdder IS
    PORT (
      in_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      in_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      in_C : IN STD_LOGIC;
      out_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      out_C : OUT STD_LOGIC;
      o_Overflow : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT xorg2 IS
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL notB : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Complement of input B
  SIGNAL muxResult : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Result from the multiplexer

BEGIN

  -- Generate the one's complement of input B
  N_Bit_Inv : onesComp
  PORT MAP(
    i_Num => input_B,
    o_Num => notB
  );

  -- Perform the addition/subtraction based on the control signal
  N_Bit_Mux : mux2t1_N
  PORT MAP(
    i_S => nAdd_Sub,
    i_D0 => input_B,
    i_D1 => notB,
    o_O => muxResult
  );

  N_Bit_Adder : nBitAdder
  PORT MAP(
    in_A => input_A,
    in_B => muxResult,
    in_C => nAdd_Sub,
    out_S => output_S,
    out_C => output_C,
    o_Overflow => o_Overflow
  );

END structure;