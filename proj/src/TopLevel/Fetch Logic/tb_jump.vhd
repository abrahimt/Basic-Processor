library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity tb_jump is
end entity tb_jump;

architecture tb of tb_jump is

    constant CLOCK_PERIOD : time := 20 ns;
    
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

    -- Clock process
    clk_process: process
    begin
        s_CLK <= '0';
        wait for CLOCK_PERIOD / 2;
        s_CLK <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    P_TB: process
    begin

	-- TEST 1
	s_Data <= x"08100008";
	s_PC   <= x"00400010";
	wait for CLOCK_PERIOD;

    end process;

end architecture tb;
	