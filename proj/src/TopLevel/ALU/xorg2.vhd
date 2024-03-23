-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- xorg2.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2-input XOR 
-- gate.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 1/16/19 by H3::Changed name to avoid name conflict with Quartus 
--         primitives.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY xorg2 IS

  PORT (
    i_A : IN STD_LOGIC;
    i_B : IN STD_LOGIC;
    o_F : OUT STD_LOGIC);

END xorg2;

ARCHITECTURE dataflow OF xorg2 IS
BEGIN

  o_F <= i_A XOR i_B;

END dataflow;