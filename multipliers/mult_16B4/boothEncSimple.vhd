--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a radix-4 booth encoder for a 3-tuple of bits
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a radix-4 booth encoder cell
--Order for the selection signals: 0,1,2
--Negative will be computed afterwards iff s=1

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


