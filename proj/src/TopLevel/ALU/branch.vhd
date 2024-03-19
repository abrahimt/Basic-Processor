-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- branch.vhd
-- Module for comparing two 32-bit vectors and setting a branch flag based on specified conditions.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity branch is 
  port (
    i_A           : in std_logic_vector(31 downto 0);  -- Input vector A
    i_B           : in std_logic_vector(31 downto 0);  -- Input vector B
    i_beq         : in std_logic;                      -- Equal comparison control signal
    i_bne         : in std_logic;                      -- Not equal comparison control signal
    o_branchFlag  : out std_logic                      -- Output branch flag
  );
end branch;

architecture dataflow of branch is
begin

  process(i_A, i_B, i_beq, i_bne) 
  begin
    if i_A = i_B and i_beq = '1' then  -- Check for equality condition
      o_branchFlag <= '1';
    elsif i_A /= i_B and i_bne = '1' then  -- Check for inequality condition
      o_branchFlag <= '1';
    else  -- Default condition if no match
      o_branchFlag <= '0';
    end if;
  end process;

end dataflow;

