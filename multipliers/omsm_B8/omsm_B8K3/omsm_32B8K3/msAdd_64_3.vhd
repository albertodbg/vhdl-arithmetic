--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a 64 msAdd_gp with k=3;

entity msAdd_64_3 is
	port(
		a: in std_logic_vector(63 downto 0);
		b: in std_logic_vector(63 downto 0);
		z: out std_logic_vector(63 downto 0);
		Gz: out std_logic_vector(20 downto 0);
		Pz: out std_logic_vector(20 downto 0);
		couts_z: out std_logic_vector(20 downto 0)
	);
end msAdd_64_3;

architecture estr of msAdd_64_3 is

	--Component declarations

	component msAdd_gp_2 is
		generic(
			N: integer;
			K: integer;
			LOG_K: integer
		);
		port(
			a: in std_logic_vector((N-1) downto 0);
			b: in std_logic_vector((N-1) downto 0);
			cins: in std_logic_vector((N/K-1) downto 0);
			z: out std_logic_vector((N-1) downto 0);
			Gz: out std_logic_vector((N/K-1) downto 0);
			Pz: out std_logic_vector((N/K-1) downto 0);
			couts_z: out std_logic_vector((N/K-1) downto 0)
		);
	end component;

	--Signal declarations

	signal cins: std_logic_vector((Gz'length-1) downto 0);

begin

	cins <= (OTHERS => '0');

	msAdd: msAdd_gp_2 generic map(64,3,2)
		port map(a,b,cins,z,Gz,Pz,couts_z);

end estr;

