library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_jump is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end entity tb_jump;

architecture tb of tb_jump is

   -- Define the total clock period time
   constant cCLK_PER  : time := gCLK_HPER * 2;
    
   component jump
	port(
	 i_CLK    : in std_logic;                          -- Clock input
         i_rst    : in std_logic;                          -- Reset input
	 i_PC	  : in std_logic_vector(31 downto 0);	   -- PC + 4 [31 - 28]
         i_Data   : in std_logic_vector(31 downto 0);      -- Jump Instruction Input
         o_Q      : out std_logic_vector(31 downto 0));    -- Jump Address Output
   end component;


   signal s_CLK, s_rst : std_logic;
   signal s_PC, s_Data, s_Q : std_logic_vector(31 downto 0) := (others => '0');
    
begin

    DUT0: jump
        port map(
            i_CLK  => s_CLK,
            i_rst  => s_rst,
            i_Data => s_Data,
	    i_PC   => s_PC,
	    o_Q    => s_Q);

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

    P_TB: process
    begin
	wait for gCLK_HPER/2; 	-- for waveform clarity, I prefer not to change inputs on clk edges

   	 s_rst <= '1';		 -- Resest low
   	 wait for gCLK_HPER * 2; -- 20
   	 s_rst <= '0';		 -- Resest low
   	 wait for gCLK_HPER * 2; -- 40

	-- TEST 1
	s_Data <= x"08100008";
	s_PC   <= x"00400010";
	wait;

    end process;

end architecture tb;
	