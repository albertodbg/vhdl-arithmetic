--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-4 Booth encoder cell considering '1' as cin 
-- for every block.
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida, S. O. Memik, “A partial carry-save on-the-
-- fly correction multispeculative multiplier,” IEEE Trans. Comput., vol. 65, no. 11, pp. 
-- 3251–3264, Nov. 2016.
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity boothEncSimple_1 is
	port(
		y0: in std_logic;
		y1: in std_logic;
		y2: in std_logic;
		sel: out std_logic_vector(1 downto 0);
		cout: out std_logic
	);
end boothEncSimple_1;

architecture estr of boothEncSimple_1 is
    
  --Signals
  signal xor_10: std_logic;
   
begin
    
    xor_10 <= y1 xor y0;
    
    sel(0) <= not(xor_10);
    sel(1) <= not(y2) and xor_10;
    
    cout <= y2 and y1;
    
end estr;
