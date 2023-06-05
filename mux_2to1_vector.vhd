
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux_2to1_vector is
    generic(n: integer := 8);
    port (a0, a1: in std_logic_vector(n-1 downto 0);
          sel: in std_logic;
          b: out std_logic_vector(n-1 downto 0));
end entity mux_2to1_vector;

architecture Behavioral of mux_2to1_vector is

begin
    b <= a1 when sel = '1' else a0;
end Behavioral;
