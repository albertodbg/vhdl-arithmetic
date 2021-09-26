--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a (3,2) counter, i.e. a Full Adder
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter3to2Simple is
	port(
		a: in std_logic;
		b: in std_logic;
		cin: in std_logic;
		z: out std_logic;
		cout: out std_logic
	);
end counter3to2Simple;

architecture estr of counter3to2Simple is
    
begin
    
    z <= a xor b xor cin;
    cout <= (a and b) or (a and cin) or (b and cin);
    
end estr;
