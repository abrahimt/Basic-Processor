-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 
-- Iowa State University
-------------------------------------------------------------------------


-- fullAdder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Structural vhdl file of a full adder circuit
--
--
-- NOTES:
-- 8/31/23
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity fullAdder is
port(A, B, C : in std_logic;
     o_S, o_C  : out std_logic);

end fullAdder;


architecture structure of fullAdder is

component andg2 
 port(i_A          : in std_logic;
      i_B          : in std_logic;
      o_F          : out std_logic);
end component;


component org2 
 port(i_A          : in std_logic;
      i_B          : in std_logic;
      o_F          : out std_logic);
end component;


component xorg2 
 port(i_A          : in std_logic;
      i_B          : in std_logic;
      o_F          : out std_logic);
end component;



-- signals for internal gate outputs
signal a_xor_b, a_and_b, c_and_a_xor_b  : std_logic;

begin

--To compute the sum value
XOR1: xorg2
  port MAP(i_A               => A,
	   i_B		     => B,
           o_F               => a_xor_b);

XOR2: xorg2
  port MAP(i_A               => a_xor_b,
	   i_B		     => C,
           o_F               => o_S);

--To compute the carry out value
AND1: andg2
  port MAP(i_A               => A,
	   i_B		     => B,
           o_F               => a_and_b);

AND2: andg2
  port MAP(i_A               => C,
	   i_B		     => a_xor_b,
           o_F               => c_and_a_xor_b);

OR1: org2
  port MAP(i_A               => a_and_b,
	   i_B		     => c_and_a_xor_b,
           o_F               => o_C);



end structure;
