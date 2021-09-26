--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compr4to2Tree_4_16 is
	port(
		x0: in std_logic_vector(15 downto 0);
		x1: in std_logic_vector(15 downto 0);
		x2: in std_logic_vector(15 downto 0);
		x3: in std_logic_vector(15 downto 0);
		s: out std_logic_vector(15 downto 0);
		c: out std_logic_vector(15 downto 0)
	);
end compr4to2Tree_4_16;

architecture estr of compr4to2Tree_4_16 is

	--Components

	component compr4to2 is
		generic(
			N: integer
		);
		port(
			q0: in std_logic_vector((N-1) downto 0);
			q1: in std_logic_vector((N-1) downto 0);
			q2: in std_logic_vector((N-1) downto 0);
			q3: in std_logic_vector((N-1) downto 0);
			cin: in std_logic;
			r0: out std_logic_vector((N-1) downto 0);
			r1: out std_logic_vector((N-1) downto 0);
			cout: out std_logic
		);
	end component;

	--Types

	type arrayResult2D is array (0 to 3) of std_logic_vector(15 downto 0);
	type arrayResult3D is array (0 to 1) of arrayResult2D;--Array de (levels+1) x (numOps) x (sizeOps)

	--Signals

	signal matrix: arrayResult3D;
	signal zero16: std_logic_vector(15 downto 0);
	signal zero1: std_logic;

	signal cout_1_0: std_logic;
	signal shMatrix_1_1: std_logic_vector(15 downto 0);


begin

	zero1 <= '0';
	zero16 <= (OTHERS => '0');

	--Mapping level 0
	matrix(0)(0) <= x0;
	matrix(0)(1) <= x1;
	matrix(0)(2) <= x2;
	matrix(0)(3) <= x3;

	--Mapping ith levels
	--Level 1
	compr1_0: compr4to2 generic map(16)
		port map(matrix(0)(0),matrix(0)(1),matrix(0)(2),matrix(0)(3),zero1,matrix(1)(0),matrix(1)(1),cout_1_0);
	shMatrix_1_1 <= matrix(1)(1)(14 downto 0) & zero1;

	--Outputs mapping

	s <= matrix(1)(0);
	c <= matrix(1)(1);

end estr;


--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compr4to2Tree_4_16_tb is
	port(
		x0: in std_logic_vector(15 downto 0);
		x1: in std_logic_vector(15 downto 0);
		x2: in std_logic_vector(15 downto 0);
		x3: in std_logic_vector(15 downto 0);
		z: out std_logic_vector(15 downto 0);
		cout: out std_logic
	);
end compr4to2Tree_4_16_tb;

architecture tb of compr4to2Tree_4_16_tb is

	--Components

	component compr4to2Tree_4_16 is
	port(
		x0: in std_logic_vector(15 downto 0);
		x1: in std_logic_vector(15 downto 0);
		x2: in std_logic_vector(15 downto 0);
		x3: in std_logic_vector(15 downto 0);
		s: out std_logic_vector(15 downto 0);
		c: out std_logic_vector(15 downto 0)
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

	--Signals

	signal cin_ks: std_logic;
	signal cout_ks: std_logic;
	signal s: std_logic_vector(15 downto 0);
	signal c: std_logic_vector(15 downto 0);
	signal ns: std_logic_vector(16 downto 0);
	signal nc: std_logic_vector(16 downto 0);
	signal nz: std_logic_vector(16 downto 0);

begin

	tree: compr4to2Tree_4_16 port map(x0,x1,x2,x3,s,c);

	ns <= '0' & s;
	nc <= c & '0';

	cin_ks <= '0';
	ks: 	cin_ks <= '0';
	ks_ks: kogge_stone generic map(17,5)
			port map(ns,nc,cin_ks,nz,cout_ks);

	z <= nz(15 downto 0);
	cout <= nz(16);

end tb;
