--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This is a generic msAdd that produces (G,P) group signals
--This version is not pipelined, storing the (G,P) and carry out signals
-- This version is the one employed in
-- A. A. D. Barrio, R. Hermida and S. O. Memik, "A Partial Carry-Save On-the-Fly Correction Multispeculative Multiplier," in IEEE Transactions on Computers, -- vol. 65, no. 11, pp. 3251-3264, 1 Nov. 2016, doi: 10.1109/TC.2016.2529626
-- See Figure 5
-- cins signal can be left blank if no outer carries are coming to the adder
-- (G,P) signals are output group generate and propagate signals. Note that the G signals are actually the same as the carry-out signals proceeding from 
-- every fragment and for the quire are the only ones required (P signals are not necessary as a first approach)
-- enHit signal must come from a controller to tell that it is the last addition, i.e. the one that may/may not produce a failure
-- hit signal must be driven to a controller to tell that there is no failure, i.e. all carry-out values are 0 (in this implementation we assume a zero 
-- static prediction for all carries

entity msAdd_gp_2 is
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
		cin: in std_logic;
		enHit: in std_logic;
		z: out std_logic_vector((N-1) downto 0);
		G: out std_logic_vector((N/K) downto 0);
		P: out std_logic_vector((N/K) downto 0);
		hit: out std_logic
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
  
  component gp_brent_kung is
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
  
  component gp_rca is
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
  
  component dff_clr is
	port(
	  rst: in std_logic;
	  clk: in std_logic;
	  clr: in std_logic;
	  load: in std_logic;
		d: in std_logic;
		q: out std_logic
	);
  end component;
  
  component dff is
	port(
	  rst: in std_logic;
	  clk: in std_logic;
	  load: in std_logic;
		d: in std_logic;
		q: out std_logic
	);
  end component;
  
  component mux2to1Simple is
	port(
		x0: in std_logic;
		x1: in std_logic;
		ctrl: in std_logic;
		z: out std_logic
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
  
  --Types
  
  type matrix is array (0 to LOG_N_DIV_K) of std_logic_vector(N/K downto 0);

	--Signals

  signal Gz_aux: std_logic_vector(N/K downto 0);
  signal Pz_aux: std_logic_vector(N/K downto 0);
  signal cins_aux: std_logic_vector(N/K downto 0);
  signal inner_cins: std_logic_vector(N/K downto 0);
  signal cins_mux: std_logic_vector(N/K downto 0);
  signal couts_z_aux: std_logic_vector(N/K downto 0);
  signal a_mux: std_logic_vector((N-1) downto 0);
  signal b_mux: std_logic_vector((N-1) downto 0);
  signal z_aux: std_logic_vector((N-1) downto 0);
  signal rZ_aux: std_logic_vector((N-1) downto 0);
  signal rGz_aux: std_logic_vector(N/K downto 0);
  signal rPz_aux: std_logic_vector(N/K downto 0);
  signal load: std_logic;
  signal hit_aux: std_logic;
  signal a_last: std_logic_vector((K-1) downto 0);
  signal b_last: std_logic_vector((K-1) downto 0);
  signal z_last: std_logic_vector((K-1) downto 0);
  signal cin_last: std_logic;
  signal G_last: std_logic;
  signal P_last: std_logic;
  
  signal diffMatrix: matrix;
  
  signal d_state: std_logic;
  signal q_state: std_logic;
  --q_state == 0--> ok, drive the input to the cins
  --q_state == 1--> correction state, drive the inner couts to the cins
  
  signal clr: std_logic;
  signal q_stateK: std_logic_vector((K-1) downto 0);
  signal q_stateNmodK: std_logic_vector(((N mod K)-1) downto 0);
	
begin
  
  q_stateK <= (OTHERS => q_state);
  q_stateNmodK <= (OTHERS => q_state);
  
  load <= enHit and diffMatrix(LOG_N_DIV_K)(0);--We load when indicated and there is a misprediction
  clr <= enHit and hit_aux;--We clear when indicated and there is a hit
  
  d_state <= diffMatrix(LOG_N_DIV_K)(0);--The new state will be the opposite of a hit
  regSt: dff_clr port map(rst,clk,clr,load,d_state,q_state);
  
  --inner_cins(0) <= '0';
  inner_cins(0) <= cin;--Must always be cin
  inner_cins(N/K downto 1) <= rGz_aux((N/K-1) downto 0);
  
  cins_mux <= inner_cins;--We force this to simplify
  
  gen_gpKS_adds:                    
  for i in 0 to (N/K-1) generate
    mux_a_i: mux2to1 generic map(K)
              port map(a((K*(i+1)-1) downto K*i),rZ_aux((K*(i+1)-1) downto K*i),q_state,a_mux((K*(i+1)-1) downto K*i));
    b_mux((K*(i+1)-1) downto K*i) <= b((K*(i+1)-1) downto K*i) and not(q_stateK);--When correcting, force to zero
    --UNCOMMENT FOR KOGGE-STONE, COMMENT THE OTHERS
    --gp_ks_x_i: gp_kogge_stone generic map(K,LOG_K)
      --                port map(a_mux((K*(i+1)-1) downto K*i),b_mux((K*(i+1)-1) downto K*i),
        --                cins_mux(i),
          --              Gz_aux(i),Pz_aux(i),z_aux((K*(i+1)-1) downto K*i),couts_z_aux(i));
    --UNCOMMENT FOR BRENT-KUNG, COMMENT THE OTHERS
    --gp_bk_x_i: gp_brent_kung generic map(K,LOG_K)
      --                port map(a_mux((K*(i+1)-1) downto K*i),b_mux((K*(i+1)-1) downto K*i),
        --                cins_mux(i),
          --              Gz_aux(i),Pz_aux(i),z_aux((K*(i+1)-1) downto K*i),couts_z_aux(i));
    --UNCOMMENT FOR RCA, COMMENT THE OTHERS
    gp_rca_x_i: gp_rca generic map(K,LOG_K)
                      port map(a_mux((K*(i+1)-1) downto K*i),b_mux((K*(i+1)-1) downto K*i),
                        cins_mux(i),
                        Gz_aux(i),Pz_aux(i),z_aux((K*(i+1)-1) downto K*i),couts_z_aux(i));
    regG_i: dff port map(rst,clk,load,Gz_aux(i),rGz_aux(i));
    regP_i: dff port map(rst,clk,load,Pz_aux(i),rPz_aux(i));
  end generate gen_gpKS_adds;
  
  ifNotMultInput:
  if (N mod K /= 0) generate
    mux_a_i: mux2to1 generic map(N mod K)
              port map(a((N-1) downto (N-(N mod K))),rZ_aux((N-1) downto (N-(N mod K))),q_state,a_mux((N-1) downto (N-(N mod K))));
    b_mux((N-1) downto (N-(N mod K))) <= b((N-1) downto (N-(N mod K))) and not(q_stateNmodK);--When correcting, force to zero
    
    a_last((K-1) downto (N mod K)) <= (OTHERS => a_mux(N-1));
    a_last(((N mod K)-1) downto 0) <= a_mux((N-1) downto (N-(N mod K)));
    b_last((K-1) downto (N mod K)) <= (OTHERS => b_mux(N-1));
    b_last(((N mod K)-1) downto 0) <= b_mux((N-1) downto (N-(N mod K)));
    --UNCOMMENT FOR KOGGE-STONE, COMMENT THE OTHERS
    --gp_ks_x_Last: gp_kogge_stone generic map(K,LOG_K)
      --                port map(A_last,B_last,cins_mux(N/K),
        --                G_last,P_last,z_last,couts_z_aux(N/K));
	--UNCOMMENT FOR BRENT-KUNG, COMMENT THE OTHERS                   
    --gp_bk_x_Last: gp_brent_kung generic map(K,LOG_K)
      --                port map(A_last,B_last,cins_mux(N/K),
        --                G_last,P_last,z_last,couts_z_aux(N/K));
    --UNCOMMENT FOR RCA, COMMENT THE OTHERS                   
    gp_rca_x_Last: gp_rca generic map(K,LOG_K)
                      port map(A_last,B_last,cins_mux(N/K),
                        G_last,P_last,z_last,couts_z_aux(N/K));
    z_aux((N-1) downto (N-(N mod K))) <= z_last(((N mod K)-1) downto 0);
    Gz_aux(N/K) <= G_last;
    Pz_aux(N/K) <= P_last;
    regG_last: dff port map(rst,clk,load,Gz_aux(N/K),rGz_aux(N/K));
    regP_last: dff port map(rst,clk,load,Pz_aux(N/K),rPz_aux(N/K));
  end generate ifNotMultInput;
  
  ifMultInput:
  if (N mod K = 0) generate
    Gz_aux(N/K) <= '0';
    Pz_aux(N/K) <= '0';
    regG_last: dff port map(rst,clk,load,Gz_aux(N/K),rGz_aux(N/K));
    regP_last: dff port map(rst,clk,load,Pz_aux(N/K),rPz_aux(N/K));    
  end generate ifMultInput;

  
  diffMatrix(0)(N/K) <= '0';
  gen_diffs:
  for i in 0 to (N/K-1) generate
    diffMatrix(0)(i) <= couts_z_aux(i);
  end generate gen_diffs;
  
  genStagesI:
  for i in 1 to (LOG_N_DIV_K) generate
    genStageI:
    for j in (N/K) downto 0 generate
      ifgenCopy:
      if ((N/K-j) < 2**(i-1)) generate
        diffMatrix(i)(j) <= diffMatrix(i-1)(j);
      end generate ifgenCopy;
      ifgenCalculate:
      if ((N/K-j) >= 2**(i-1)) generate
        diffMatrix(i)(j) <= diffMatrix(i-1)(j) or diffMatrix(i-1)(j+2**(i-1));
      end generate ifgenCalculate;
    end generate genStageI;
  end generate genStagesI;
  
  zReg: reg generic map(N)
          port map(rst,clk,load,z_aux,rZ_aux); 
  
  --Hit is the opposite of a different carry
  hit_aux <= not(diffMatrix(LOG_N_DIV_K)(0));
  
  G <= Gz_aux;
  P <= Pz_aux;
  z <= z_aux;
  hit <= hit_aux;
  
end estr;



