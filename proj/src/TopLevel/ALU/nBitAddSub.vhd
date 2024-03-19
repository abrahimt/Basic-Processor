-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitAddSub.vhd
-- Module for performing n-bit addition/subtraction with overflow detection.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity nBitAddSub is
  generic (
    N : integer := 32  -- Default value for the input/output data width is 32
  );
  port (
    input_A      : in std_logic_vector(N-1 downto 0);  -- Input vector A
    input_B      : in std_logic_vector(N-1 downto 0);  -- Input vector B
    nAdd_Sub     : in std_logic;  -- Control signal for addition/subtraction
    output_S     : out std_logic_vector(N-1 downto 0);  -- Output vector for sum/difference
    output_C     : out std_logic;  -- Output carry for addition
    o_Overflow   : out std_logic  -- Overflow flag for addition/subtraction
  );
end nBitAddSub;

architecture structure of nBitAddSub is 
  component mux2t1_N is
    port (
      i_S  : in std_logic;
      i_D0 : in std_logic_vector(N-1 downto 0);
      i_D1 : in std_logic_vector(N-1 downto 0);
      o_O  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component onesComp is
    port (
      i_Num : in std_logic_vector(N-1 downto 0);
      o_Num : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component nBitAdder is
    port (
      in_A        : in std_logic_vector(N-1 downto 0);
      in_B        : in std_logic_vector(N-1 downto 0);
      in_C        : in std_logic;
      out_S       : out std_logic_vector(N-1 downto 0);
      out_C       : out std_logic;
      o_Overflow  : out std_logic
    );
  end component;

  component xorg2 is 
    port (
      i_A  : in std_logic;
      i_B  : in std_logic;
      o_F  : out std_logic
    );
  end component;

  signal notB       : std_logic_vector(N-1 downto 0);  -- Complement of input B
  signal muxResult  : std_logic_vector(N-1 downto 0);  -- Result from the multiplexer

begin

  -- Generate the one's complement of input B
  N_Bit_Inv: onesComp 
    port map (
      i_Num => input_B,
      o_Num => notB
    );

  -- Perform the addition/subtraction based on the control signal
  N_Bit_Mux: mux2t1_N
    port map (
      i_S  => nAdd_Sub,
      i_D0 => input_B,
      i_D1 => notB,
      o_O  => muxResult
    );

  N_Bit_Adder: nBitAdder
    port map (
      in_A       => input_A,
      in_B       => muxResult, 
      in_C       => nAdd_Sub,
      out_S      => output_S,
      out_C      => output_C,
      o_Overflow => o_Overflow
    );

end structure;
