--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a 3to1 multiplexer for 1-bit inputs
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mux3to1Simple is
	port(
		x0: in std_logic;
		x1: in std_logic;
		x2: in std_logic;
		ctrl: in std_logic_vector(1 downto 0);
		z: out std_logic
	);
end mux3to1Simple;

architecture estr of mux3to1Simple is

  --Signals
  signal a0: std_logic;
  signal a1: std_logic;
  signal a2: std_logic;

begin
  
  
  
  a0 <= x0 and not(ctrl(1)) and not(ctrl(0));
  a1 <= x1 and not(ctrl(1)) and ctrl(0);
  a2 <= x2 and ctrl(1) and not(ctrl(0));
  
  z <= a0 or a1 or a2;
    
end estr;











