----------------------------------------------------------------------------------
-- Register with asyn reset(clear),
-- enable and configurable triggering clk edge and size
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
 generic (n : integer := 8; edge : std_logic := '1');
 -- size of register in number of bits, triggering clock edge, '1' for rising, '0' for falling
 port(D : in std_logic_vector(n-1 downto 0); --Data in    (Reg Write)
      Clk, En, reset : in std_logic;         --Clock, Write Enable, asyc Reset
      Q : out std_logic_vector(n-1 downto 0)); --Data out (Reg Read)
end reg;

architecture Behavioral of reg is
    begin
        process(Clk, reset)
        begin
            if (reset = '1') then
                Q <= (others => '0');
            elsif Clk'event and Clk = edge then
                if En = '1' then
                    Q <= D;
                end if;
            end if; 
        end process;       
end Behavioral;
