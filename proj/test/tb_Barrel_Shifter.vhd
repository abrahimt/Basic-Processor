
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;


entity tb_Barrel_Shifter is
  generic(gCLK_HPER   : time := 10 ns);
end tb_Barrel_Shifter;

architecture structural of tb_Barrel_Shifter is

component Barrel_Shifter is
    port(
	   i_shamt : in std_logic_vector(4 downto 0);
	   i_sign : std_logic;
	   i_leftShift : std_logic;
       i_D : in std_logic_vector(31 downto 0);
       o_O : out std_logic_vector(31 downto 0));
end component;

signal CLK : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_i_shamt    : std_logic_vector(4 downto 0) := (others => '0');
signal s_i_sign     : std_logic := '0';
signal s_i_leftShift : std_logic := '0';
signal s_i_D     : std_logic_vector(31 downto 0) := (others => '0');
signal s_o_O     : std_logic_vector(31 downto 0) := (others => '0');

begin

  DUT0: Barrel_Shifter
  port map(
       i_shamt => s_i_shamt,
	   i_sign => s_i_sign,
	   i_leftShift =>  s_i_leftShift,
       i_D => s_i_D,
       o_O => s_o_O
	);
  
  --This first process is to setup the clock for the test bench
  P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;

  
  P_TC: process
  begin
    wait for gCLK_HPER*3;

	for i in 0 to 31 loop 
		s_i_D <= x"AAAAAAAA";
		s_i_leftShift <= '1';
		s_i_shamt <= std_logic_vector(to_unsigned(i, s_i_shamt'length));
		s_i_sign <= '0';
		wait for gCLK_HPER*2;
	end loop;
    
	for i in 0 to 31 loop 
		s_i_D <= x"AAAAAAAA";
		s_i_leftShift <= '1';
		s_i_shamt <= std_logic_vector(to_unsigned(i, s_i_shamt'length));
		s_i_sign <= '1';
		wait for gCLK_HPER*2;
	end loop;
	
	for i in 0 to 31 loop 
		s_i_D <= x"AAAAAAAA";
		s_i_leftShift <= '0';
		s_i_shamt <= std_logic_vector(to_unsigned(i, s_i_shamt'length));
		s_i_sign <= '0';
		wait for gCLK_HPER*2;
	end loop;
    
	for i in 0 to 31 loop 
		s_i_D <= x"AAAAAAAA";
		s_i_leftShift <= '0';
		s_i_shamt <= std_logic_vector(to_unsigned(i, s_i_shamt'length));
		s_i_sign <= '1';
		wait for gCLK_HPER*2;
	end loop;
    
	



    wait;
  end process;

end structural;