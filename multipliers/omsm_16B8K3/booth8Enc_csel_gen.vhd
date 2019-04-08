--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-8 booth encoder with the csel technique
-- We use both the conventional, and the +1 radix-8 encoders
-- This implementation is generic for K and for N
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida and S. Ogrenci-Memik, "A Combined Arithmetic-High-Level Synthesis Solution to Deploy Partial Carry-Save Radix-8 Booth
-- Multipliers in Datapaths," in IEEE Transactions on Circuits and Systems I: Regular Papers, vol. 66, no. 2, pp. 742-755, Feb. 2019. doi:
-- 10.1109/TCSI.2018.2866172
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity booth8Enc_csel_gen is
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
end booth8Enc_csel_gen;

architecture estr of booth8Enc_csel_gen is

  --Components
  component booth8Enc_0_gen is
  generic(
    N: integer;
    K: integer
  );
 	port(
		x: in std_logic_vector((N-1) downto 0);
		lsBits: in std_logic_vector((N/3) downto 0);
		sel: out std_logic_vector((3*(N/3)+2) downto 0);
		signs: out std_logic_vector((N/3) downto 0)
	);
  end component;
  
  component booth8Enc_1_gen is
  generic(
    N: integer;
    K: integer
  );
	port(
		x: in std_logic_vector((N-1) downto 0);
		lsBits: in std_logic_vector((N/3) downto 0);
		sel: out std_logic_vector((3*(N/3)+2) downto 0);
		signs: out std_logic_vector((N/3) downto 0);
		couts: out std_logic_vector((N/3) downto 0)
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
  
  component mux2to1Simple is
	port(
		x0: in std_logic;
		x1: in std_logic;
		ctrl: in std_logic;
		z: out std_logic
	);
  end component;
    
  --Signals
  signal sel0: std_logic_vector((3*(N/3)+2) downto 0);
  signal sel1: std_logic_vector((3*(N/3)+2) downto 0);
  signal signs0: std_logic_vector((N/3) downto 0);
  signal signs1: std_logic_vector((N/3) downto 0);
  signal couts1: std_logic_vector((N/3) downto 0);
  signal and_couts1: std_logic_vector((N/3) downto 0);
  --Positions multiple of (K/3) contains the Creal
  --Positions not multiple of (K/3) contains the and with the previous Cin
  signal msBits: std_logic_vector((N/3) downto 0);
  signal ctrl: std_logic_vector((N/3) downto 0);
  signal ls_bits: std_logic_vector((N/3) downto 0);
  signal s: std_logic_vector((N/3) downto 0);
  
  signal zero: std_logic;
   
begin
    
    zero <= '0';
    
    b0: booth8Enc_0_gen generic map(N,K)
                  port map(x,ls_bits,sel0,signs0);
                  
    b1: booth8Enc_1_gen generic map(N,K)
                  port map(x,ls_bits,sel1,signs1,couts1);
                  
    --chunk 0, K/3 multiple chunk, cin comes from the real carries
    mSel0: mux2to1 generic map(3)
                 port map(sel0(2 downto 0),sel1(2 downto 0),
                 ctrl(0),sel(2 downto 0));
    mSigns0: mux2to1Simple port map(signs0(0),signs1(0),ctrl(0),signs(0));
    ctrl(0) <= zero;
    msBits(0) <= signs1(0);
    
    and_couts1(0) <= zero;

    genFragment0:
    for i in 1 to (K/3-1) generate
      msBits(i) <= signs1(i);
      s(i) <= ctrl(i-1);
      ls_bits(i) <= (msBits(i-1) and s(i)) or 
            (x(3*i-1) and not(s(i)));
      --All these carries are internal, p mod k!= 0
      --if in the previous chunk the real carry was '1', then cin comes from the booth8Enc_1
      --Hence, in this case we should select sel1. Otherwise, we select sel0
      --The real carry of fragment 0 is '0', hence sel0 is selected
      ctrl(i) <= zero;
      sel(3*i+2 downto 3*i) <= sel0(3*i+2 downto 3*i);
      signs(i) <= signs0(i);
      
      and_couts1(i) <= zero;
    end generate genFragment0;
    
                  
    genIMux:
    for i in (K/3) to (N/3) generate
      s(i) <= ctrl(i-1);
      ifGenltN3:
      if (i<N/3) generate
        msBits(i) <= signs1(i);
        ls_bits(i) <= (msBits(i-1) and s(i)) or 
            (x(3*i-1) and not(s(i)));
      end generate ifGenltN3;
      ifGeneqN3:
      if (i=N/3) generate
        msBits(i) <= signs1(i);
        ls_bits(i) <= (msBits(i-1) and s(i)) or 
            (x(3*i-1) and not(s(i)));
      end generate ifGeneqN3;
      ifGenMod0:
      if ((i mod (K/3)) = 0) generate --p mod k = 0
        --cin comes from the real carries
        and_couts1(i) <= realCarrys((3*i)/K-1);
        ctrl(i) <= and_couts1(i);
        mSeli: mux2to1 generic map(3)
                      port map(sel0(3*i+2 downto 3*i),sel1(3*i+2 downto 3*i),
                      ctrl(i),sel(3*i+2 downto 3*i));
        mSignsi: mux2to1Simple port map(signs0(i),signs1(i),ctrl(i),signs(i));
      end generate ifGenMod0;
      
      ifGenMod1:
      if ((i mod (K/3)) /= 0) generate --p mod k = != 0
        --if in the previous chunk the real carry was '1', then cin comes from the booth8Enc_1
        --Hence, in this case we should select sel1. Otherwise, we select sel0
        and_couts1(i) <= and_couts1(i-1) and couts1(i-1);
        ctrl(i) <= realCarrys((3*i)/K-1) and and_couts1(i);
        mSeli: mux2to1 generic map(3)
                      port map(sel0(3*i+2 downto 3*i),sel1(3*i+2 downto 3*i),
                      ctrl(i),sel(3*i+2 downto 3*i));
        mSignsi: mux2to1Simple port map(signs0(i),signs1(i),ctrl(i),signs(i));
      end generate ifGenMod1;
    end generate genIMux;
    
end estr;










