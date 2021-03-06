--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-8 Booth encoder cell
-- Order for the selection signals: 0,1,2,3,4
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity booth8EncSimple is
	port(
		y0: in std_logic;
		y1: in std_logic;
		y2: in std_logic;
		y3: in std_logic;
		sel: out std_logic_vector(2 downto 0)
	);
end booth8EncSimple;

architecture estr of booth8EncSimple is
    
  --Signals
  signal xor10: std_logic;
   
begin
    
    xor10 <= y1 xor y0;
    
    sel(0) <= xor10;
    sel(1) <= (y2 and not(y1) and not(y0)) or (y3 and not(y2) and not(y1)) or
      (not(y3) and y2 and not(y1)) or (y3 and not(y2) and y0) or
      (not(y3) and y2 and not(y0)) or (not(y3) and not(y2) and y1 and y0);
    sel(2) <= (not(y3) and y2 and y1 and y0) or
      (y3 and not(y2) and not(y1) and not(y0));
    
end estr;






