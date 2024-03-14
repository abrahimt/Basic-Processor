-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 
-- Iowa State University
-------------------------------------------------------------------------


-- nBitAdder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Structural vhdl file of a n bit ripple carry adder circuit
--
--
-- NOTES:
-- 9/6/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity nBitAdder is
generic(N : integer := 32); --use generics for a multiple bit input/output

port(in_A, in_B  : in std_logic_vector(N-1 downto 0);
     in_C        : in std_logic;
     out_S       : out std_logic_vector(N-1 downto 0);
     out_C       : out std_logic;
     o_Overflow  : out std_logic);
end nBitAdder;



architecture structure of nBitAdder is 
 component fullAdder 
  port(A          : in std_logic;
       B          : in std_logic;
       C          : in std_logic;
       o_C        : out std_logic;
       o_S        : out std_logic);
 end component;

--signals for carry in and carry out values
signal s_Carry   : std_logic_vector(N-1 downto 1);


begin
o_Overflow <= (in_A(31) and in_B(31) and not(s_Carry(31))) or ((not in_A(31)) and (not in_B(31)) and s_Carry(31));  

--Separate port map for first adder so that we utilize the carry in input
ADDI: fullAdder port map(
              A        => in_A(0),
              B        => in_B(0), 
	      C        => in_C,
	      o_C      => s_Carry(1), 
              o_S      => out_S(0)); 


G_NBit_Adder: for i in 1 to N-2 generate
    ADDI1: fullAdder port map(
              A        => in_A(i),
              B        => in_B(i), 
	      C        => s_Carry(i),
	      o_C      => s_Carry(i + 1), 
              o_S      => out_S(i));  
end generate G_NBit_Adder;


--Separate port map for final adder so that we utilize the carry out output
ADDI2: fullAdder port map(
              A        => in_A(N-1),
              B        => in_B(N-1), 
	      C        => s_Carry(N-1),
	      o_C      => out_C, 
              o_S      => out_S(N-1)); 



end structure;
