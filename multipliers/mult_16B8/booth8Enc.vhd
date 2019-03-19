--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-8 Booth encoder for n-bits
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity booth8Enc is
  generic(
    N: integer
  );
	port(
		x: in std_logic_vector((N-1) downto 0);
		sel: out std_logic_vector((3*(N/3)+ 2) downto 0);
		signs: out std_logic_vector((N/3) downto 0)
	);
end booth8Enc;

architecture estr of booth8Enc is

  --Components
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
   
begin
    
    zero1 <= '0';
    
    enc0: booth8EncSimple port map(zero1,x(0),x(1),x(2),sel(2 downto 0));
    signs(0) <= x(2);
    
    genIEnc:
    for i in 1 to (N/3-1) generate
      encI: booth8EncSimple port map(x(3*i-1),x(3*i),x(3*i+1),x(3*i+2),
        sel((3*i+2) downto (3*i)));
      signs(i) <= x(3*i+2);
    end generate genIEnc;
    
    ifGen0:
    if ((N mod 3)=0) generate
      sel((3*(N/3)+2) downto (3*(N/3))) <= (OTHERS => '0');
      signs(N/3) <= zero1;
    end generate ifGen0;
    
    ifGen1:
    if ((N mod 3)=1) generate
      encN1: booth8EncSimple port map(x(N-2),X(N-1),x(N-1),x(N-1),
            sel((3*(N/3)+2) downto (3*(N/3))));
      signs(N/3) <= x(N-1);
    end generate ifGen1;
    
    ifGen2:
    if ((N mod 3)=2) generate
      encN1: booth8EncSimple port map(x(N-3),X(N-2),x(N-1),x(N-1),
            sel((3*(N/3)+2) downto (3*(N/3))));
      signs(N/3) <= x(N-1);
    end generate ifGen2;
    
end estr;








