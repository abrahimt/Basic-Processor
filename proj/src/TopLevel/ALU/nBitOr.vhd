-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- nBitOr.vhd
-- n-Bit OR module to perform bitwise OR operation on multiple input bits.
-------------------------------------------------------------------------

library IEEE; -- Library declaration for IEEE standard
use IEEE.std_logic_1164.all; -- Importing standard logic data types

entity nBitOr is -- Entity declaration for the nBitOr module
 port(
    i_A          : in std_logic_vector(31 downto 0); -- Input port i_A for first operand
    i_B          : in std_logic_vector(31 downto 0); -- Input port i_B for second operand
    o_F          : out std_logic_vector(31 downto 0) -- Output port o_F for result
 );

end nBitOr; -- End of entity declaration

architecture structure of nBitOr is -- Architecture declaration for the structural modeling

component org2 is -- Component declaration for the org2 (OR gate) module
   port(
       i_A          : in std_logic; -- Input port i_A for the OR gate
       i_B          : in std_logic; -- Input port i_B for the OR gate
       o_F          : out std_logic -- Output port o_F for the OR gate result
   );
end component;

begin 
G_NBit_OR: for i in 0 to 31 generate -- Generate loop for bitwise OR operation on each bit position

    NBitOR: org2 -- Instance of the org2 (OR gate) component for each bit position
    port map(
         i_A  => i_A(i), -- Connecting input bit from i_A
         i_B  => i_B(i), -- Connecting input bit from i_B
         o_F  => o_F(i)  -- Connecting output bit to o_F
    );

end generate G_NBit_OR; -- End of generate loop

end structure; -- End of architecture declaration
