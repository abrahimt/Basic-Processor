-- MIPSregister.vhd

library IEEE;
use IEEE.std_logic_1164.all;
use work.my_registers.all;

entity MIPSregister is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(i_SEL		: in std_logic_vector(4 downto 0);	-- selection bits
	     i_clk		: in std_logic;				-- clk bit
	     i_rst		: in std_logic;				-- reset bit
	     i_we		: in std_logic;				-- write enable
	     i_d		: in std_logic_vector(31 downto 0);	-- 32 bits of data for register
	     i_rs		: in std_logic_vector(4 downto 0);	-- read selction bit for mux
	     i_rt		: in std_logic_vector(4 downto 0);	-- read selction bit for mux
	     o_OUT1		: out std_logic_vector(31 downto 0);	-- output of write
	     o_OUT2		: out std_logic_vector(31 downto 0));	-- output of write
end MIPSregister;

architecture structural of MIPSregister is

  component Nbit_reg
  	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  	port(i_CLK        : in std_logic;     			 -- Clock input
             i_RST        : in std_logic;     			 -- Reset input
             i_WE         : in std_logic;                        -- Write enable input
             i_D          : in std_logic_vector(N-1 downto 0);	 -- 32 bit input
             o_Q          : out std_logic_vector(N-1 downto 0)); -- 32 bit output
  end component;

  component my_32t1_mux
	port(i_S         : in std_logic_vector(4 downto 0);
	     registers   : in regs;
	     mx_out      : out std_logic_vector(31 downto 0));
  end component;

  component decoder
	port(SEL   : in std_logic_vector(4 downto 0);
	     F_OUT : out std_logic_vector(31 downto 0));
  end component;

  component andg2N
	port(i_A          : in std_logic;
             i_B          : in std_logic_vector(31 downto 0);
             o_F          : out std_logic_vector(31 downto 0));
  end component;


  -- Signal to carry decoder output
  signal i_F           : std_logic_vector(31 downto 0);
  -- Signal to carry decoder and write bit
  signal i_decode      : std_logic_vector(31 downto 0);
  -- Signal to carry Nbit_regs output
  signal i_reg	       : regs;

  begin

  ---------------------------------------------------------------------------
  -- Level 1: 
  ---------------------------------------------------------------------------

  dec1: decoder
	port MAP(SEL		=> i_SEL,		-- Input is selection bits
		 F_OUT		=> i_F);		-- Output is one of 32 unique options

  and1: andg2N
	port MAP(i_A		=> i_WE,
		 i_B		=> i_F,
		 o_F		=> i_decode);


  ---------------------------------------------------------------------------
  -- Level 2: 
  ---------------------------------------------------------------------------

  reg0: Nbit_reg
	port MAP(i_CLK		=> i_clk,
		 i_RST		=> '1',
		 i_WE		=> '1',
		 i_D		=> i_d,
		 o_Q		=> i_reg(0));


  regi: for i in 1 to N-1 generate
	REG: Nbit_reg port MAP(i_CLK		=> i_clk,		-- Clock bit input
		 	       i_RST		=> i_rst,		-- Reset bit input
	 	 	       i_WE		=> i_decode(i),		-- Should be selecting 1 bit from decoder for each register; ex) 0000 1000 would be register $3
		 	       i_D		=> i_d,			-- Data bit input
		 	       o_Q		=> i_reg(i));
  end generate regi;

  ---------------------------------------------------------------------------
  -- Level 3: 
  ---------------------------------------------------------------------------

  mux1: my_32t1_mux
	port MAP(i_S		=> i_rs,		-- Selecting output
		 registers	=> i_reg,		-- Output from Nbit_reg
		 mx_out		=> o_OUT1);		-- Outputs single register (32 bit register)


  mux2: my_32t1_mux
	port MAP(i_S		=> i_rt,		-- Selecting output
		 registers	=> i_reg,		-- Output from Nbit_reg
		 mx_out		=> o_OUT2);		-- Outputs single register (32 bit register)


end structural;