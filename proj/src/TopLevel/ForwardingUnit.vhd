-- ForwardingUnit

library IEEE;
use IEEE.std_logic_1164.all;

entity ForwardingUnit is 
    generic(N : integer := 32);                         -- Generic of type integer for input/output data width. Default value is 32.
    port(
	    i_WB		: in std_logic;				        -- write back bit from write back
        i_memWb		: in std_logic;				        -- write back bit from memory
	    i_memMux	: in std_logic_vector(4 downto 0);	-- 5 bit RD or Shamt from memory?
        i_wbMux	    : in std_logic_vector(4 downto 0);	-- 5 bit RD or Shamt from write back?
	    i_rs	    : in std_logic_vector(4 downto 0);	-- 5 bit rs
	    i_rt	    : in std_logic_vector(4 downto 0);	-- 5 bit rt
        o_mux1	    : out std_logic_vector(1 downto 0);	-- output mux one
        o_mux2	    : out std_logic_vector(1 downto 0));-- output mux two
end ForwardingUnit;

architecture structure of ForwardingUnit is

begin

    o_mux1 <= "00" when (i_rs /= i_memMux and i_rs /= i_wbMux) else     -- rs in decode does not match rs in memory or write back
              "01" when (i_rs /= i_memMux and i_rs = i_wbMux) else     -- rs in decode matches write back but not memory
              "10" when (i_rs = i_memMux and i_rs /= i_wbMux) else     -- rs in decode matches memory and not write back
              "10" when (i_rs = i_memMux and i_rs = i_wbMux) else     -- rs in decode matches both memory and write back
              "00";

    o_mux2 <= "00" when (i_rt /= i_memMux and i_rt /= i_wbMux) else     -- rt in decode does not match rt in memory or write back
              "01" when (i_rt /= i_memMux and i_rt = i_wbMux) else     -- rt in decode matches write back but not memory
              "10" when (i_rt = i_memMux and i_rt /= i_wbMux) else     -- rt in decode matches memory and not write back
              "10" when (i_rt = i_memMux and i_rt = i_wbMux) else     -- rt in decode matches both memory and write back
              "00";

end structure;