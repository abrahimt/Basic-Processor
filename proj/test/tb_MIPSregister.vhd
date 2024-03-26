library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O
use work.my_registers.all;

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_MIPSregister is
  generic(gCLK_HPER   : time := 10 ns; N : integer := 32);   -- Generic for half of the clock cycle period
end tb_MIPSregister;

architecture mixed of tb_MIPSregister is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component MIPSregister is
        generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_SEL		: in std_logic_vector(4 downto 0);	-- selection bits
	     i_clk		: in std_logic;				-- clk bit
	     i_rst		: in std_logic;				-- reset bit
	     i_we		: in std_logic;				-- write enable
	     i_d		: in std_logic_vector(31 downto 0);	-- 32 bits of data for register
	     i_rs		: in std_logic_vector(4 downto 0);	-- read selction bit for mux
	     i_rt		: in std_logic_vector(4 downto 0);	-- read selction bit for mux
	     o_OUT1		: out std_logic_vector(31 downto 0);	-- output of write
	     o_OUT2		: out std_logic_vector(31 downto 0));	-- output of write
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal s_CLK, s_RST, s_WE	   : std_logic;
signal s_SEL, s_rs, s_rt           : std_logic_vector(4 downto 0) := (others => '0');
signal s_d, s_out1, s_out2   	   : std_logic_vector(31 downto 0) := (others => '0');

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: MIPSregister
  port map(i_SEL        => s_SEL,
	   i_clk	=> s_CLK,
	   i_rst	=> s_RST,
	   i_we		=> s_WE,
	   i_d		=> s_d,
           i_rs		=> s_rs,
           i_rt		=> s_rt,
           o_OUT1       => s_out1,
	   o_OUT2	=> s_out2);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  

 P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges


    -- TEST 1
    s_SEL <= "00001";		-- Selecting Register(1) or $1
    s_RST <= '0';		-- Resest high
    s_WE  <= '0';		-- Write enable low
    s_D   <= x"0000_0000";	-- Data 0
    wait for 100 ns;

    s_RST <= '0';		-- Resest low
    s_WE  <= '1';		-- Write enable high
    s_D   <= x"abcd_ef00";	-- Data 
    s_rs  <= "00001";		-- Read Reg(1)
    wait for 100 ns;

    s_RST <= '0';		-- Resest low
    s_WE  <= '0';		-- Write enable low
    s_D   <= x"0000_0000";	-- Data 0
    wait for 100 ns;

   -- Should have wrote abcd_ef00 into register 1


    -- TEST 2
    s_SEL <= "00010";		-- Selecting Register(5) or $5
    s_RST <= '0';		-- Resest low
    s_WE  <= '0';		-- Write enable low
    s_D   <= x"0000_0000";	-- Data 0
    wait for 100 ns;

    s_RST <= '0';		-- Resest low
    s_WE  <= '1';		-- Write enable high
    s_D   <= x"4673_4238";	-- Data 
    s_rt  <= "00010";		-- Read Reg(5)
    wait for 100 ns;

    s_RST <= '0';		-- Resest low
    s_WE  <= '0';		-- Write enable low
    s_D   <= x"0000_0000";	-- Data 0
    wait for 100 ns;

   -- Should have wrote abcd_ef00 into register 1
   -- Should have wrote 4673_4238 into register 5











end process;

end mixed;