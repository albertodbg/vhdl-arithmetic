--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a tb for the omsMult with k=8

entity omsMult_64_8_synth is
        port(
          rst: in std_logic;
		      clk: in std_logic;
		      Xs: in std_logic_vector(63 downto 0);
		      Ys: in std_logic_vector(63 downto 0);
		      Gx: in std_logic_vector(7 downto 0);
		      Px: in std_logic_vector(7 downto 0);
		      Gy: in std_logic_vector(7 downto 0);
		      Py: in std_logic_vector(7 downto 0);
		      enHit: in std_logic;
		      Z: out std_logic_vector(127 downto 0);
		      Gz: out std_logic_vector(15 downto 0);
		      Pz: out std_logic_vector(15 downto 0);
		      couts_z: out std_logic_vector(15 downto 0);
		      hit: out std_logic
        );
end omsMult_64_8_synth;


architecture estr of omsMult_64_8_synth is

  --Components declaration

  component omsMult_64_8 is
        port(
          rst: in std_logic;
          clk: in std_logic;
          Xs: in std_logic_vector(63 downto 0);--X sum component
          Ys: in std_logic_vector(63 downto 0);--Y sum component
          Gx: in std_logic_vector(7 downto 0);
          Px: in std_logic_vector(7 downto 0);
          Gy: in std_logic_vector(7 downto 0);
          Py: in std_logic_vector(7 downto 0);
          Zs: out std_logic_vector(127 downto 0);--Z sum component
          Zc: out std_logic_vector(127 downto 0)--Z carries component
        );
  end component;
  
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
  
  signal cins: std_logic_vector(15 downto 0);
  signal Zs: std_logic_vector(127 downto 0);
  signal Zc: std_logic_vector(127 downto 0);
  signal Zc_aux: std_logic_vector(127 downto 0);

begin

	oms_mult: omsMult_64_8 port map(rst,clk,Xs,Ys,Gx,Px,Gy,Py,Zs,Zc);

	cins <= (OTHERS => '0');
  Zc_aux <= Zc(126 downto 0) & '0';
  
	oms_add: msAdd_gp_2 generic map(128,8,3)
        		port map(Zs,Zc_aux,cins,z,Gz,Pz,couts_z);

end estr;


















