-- ForwardingUnit

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ForwardingUnit IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
        i_WB : IN STD_LOGIC; -- write back bit from write back
        i_memWb : IN STD_LOGIC; -- write back bit from memory
        i_memMux : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bit RD or Shamt from memory?
        i_wbMux : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bit RD or Shamt from write back?
        i_rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bit rs
        i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- 5 bit rt
        o_mux1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- output mux one
        o_mux2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));-- output mux two
END ForwardingUnit;

ARCHITECTURE structure OF ForwardingUnit IS

BEGIN

    o_mux1 <= "00" WHEN (i_rs /= i_memMux AND i_rs /= i_wbMux) ELSE -- rs in decode does not match rs in memory or write back
        "01" WHEN (i_rs /= i_memMux AND i_rs = i_wbMux) ELSE -- rs in decode matches write back but not memory
        "10" WHEN (i_rs = i_memMux AND i_rs /= i_wbMux) ELSE -- rs in decode matches memory and not write back
        "10" WHEN (i_rs = i_memMux AND i_rs = i_wbMux) ELSE -- rs in decode matches both memory and write back
        "00";

    o_mux2 <= "00" WHEN (i_rt /= i_memMux AND i_rt /= i_wbMux) ELSE -- rt in decode does not match rt in memory or write back
        "01" WHEN (i_rt /= i_memMux AND i_rt = i_wbMux) ELSE -- rt in decode matches write back but not memory
        "10" WHEN (i_rt = i_memMux AND i_rt /= i_wbMux) ELSE -- rt in decode matches memory and not write back
        "10" WHEN (i_rt = i_memMux AND i_rt = i_wbMux) ELSE -- rt in decode matches both memory and write back
        "00";

END structure;