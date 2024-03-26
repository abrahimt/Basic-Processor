library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity tb_shift is
end entity tb_shift;

architecture tb of tb_shift is

    constant CLOCK_PERIOD : time := 20 ns;
    
    component Barrel_Shifter
	port(
	i_shamt      : in std_logic_vector(4 downto 0);  -- Shift amount
    	i_sign       : in std_logic;                     -- Shift direction control (left or right)
    	i_leftShift  : in std_logic;                     -- Logical shift direction control
    	i_D          : in std_logic_vector(31 downto 0); -- Input vector to be shifted
    	o_O          : out std_logic_vector(31 downto 0) -- Output vector after shifting
  	);
    end component;


    signal s_sign, s_leftShift : std_logic;
    signal s_shamt : std_logic_vector(4 downto 0);
    signal s_D, s_O : std_logic_vector(31 downto 0);
    
begin

    DUT0: Barrel_Shifter
        port map(
            i_shamt  	=> s_shamt,
            i_sign  	=> s_sign,
            i_leftShift => s_leftShift,
	    i_D   	=> s_D,
	    o_O    	=> s_O);

    P_TB: process
    begin

	-- TEST 1
	s_shamt <= "00110";
	s_D   <= x"08100008";
	s_sign <= '0';
	s_leftShift <= '1';
	wait for 150 ns;

	-- TEST 2
	s_shamt <= "00100";
	s_D   <= x"04000200";
	s_sign <= '0';
	s_leftShift <= '0';
	wait for 150 ns;

	-- TEST 3
	s_shamt <= "11100";
	s_D   <= x"00400014";
	s_sign <= '0';
	s_leftShift <= '1';
	wait for 150 ns;

	-- TEST 4
	s_shamt <= "11100";
	s_D   <= x"00000000";
	s_sign <= '0';
	s_leftShift <= '0';
	wait;

    end process;

end architecture tb;
	