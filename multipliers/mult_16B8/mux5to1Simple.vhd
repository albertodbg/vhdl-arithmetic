--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a 5to1 multiplexer for 1-bit inputs
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mux5to1Simple is
	port(
		x0: in std_logic;
		x1: in std_logic;
		x2: in std_logic;
		x3: in std_logic;
		x4: in std_logic;
		ctrl: in std_logic_vector(2 downto 0);
		z: out std_logic
	);
end mux5to1Simple;

architecture estr of mux5to1Simple is

  --Signals
  signal a0: std_logic;
  signal a1: std_logic;
  signal a2: std_logic;
  signal a3: std_logic;
  signal a4: std_logic;

begin
  
  
  
  a0 <= x0 and not(ctrl(2)) and not(ctrl(1)) and not(ctrl(0));
  a1 <= x1 and not(ctrl(2)) and not(ctrl(1)) and ctrl(0);
  a2 <= x2 and not(ctrl(2)) and ctrl(1) and not(ctrl(0));
  a3 <= x3 and not(ctrl(2)) and ctrl(1) and ctrl(0);
  a4 <= x4 and ctrl(2) and not(ctrl(1)) and not(ctrl(0));
  
  z <= a0 or a1 or a2 or a3 or a4;
    
end estr;











