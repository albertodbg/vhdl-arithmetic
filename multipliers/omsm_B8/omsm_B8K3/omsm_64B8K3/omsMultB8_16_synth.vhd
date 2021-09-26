--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module is the top file of an 16x16 radix-8 omsMult with k=3;

entity omsMultB8_16_synth is
	port(
		rst: in std_logic;
		clk: in std_logic;
		Xs: in std_logic_vector(15 downto 0);
		Ys: in std_logic_vector(15 downto 0);
		Ts: in std_logic_vector(17 downto 0);
		Gx: in std_logic_vector(4 downto 0);
		Px: in std_logic_vector(4 downto 0);
		Gy: in std_logic_vector(4 downto 0);
		Py: in std_logic_vector(4 downto 0);
		Gt: in std_logic_vector(5 downto 0);
		Pt: in std_logic_vector(5 downto 0);
		enHit: in std_logic;
		Z: out std_logic_vector(31 downto 0);
		G: out std_logic_vector(9 downto 0);
		P: out std_logic_vector(9 downto 0);
		couts: out std_logic_vector(9 downto 0);
		hit: out std_logic
	);
end omsMultB8_16_synth;

architecture estr of omsMultB8_16_synth is

	--Component declarations

	component omsMultB8_16_3 is
		port(
			Xs: in std_logic_vector(15 downto 0);
			Ys: in std_logic_vector(15 downto 0);
			Ts: in std_logic_vector(17 downto 0);
			Gx: in std_logic_vector(4 downto 0);
			Px: in std_logic_vector(4 downto 0);
			Gy: in std_logic_vector(4 downto 0);
			Py: in std_logic_vector(4 downto 0);
			Gt: in std_logic_vector(5 downto 0);
			Pt: in std_logic_vector(5 downto 0);
			Zs: out std_logic_vector(31 downto 0);
			Zc: out std_logic_vector(31 downto 0)
		);
	end component;

	component msAdd_32_3 is
		port(
			rst: in std_logic;
			clk: in std_logic;
			a: in std_logic_vector(31 downto 0);
			b: in std_logic_vector(31 downto 0);
			cins: in std_logic_vector(9 downto 0);
			enHit: in std_logic;
			z: out std_logic_vector(31 downto 0);
			G: out std_logic_vector(9 downto 0);
			P: out std_logic_vector(9 downto 0);
			couts: out std_logic_vector(9 downto 0);
			hit: out std_logic
		);
	end component;

	--Signal declarations

	signal cins_z: std_logic_vector(9 downto 0);
	signal Zs: std_logic_vector(31 downto 0);
	signal Zc: std_logic_vector(31 downto 0);
	signal Zc_aux: std_logic_vector(31 downto 0);

begin

	oms_mult: omsMultB8_16_3 port map(Xs,Ys,Ts,Gx,Px,Gy,Py,Gt,Pt,Zs,Zc);

	cins_z <= (OTHERS => '0');
	Zc_aux <= Zc(30 downto 0) & '0';

	oms_addz: msAdd_32_3 port map(rst,clk,Zs,Zc_aux,cins_z,enHit,z,G,P,couts,hit);

end estr;
