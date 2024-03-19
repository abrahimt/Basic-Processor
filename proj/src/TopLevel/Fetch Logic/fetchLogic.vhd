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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetchLogic is
   port(i_CLK     : in std_logic;
        i_RST     : in std_logic;
        i_j       : in std_logic;
        i_jal     : in std_logic;
        i_jReg    : in std_logic;
        i_jRetReg : in std_logic_vector(31 downto 0);
        i_brEQ      : in std_logic;
        i_brNE    : in std_logic;
        i_ALU0    : in std_logic;
        i_pInst   : in std_logic_vector(31 downto 0);
        o_nAddr   : out std_logic_vector(31 downto 0);
        o_pJPC    : out std_logic_vector(31 downto 0));
end fetchLogic;

architecture structure of fetchLogic is

component nBitAdder is
   generic(N : integer := 32); -- use generics for a multiple bit input/output
   port(in_A       : in std_logic_vector(N-1 downto 0);
        in_B       : in std_logic_vector(N-1 downto 0);
        in_C       : in std_logic;
        out_S      : out std_logic_vector(N-1 downto 0);
        out_C      : out std_logic);
end component;

component mux2t1_N is
   generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
   port(i_S         : in std_logic;
        i_D0        : in std_logic_vector(N-1 downto 0);
        i_D1        : in std_logic_vector(N-1 downto 0);
        o_O         : out std_logic_vector(N-1 downto 0));
end component;

component pcRegister is
   port(i_CLK        : in std_logic;                          -- Clock input
        i_RST        : in std_logic;                          -- Reset input
        i_WE         : in std_logic;                          -- Write enable input
        i_D          : in std_logic_vector(31 downto 0);     -- Data value input
        o_Q          : out std_logic_vector(31 downto 0));   -- Data value output
end component;

component extendSign is
   port(i_sign   : in std_logic_vector(15 downto 0);
        o_sign   : out std_logic_vector(31 downto 0));
end component;

component shift is
   port(i_In    : in std_logic_vector(31 downto 0);
        o_Out   : out std_logic_vector(31 downto 0));
end component;

component addToStart is
   port(i_jBits : in std_logic_vector(27 downto 0);
        i_PCb    : in std_logic_vector(3 downto 0);
        o_Out    : out std_logic_vector(31 downto 0));
end component;

component addToEnd is
   port(i_In     : in std_logic_vector(25 downto 0);
        o_Out    : out std_logic_vector(27 downto 0));
end component;

signal const4      : std_logic_vector(31 downto 0) := x"00000004";
signal const1      : std_logic := '1';
signal reset       : std_logic := '0';
signal update, brUpdate     : std_logic_vector(31 downto 0) := x"00000000";
signal newAddr, pcIncrement, selAddr : std_logic_vector(31 downto 0);
signal brFin, brShift, brExt  : std_logic_vector(31 downto 0);
signal leave, brSelect : std_logic;
signal jSelect  : std_logic;
signal jMUX, jFin  : std_logic_vector(31 downto 0);
signal jAddToEnd  : std_logic_vector(27 downto 0);

begin
   -- Calculate branch selection
   brSelect <= ((i_ALU0 and i_brEQ) or (i_ALU0 and i_brNE));

   -- Instantiate PC register
   PC: pcRegister
   port map(i_CLK  => i_CLK,
            i_RST  => i_RST,
            i_WE   => const1,
            i_D    => selAddr,
            o_Q    => newAddr);

   -- Increment PC by 4
   INCREMENT_PC: nBitAdder
   port map(in_A    => const4,
            in_B    => newAddr,
            in_C    => reset,
            out_S   => pcIncrement,
            out_C   => leave);

   -- Extend the sign for branch calculation
   BRANCH_EXTEND: extendSign
   port map(i_sign => i_pInst(15 downto 0),
            o_sign => brExt);

   -- Shift the extended sign for branch calculation
   BRANCH_SHIFT: shift
   port map(i_In    => brExt,
            o_Out   => brShift);

   -- Calculate branch address
   BRANCH_CALCULATE: nBitAdder
   port map(in_A    => brShift,
            in_B    => pcIncrement,
            in_C    => reset,
            out_S   => brFin,
            out_C   => leave);

   -- Select between PC increment and branch address
   BRANCH_SELECT: mux2t1_N
   generic map(N => 32)
   port map(i_S    => brSelect,
            i_D0   => pcIncrement,
            i_D1   => brFin,
            o_O    => brUpdate);

   -- Add to end for jump calculation
   JUMP_ADDTOEND: addToEnd
   port map(i_In    => i_pInst(25 downto 0),
            o_Out   => jAddToEnd);

   -- Add to start for jump calculation
   JUMP_ADDTOSTART: addToStart
   port map(i_jBits => jAddToEnd,
            i_PCb    => pcIncrement(31 downto 28),
            o_Out    => jFin);

   -- Select between branch update and jump address
   JUMP_SELECT: mux2t1_N
   generic map(N => 32)
   port map(i_S    => i_j,
            i_D0   => brUpdate,
            i_D1   => jFin,
            o_O    => jMUX);

   -- Select between jump register and jump return register
   RA_SELECT: mux2t1_N
   generic map(N => 32)
   port map(i_S    => i_jReg,
            i_D0   => jMUX,
            i_D1   => i_jRetReg,
            o_O    => selAddr);

   -- Output new address and PC + 4
   o_nAddr  <=  newAddr;
   o_pJPC   <=  pcIncrement;

end structure;
