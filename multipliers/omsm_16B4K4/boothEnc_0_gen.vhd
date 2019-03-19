--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-4 booth encoder considering '0' as cin 
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

entity boothEnc_0_gen is
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
end boothEnc_0_gen;

architecture estr of boothEnc_0_gen is

  --Components
  component boothEncSimple is
	 port(
		  y0: in std_logic;
		  y1: in std_logic;
		  y2: in std_logic;
		  sel: out std_logic_vector(1 downto 0)
	 );
  end component;
    
  --Signals
  signal zero1: std_logic;
     
begin
    
    zero1 <= '0';
    
    enc0: boothEncSimple port map(zero1,x(0),x(1),sel(1 downto 0));
    signs(0) <= x(1);
    
    enc1: boothEncSimple port map(x(1),x(2),x(3),sel(3 downto 2));
    signs(1) <= x(3);
    
    genIEnc:
    for i in 2 to (N/2-1) generate
      ifGenEven:
      if (i mod (K/2) = 0) generate
      --Take into account the real carries
        encI: boothEncSimple port map(lsBits(i),x(2*i),x(2*i+1),
          sel((2*i+1) downto (2*i)));
        signs(i) <= x(2*i+1);
      end generate ifGenEven;
      ifGenOdd:
      if (i mod (K/2) /= 0) generate
      --As usual
        encI: boothEncSimple port map(lsBits(i),x(2*i),x(2*i+1),
          sel((2*i+1) downto (2*i)));
        signs(i) <= x(2*i+1);
      end generate ifGenOdd;
    end generate genIEnc;
    
    ifGen0:
    if ((N mod 2)=0) generate
      sel((2*(N/2)+1) downto (2*(N/2))) <= "00";
      signs(N/2) <= zero1; 
    end generate ifGen0;
    
    ifGen1:
    if ((N mod 2)=1) generate
      encN1: boothEncSimple port map(lsBits(N/2),X(N-1),x(N-1),
            sel((2*(N/2)+1) downto (2*(N/2))));
      signs(N/2) <= x(N-1);
    end generate ifGen1;
    
end estr;








