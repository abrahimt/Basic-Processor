-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Structural vhdl file of a 2 to 1 multiplexor
--
--
-- NOTES:
-- 8/31/23
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;



entity mux2t1_dataflow is
 port(i_S, i_D0, i_D1: in std_logic;
	o_O: out std_logic);

end mux2t1_dataflow;

architecture dataflow of mux2t1_dataflow is 
begin 
  o_O <= i_D0 when (i_S = '0') else 
	 i_D1 when (i_S = '1') else 
	 '0';
end dataflow;