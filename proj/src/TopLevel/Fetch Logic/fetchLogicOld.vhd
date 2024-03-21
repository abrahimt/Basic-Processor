------------------------------------------------------------
-- Abrahim Toutoungi
-- CPRE 381
-- Iowa State University
-- 3/14/24
------------------------------------------------------------
-- fetchLogic.vhd
------------------------------------------------------------
-- This program implements the basic fetch function (PC + 4)
-- that we used in the original fetch.vhd file along with
-- the addition of jump and branch instructions
------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fetchLogic IS
   PORT (
      i_CLK : IN STD_LOGIC;
      i_RST : IN STD_LOGIC;
      i_j : IN STD_LOGIC;
      i_jal : IN STD_LOGIC;
      i_jReg : IN STD_LOGIC;
      i_jRetReg : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_brEQ : IN STD_LOGIC;
      i_brNE : IN STD_LOGIC;
      i_ALU0 : IN STD_LOGIC;
      i_pInst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_nAddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_pJPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END fetchLogic;

ARCHITECTURE structure OF fetchLogic IS

   COMPONENT nBitAdder IS
      GENERIC (N : INTEGER := 32); -- use generics for a multiple bit input/output
      PORT (
         in_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
         in_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
         in_C : IN STD_LOGIC;
         out_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
         out_C : OUT STD_LOGIC);
   END COMPONENT;

   COMPONENT mux2t1_N IS
      GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
      PORT (
         i_S : IN STD_LOGIC;
         i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
         i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
         o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
   END COMPONENT;

   COMPONENT pcRegister IS
      PORT (
         i_CLK : IN STD_LOGIC; -- Clock input
         i_RST : IN STD_LOGIC; -- Reset input
         i_WE : IN STD_LOGIC; -- Write enable input
         i_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data value input
         o_Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Data value output
   END COMPONENT;

   COMPONENT extendSign IS
      PORT (
         i_sign : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         o_sign : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
   END COMPONENT;

   COMPONENT shift IS
      PORT (
         i_In : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
   END COMPONENT;

   COMPONENT addToStart IS
      PORT (
         i_jBits : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
         i_PCb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
   END COMPONENT;

   COMPONENT addToEnd IS
      PORT (
         i_In : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
         o_Out : OUT STD_LOGIC_VECTOR(27 DOWNTO 0));
   END COMPONENT;

   SIGNAL const4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000004";
   SIGNAL const1 : STD_LOGIC := '1';
   SIGNAL reset : STD_LOGIC := '0';
   SIGNAL update, brUpdate : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
   SIGNAL newAddr, pcIncrement, selAddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL brFin, brShift, brExt : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL leave, brSelect : STD_LOGIC;
   SIGNAL jSelect : STD_LOGIC;
   SIGNAL jMUX, jFin : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL jAddToEnd : STD_LOGIC_VECTOR(27 DOWNTO 0);

BEGIN
   -- Calculate branch selection
   brSelect <= ((i_ALU0 AND i_brEQ) OR (i_ALU0 AND i_brNE));

   -- Instantiate PC register
   PC : pcRegister
   PORT MAP(
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE => const1,
      i_D => selAddr,
      o_Q => newAddr);

   -- Increment PC by 4
   INCREMENT_PC : nBitAdder
   PORT MAP(
      in_A => const4,
      in_B => newAddr,
      in_C => reset,
      out_S => pcIncrement,
      out_C => leave);

   -- Extend the sign for branch calculation
   BRANCH_EXTEND : extendSign
   PORT MAP(
      i_sign => i_pInst(15 DOWNTO 0),
      o_sign => brExt);

   -- Shift the extended sign for branch calculation
   BRANCH_SHIFT : shift
   PORT MAP(
      i_In => brExt,
      o_Out => brShift);

   -- Calculate branch address
   BRANCH_CALCULATE : nBitAdder
   PORT MAP(
      in_A => brShift,
      in_B => pcIncrement,
      in_C => reset,
      out_S => brFin,
      out_C => leave);

   -- Select between PC increment and branch address
   BRANCH_SELECT : mux2t1_N
   GENERIC MAP(N => 32)
   PORT MAP(
      i_S => brSelect,
      i_D0 => pcIncrement,
      i_D1 => brFin,
      o_O => brUpdate);

   -- Add to end for jump calculation
   JUMP_ADDTOEND : addToEnd
   PORT MAP(
      i_In => i_pInst(25 DOWNTO 0),
      o_Out => jAddToEnd);

   -- Add to start for jump calculation
   JUMP_ADDTOSTART : addToStart
   PORT MAP(
      i_jBits => jAddToEnd,
      i_PCb => pcIncrement(31 DOWNTO 28),
      o_Out => jFin);

   -- Select between branch update and jump address
   JUMP_SELECT : mux2t1_N
   GENERIC MAP(N => 32)
   PORT MAP(
      i_S => i_j,
      i_D0 => brUpdate,
      i_D1 => jFin,
      o_O => jMUX);

   -- Select between jump register and jump return register
   RA_SELECT : mux2t1_N
   GENERIC MAP(N => 32)
   PORT MAP(
      i_S => i_jReg,
      i_D0 => jMUX,
      i_D1 => i_jRetReg,
      o_O => selAddr);

   -- Output new address and PC + 4
   o_nAddr <= newAddr;
   o_pJPC <= pcIncrement;

END structure;