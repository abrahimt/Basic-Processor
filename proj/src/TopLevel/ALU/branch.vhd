--Abrahim Toutoungi
--3/17/2024
--branch.vhd
--To be used by the ALU for bne and beq instructions

library IEEE;
use IEEE.std_logic_1164.all;

entity branch is 
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       i_beq        : in std_logic;
       i_bne        : in std_logic;
       o_branchFlag     : out std_logic);
end branch;

architecture dataflow of branch is
begin

process(i_A, i_B, i_beq, i_bne) 
begin

if i_A = i_B and i_beq = '1' then 
   o_branchFlag <= '1';

elsif i_A /= i_B and i_bne = '1' then 
   o_branchFlag <= '1';

else 
   o_branchFlag <= '0';

end if;
end process;


	 
end dataflow;
