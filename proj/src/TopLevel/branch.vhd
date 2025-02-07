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

entity branch is 
    port(i_clk    : in std_logic;                          -- Clock input
         i_rst    : in std_logic;                          -- Reset input
	     i_PC	  : in std_logic_vector(31 downto 0);	   -- PC + 4 [31 - 0]
         i_Data   : in std_logic_vector(31 downto 0);      -- Branch Instruction Input [15-0]
         o_Q      : out std_logic_vector(31 downto 0));    -- Jump Address Output
end branch;

   architecture structural of branch is 

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

	component Extender is
  	   port(i_data       : in std_logic_vector(15 downto 0);
			i_S			 : in std_logic;
   	     	o_out        : out std_logic_vector(31 downto 0));
	end component;

	signal SE_branch_addr 		: std_logic_vector(31 downto 0);     -- i_Data [15-0]
	signal shifted_branch_addr 	: std_logic_vector(31 downto 0);     -- i_Data [15-0]
	signal PC_4	      		: std_logic_vector(31 downto 0);     -- i_PC + 4
	signal carry1	      		: std_logic; 		     -- signal for carry of adder
	signal carry2	      		: std_logic; 		     -- signal for carry of adder

  begin

  G_ADD: nBitAdder
	port map(
		in_A		=> i_PC,	-- PC Address
		in_B		=> x"00000004",	-- Four
		in_C		=> '0',	-- Carry Bit
		out_S		=> PC_4,	-- PC Address Plus 4
		out_C		=> carry1);	-- Carry Bit Output

  G_EXTEND: Extender
	port map(
		i_data		=> i_Data(15 downto 0),
		i_S			=> '1',
		o_out		=> SE_branch_addr);

  G_SHIFT: shift
	port map(
		i_IN		=> SE_branch_addr,	 -- Sign Extended branch address
		o_Out		=> shifted_branch_addr); -- Shifted left 2 branch address

  G_ADD2: nbitAdder
	port map(
		in_A 		=> PC_4,
                in_B 		=> shifted_branch_addr,
                in_C 		=> '0',
                out_S 		=> o_Q,
                out_C 		=> carry2);


end structural; 