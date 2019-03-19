--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-4 Booth encoder cell considering '0' as cin 
-- for every block, that is, a conventional radix-4 Booth encoder
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida, S. O. Memik, “A partial carry-save on-the-
-- fly correction multispeculative multiplier,” IEEE Trans. Comput., vol. 65, no. 11, pp. 
-- 3251–3264, Nov. 2016.
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity boothEncSimple is
	port(
		y0: in std_logic;
		y1: in std_logic;
		y2: in std_logic;
		sel: out std_logic_vector(1 downto 0)
	);
end boothEncSimple;

architecture estr of boothEncSimple is
    
  --Signals
  signal xor10: std_logic;
   
begin
    
    xor10 <= y1 xor y0;
    
    sel(0) <= xor10;
    sel(1) <= (y2 and not(y1) and not(y0)) or (not(y2) and y1 and y0);
    
end estr;


