------------------------------------------------------------
-- Mitchell Driscoll
-- CPRE 381 
-- Iowa State University 
-- 3/14/2024
------------------------------------------------------------
-- jump.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity jump is 
    port(i_CLK    : in std_logic;                          -- Clock input
         i_rst    : in std_logic;                          -- Reset input
	 i_PC	  : in std_logic_vector(31 downto 0);	   -- PC + 4 [31 - 28]
         i_Data   : in std_logic_vector(31 downto 0);      -- Jump Instruction Input
         o_Q      : out std_logic_vector(31 downto 0));    -- Jump Address Output
end jump;

   architecture structural of jump is 

        COMPONENT nBitAdder IS
            GENERIC (N : INTEGER := 32); -- use generics for a multiple bit input/output
            PORT (
                in_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
                in_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
                in_C : IN STD_LOGIC;
                out_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
                out_C : OUT STD_LOGIC);
        END COMPONENT;

        COMPONENT shift IS
            PORT (
                i_In : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
        END COMPONENT;

	component Barrel_Shifter is
  	    port(
    		i_shamt      : in std_logic_vector(4 downto 0);    -- Shift amount
    		i_sign       : in std_logic;                       -- Shift direction control (left or right)
    		i_leftShift  : in std_logic;                       -- Logical shift direction control
    		i_D          : in std_logic_vector(31 downto 0);   -- Input vector to be shifted
    		o_O          : out std_logic_vector(31 downto 0)); -- Output vector after shifting
	end component;

	
	signal jump_addr : std_logic_vector(31 downto 0);  -- i_Data [25-0]
	signal PC_4	 : std_logic_vector(31 downto 0);  -- i_PC [31-28]
	signal carry	 : std_logic := '0'; 		   -- signal for carry of adder
	
   begin 

   G_LEFT_SHIFT: Barrel_Shifter
	port map(
		i_shamt		=> "00110",	-- shift by 6
		i_sign  	=> '0',		-- shift left
		i_leftShift 	=> '0',		-- logical shift
		i_D		=> i_Data,	-- Jump Instrcution
		o_O		=> jump_addr);	-- Shifted Jump Address

   G_RIGHT_SHIFT: Barrel_Shifter
	port map(
		i_shamt		=> "00100",	-- shift by 4
		i_sign  	=> '1',		-- shift right
		i_leftShift 	=> '0',		-- logical shift
		i_D		=> jump_addr,	-- Shifted Jump Address
		o_O		=> jump_addr);	-- Final Shifted Jump Address

   G_ADD: nBitAdder
	port map(
		in_A		=> PC_4,	-- PC Address
		in_B		=> x"00000004",	-- Four
		in_C		=> carry,	-- Carry Bit
		out_S		=> o_Q,		-- PC Address Plus 4
		out_C		=> carry);	-- Carry Bit Output

   G_RIGHT_SHIFT_PC: Barrel_Shifter
	port map(
		i_shamt		=> "11100",	-- shift by 28
		i_sign  	=> '1',		-- shift right
		i_leftShift 	=> '0',		-- logical shift
		i_D		=> i_PC,	-- PC Address
		o_O		=> PC_4);	-- Shifted PC Address

   G_LEFT_SHIFT_PC: Barrel_Shifter
	port map(
		i_shamt		=> "11100",	-- shift by 28
		i_sign  	=> '0',		-- shift left
		i_leftShift 	=> '0',		-- logical shift
		i_D		=> PC_4,	-- Jump Instrcution
		o_O		=> PC_4);	-- Shifted PC Address

   G_ADD2: nBitAdder
	port map(
		in_A		=> jump_addr,
		in_B		=> PC_4,
		in_C		=> carry,
		out_S		=> o_Q,
		out_C		=> carry);


end structural; 