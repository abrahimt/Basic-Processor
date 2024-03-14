--Benjamin Towle
--9/7/2023
--pcRegister.vhd
--File contains elements of an N bit register with dffg.vhd as a component

library IEEE;
use IEEE.std_logic_1164.all;

entity pcRegister is 
   port(i_CLK        : in std_logic;                          -- Clock input
        i_reset      : in std_logic;                          -- Reset input
        i_WE         : in std_logic;                          -- Write enable input
        i_D          : in std_logic_vector(31 downto 0);     -- Data value input
        o_Q          : out std_logic_vector(31 downto 0));   -- Data value output

end pcRegister;

architecture structure of pcRegister is

 component dffg_set is 
  port(i_CLK        : in std_logic;     -- Clock input
       i_reset      : in std_logic;     -- Reset input
       i_SET        : in std_logic;
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output
 end component;

signal s_D : std_logic_vector(31 downto 0);

begin

G_NBit_Register_21: for i in 0 to 21 generate
DFF: dffg_set
 port map(  i_CLK   => i_CLK,
            i_reset   => i_reset,
            i_SET   => '0',
            i_WE    => i_WE,
            i_D     => i_D(i),
            o_Q     => o_Q(i));
end generate G_NBit_Register_21;


DFF: dffg_set
	port map(  i_CLK   => i_CLK,
            i_reset   => '0',
            i_SET   => i_reset,
            i_WE    => i_WE,
            i_D     => i_D(22),
            o_Q     => o_Q(22));


G_NBit_Register: for i in 23 to 31 generate
DFF: dffg_set
 port map(  i_CLK   => i_CLK,
            i_reset   => i_reset,
            i_SET   => '0',
            i_WE    => i_WE,
            i_D     => i_D(i),
            o_Q     => o_Q(i));
end generate G_NBit_Register;
  

end structure;