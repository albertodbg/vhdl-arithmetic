--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a 16x16 multiplier based on the OMSM-B4, with k=4
-- This is the top module
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida, S. O. Memik, “A partial carry-save on-the-
-- fly correction multispeculative multiplier,” IEEE Trans. Comput., vol. 65, no. 11, pp. -- 3251–3264, Nov. 2016.
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity omsMult_16_4_synth is
        port(
          Xs: in std_logic_vector(15 downto 0);--X sum component
          Ys: in std_logic_vector(15 downto 0);--Y sum component
          Gx: in std_logic_vector(3 downto 0);
          Px: in std_logic_vector(3 downto 0);
          Gy: in std_logic_vector(3 downto 0);
          Py: in std_logic_vector(3 downto 0);
          Z: out std_logic_vector(31 downto 0);
          Gz: out std_logic_vector(7 downto 0);
          Pz: out std_logic_vector(7 downto 0);
          couts_z: out std_logic_vector(7 downto 0)
        );
end omsMult_16_4_synth;


architecture estr of omsMult_16_4_synth is

  --Components declaration

  component omsMult_16_4 is
        port(
          Xs: in std_logic_vector(15 downto 0);--X sum component
          Ys: in std_logic_vector(15 downto 0);--Y sum component
          Gx: in std_logic_vector(3 downto 0);
          Px: in std_logic_vector(3 downto 0);
          Gy: in std_logic_vector(3 downto 0);
          Py: in std_logic_vector(3 downto 0);
          Zs: out std_logic_vector(31 downto 0);--Z sum component
          Zc: out std_logic_vector(31 downto 0)--Z carries component
        );
  end component;
  
  component msAdd_32_4 is
	port(
		a: in std_logic_vector(31 downto 0);
		b: in std_logic_vector(31 downto 0);
		z: out std_logic_vector(31 downto 0);
		Gz: out std_logic_vector(7 downto 0);
		Pz: out std_logic_vector(7 downto 0);
		couts_z: out std_logic_vector(7 downto 0)
	);
  end component;
  
  
  --Signal declarations
  
  signal Zs: std_logic_vector(31 downto 0);
  signal Zc: std_logic_vector(31 downto 0);

begin
                          
  oms_mult: omsMult_16_4 port map(Xs,Ys,Gx,Px,Gy,Py,Zs,Zc);
  
  oms_add: msAdd_32_4 port map(Zs,Zc,Z,Gz,Pz,couts_z);

end estr;


















