--Benjamin Towle
--10/7/2023
--tb_branch.vhd
--Test bench for the nBitOr.vhd module

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.textio.all;             -- For basic I/O

entity tb_branch is 
end tb_branch;

architecture structure of tb_branch is 

component branch is 
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       i_beq        : in std_logic;
       i_bne        : in std_logic;
       o_branchFlag : out std_logic);
end component;

signal s_A, s_B   : std_logic_vector(31 downto 0);
signal s_beq, s_bne : std_logic;
signal s_branchOrNa   : std_logic;

begin 
DUT0: branch

port map (i_A     => s_A,
	  i_B     => s_B,
	  i_beq   => s_beq,
	  i_bne   => s_bne,
	  o_branchFlag  => s_branchOrNa);

TEST_CASES: process 
begin

--Don't branch
s_A  <= x"00000032";
s_B  <= x"00000032";
s_bne <= '1';
s_beq <= '0';    
wait for 50 ns;

--branch
s_A  <= x"00000032";
s_B  <= x"00000032";
s_bne <= '0';
s_beq <= '1';    
wait for 50 ns;

--branch
s_A  <= x"000046A3";
s_B  <= x"0E207003";
s_bne <= '1';
s_beq <= '0';    
wait for 50 ns;

--Don't branch
s_A  <= x"000046A3";
s_B  <= x"0E207002";
s_bne <= '0';
s_beq <= '1';    
wait for 50 ns;

--Don't branch
s_A  <= x"80000000";
s_B  <= x"7FFFFFFF";
s_bne <= '0';
s_beq <= '1';   
wait for 50 ns;

--branch
s_A  <= x"80000000";
s_B  <= x"7FFFFFFF";
s_bne <= '1';
s_beq <= '0';   
wait for 50 ns;

--branch
s_A  <= x"00000000";
s_B  <= x"FFFFFFFF";
s_bne <= '1';
s_beq <= '0';   
wait for 50 ns;

--Don't branch
s_A  <= x"00000000";
s_B  <= x"FFFFFFFF";
s_bne <= '0';
s_beq <= '1';   
wait for 50 ns;
end process;

end structure;
