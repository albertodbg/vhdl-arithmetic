--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module is the top file of an 32x32 omsMult with k=4;

entity omsMult_32_synth is
	port(
		rst: in std_logic;
		clk: in std_logic;
		Xs: in std_logic_vector(31 downto 0);
		Ys: in std_logic_vector(31 downto 0);
		Gx: in std_logic_vector(7 downto 0);
		Px: in std_logic_vector(7 downto 0);
		Gy: in std_logic_vector(7 downto 0);
		Py: in std_logic_vector(7 downto 0);
		enHit: in std_logic;
		Z: out std_logic_vector(63 downto 0);
		G: out std_logic_vector(15 downto 0);
		P: out std_logic_vector(15 downto 0);
		couts: out std_logic_vector(15 downto 0);
		hit: out std_logic
	);
end omsMult_32_synth;

architecture estr of omsMult_32_synth is

	--Component declarations

	component omsMult_32_4 is
		port(
			Xs: in std_logic_vector(31 downto 0);
			Ys: in std_logic_vector(31 downto 0);
			Gx: in std_logic_vector(7 downto 0);
			Px: in std_logic_vector(7 downto 0);
			Gy: in std_logic_vector(7 downto 0);
			Py: in std_logic_vector(7 downto 0);
			Zs: out std_logic_vector(63 downto 0);
			Zc: out std_logic_vector(63 downto 0)
		);
	end component;

	component msAdd_64_4 is
		port(
			a: in std_logic_vector(63 downto 0);
			b: in std_logic_vector(63 downto 0);
			z: out std_logic_vector(63 downto 0);
			Gz: out std_logic_vector(15 downto 0);
			Pz: out std_logic_vector(15 downto 0);
			couts_z: out std_logic_vector(15 downto 0)
		);
	end component;

	--Signal declarations

	signal cins_z: std_logic_vector(15 downto 0);
	signal Zs: std_logic_vector(63 downto 0);
	signal Zc: std_logic_vector(63 downto 0);
	signal Zc_aux: std_logic_vector(63 downto 0);

begin

	oms_mult: omsMult_32_4 port map(Xs,Ys,Gx,Px,Gy,Py,Zs,Zc);

	cins_z <= (OTHERS => '0');
	Zc_aux <= Zc(62 downto 0) & '0';

	oms_addz: msAdd_64_4 port map(Zs,Zc_aux,z,G,P,couts);

end estr;
