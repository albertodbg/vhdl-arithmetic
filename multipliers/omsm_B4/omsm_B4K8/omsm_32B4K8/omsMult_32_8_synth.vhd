--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module is the top file of an 32x32 omsMult with k=8;

entity omsMult_32_8_synth is
	port(
		rst: in std_logic;
		clk: in std_logic;
		Xs: in std_logic_vector(31 downto 0);
		Ys: in std_logic_vector(31 downto 0);
		Gx: in std_logic_vector(3 downto 0);
		Px: in std_logic_vector(3 downto 0);
		Gy: in std_logic_vector(3 downto 0);
		Py: in std_logic_vector(3 downto 0);
		enHit: in std_logic;
		Z: out std_logic_vector(63 downto 0);
		Gz: out std_logic_vector(7 downto 0);
		Pz: out std_logic_vector(7 downto 0);
		couts_z: out std_logic_vector(7 downto 0);
		hit: out std_logic
	);
end omsMult_32_8_synth;

architecture estr of omsMult_32_8_synth is

	--Component declarations

	component omsMult_32_8_piped is
	port(
		rst: in std_logic;
		clk: in std_logic;
		Xs: in std_logic_vector(31 downto 0);
		Ys: in std_logic_vector(31 downto 0);
		Gx: in std_logic_vector(3 downto 0);
		Px: in std_logic_vector(3 downto 0);
		Gy: in std_logic_vector(3 downto 0);
		Py: in std_logic_vector(3 downto 0);
		Zs: out std_logic_vector(63 downto 0);
		Zc: out std_logic_vector(63 downto 0)
	);
  end component;

	component msAdd_gp_piped is
		generic(
			N: integer;
			K: integer;
			LOG_K: integer;
			LOG_N_DIV_K: integer
		);
		port(
			rst: in std_logic;
			clk: in std_logic;
			a: in std_logic_vector((N-1) downto 0);
			b: in std_logic_vector((N-1) downto 0);
			cins: in std_logic_vector((N/K-1) downto 0);
			enHit: in std_logic;
			z: out std_logic_vector((N-1) downto 0);
			Gz: out std_logic_vector((N/K-1) downto 0);
			Pz: out std_logic_vector((N/K-1) downto 0);
			couts_z: out std_logic_vector((N/K-1) downto 0);
			hit: out std_logic
		);
	end component;

	component reg is
		generic(N: integer);
		port(
			rst: in std_logic;
			clk: in std_logic;
			load: in std_logic;
			d: in std_logic_vector((N-1) downto 0);
			q: out std_logic_vector((N-1) downto 0)
		);
	end component;

	--Signal declarations

	signal cins_z: std_logic_vector((couts_z'length-1) downto 0);
	signal Zs: std_logic_vector(63 downto 0);
	signal Zc: std_logic_vector(63 downto 0);
	signal Zc_aux: std_logic_vector(63 downto 0);

	signal rZs: std_logic_vector(63 downto 0);
	signal rZc_aux: std_logic_vector(63 downto 0);
	signal one: std_logic;

begin

	one <= '1';

	oms_mult: omsMult_32_8_piped port map(rst,clk,Xs,Ys,Gx,Px,Gy,Py,Zs,Zc);

	cins_z <= (OTHERS => '0');
	Zc_aux <= Zc(62 downto 0) & '0';

	--For the pipelined version
	--regZs: reg generic map(64)
			--port map(rst,clk,one,Zs,rZs);

	--regZc: reg generic map(64)
			--port map(rst,clk,one,Zc_aux,rZc_aux);

	oms_addz: msAdd_gp_piped generic map(64,8,3,3)
		 --port map(rst,clk,rZs,rZc_aux,cins_z,enHit,z,Gz,Pz,couts_z,hit);
		 port map(rst,clk,Zs,Zc_aux,cins_z,enHit,z,Gz,Pz,couts_z,hit);

end estr;


