--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a modified radix-8 booth encoder using '1' as cin for every block
-- MS-bits are the same as the signs.
-- This works for whatever k fragment size which is multiple of the tuple size -1
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida and S. Ogrenci-Memik, "A Combined Arithmetic-High-Level Synthesis Solution to Deploy Partial Carry-Save Radix-8 Booth
-- Multipliers in Datapaths," in IEEE Transactions on Circuits and Systems I: Regular Papers, vol. 66, no. 2, pp. 742-755, Feb. 2019. doi:
-- 10.1109/TCSI.2018.2866172
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity booth8Enc_1_gen is
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
end booth8Enc_1_gen;

architecture estr of booth8Enc_1_gen is

  --Components
  component booth8EncSimple_1 is
	 port(
		  y0: in std_logic;
		  y1: in std_logic;
		  y2: in std_logic;
		  y3: in std_logic;
		  sel: out std_logic_vector(2 downto 0);
		  cout: out std_logic
	 );
  end component;
  
  component booth8EncSimple is
	port(
		y0: in std_logic;
		y1: in std_logic;
		y2: in std_logic;
		y3: in std_logic;
		sel: out std_logic_vector(2 downto 0)
	);
  end component;
    
  --Signals
  signal zero1: std_logic;
  signal ls_bits: std_logic_vector((N/3) downto 0);
  signal nXn1: std_logic;
   
begin
    
    zero1 <= '0';
    ls_bits <= lsBits;
    
    enc0: booth8EncSimple_1 port map(zero1,x(0),x(1),x(2),sel(2 downto 0),couts(0));
    signs(0) <= (x(2) and not(x(0))) or (x(2) and not(x(1)))
          or (not(x(2)) and x(1) and x(0));
    
    genIEnc:
    for i in 1 to (N/3-1) generate
      signs(i) <= (x(3*i+2) and not(x(3*i))) or (x(3*i+2) and not(x(3*i+1)))
          or (not(x(3*i+2)) and x(3*i+1) and x(3*i));
      encI: booth8EncSimple_1 port map(ls_bits(i),x(3*i),x(3*i+1),x(3*i+2),
          sel((3*i+2) downto (3*i)),couts(i));
    end generate genIEnc;
    
    ifGen0:
    if ((N mod 3)=0) generate
      encN1: booth8EncSimple_1 port map(ls_bits(N/3),ls_bits(N/3),ls_bits(N/3),ls_bits(N/3),
            sel((3*(N/3)+2) downto (3*(N/3))),couts(N/3));
      signs(N/3) <= zero1;
    end generate ifGen0;
    
    ifGen1:
    if ((N mod 3)=1) generate
      nXn1 <= not(x(N-1));
      encN1: booth8EncSimple port map(ls_bits(N/3),nXn1,nXn1,nXn1,
            sel((3*(N/3)+2) downto (3*(N/3))));
      signs(N/3) <= nXn1;
      couts(N/3) <= ls_bits(N/3);
    end generate ifGen1;
    
    ifGen2:
    if ((N mod 3)=2) generate
      encN1: booth8EncSimple_1 port map(ls_bits(N/3),x(N-2),x(N-1),x(N-1),
            sel((3*(N/3)+2) downto (3*(N/3))),couts(N/3));
      signs(N/3) <= (x(N-1) and not(x(N-2)));
    end generate ifGen2;
    
end estr;










