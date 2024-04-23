-- MIPSregister.vhd

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.MIPS_types.ALL;

ENTITY MIPSregister IS
	GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
	PORT (
		i_SEL : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- selection bits
		i_clk : IN STD_LOGIC; -- clk bit
		i_rst : IN STD_LOGIC; -- reset bit
		i_we : IN STD_LOGIC; -- write enable
		i_d : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32 bits of data for register
		i_rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- read selction bit for mux
		i_rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- read selction bit for mux
		o_OUT1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- output of write
		o_OUT2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- output of write
END MIPSregister;

ARCHITECTURE structural OF MIPSregister IS

	COMPONENT Nbit_reg
		GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
		PORT (
			i_CLK : IN STD_LOGIC; -- Clock input
			i_RST : IN STD_LOGIC; -- Reset input
			i_WE : IN STD_LOGIC; -- Write enable input
			i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- 32 bit input
			o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- 32 bit output
	END COMPONENT;

	COMPONENT my_32t1_mux
		PORT (
			i_S : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			registers : IN reg;
			mx_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT decoder
		PORT (
			SEL : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			F_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT andg2N
		PORT (
			i_A : IN STD_LOGIC;
			i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;
	-- Signal to carry decoder output
	SIGNAL i_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- Signal to carry decoder and write bit
	SIGNAL i_decode : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- Signal to carry Nbit_regs output
	SIGNAL i_reg : reg;

BEGIN

	---------------------------------------------------------------------------
	-- Level 1: 
	---------------------------------------------------------------------------

	dec1 : decoder
	PORT MAP(
		SEL => i_SEL, -- Input is selection bits
		F_OUT => i_F); -- Output is one of 32 unique options

	and1 : andg2N
	PORT MAP(
		i_A => i_WE,
		i_B => i_F,
		o_F => i_decode);
	---------------------------------------------------------------------------
	-- Level 2: 
	---------------------------------------------------------------------------

	reg0 : Nbit_reg
	PORT MAP(
		i_CLK => i_clk,
		i_RST => '1',
		i_WE => '1',
		i_D => i_d,
		o_Q => i_reg(0));
	regi : FOR i IN 1 TO N - 1 GENERATE
		REG : Nbit_reg PORT MAP(
			i_CLK => i_clk, -- Clock bit input
			i_RST => i_rst, -- Reset bit input
			i_WE => i_decode(i), -- Should be selecting 1 bit from decoder for each register; ex) 0000 1000 would be register $3
			i_D => i_d, -- Data bit input
			o_Q => i_reg(i));
	END GENERATE regi;

	---------------------------------------------------------------------------
	-- Level 3: 
	---------------------------------------------------------------------------

	mux1 : my_32t1_mux
	PORT MAP(
		i_S => i_rs, -- Selecting output
		registers => i_reg, -- Output from Nbit_reg
		mx_out => o_OUT1); -- Outputs single register (32 bit register)
	mux2 : my_32t1_mux
	PORT MAP(
		i_S => i_rt, -- Selecting output
		registers => i_reg, -- Output from Nbit_reg
		mx_out => o_OUT2); -- Outputs single register (32 bit register)