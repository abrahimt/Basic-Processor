LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY prediction IS
    PORT (
        i_branch : IN STD_LOGIC; -- Input: indicates if the branch is true or not
        o_Out : OUT STD_LOGIC); -- Output: predicted true or false
END prediction;

ARCHITECTURE structure OF prediction IS
    SIGNAL s_location : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11"; -- 2-bit vector to determine prediction (initially set to true)
BEGIN
    -- Output assignment based on current state
    o_Out <= '1' WHEN (s_location = "11") ELSE -- Predict true if s_location is "11"
        '1' WHEN (s_location = "10") ELSE -- Predict true if s_location is "10"
        '0' WHEN (s_location = "01") ELSE -- Predict false if s_location is "01"
        '0' WHEN (s_location = "00") ELSE -- Predict false if s_location is "00"
        '0'; -- Default prediction

    -- State transition logic based on input branch
    s_location <= "10" WHEN (i_branch = '0' AND s_location = "11") ELSE -- Transition to "10" if input is '0' and previous state is "11"
        "01" WHEN (i_branch = '0' AND s_location = "10") ELSE -- Transition to "01" if input is '0' and previous state is "10"
        "00" WHEN (i_branch = '0' AND s_location = "01") ELSE -- Transition to "00" if input is '0' and previous state is "01"
        "00" WHEN (i_branch = '0' AND s_location = "00") ELSE -- Stay at "00" if input is '0' and previous state is "00"
        "11" WHEN (i_branch = '1' AND s_location = "11") ELSE -- Stay at "11" if input is '1' and previous state is "11"
        "11" WHEN (i_branch = '1' AND s_location = "10") ELSE -- Stay at "11" if input is '1' and previous state is "10"
        "10" WHEN (i_branch = '1' AND s_location = "01") ELSE -- Transition to "10" if input is '1' and previous state is "01"
        "01" WHEN (i_branch = '1' AND s_location = "00") ELSE -- Transition to "01" if input is '1' and previous state is "00"
        "00"; -- Default transition
END structure;