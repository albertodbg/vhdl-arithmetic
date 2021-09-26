--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a multispeculative N-bit Kogge-Stone adder returning the (G,P) vectors
-- This is generic for whatever fragment size (K)
-- Also, the upper carry calculation (2 stages) are performed within this adder
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida and S. Ogrenci-Memik, "A Combined Arithmetic-High-Level Synthesis Solution to Deploy Partial Carry-Save Radix-8 Booth
-- Multipliers in Datapaths," in IEEE Transactions on Circuits and Systems I: Regular Papers, vol. 66, no. 2, pp. 742-755, Feb. 2019. doi:
-- 10.1109/TCSI.2018.2866172
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity msAdd_gp_2 is
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
end msAdd_gp_2;

architecture estr of msAdd_gp_2 is

	--Components
	
	component gp_kogge_stone is
    generic(N: integer;
            S: integer);--Number of stages=log(N)
    port(
    		a: in std_logic_vector((N-1) downto 0);
    		b: in std_logic_vector((N-1) downto 0);
    		cin: in std_logic;
    		G: out std_logic;--Group generate signal
    		P: out std_logic;--Group propagate signal
    		z: out std_logic_vector((N-1) downto 0);
    		cout: out std_logic
  	 );
  end component;
  
  component realCarryCalc_upper is
        generic(
          N: integer;
          S: integer--Number of stages to complete, lower than LOG_N
        );
        port(
          G_in: in std_logic_vector((N-1) downto 0);
          P_in: in std_logic_vector((N-1) downto 0);
          G_out: out std_logic_vector((N-1) downto 0);
          P_out: out std_logic_vector((N-1) downto 0)
        );
  end component;

	--Signals

  signal Gz_aux: std_logic_vector((N/K-1) downto 0);
  signal Pz_aux: std_logic_vector((N/K-1) downto 0);
  signal Gz_aux_2: std_logic_vector((N/K-1) downto 0);
  signal Pz_aux_2: std_logic_vector((N/K-1) downto 0);
  signal couts_z_aux: std_logic_vector((N/K-1) downto 0);
  signal z_aux: std_logic_vector((N-1) downto 0);
	
begin
  
  gen_gpKS_adds:                    
  for i in 0 to (N/K-1) generate
    gp_ks_x_i: gp_kogge_stone generic map(K,LOG_K)
                      port map(a((K*(i+1)-1) downto K*i),b((K*(i+1)-1)
downto K*i),
                        cins(i),
                        Gz_aux(i),Pz_aux(i),z_aux((K*(i+1)-1) downto K*i),couts_z_aux(i));
  end generate gen_gpKS_adds;
  
  gp_upper: realCarryCalc_upper generic map(N/K,2)
              port map (Gz_aux,Pz_aux,Gz_aux_2,Pz_aux_2);--Just 2 extra stages
  
  Gz <= Gz_aux_2;
  Pz <= Pz_aux_2;
  couts_z <= couts_z_aux;
  z <= z_aux;
  
end estr;





