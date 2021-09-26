--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a 32-bit msAdd_gp with k=3;
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida and S. Ogrenci-Memik, "A Combined Arithmetic-High-Level Synthesis Solution to Deploy Partial Carry-Save Radix-8 Booth
-- Multipliers in Datapaths," in IEEE Transactions on Circuits and Systems I: Regular Papers, vol. 66, no. 2, pp. 742-755, Feb. 2019. doi:
-- 10.1109/TCSI.2018.2866172
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a 32 msAdd_gp with k=4;

entity msAdd_32_3 is
	port(
		a: in std_logic_vector(31 downto 0);
		b: in std_logic_vector(31 downto 0);
		z: out std_logic_vector(31 downto 0);
		Gz: out std_logic_vector(9 downto 0);
		Pz: out std_logic_vector(9 downto 0);
		couts_z: out std_logic_vector(9 downto 0)
	);
end msAdd_32_3;

architecture estr of msAdd_32_3 is

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

	msAdd: msAdd_gp_2 generic map(32,3,2)
		port map(a,b,cins,z,Gz,Pz,couts_z);

end estr;

