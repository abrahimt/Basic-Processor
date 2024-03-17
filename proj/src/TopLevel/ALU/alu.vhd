-------------------------------------------------------------------------
-- Abrahim Toutoungi
-- 3/14/2024
-- alu.vhd
-- Used to perform operations based on the particular instruction
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity alu is 
   port(i_RS, i_RT   : in std_logic_vector(31 downto 0);
	i_Imm              : in std_logic_vector(31 downto 0);
	i_ALUOp            : in std_logic_vector(3 downto 0);
	i_ALUSrc           : in std_logic;
	i_bne              : in std_logic;
	i_beq              : in std_logic;
	i_shiftDir         : in std_logic;
	i_shiftType        : in std_logic;
	i_shamt            : in std_logic_vector(4 downto 0);
	i_addSub           : in std_logic;
	i_signed           : in std_logic;
	i_lui              : in std_logic;
	o_result           : out std_logic_vector(31 downto 0);
	o_overflow         : out std_logic;
	o_branch           : out std_logic);  
	
end alu;

architecture structure of alu is 

component nBitAddSub is 
  port(input_A, input_B  : in std_logic_vector(31 downto 0);
       nAdd_Sub    : in std_logic;    
       output_S    : out std_logic_vector(31 downto 0);
       output_C    : out std_logic;
       o_Overflow  : out std_logic);
end component;

component nBitOr is 
    port(i_A          : in std_logic_vector(31 downto 0);
         i_B          : in std_logic_vector(31 downto 0);
         o_F          : out std_logic_vector(31 downto 0));
end component;

component nBitAnd is 
    port(i_A          : in std_logic_vector(31 downto 0);
         i_B          : in std_logic_vector(31 downto 0);
         o_F          : out std_logic_vector(31 downto 0));
end component;

component nBitNor is 
    port(i_A          : in std_logic_vector(31 downto 0);
         i_B          : in std_logic_vector(31 downto 0);
         o_F          : out std_logic_vector(31 downto 0));
end component;

component nBitXor is 
    port(i_A          : in std_logic_vector(31 downto 0);
         i_B          : in std_logic_vector(31 downto 0);
         o_F          : out std_logic_vector(31 downto 0));
end component;

component setLessThan is 
    port(i_A          : in std_logic_vector(31 downto 0);
         i_B          : in std_logic_vector(31 downto 0);
         o_F          : out std_logic_vector(31 downto 0));
end component;

component branch is 
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       i_beq        : in std_logic;
       i_bne        : in std_logic;
       o_branchFlag     : out std_logic);
end component;

component Barrel_Shifter is 
   port(i_shamt : in std_logic_vector(4 downto 0);
	i_sign : std_logic;
	i_leftShift : std_logic;
        i_D : in std_logic_vector(31 downto 0);
        o_O : out std_logic_vector(31 downto 0));
end component;

component mux2t1_N is 
 port(i_S          : in std_logic;
      i_D0         : in std_logic_vector(31 downto 0);
      i_D1         : in std_logic_vector(31 downto 0);
      o_O          : out std_logic_vector(31 downto 0));
end component;

component mux2t1_5bit is 
 port(i_S          : in std_logic;
      i_D0         : in std_logic_vector(4 downto 0);
      i_D1         : in std_logic_vector(4 downto 0);
      o_O          : out std_logic_vector(4 downto 0));
end component;

component andg2 is 
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component xorg2 is 
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;


--Driven by the ALUOp control signal, this module will decide what operation is output by ALU
component selectOperation is 
    port(i_ALUOp   : in std_logic_vector(3 downto 0);
	 i_orResult : in std_logic_vector(31 downto 0);
	 i_andResult : in std_logic_vector(31 downto 0);
 	 i_xorResult : in std_logic_vector(31 downto 0);
 	 i_norResult : in std_logic_vector(31 downto 0);
 	 i_sltResult : in std_logic_vector(31 downto 0);
 	 i_addSubResult : in std_logic_vector(31 downto 0);
 	 i_shiftResult : in std_logic_vector(31 downto 0);
 	 o_result : out std_logic_vector(31 downto 0));
end component;


signal s_Operand       : std_logic_vector(31 downto 0); -- either RS or Immediate
signal s_orResult      : std_logic_vector(31 downto 0);
signal s_andResult     : std_logic_vector(31 downto 0);
signal s_xorResult     : std_logic_vector(31 downto 0);
signal s_norResult     : std_logic_vector(31 downto 0);
signal s_addSubResult  : std_logic_vector(31 downto 0);
signal s_addSubCarry   : std_logic;
signal s_sltResult     : std_logic_vector(31 downto 0);
signal s_shiftResult   : std_logic_vector(31 downto 0);
signal s_barrelShiftSign : std_logic;
signal s_MSB            : std_logic;
signal s_overflowDetected : std_logic;
signal s_constShamt      : std_logic_vector(4 downto 0)   := "10000";
signal s_shamt           : std_logic_vector(4 downto 0);


begin 
s_MSB <=  s_addSubResult(31);
process(i_RT, i_shiftType) --to determined the value of the sign port in the barrel shifter
begin

 if i_RT(31) = '1' and i_shiftType = '1' then   --used to determine if which sign the barrel shifter will take on based on whether it is logical or arithmetic
     s_barrelShiftSign <= '1';
 else 
     s_barrelShiftSign <= '0';
 end if;

end process;

G_MUX_IMM: mux2t1_N
  port map(i_S    => i_ALUSrc,
	   i_D0   => i_RT,
	   i_D1   => i_Imm,
	   o_O    => s_Operand);

G_MUX_LUI: mux2t1_5bit   --determines if we shift by shamt (for shift instructions) or by constant 16 for lui instruction
  port map(i_S    => i_lui,
	   i_D0   => i_shamt,
	   i_D1   => s_constShamt,
	   o_O    => s_shamt);

G_OR: nBitOr
  port map (i_A   => i_RS,
	    i_B   => s_Operand,
	    o_F   => s_orResult);

G_AND: nBitAnd
  port map (i_A   => i_RS,
	    i_B   => s_Operand,
	    o_F   => s_andResult);

G_XOR: nBitXor
  port map (i_A   => i_RS,
	    i_B   => s_Operand,
	    o_F   => s_xorResult);

G_NOR: nBitNor
  port map (i_A   => i_RS,
	    i_B   => s_Operand,
	    o_F   => s_norResult);

G_SLT: setLessThan
  port map (i_A   => i_RS,
	    i_B   => s_Operand,
	    o_F   => s_sltResult);

G_ADDSUB: nBitAddSub
   port map (input_A  => i_RS,
	     input_B  => s_Operand,
	     nAdd_Sub => i_addSub,
	     output_S => s_addSubResult,
	     output_C => s_addSubCarry,
	     o_Overflow => s_overflowDetected);


G_OVERFLOWAND: andg2     --only care about overflow flag if and only if the operation is not unsigned
   port map(i_A  => s_overflowDetected,
	    i_B  => i_signed,
	    o_F  => o_overflow);

G_SHIFT: Barrel_Shifter
   port map(i_shamt      => s_shamt,
	    i_sign       => s_barrelShiftSign,  
	    i_leftShift  => i_shiftDir,
	    i_D          => s_Operand,
	    o_O          => s_shiftResult);

G_BRANCH: branch 
   port map(i_A  => i_RS,
	    i_B  => s_Operand,
	    i_bne  => i_bne,
	    i_beq  => i_beq,
	    o_branchFlag  => o_branch);

G_SELECT: selectOperation
   port map(i_ALUOp => i_ALUOp,
	    i_orResult => s_orResult,
	    i_andResult => s_andResult,
	    i_xorResult => s_xorResult,
	    i_norResult => s_norResult,
	    i_sltResult => s_sltResult,
	    i_addSubResult => s_addSubResult,
	    i_shiftResult => s_shiftResult,
	    o_result      => o_result);	    
	
	     
	   
	   

end structure;
