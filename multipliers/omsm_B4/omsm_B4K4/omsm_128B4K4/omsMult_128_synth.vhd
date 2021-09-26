--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a 128x128 omsMult

entity omsMult_128_synth is
        port(
          Xs: in std_logic_vector(127 downto 0);--X sum component
          Ys: in std_logic_vector(127 downto 0);--Y sum component
          Gx: in std_logic_vector(31 downto 0);
          Px: in std_logic_vector(31 downto 0);
          Gy: in std_logic_vector(31 downto 0);
          Py: in std_logic_vector(31 downto 0);
          Z: out std_logic_vector(255 downto 0);
          Gz: out std_logic_vector(63 downto 0);
          Pz: out std_logic_vector(63 downto 0);
          couts_z: out std_logic_vector(63 downto 0)
        );
end omsMult_128_synth;


architecture estr of omsMult_128_synth is

  --Components declaration

  component omsMult_128_4 is
        port(
          Xs: in std_logic_vector(127 downto 0);--X sum component
          Ys: in std_logic_vector(127 downto 0);--Y sum component
          Gx: in std_logic_vector(31 downto 0);
          Px: in std_logic_vector(31 downto 0);
          Gy: in std_logic_vector(31 downto 0);
          Py: in std_logic_vector(31 downto 0);
          Zs: out std_logic_vector(255 downto 0);--Z sum component
          Zc: out std_logic_vector(255 downto 0)--Z carries component
        );
  end component;
  
  component msAdd_256_4 is
	port(
		a: in std_logic_vector(255 downto 0);
		b: in std_logic_vector(255 downto 0);
		z: out std_logic_vector(255 downto 0);
		Gz: out std_logic_vector(63 downto 0);
		Pz: out std_logic_vector(63 downto 0);
		couts_z: out std_logic_vector(63 downto 0)
	);
  end component;
  
  
  --Signal declarations
  
  signal Zs: std_logic_vector(255 downto 0);
  signal Zc: std_logic_vector(255 downto 0);

begin
                          
  oms_mult: omsMult_128_4 port map(Xs,Ys,Gx,Px,Gy,Py,Zs,Zc);
  
  oms_add: msAdd_256_4 port map(Zs,Zc,Z,Gz,Pz,couts_z);

end estr;


















