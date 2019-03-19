--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements an n-bit onTheFlyCorrecter module for fragments of k-bits
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida, S. O. Memik, “A partial carry-save on-the-
-- fly correction multispeculative multiplier,” IEEE Trans. Comput., vol. 65, no. 11, pp. 
-- 3251–3264, Nov. 2016.
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity onTheFlyCorrecter is
        generic(
          N: integer;
          K: integer;
          LOG_N: integer;--Ceiling log(N)
          LOG_K: integer;--Ceiling log(K)
          LOG_N_div_K: integer--Ceiling log(N/K)
        );
        port(
          Xs: in std_logic_vector((N-1) downto 0);--X sum component
          Ys: in std_logic_vector((N-1) downto 0);--Y sum component
          Gx: in std_logic_vector((N/K-1) downto 0);
          Px: in std_logic_vector((N/K-1) downto 0);
          Gy: in std_logic_vector((N/K-1) downto 0);
          Py: in std_logic_vector((N/K-1) downto 0);
          X: out std_logic_vector((N-1) downto 0);--X real multiplicand
          YBooth_sel: out std_logic_vector((2*(N/2)+1) downto 0);--Y Booth selection signals
          YBooth_signs: out std_logic_vector((N/2) downto 0)--Y Booth sign signals
        );
end onTheFlyCorrecter;


architecture estr of onTheFlyCorrecter is

  --Components declaration
  
  component realCarryCalc_lower is
        generic(
          N: integer;
          S: integer;--Number of required stages for the upper part, S < LOG_N
          LOG_N: integer
        );
        port(
          G: in std_logic_vector((N-1) downto 0);
          P: in std_logic_vector((N-1) downto 0);
          corrCarrys: out std_logic_vector((N-1) downto 0)
        );
  end component;

  component kogge_stone is
     generic(N: integer;
             S: integer);--Number of stages=log(N)
  	   port(
    		  a: in std_logic_vector((N-1) downto 0);
      		b: in std_logic_vector((N-1) downto 0);
      		cin: in std_logic;
      		z: out std_logic_vector((N-1) downto 0);
      		cout: out std_logic
    	 );
  end component;
  
  component boothEnc_csel_gen is
    generic(
      N: integer;
      K: integer
    );
  	 port(
    		x: in std_logic_vector((N-1) downto 0);
    		realCarrys: in std_logic_vector((N/K-1) downto 0);
    		sel: out std_logic_vector((2*(N/2)+1) downto 0);
    		signs: out std_logic_vector((N/2) downto 0)
    );
  end component;
  
  component mux2to1 is
   generic(N: integer);
	port(
		x0: in std_logic_vector((N-1) downto 0);
		x1: in std_logic_vector((N-1) downto 0);
		ctrl: in std_logic;
		z: out std_logic_vector((N-1) downto 0)
	);
  end component;
    
  --Signal declarations
  signal zero: std_logic;
  signal oneK: std_logic_vector((K-1) downto 0);

  signal realCarries_multiplicand: std_logic_vector((N/K-1) downto 0);
  signal realCarries_multiplier: std_logic_vector((N/K-1) downto 0);
  signal cout_dummys: std_logic_vector((N/K-1) downto 0);
  signal X1: std_logic_vector((N-1) downto 0);
  
  signal Y: std_logic_vector((N-1) downto 0);
  signal Y1: std_logic_vector((N-1) downto 0);
  signal Y_cout_dummys: std_logic_vector((N/K-1) downto 0);

begin
  
  zero <= '0';
  oneK((K-1) downto 1) <= (OTHERS => '0');
  oneK(0) <= '1';

  --Multiplicand
  
  ifGE2Stages_mnd:
  if (N/K >= 4) generate
    rc_mnd: realCarryCalc_lower generic map(N/K,2,LOG_N_div_K)
                    port map(Gx,Px,realCarries_multiplicand);
  end generate ifGE2Stages_mnd;
  
  ifLT2Stages_mnd:
  if (N/K < 4) generate
    realCarries_multiplicand <= Gx;
  end generate ifLT2Stages_mnd;
                    
  --genKS_block_0                    
  X((K-1) downto 0) <= Xs((K-1) downto 0);
                    
  genKS_blocks:
  for i in 1 to (N/K-1) generate
    ks_1_i: kogge_stone generic map(K,LOG_K)
                        port map(Xs(((i+1)*K-1) downto i*K),oneK,zero,
                        X1(((i+1)*K-1) downto i*K),cout_dummys(i));
    mux_X_i: mux2to1 generic map(K)
                    port map(Xs(((i+1)*K-1) downto i*K),X1(((i+1)*K-1) downto i*K),
                    realCarries_multiplicand(i-1),X(((i+1)*K-1) downto i*K));
  end generate genKS_blocks;
                
  --Multiplier    

  ifGE2Stages_mplr:
  if (N/K >= 4) generate             
    rc_mplr: realCarryCalc_lower generic map(N/K,2,LOG_N_div_K)
                    port map(Gy,Py,realCarries_multiplier);
  end generate ifGE2Stages_mplr;
  
  ifLT2Stages_mplr:
  if (N/K < 4) generate
    realCarries_multiplier <= Gy;
  end generate ifLT2Stages_mplr;
                      
  b_enc: boothEnc_csel_gen generic map(N,K)
                  port map(Ys,realCarries_multiplier,YBooth_sel,YBooth_signs);


end estr;







