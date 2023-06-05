----------------------------------------------------------------------------------
-- Engineer: Joe Mu
-- Module Name: reg_z_address - Structural
-- Description: Register with addressing and tristate IO buffer.
-- 
-- Dependencies: tristate_buffer_vector.vhd
--               reg.vhd


--COMPONENT DEFINITION FOR USE IN OTHER MODULES
--COPY PASTE THEN UNCOMMENT

--component reg_z_address is
--    generic (DATA_BUS_WIDTH : integer := 32; ADDRESS_BUS_WIDTH : integer := 16;
--            EDGE : std_logic := '1'; ADDRESS: integer := 0);
--    -- size of register in number of bits, triggering clock edge, '1' for rising, '0' for falling, address
--    port(reset, clock, enable, rw : in std_logic;
--         data_bus : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
--         address_bus : in std_logic_vector(ADDRESS_BUS_WIDTH-1 downto 0));
--end component reg_z_address;
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity reg_z_address is
    generic (DATA_BUS_WIDTH : integer := 32; ADDRESS_BUS_WIDTH : integer := 16;
            EDGE : std_logic := '1'; ADDRESS: integer := 0);
    -- size of register in number of bits, triggering clock edge, '1' for rising, '0' for falling, address
    port(reset, clock, enable, rw : in std_logic;
         data_bus : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
         address_bus : in std_logic_vector(ADDRESS_BUS_WIDTH-1 downto 0));
end reg_z_address;

architecture Structural of reg_z_address is

component reg is
    generic (n : integer := 8; edge : std_logic := '1');
    -- size of register in number of bits, triggering clock edge, '1' for rising, '0' for falling
    port(D : in std_logic_vector(n-1 downto 0); --Data in    (Reg Write)
         Clk, En, reset : in std_logic;         --Clock, Write Enable, asyc Reset
         Q : out std_logic_vector(n-1 downto 0)); --Data out (Reg Read)
end component reg;

component tristate_buffer_vector is
    generic (n: integer:= 8; Z_STATE: std_logic := '0');
    Port (input: in std_logic_vector(n-1 downto 0);
          z: in std_logic;
          output: out std_logic_vector(n-1 downto 0));
end component tristate_buffer_vector;


signal data_w, data_r: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
signal write, read, address_match, reg_enable: std_logic;

begin
    address_match <= '1' when (to_integer(unsigned(address_bus)) = ADDRESS) else '0';
    reg_enable <= address_match and enable;
    write <= reg_enable and rw;
    read <= reg_enable and (not rw);
    u_inbuf: tristate_buffer_vector generic map (n=>DATA_BUS_WIDTH, Z_STATE => '0')
                                    port map (input=>data_bus, z=>write, output=>data_w);
    u_reg: reg generic map (n=>DATA_BUS_WIDTH, edge=>EDGE)
               port map (D=>data_w, clk=>clock, en=>write, reset=>reset, Q=>data_r);
    u_outbuf: tristate_buffer_vector generic map (n=>DATA_BUS_WIDTH, Z_STATE => '0')
                                     port map (input=>data_r, z=>read, output=>data_bus);


end Structural;
