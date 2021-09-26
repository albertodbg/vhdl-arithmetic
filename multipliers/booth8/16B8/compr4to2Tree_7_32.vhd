--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a [4:2] compressor tree for 7 32-bit operands
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compr4to2Tree_7_32 is
	port(
		x0: in std_logic_vector(31 downto 0);
		x1: in std_logic_vector(31 downto 0);
		x2: in std_logic_vector(31 downto 0);
		x3: in std_logic_vector(31 downto 0);
		x4: in std_logic_vector(31 downto 0);
		x5: in std_logic_vector(31 downto 0);
		x6: in std_logic_vector(31 downto 0);
		s: out std_logic_vector(31 downto 0);
		c: out std_logic_vector(31 downto 0)
	);
end compr4to2Tree_7_32;

architecture estr of compr4to2Tree_7_32 is

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

	type arrayResult2D is array (0 to 6) of std_logic_vector(31 downto 0);
	type arrayResult3D is array (0 to 2) of arrayResult2D;--Array of (levels+1) x (numOps) x (sizeOps)

	--Signals

	signal matrix: arrayResult3D;
	signal zero32: std_logic_vector(31 downto 0);
	signal zero1: std_logic;

	signal cout_1_0: std_logic;
	signal cout_1_1: std_logic;
	signal cout_2_0: std_logic;
	signal shMatrix_1_1: std_logic_vector(31 downto 0);
	signal shMatrix_1_3: std_logic_vector(31 downto 0);
	signal shMatrix_2_1: std_logic_vector(31 downto 0);


begin

	zero1 <= '0';
	zero32 <= (OTHERS => '0');

	--Mapping level 0
	matrix(0)(0) <= x0;
	matrix(0)(1) <= x1;
	matrix(0)(2) <= x2;
	matrix(0)(3) <= x3;
	matrix(0)(4) <= x4;
	matrix(0)(5) <= x5;
	matrix(0)(6) <= x6;

	--Mapping ith levels
	--Level 1
	compr1_0: compr4to2 generic map(32)
		port map(matrix(0)(0),matrix(0)(1),matrix(0)(2),matrix(0)(3),zero1,matrix(1)(0),matrix(1)(1),cout_1_0);
	shMatrix_1_1 <= matrix(1)(1)(30 downto 0) & zero1;
	compr1_1: compr4to2 generic map(32)
		port map(matrix(0)(4),matrix(0)(5),matrix(0)(6),zero32,zero1,matrix(1)(2),matrix(1)(3),cout_1_1);
	shMatrix_1_3 <= matrix(1)(3)(30 downto 0) & zero1;
	--Level 2
	compr2_0: compr4to2 generic map(32)
		port map(matrix(1)(0),shMatrix_1_1,matrix(1)(2),shMatrix_1_3,zero1,matrix(2)(0),matrix(2)(1),cout_2_0);
	shMatrix_2_1 <= matrix(2)(1)(30 downto 0) & zero1;

	--Outputs mapping

	s <= matrix(2)(0);
	c <= matrix(2)(1);

end estr;


--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compr4to2Tree_7_32_tb is
	port(
		x0: in std_logic_vector(31 downto 0);
		x1: in std_logic_vector(31 downto 0);
		x2: in std_logic_vector(31 downto 0);
		x3: in std_logic_vector(31 downto 0);
		x4: in std_logic_vector(31 downto 0);
		x5: in std_logic_vector(31 downto 0);
		x6: in std_logic_vector(31 downto 0);
		z: out std_logic_vector(31 downto 0);
		cout: out std_logic
	);
end compr4to2Tree_7_32_tb;

architecture tb of compr4to2Tree_7_32_tb is

	--Components

	component compr4to2Tree_7_32 is
	port(
		x0: in std_logic_vector(31 downto 0);
		x1: in std_logic_vector(31 downto 0);
		x2: in std_logic_vector(31 downto 0);
		x3: in std_logic_vector(31 downto 0);
		x4: in std_logic_vector(31 downto 0);
		x5: in std_logic_vector(31 downto 0);
		x6: in std_logic_vector(31 downto 0);
		s: out std_logic_vector(31 downto 0);
		c: out std_logic_vector(31 downto 0)
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
	signal s: std_logic_vector(31 downto 0);
	signal c: std_logic_vector(31 downto 0);
	signal ns: std_logic_vector(32 downto 0);
	signal nc: std_logic_vector(32 downto 0);
	signal nz: std_logic_vector(32 downto 0);

begin

	tree: compr4to2Tree_7_32 port map(x0,x1,x2,x3,x4,x5,x6,s,c);

	ns <= '0' & s;
	nc <= c & '0';

	cin_ks <= '0';
	ks: 	cin_ks <= '0';
	ks_ks: kogge_stone generic map(33,6)
			port map(ns,nc,cin_ks,nz,cout_ks);

	z <= nz(31 downto 0);
	cout <= nz(32);

end tb;
