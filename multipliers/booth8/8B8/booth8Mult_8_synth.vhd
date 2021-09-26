--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module is the top file of an 8x8 msMult;

entity booth8Mult_8_synth is
	port(
		X: in std_logic_vector(7 downto 0);
		Y: in std_logic_vector(7 downto 0);
		Z: out std_logic_vector(15 downto 0)
	);
end booth8Mult_8_synth;

architecture estr of booth8Mult_8_synth is

	--Component declarations

	component booth8Mult_8 is
		port(
			X: in std_logic_vector(7 downto 0);
			Y: in std_logic_vector(7 downto 0);
			Zs: out std_logic_vector(15 downto 0);
			Zc: out std_logic_vector(15 downto 0)
		);
	end component;

	component kogge_stone is
		generic(N: integer;
			S: integer);--Number of stages
		port(
			a: in std_logic_vector((N-1) downto 0);
			b: in std_logic_vector((N-1) downto 0);
			cin: in std_logic;
			z: out std_logic_vector((N-1) downto 0);
			cout: out std_logic
		);
	end component;

	--Signal declarations

	signal cin_z: std_logic;
	signal cout_z: std_logic;
	signal Zs: std_logic_vector(15 downto 0);
	signal Zc: std_logic_vector(15 downto 0);
	signal Zc_aux: std_logic_vector(15 downto 0);

begin

	booth8_mult: booth8Mult_8 port map(X,Y,Zs,Zc);

	Zc_aux <= Zc(14 downto 0) & '0';

		cin_z <= '0';
	ks_z: kogge_stone generic map(16,4)
			port map(Zs,Zc_aux,cin_z,z,cout_z);


end estr;
