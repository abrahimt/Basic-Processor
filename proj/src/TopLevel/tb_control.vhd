-- tb_control.vhd


library IEEE;
use IEEE.std_logic_1164.all;

entity tb_control is
  generic(gCLK_HPER   : time := 50 ns; N : integer := 32);
end tb_control;

architecture behavior of tb_control is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component Control
    port(i_instruction		: in std_logic_vector(5 downto 0); 		-- Opcode of Instruction [31-26]
	o_RegDst		: out std_logic;				-- Selects Rd or Rt register as destination
	o_Jump			: out std_logic;				-- 1 for jumping, 0 for no jump
	o_Branch		: out std_logic;				-- 1 for branch, 0 for no branch
	o_MemRead		: out std_logic;				-- 1 if reading memory, 0 otherwise
	o_MemtoReg		: out std_logic;				-- 1 if memory to register, 0 otherwise
	o_ALUOp			: out std_logic;				-- Input to ALUControl, 1 for R type, 0 otherwise
	o_MemWrite		: out std_logic;				-- 1 if writing to memory, 0 otherwise
	o_ALUSrc		: out std_logic;				-- 1 if Immediate value is being selected, 0 for B register
	o_RegWrite		: out std_logic);				-- 1 if writing to register, 0 otherwise
  end component;

  -- Temporary signals to connect to the dff component.
  signal s_instruction : std_logic_vector(5 downto 0) := (others => '0');
  signal s_RegDst, s_Jump, s_Branch, s_MemRead, s_MemtoReg, s_ALUOp, s_MemWrite, s_ALUSrc, s_RegWrite   : std_logic;



begin

  DUT: Control 
  port map(i_instruction	=> s_instruction,
	o_RegDst		=> s_RegDst,
	o_Jump			=> s_Jump,
	o_Branch		=> s_Branch,
	o_MemRead		=> s_MemRead,
	o_MemtoReg		=> s_MemtoReg,
	o_ALUOp			=> s_ALUOp,
	o_MemWrite		=> s_MemWrite,
	o_ALUSrc		=> s_ALUSrc,
	o_RegWrite		=> s_RegWrite);
  
  -- Testbench process  
  P_TB: process
  begin

    -- R type instruction
    s_instruction <= "000000";
    wait for 100 ns;  

    -- beq instruction
    s_instruction <= "000100";
    wait for 100 ns;   

    -- bne instruction    
    s_instruction <= "000101";
    wait for 100 ns; 

    -- jump instruction
    s_instruction <= "000010";
    wait for 100 ns;  

    -- sw instruction
    s_instruction <= "101011";
 

    wait;
  end process;
  
end behavior;