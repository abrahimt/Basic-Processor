-------------------------------------------------------------------------
-- Benjamin Towle

-- Iowa State University
-------------------------------------------------------------------------
-- tb_mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the onesComp unit.
--              
-- 9/5/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.textio.all;             -- For basic I/O

entity tb_onesComp is
 generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
end tb_onesComp;

architecture structure of tb_onesComp is

component onesComp is
  port (i_Num : in std_logic_vector(N-1 downto 0);
	o_Num : out std_logic_vector(N-1 downto 0));
end component;


signal s_I : std_logic_vector(N-1 downto 0);
signal s_O : std_logic_vector(N-1 downto 0);


begin
DUT0: onesComp
port map(i_Num    => s_I,
	 o_Num    => s_O);



TEST_CASE_1: process
begin
 s_I <= "10011100000000101011001011010001";
 
--Expect the o_Num to be the inverse of i_Num
 

wait for 300 ns;
end process;


end structure;
