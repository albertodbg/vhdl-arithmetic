--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module is the top file of an 8x8 radix-8 omsMult with k=6;

entity omsMultB8_8_synth is
	port(
		Xs: in std_logic_vector(7 downto 0);
		Ys: in std_logic_vector(7 downto 0);
		Ts: in std_logic_vector(9 downto 0);
		Gx: in std_logic_vector(0 downto 0);
		Px: in std_logic_vector(0 downto 0);
		Gy: in std_logic_vector(0 downto 0);
		Py: in std_logic_vector(0 downto 0);
		Gt: in std_logic_vector(0 downto 0);
		Pt: in std_logic_vector(0 downto 0);
		Z: out std_logic_vector(15 downto 0);
		G: out std_logic_vector(1 downto 0);
		P: out std_logic_vector(1 downto 0);
		couts: out std_logic_vector(1 downto 0)
	);
end omsMultB8_8_synth;

architecture estr of omsMultB8_8_synth is

	--Component declarations

	component omsMultB8_8_6 is
		port(
			Xs: in std_logic_vector(7 downto 0);
			Ys: in std_logic_vector(7 downto 0);
			Ts: in std_logic_vector(9 downto 0);
			Gx: in std_logic_vector(0 downto 0);
			Px: in std_logic_vector(0 downto 0);
			Gy: in std_logic_vector(0 downto 0);
			Py: in std_logic_vector(0 downto 0);
			Gt: in std_logic_vector(0 downto 0);
			Pt: in std_logic_vector(0 downto 0);
			Zs: out std_logic_vector(15 downto 0);
			Zc: out std_logic_vector(15 downto 0)
		);
	end component;

	component msAdd_16_6 is
		port(
			a: in std_logic_vector(15 downto 0);
			b: in std_logic_vector(15 downto 0);
			z: out std_logic_vector(15 downto 0);
			Gz: out std_logic_vector(1 downto 0);
			Pz: out std_logic_vector(1 downto 0);
			couts_z: out std_logic_vector(1 downto 0)
		);
	end component;

	--Signal declarations

	signal cins_z: std_logic_vector(1 downto 0);
	signal Zs: std_logic_vector(15 downto 0);
	signal Zc: std_logic_vector(15 downto 0);
	signal Zc_aux: std_logic_vector(15 downto 0);

begin

	oms_mult: omsMultB8_8_6 port map(Xs,Ys,Ts,Gx,Px,Gy,Py,Gt,Pt,Zs,Zc);

	cins_z <= (OTHERS => '0');
	Zc_aux <= Zc(14 downto 0) & '0';

	oms_addz: msAdd_16_6 port map(Zs,Zc_aux,z,G,P,couts);

end estr;
