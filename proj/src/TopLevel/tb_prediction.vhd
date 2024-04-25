LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

ENTITY tb_prediction IS
    GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END ENTITY tb_prediction;

ARCHITECTURE tb OF tb_prediction IS

    -- Define the total clock period time
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT prediction
        PORT (
            i_clk : IN STD_LOGIC; -- Clock input
            i_branch : IN STD_LOGIC; -- if the branch is true or not
            o_Out : OUT STD_LOGIC); -- whether we predict true or false
    END COMPONENT;

    SIGNAL s_branch, s_Out, s_clk : STD_LOGIC;

BEGIN

    DUT0 : prediction
    PORT MAP(
        i_clk => s_clk,
        i_branch => s_branch,
        o_Out => s_Out);

    P_CLK : PROCESS
    BEGIN
        s_clk <= '0';
        WAIT FOR gCLK_HPER;
        s_clk <= '1';
        WAIT FOR gCLK_HPER;
    END PROCESS;

    P_TB : PROCESS
    BEGIN

        -- TEST 1
        s_branch <= '1';
        WAIT FOR 20 ns;

        -- TEST 2
        s_branch <= '0';
        WAIT FOR 20 ns;

        -- TEST 3
        s_branch <= '0';
        WAIT FOR 20 ns;

        -- TEST 4
        s_branch <= '1';
        WAIT FOR 20 ns;

        -- TEST 5
        s_branch <= '0';
        WAIT;


  END PROCESS;

  END ARCHITECTURE tb;