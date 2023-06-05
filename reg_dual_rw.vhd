----------------------------------------------------------------------------------
-- Author Joe Mu
-- 
-- Create Date: 02.06.2023 15:15:48
-- Module Name: reg_dual_rw - Behavioral

-- Description: register with two read/write modes
--              configurable address to use with data/address bus
--              special read&write for access directly from within a module
--              useful as eg. GP register in CPU or control registers for peripherals
-- 
-- Dependencies: reg.vhd   register with configurable size and capture edge
--               tristate_buffer_vector.vhd tristate buffer
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:



-- -- component definition
--component reg_dual_rw is
--    generic (DATA_BUS_WIDTH : integer := 32; ADDRESS_BUS_WIDTH : integer := 16;
--            EDGE : std_logic := '1'; ADDRESS: integer := 0);
--    -- size of register in number of bits, triggering clock edge, '1' for rising, '0' for falling, address
--    port(reset, clock, enable, rw : in std_logic;
--         data_bus : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
--         address_bus : in std_logic_vector(ADDRESS_BUS_WIDTH-1 downto 0);
--         w_special: in std_logic;
--         data_write: in std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
--         data_read: out std_logic_vector(DATA_BUS_WIDTH-1 downto 0));
--end component reg_dual_rw;
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity reg_dual_rw is
    generic (DATA_BUS_WIDTH : integer := 32;
            ADDRESS_BUS_WIDTH : integer := 16;
            EDGE : std_logic := '1';            -- which clock edge is used to trigger a capture '1' for rising '0' for falling
            ADDRESS: integer := 0;              -- address of the register on the memory bus
            BUS_HAS_PRIORITY: std_logic := '1');-- if bus write or special write has priority when both are trying to write.
                                                -- eg. bus should have priority for GPIO data reg.
    port(reset, clock, enable: in std_logic; -- async reset, clock, enable
         --------memory bus read&write------------------------------------
         rw: in std_logic;  --read or write from memory bus, write is '1' read is '0'.
         data_bus : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
         address_bus : in std_logic_vector(ADDRESS_BUS_WIDTH-1 downto 0);
         --------special read&write---------------------------------------
         w_special: in std_logic;                 -- special write enable, will only write to register if '1'
         data_write: in std_logic_vector(DATA_BUS_WIDTH-1 downto 0); --the data to be written into the register
         data_read: out std_logic_vector(DATA_BUS_WIDTH-1 downto 0));--data to be read, always active
end reg_dual_rw;


architecture Structural of reg_dual_rw is

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
signal normal_write, special_write, write, read, address_match, reg_enable: std_logic;

begin
    address_match <= '1' when (to_integer(unsigned(address_bus)) = ADDRESS) else '0';
    reg_enable <= address_match and enable;
    normal_write <= reg_enable and rw and (BUS_HAS_PRIORITY or (not w_special));
    read <= reg_enable and (not rw);
    write <= normal_write or w_special;
    special_write <= w_special and not normal_write;
    u_inbuf: tristate_buffer_vector generic map (n=>DATA_BUS_WIDTH, Z_STATE => '0')
                                    port map (input=>data_bus, z=>normal_write, output=>data_w);
    u_inbuf_special: tristate_buffer_vector generic map (n=>DATA_BUS_WIDTH, Z_STATE => '0')
                                    port map (input=>data_write, z=>special_write, output=>data_w);
    u_reg: reg generic map (n=>DATA_BUS_WIDTH, edge=>EDGE)
               port map (D=>data_w, clk=>clock, en=>write, reset=>reset, Q=>data_r);
    u_outbuf: tristate_buffer_vector generic map (n=>DATA_BUS_WIDTH, Z_STATE => '0')
                                     port map (input=>data_r, z=>read, output=>data_bus);
    data_read <= data_r;


end Structural;
