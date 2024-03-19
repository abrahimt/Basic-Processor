-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- onesComp.vhd
-- Module to perform one's complement operation on an input vector.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity onesComp is
  generic (
    N : integer := 32  -- Generic parameter specifying the input/output data width, default is 32 bits
  );
  port (
    i_Num : in std_logic_vector(N-1 downto 0);  -- Input vector for one's complement operation
    o_Num : out std_logic_vector(N-1 downto 0)  -- Output vector after one's complement operation
  );
end onesComp; 

architecture structure of onesComp is 

  -- Component declaration for inverter
  component invg 
    port (
      i_A : in std_logic;
      o_F : out std_logic
    );
  end component;

begin
  -- Generate loop to perform one's complement operation on each bit of the input vector
  G_NBit_OnesComp: for i in 0 to N-1 generate

    g_inv: invg
      port MAP (
        i_A => i_Num(i),
        o_F => o_Num(i)
      );

  end generate G_NBit_OnesComp;

end structure;

