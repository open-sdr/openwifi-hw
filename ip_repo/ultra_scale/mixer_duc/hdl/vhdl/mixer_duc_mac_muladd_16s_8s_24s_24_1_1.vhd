-- ==============================================================
-- File generated on Mon Mar 09 18:12:13 CET 2020
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2018.3 (64-bit)
-- SW Build 2405991 on Thu Dec  6 23:36:41 MST 2018
-- IP Build 2404404 on Fri Dec  7 01:43:56 MST 2018
-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mixer_duc_mac_muladd_16s_8s_24s_24_1_1_DSP48_2 is
port (
    in0:  in  std_logic_vector(16 - 1 downto 0);
    in1:  in  std_logic_vector(8 - 1 downto 0);
    in2:  in  std_logic_vector(24 - 1 downto 0);
    dout: out std_logic_vector(24 - 1 downto 0));

end entity;

architecture behav of mixer_duc_mac_muladd_16s_8s_24s_24_1_1_DSP48_2 is
    signal a       : signed(27-1 downto 0);
    signal b       : signed(18-1 downto 0);
    signal c       : signed(48-1 downto 0);
    signal m       : signed(45-1 downto 0);
    signal p       : signed(48-1 downto 0);
begin
a  <= signed(resize(signed(in0), 27));
b  <= signed(resize(signed(in1), 18));
c  <= signed(resize(signed(in2), 48));

m  <= a * b;
p  <= m + c;

dout <= std_logic_vector(resize(unsigned(p), 24));

end architecture;
Library IEEE;
use IEEE.std_logic_1164.all;

entity mixer_duc_mac_muladd_16s_8s_24s_24_1_1 is
    generic (
        ID : INTEGER;
        NUM_STAGE : INTEGER;
        din0_WIDTH : INTEGER;
        din1_WIDTH : INTEGER;
        din2_WIDTH : INTEGER;
        dout_WIDTH : INTEGER);
    port (
        din0 : IN STD_LOGIC_VECTOR(din0_WIDTH - 1 DOWNTO 0);
        din1 : IN STD_LOGIC_VECTOR(din1_WIDTH - 1 DOWNTO 0);
        din2 : IN STD_LOGIC_VECTOR(din2_WIDTH - 1 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR(dout_WIDTH - 1 DOWNTO 0));
end entity;

architecture arch of mixer_duc_mac_muladd_16s_8s_24s_24_1_1 is
    component mixer_duc_mac_muladd_16s_8s_24s_24_1_1_DSP48_2 is
        port (
            in0 : IN STD_LOGIC_VECTOR;
            in1 : IN STD_LOGIC_VECTOR;
            in2 : IN STD_LOGIC_VECTOR;
            dout : OUT STD_LOGIC_VECTOR);
    end component;



begin
    mixer_duc_mac_muladd_16s_8s_24s_24_1_1_DSP48_2_U :  component mixer_duc_mac_muladd_16s_8s_24s_24_1_1_DSP48_2
    port map (
        in0 => din0,
        in1 => din1,
        in2 => din2,
        dout => dout);

end architecture;


