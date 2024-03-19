-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- mux2t1_dataflow.vhd
-- Two-to-One Multiplexer (MUX) module using dataflow modeling to select 
-- one of two input signals based on the select input.
-------------------------------------------------------------------------

library IEEE; -- Library declaration for IEEE standard
use IEEE.std_logic_1164.all; -- Importing standard logic data types

entity mux2t1_dataflow is -- Entity declaration for the mux2t1_dataflow module
port(
    i_S, i_D0, i_D1: in std_logic; -- Input ports i_S (select), i_D0 (data 0), i_D1 (data 1)
    o_O: out std_logic -- Output port o_O (output signal)
);

end mux2t1_dataflow; -- End of entity declaration

architecture dataflow of mux2t1_dataflow is -- Architecture declaration for the dataflow modeling

begin 
  -- Dataflow modeling to select one of two input signals based on the select input
  o_O <= i_D0 when (i_S = '0') else -- Assign i_D0 to o_O when select input i_S is '0'
         i_D1 when (i_S = '1') else -- Assign i_D1 to o_O when select input i_S is '1'
         '0'; -- Assign '0' to o_O for any other value of select input i_S

end dataflow; -- End of architecture declaration
