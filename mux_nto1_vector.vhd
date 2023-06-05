----------------------------------------------------------------------------------
-- Author: Joe Mu

-- Create Date: 04.06.2023 15:47:14
-- Module Name: mux_nto1_vector - Behavioral

-- Description: Multiplexer (vector inputs/outputs) with arbitrary number of inputs
-- 
-- Dependencies: 2 to 1 multiplexer mux_2to1_vector.vhd
-- 
-- Revision 0.10 - RTL working, more testing needed
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux_nto1_vector is
    generic (N_SEL_BIT: integer := 5;
             N_BIT: integer:= 8);
    Port (input: in std_logic_vector ((2**N_SEL_BIT)*N_BIT - 1 downto 0);
          sel: in std_logic_vector(N_SEL_BIT - 1 downto 0);
          output: out std_logic_vector (N_BIT - 1 downto 0));
end mux_nto1_vector;

architecture Behavioral of mux_nto1_vector is

component mux_2to1_vector is
    generic(n: integer := 8);
    port (a0, a1: in std_logic_vector(n-1 downto 0);
          sel: in std_logic;
          b: out std_logic_vector(n-1 downto 0));
end component mux_2to1_vector;


--type array_2d is array (natural range<>, natural range<>) of std_logic;
constant N_INPUT: integer:= 2 ** N_SEL_BIT;
signal misc: std_logic_vector(N_INPUT*N_BIT - 1 downto 0);



begin
    mux_2to1_layer1: for i in 0 to N_INPUT/2 - 1 generate
            mux_2to1: mux_2to1_vector generic map(n=> N_BIT)
                                      port map (a0=>input((i*2+1)*N_BIT - 1 downto (i*2)*N_BIT),
                                                a1=>input((i*2+2)*N_BIT - 1 downto (i*2+1)*N_BIT),
                                                sel=>sel(0), b=>misc((i+1)*N_BIT - 1 downto i*N_BIT));
    end generate;
    mux_layer: for i in 1 to N_SEL_BIT - 1 generate
        constant n_in_layer: integer:= 2**(N_SEL_BIT - 1 - i);
        constant signal_i: integer := N_INPUT-4*(n_in_layer);
        begin
        mux: for j in 0 to n_in_layer-1 generate
            mux_2to1: mux_2to1_vector generic map(n=> N_BIT)
                                      port map (a0=>misc((signal_i+j*2+1)*N_BIT - 1 downto (signal_i+j*2)*N_BIT),
                                                a1=>misc((signal_i+j*2+2)*N_BIT - 1 downto (signal_i+j*2+1)*N_BIT),
                                                sel=>sel(i), b=>misc((signal_i+j+n_in_layer*2+1)*N_BIT - 1 downto (signal_i+j+n_in_layer*2)*N_BIT));
        end generate;
    end generate;
    
    output<=misc((N_INPUT-1)*N_BIT -1 downto (N_INPUT-2)*N_BIT);


end Behavioral;
