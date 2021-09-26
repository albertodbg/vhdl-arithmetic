--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a 32 msAdd_gp with k=4;

entity msAdd_32_4 is
	port(
		a: in std_logic_vector(31 downto 0);
		b: in std_logic_vector(31 downto 0);
		z: out std_logic_vector(31 downto 0);
		Gz: out std_logic_vector(7 downto 0);
		Pz: out std_logic_vector(7 downto 0);
		couts_z: out std_logic_vector(7 downto 0)
	);
end msAdd_32_4;

architecture estr of msAdd_32_4 is

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

	signal cins: std_logic_vector(7 downto 0);

begin

	cins <= (OTHERS => '0');

	msAdd: msAdd_gp_2 generic map(32,4,2)
		port map(a,b,cins,z,Gz,Pz,couts_z);

end estr;

