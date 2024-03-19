-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitAdder.vhd
-- n-Bit Adder module to compute the sum and carry-out for multiple input bits.
-------------------------------------------------------------------------

library IEEE; -- Library declaration for IEEE standard
use IEEE.std_logic_1164.all; -- Importing standard logic data types

entity nBitAdder is -- Entity declaration for the nBitAdder module
generic(
    N : integer := 32 -- Generic parameter for the number of bits in the input/output
);

port(
    in_A, in_B  : in std_logic_vector(N-1 downto 0); -- Input ports in_A and in_B
    in_C        : in std_logic; -- Input port in_C for carry-in
    out_S       : out std_logic_vector(N-1 downto 0); -- Output port out_S for sum
    out_C       : out std_logic; -- Output port out_C for carry-out
    o_Overflow  : out std_logic -- Output port o_Overflow for overflow detection
);

end nBitAdder; -- End of entity declaration

architecture structure of nBitAdder is -- Architecture declaration for the structural modeling

component fullAdder -- Component declaration for the fullAdder module
  port(
    A          : in std_logic; -- Input port A for the full adder
    B          : in std_logic; -- Input port B for the full adder
    C          : in std_logic; -- Input port C for the full adder
    o_C        : out std_logic; -- Output port o_C for carry-out
    o_S        : out std_logic -- Output port o_S for sum
  );
end component;

-- Signals for carry-in and carry-out values
signal s_Carry   : std_logic_vector(N-1 downto 1); -- Signal for internal carry propagation

begin
-- Overflow detection logic based on the MSB of inputs and carry-out
o_Overflow <= (in_A(N-1) and in_B(N-1) and not(s_Carry(N-1))) or 
              ((not in_A(N-1)) and (not in_B(N-1)) and s_Carry(N-1));  

-- Separate fullAdder instance for the first bit to utilize the carry-in input
ADDI: fullAdder port map(
              A        => in_A(0),
              B        => in_B(0), 
	      C        => in_C,
	      o_C      => s_Carry(1), 
              o_S      => out_S(0)); 

-- Generate n-2 fullAdder instances for the remaining bits
G_NBit_Adder: for i in 1 to N-2 generate
    ADDI1: fullAdder port map(
              A        => in_A(i),
              B        => in_B(i), 
	      C        => s_Carry(i),
	      o_C      => s_Carry(i + 1), 
              o_S      => out_S(i));  
end generate G_NBit_Adder;

-- Separate fullAdder instance for the final bit to utilize the carry-out output
ADDI2: fullAdder port map(
              A        => in_A(N-1),
              B        => in_B(N-1), 
	      C        => s_Carry(N-1),
	      o_C      => out_C, 
              o_S      => out_S(N-1)); 

end structure; -- End of architecture declaration
