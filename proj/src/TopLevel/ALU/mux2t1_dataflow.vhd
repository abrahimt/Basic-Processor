-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- mux2t1_dataflow.vhd
-- Two-to-One Multiplexer (MUX) module using dataflow modeling to select 
-- one of two input signals based on the select input.
-------------------------------------------------------------------------

LIBRARY IEEE; -- Library declaration for IEEE standard
USE IEEE.std_logic_1164.ALL; -- Importing standard logic data types

ENTITY mux2t1_dataflow IS -- Entity declaration for the mux2t1_dataflow module
  PORT (
    i_S, i_D0, i_D1 : IN STD_LOGIC; -- Input ports i_S (select), i_D0 (data 0), i_D1 (data 1)
    o_O : OUT STD_LOGIC -- Output port o_O (output signal)
  );

END mux2t1_dataflow; -- End of entity declaration

ARCHITECTURE dataflow OF mux2t1_dataflow IS -- Architecture declaration for the dataflow modeling

BEGIN
  -- Dataflow modeling to select one of two input signals based on the select input
  o_O <= i_D0 WHEN (i_S = '0') ELSE -- Assign i_D0 to o_O when select input i_S is '0'
    i_D1 WHEN (i_S = '1') ELSE -- Assign i_D1 to o_O when select input i_S is '1'
    '0'; -- Assign '0' to o_O for any other value of select input i_S

END dataflow; -- End of architecture declaration