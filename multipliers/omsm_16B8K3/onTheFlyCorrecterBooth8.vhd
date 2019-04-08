--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements the correcting part of the On-the-fly Correcting MS-Mult for a radix-8 Booth encoding
-- This version includes the triple calculation
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida and S. Ogrenci-Memik, "A Combined Arithmetic-High-Level Synthesis Solution to Deploy Partial Carry-Save Radix-8 Booth
-- Multipliers in Datapaths," in IEEE Transactions on Circuits and Systems I: Regular Papers, vol. 66, no. 2, pp. 742-755, Feb. 2019. doi:
-- 10.1109/TCSI.2018.2866172
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity onTheFlyCorrecterBooth8 is
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
          Ts: in std_logic_vector((N+1) downto 0);--T sum component
          Gx: in std_logic_vector((N/K-1) downto 0);
          Px: in std_logic_vector((N/K-1) downto 0);
          Gy: in std_logic_vector((N/K-1) downto 0);
          Py: in std_logic_vector((N/K-1) downto 0);
          Gt: in std_logic_vector(((N+2)/K-1) downto 0);
          Pt: in std_logic_vector(((N+2)/K-1) downto 0);
          X: out std_logic_vector((N-1) downto 0);--X real multiplicand
          T: out std_logic_vector((N+1) downto 0);--T real multiple
          YBooth_sel: out std_logic_vector((3*(N/3)+2) downto 0);--Y Booth selection signals
          YBooth_signs: out std_logic_vector((N/3) downto 0)--Y Booth sign signals
        );
end onTheFlyCorrecterBooth8;


architecture estr of onTheFlyCorrecterBooth8 is

  --Components declaration

  component realCarryCalc is
          generic(
            N: integer;
            LOG_N: integer--Ceiling log(N)
          );
          port(
            compl: in std_logic;
            G: in std_logic_vector((N-1) downto 0);
            P: in std_logic_vector((N-1) downto 0);
            corrCarrys: out std_logic_vector((N-1) downto 0)
          );
  end component;
  
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
  
  component booth8Enc_csel_gen is
    generic(
      N: integer;
      K: integer
    );
  	 port(
    		x: in std_logic_vector((N-1) downto 0);
    		realCarrys: in std_logic_vector((N/K-1) downto 0);
    		sel: out std_logic_vector((3*(N/3)+2) downto 0);
    		signs: out std_logic_vector((N/3) downto 0)
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
  signal realCarries_triple: std_logic_vector(((N+2)/K-1) downto 0);
  signal cout_dummys: std_logic_vector((N/K-1) downto 0);
  signal X1: std_logic_vector((N-1) downto 0);
  signal Xs_last: std_logic_vector((K-1) downto 0);
  signal X1_last: std_logic_vector((K-1) downto 0);
  signal X_last: std_logic_vector((K-1) downto 0);
  signal cout_dummy_last: std_logic;
  signal cout_dummys_t: std_logic_vector(((N+2)/K-1) downto 0);
  signal T1: std_logic_vector((N+1) downto 0);
  signal Ts_last: std_logic_vector((K-1) downto 0);
  signal T1_last: std_logic_vector((K-1) downto 0);
  signal T_last: std_logic_vector((K-1) downto 0);
  signal cout_dummy_last_t: std_logic;

begin
  
  zero <= '0';
  oneK((K-1) downto 1) <= (OTHERS => '0');
  oneK(0) <= '1';

  --Multiplicand
  rc_mnd: realCarryCalc_lower generic map(N/K,2,LOG_N_div_K)
                    port map(Gx,Px,realCarries_multiplicand);
                    
  --genKS_block_0                    
  X((K-1) downto 0) <= Xs((K-1) downto 0);
  X1((K-1) downto 0) <= Xs((K-1) downto 0);--cin='0'
                    
  genKS_blocks:
  for i in 1 to (N/K-1) generate
    ks_1_i: kogge_stone generic map(K,LOG_K)
                        port map(Xs(((i+1)*K-1) downto i*K),oneK,zero,
                        X1(((i+1)*K-1) downto i*K),cout_dummys(i));
    mux_X_i: mux2to1 generic map(K)
                    port map(Xs(((i+1)*K-1) downto i*K),X1(((i+1)*K-1) downto i*K),
                    realCarries_multiplicand(i-1),X(((i+1)*K-1) downto i*K));
  end generate genKS_blocks;
  
  ifNotMult:
  if (N mod K /= 0) generate
    Xs_last((K-1) downto (N mod K)) <= (OTHERS => Xs(N-1));
    Xs_last(((N mod K)-1) downto 0) <= Xs((N-1) downto (N-(N mod K)));
    ks_1_last: kogge_stone generic map(K,LOG_K)
                        port map(Xs_last,oneK,zero,
                        X1_last,cout_dummy_last);
    X1((N-1) downto (N-(N mod K))) <= X1_last(((N mod K)-1) downto 0);                    
    mux_X_last: mux2to1 generic map(K)
                    port map(Xs_last,X1_last,
                    realCarries_multiplicand(N/K-1),X_last);
    X((N-1) downto (N-(N mod K))) <= X_last(((N mod K)-1) downto 0);
  end generate ifNotMult;
                
  --Multiplier    
  rc_mplr: realCarryCalc_lower generic map(N/K,2,LOG_N_div_K)
                    port map(Gy,Py,realCarries_multiplier);              
                      
  b_enc: booth8Enc_csel_gen generic map(N,K)
                      port map(Ys,realCarries_multiplier,YBooth_sel,YBooth_signs);
                      
  --Triple X
  ifgen0:
  if (N mod K = 0) generate
    rc_trp: realCarryCalc_lower generic map((N+2)/K,2,LOG_N_div_K+1)
                    port map(Gt,Pt,realCarries_triple);
  end generate ifgen0;
  
  ifgenN0:
  if (N mod K > 0) generate
    rc_trp: realCarryCalc_lower generic map((N+2)/K,2,LOG_N_div_K)--log(N/K) already rounded up
                    port map(Gt,Pt,realCarries_triple);
  end generate ifgenN0;
  
  --genKS_block_0 for T
  T((K-1) downto 0) <= Ts((K-1) downto 0);
  T1((K-1) downto 0) <= Ts((K-1) downto 0);--cin='0'
                    
  genKS_T_blocks:
  for i in 1 to ((N+2)/K-1) generate
    ks_t_1_i: kogge_stone generic map(K,LOG_K)
                        port map(Ts(((i+1)*K-1) downto i*K),oneK,zero,
                        T1(((i+1)*K-1) downto i*K),cout_dummys_t(i));
    mux_T_i: mux2to1 generic map(K)
                    port map(Ts(((i+1)*K-1) downto i*K),T1(((i+1)*K-1) downto i*K),
                    realCarries_triple(i-1),T(((i+1)*K-1) downto i*K));
  end generate genKS_T_blocks;
  
  ifNotMult_t:
  if ((N+2) mod K /= 0) generate
    Ts_last((K-1) downto ((N+2) mod K)) <= (OTHERS => Ts(N-1));
    Ts_last((((N+2) mod K)-1) downto 0) <= Ts((N+1) downto (N+2-((N+2) mod K)));
    ks_t_1_last: kogge_stone generic map(K,LOG_K)
                        port map(Ts_last,oneK,zero,
                        T1_last,cout_dummy_last_t);
    T1((N+1) downto (N+2-((N+2) mod K))) <= X1_last((((N+2) mod K)-1) downto 0);                    
    mux_T_last: mux2to1 generic map(K)
                    port map(Ts_last,T1_last,
                    realCarries_triple((N+2)/K-1),T_last);
    T((N+1) downto ((N+2)-((N+2) mod K))) <= T_last(((N mod K)-1) downto 0);
  end generate ifNotMult_t;


end estr;











