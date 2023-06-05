----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.06.2023 13:57:33
-- Design Name: 
-- Module Name: tristate_buffer_vector - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tristate_buffer_vector is
    generic (n: integer:= 8; Z_STATE: std_logic := '0');
    Port (input: in std_logic_vector(n-1 downto 0);
          z: in std_logic;
          output: out std_logic_vector(n-1 downto 0));
end tristate_buffer_vector;

architecture Behavioral of tristate_buffer_vector is

begin
    output <= (others=>'Z') when z = Z_STATE else input;
end Behavioral;
