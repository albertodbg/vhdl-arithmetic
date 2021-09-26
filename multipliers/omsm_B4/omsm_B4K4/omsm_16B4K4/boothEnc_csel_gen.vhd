--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-4 booth encoder with the csel technique
-- We use both the conventional, and the +1 radix-4 encoders
-- This implementation is generic for n-bit operands and k-bit fragments
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida, S. O. Memik, “A partial carry-save on-the-
-- fly correction multispeculative multiplier,” IEEE Trans. Comput., vol. 65, no. 11, pp. 
-- 3251–3264, Nov. 2016.
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity boothEnc_csel_gen is
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
end boothEnc_csel_gen;

architecture estr of boothEnc_csel_gen is

  --Components
  component boothEnc_0_gen is
   generic(
     N: integer;
     K: integer
   );
	 port(
		 x: in std_logic_vector((N-1) downto 0);
		 lsBits: in std_logic_vector((N/2) downto 0);
		 ctrl: in std_logic_vector((N/2) downto 0);
		 sel: out std_logic_vector((2*(N/2)+1) downto 0);
		 signs: out std_logic_vector((N/2) downto 0)
	 );
  end component;
  
  component boothEnc_1_gen is
  generic(
    N: integer;
    K: integer
  );
	port(
		x: in std_logic_vector((N-1) downto 0);
		lsBits: in std_logic_vector((N/2) downto 0);
		ctrl: in std_logic_vector((N/2) downto 0);
		sel: out std_logic_vector((2*(N/2)+1) downto 0);
		signs: out std_logic_vector((N/2) downto 0);
		couts: out std_logic_vector((N/2) downto 0)
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
  signal sel0: std_logic_vector((2*(N/2)+1) downto 0);
  signal sel1: std_logic_vector((2*(N/2)+1) downto 0);
  signal signs0: std_logic_vector((N/2) downto 0);
  signal signs1: std_logic_vector((N/2) downto 0);
  signal couts1: std_logic_vector((N/2) downto 0);
  signal and_couts1: std_logic_vector((N/2) downto 0);
  --Positions multiple of (K/2) contain the Creal
  --Positions not multiple of (K/2) contain the and with the previous Cin
  signal msBits: std_logic_vector((N/2) downto 0);
  signal ctrl: std_logic_vector((N/2) downto 0);
  signal ls_bits: std_logic_vector((N/2) downto 0);
  signal s: std_logic_vector((N/2) downto 0);
  
  signal zero: std_logic;
   
begin
    
    zero <= '0';
    
    b0: boothEnc_0_gen generic map(N,K)
                  port map(x,ls_bits,ctrl,sel0,signs0);
                  
    b1: boothEnc_1_gen generic map(N,K)
                  port map(x,ls_bits,ctrl,sel1,signs1,couts1);
                  
    --chunk 0,Even chunk, cin comes from the real carries
    mSel0: mux2to1 generic map(2)
                 port map(sel0(1 downto 0),sel1(1 downto 0),
                 ctrl(0),sel(1 downto 0));
    mSigns0: mux2to1Simple port map(signs0(0),signs1(0),ctrl(0),signs(0));
    ctrl(0) <= zero;
    msBits(0) <= x(1) xor x(0);
    
    and_couts1(0) <= zero;

    genFragment0:
    for i in 1 to (K/2-1) generate
      msBits(i) <= x(2*i+1) xor x(2*i);
      s(i) <= ctrl(i-1);
      ls_bits(i) <= (msBits(i-1) and s(i)) or 
            (x(2*i-1) and not(s(i)));
      --All these carries are internal, p mod k!= 0
      --if in the previous chunk the real carry was '1', then cin comes from the boothEnc_1
      --Hence, in this case we should select sel1. Otherwise, we select sel0
      --The real carry of fragment 0 is '0', hence sel0 is selected
      ctrl(i) <= zero;
      sel(2*i+1 downto 2*i) <= sel0(2*i+1 downto 2*i);
      signs(i) <= signs0(i);
      
      and_couts1(i) <= zero;
    end generate genFragment0;
    
                  
    genIMux:
    for i in (K/2) to (N/2) generate
      ifGenltN2:
      if (i<N/2) generate
        msBits(i) <= x(2*i+1) xor x(2*i);
      end generate ifGenltN2;
      ifGeneqN2:
      if (i=N/2) generate
        msBits(i) <= x(i);
      end generate ifGeneqN2;
      s(i) <= ctrl(i-1);
        ls_bits(i) <= (msBits(i-1) and s(i)) or 
            (x(2*i-1) and not(s(i)));
      ifGenMod0:
      if ((i mod (K/2)) = 0) generate --p mod k = 0
        --cin comes from the real carries
        and_couts1(i) <= realCarrys((2*i)/K-1);
        ctrl(i) <= and_couts1(i);
        mSeli: mux2to1 generic map(2)
                      port map(sel0(2*i+1 downto 2*i),sel1(2*i+1 downto 2*i),
                      ctrl(i),sel(2*i+1 downto 2*i));
        mSignsi: mux2to1Simple port map(signs0(i),signs1(i),ctrl(i),signs(i));
      end generate ifGenMod0;
      
      ifGenMod1:
      if ((i mod (K/2)) /= 0) generate --p mod k = != 0
        --if in the previous chunk the real carry was '1', then cin comes from the boothEnc_1
        --Hence, in this case we should select sel1. Otherwise, we select sel0
        and_couts1(i) <= and_couts1(i-1) and couts1(i-1);
        ctrl(i) <= realCarrys((2*i)/K-1) and and_couts1(i);
        mSeli: mux2to1 generic map(2)
                      port map(sel0(2*i+1 downto 2*i),sel1(2*i+1 downto 2*i),
                      ctrl(i),sel(2*i+1 downto 2*i));
        mSignsi: mux2to1Simple port map(signs0(i),signs1(i),ctrl(i),signs(i));
      end generate ifGenMod1;
    end generate genIMux;
    
end estr;








