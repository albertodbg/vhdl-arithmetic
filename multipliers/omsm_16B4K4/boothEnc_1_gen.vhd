--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-4 booth encoder considering '1' as cin 
-- for every block. Note: msBits are the same as the signs vector.
-- This implementation is generic for n-bit operands and k-bit fragments
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida, S. O. Memik, “A partial carry-save on-the-
-- fly correction multispeculative multiplier,” IEEE Trans. Comput., vol. 65, no. 11, pp. 
-- 3251–3264, Nov. 2016.
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity boothEnc_1_gen is
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
end boothEnc_1_gen;

architecture estr of boothEnc_1_gen is

  --Components
  component boothEncSimple_1 is
	 port(
		  y0: in std_logic;
		  y1: in std_logic;
		  y2: in std_logic;
		  sel: out std_logic_vector(1 downto 0);
		  cout: out std_logic
	 );
  end component;
    
  --Signals
  signal zero1: std_logic;
  signal couts_aux: std_logic_vector((N/2) downto 0);
   
begin
    
    zero1 <= '0';
    
    enc0: boothEncSimple_1 port map(zero1,x(0),x(1),sel(1 downto 0),couts_aux(0));
    couts(0) <= x(1) and x(0);
    
    enc1: boothEncSimple_1 port map(x(1),x(2),x(3),sel(3 downto 2),couts_aux(1));
    couts(1) <= x(3) and x(2);
    
    genIEnc:
    for i in 2 to (N/2-1) generate
      signs(i) <= x(2*i+1) xor x(2*i);
      couts(i) <= x(2*i+1) and x(2*i);
      ifGenEven:
      if ((i mod (K/2)) = 0) generate     
        --The real carry is not the (i-1)th, but the (i-2)th, which
        --is input to the (i-1)th block
        encI: boothEncSimple_1 port map(lsBits(i),x(2*i),x(2*i+1),
          sel((2*i+1) downto (2*i)),couts_aux(i));
      end generate ifGenEven;
      ifGenOdd:
      if ((i mod (K/2)) /= 0) generate
        --As we suppose that the cin of the even chunk is a '0', 
        --the input bits should be modified
        --The ms bit of the previous chunk (even) is the sign
        encI: boothEncSimple_1 port map(lsBits(i),x(2*i),x(2*i+1),
          sel((2*i+1) downto (2*i)),couts_aux(i));
      end generate ifGenOdd;
    end generate genIEnc;
    
    ifGen0:
    if ((N mod 2)=0) generate
      sel((2*(N/2)+1) downto (2*(N/2))) <= "00";
      signs(N/2) <= zero1;
    end generate ifGen0;
    
    ifGen1:
    if ((N mod 2)=1) generate
      couts(N/2) <= x(N-1);
      encN1: boothEncSimple_1 port map(lsBits(N/2),x(N-1),x(N-1),
            sel((2*(N/2)+1) downto (2*(N/2))),couts_aux(N/2));
      signs(N/2) <= zero1;
    end generate ifGen1;
    
end estr;








