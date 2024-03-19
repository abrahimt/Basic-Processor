-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitXor.vhd
-- n-Bit XOR module to perform bitwise XOR operation on multiple input bits.
-------------------------------------------------------------------------

library IEEE; -- Library declaration for IEEE standard
use IEEE.std_logic_1164.all; -- Importing standard logic data types

entity nBitXor is -- Entity declaration for the nBitXor module
 port(
    i_A          : in std_logic_vector(31 downto 0); -- Input port i_A for first operand
    i_B          : in std_logic_vector(31 downto 0); -- Input port i_B for second operand
    o_F          : out std_logic_vector(31 downto 0) -- Output port o_F for result
 );

end nBitXor; -- End of entity declaration

architecture structure of nBitXor is -- Architecture declaration for the structural modeling

component xorg2 is -- Component declaration for the xorg2 (XOR gate) module
   port(
       i_A          : in std_logic; -- Input port i_A for the XOR gate
       i_B          : in std_logic; -- Input port i_B for the XOR gate
       o_F          : out std_logic -- Output port o_F for the XOR gate result
   );
end component;

begin 
G_NBit_XOR: for i in 0 to 31 generate -- Generate loop for bitwise XOR operation on each bit position

    NBitXor: xorg2 -- Instance of the xorg2 (XOR gate) component for each bit position
    port map(
         i_A  => i_A(i), -- Connecting input bit from i_A
         i_B  => i_B(i), -- Connecting input bit from i_B
         o_F  => o_F(i)  -- Connecting output bit to o_F
    );

end generate G_NBit_XOR; -- End of generate loop

end structure; -- End of architecture declaration
