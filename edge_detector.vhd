----------------------------------------------------------------------------------
-- edge_detector.vhd
-- Author: Joe Mu
-- May 2023
-- Design Name: Edge Detector
-- detects rising or falling edge of a signal and outputs a single clock cycle pulse


-- based on code and discussions on Stack overflow post
-- https://stackoverflow.com/questions/17429280/vhdl-edge-detection
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity edge_detector is
    generic (rising : std_logic := '1'; -- set to 1 to detect rising
             falling : std_logic := '0' -- set to 1 to detect falling, both to 1 to detect both edges
             );
    Port (clk, sig: in std_logic; --clock and the signal to perform detection on
          pulse: out std_logic);   --output pulse
end edge_detector;

architecture Behavioral of edge_detector is
signal prev, pulse_rise, pulse_fall : std_logic;

begin
    process (clk) is

    begin
        if (clk = '1' and clk'event) then
            pulse_rise <= sig and (not prev); --rising edge detection pulse
            pulse_fall <= (not sig) and prev; --falling edge
            prev <= sig;  
        end if;
    end process;
    pulse <= (pulse_rise and rising) or (pulse_fall and falling); --outputs the corresponding pulse

end Behavioral;
