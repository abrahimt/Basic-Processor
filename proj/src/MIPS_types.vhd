-------------------------------------------------------------------------
-- Author: Braedon Giblin
-- Date: 2022.02.12
-- Files: MIPS_types.vhd
-------------------------------------------------------------------------
-- Description: This file contains a skeleton for some types that 381 students
-- may want to use. This file is guarenteed to compile first, so if any types,
-- constants, functions, etc., etc., are wanted, students should declare them
-- here.
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE MIPS_types IS

  -- Example Constants. Declare more as needed
  CONSTANT DATA_WIDTH : INTEGER := 32;
  CONSTANT ADDR_WIDTH : INTEGER := 10;

  -- Example record type. Declare whatever types you need here
  TYPE control_t IS RECORD
    reg_wr : STD_LOGIC;
    reg_to_mem : STD_LOGIC;
  END RECORD control_t;

  TYPE reg IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

END PACKAGE MIPS_types;

PACKAGE BODY MIPS_types IS
  -- Probably won't need anything here... function bodies, etc.
END PACKAGE BODY MIPS_types;