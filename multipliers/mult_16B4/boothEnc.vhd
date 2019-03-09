--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-4 booth encoder for n-bits
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity boothEnc is
  generic(
    N: integer
  );
	port(
		x: in std_logic_vector((N-1) downto 0);
		sel: out std_logic_vector((2*(N/2)+1) downto 0);
		signs: out std_logic_vector((N/2) downto 0)
	);
end boothEnc;

architecture estr of boothEnc is

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
    
    genIEnc:
    for i in 1 to (N/2-1) generate
      encI: boothEncSimple port map(x(2*i-1),x(2*i),x(2*i+1),
        sel((2*i+1) downto (2*i)));
      signs(i) <= x(2*i+1);
    end generate genIEnc;
    
    ifGen0:
    if ((N mod 2)=0) generate
      encN0: boothEncSimple port map(x(N-1),x(N-1),x(N-1),
            sel((2*(N/2)+1) downto (2*(N/2))));
      signs(N/2) <= x(N-1);
    end generate ifGen0;
    
    ifGen1:
    if ((N mod 2)=1) generate
      encN1: boothEncSimple port map(x(N-2),X(N-1),x(N-1),
            sel((2*(N/2)+1) downto (2*(N/2))));
      signs(N/2) <= x(N-1);
    end generate ifGen1;
    
end estr;




