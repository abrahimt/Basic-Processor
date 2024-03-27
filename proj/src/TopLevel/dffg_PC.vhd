library IEEE;
use IEEE.std_logic_1164.all;

entity dffg_PC is

  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       r_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output

end dffg_PC;

architecture mixed of dffg_PC is

COMPONENT mux2t1 IS
PORT (
    i_S : IN STD_LOGIC;
    i_D0 : IN STD_LOGIC;
    i_D1 : IN STD_LOGIC;
    o_O : OUT STD_LOGIC);
END COMPONENT;

  signal s_D    : std_logic;    -- Multiplexed input to the FF
  signal s_Q    : std_logic;    -- Output of the FF

begin

  -- The output of the FF is fixed to s_Q
  o_Q <= s_Q;
  
  -- Create a multiplexed input to the FF based on i_WE
  with i_WE select
    s_D <= i_D when '1',
           s_Q when others;
  
  -- This process handles the asyncrhonous reset and
  -- synchronous write. We want to be able to reset 
  -- our processor's registers so that we minimize
  -- glitchy behavior on startup.
  process (i_CLK)
  begin
    if (i_RST = '1') then
      s_Q <= r_D; -- Use "(others => '0')" for N-bit values
    elsif (falling_edge(i_CLK)) then
      s_Q <= s_D;
    end if;

  end process;

  --G_MUX : mux2t1
  --PORT MAP(
    --i_S => i_WE, -- selection bit from Control
    --i_D0 => s_Q, -- ALU data from ALU
    --i_D1 => i_D, -- Memory data from MEM
    --o_O => s_D); -- Data output to Register Data Input

    -- This process handles the asyncrhonous reset and
  -- synchronous write. We want to be able to reset 
  -- our processor's registers so that we minimize
  -- glitchy behavior on startup.
   
  --G_MUX1 : mux2t1
  --port map(
   -- i_S => i_RST, -- selection bit from Control
    --i_D0 => s_D, -- ALU data from ALU
    --i_D1 => r_D, -- Memory data from MEM
   --o_O => s_Q); -- Data output to Register Data Input
    

  
end mixed;
