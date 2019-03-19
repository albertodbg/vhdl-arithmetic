--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a [4:2] compressor cell for 1-bit operands
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compr4to2Simple is
	port(
	  q0: in std_logic;
		q1: in std_logic;
		q2: in std_logic;
		q3: in std_logic;
		cin: in std_logic;
		r0: out std_logic;
		r1: out std_logic;
		cout: out std_logic
	);
end compr4to2Simple;

architecture estr of compr4to2Simple is

  --Components
  component counter3to2Simple is
	port(
		  a: in std_logic;
		  b: in std_logic;
		  cin: in std_logic;
		  z: out std_logic;
		  cout: out std_logic
	 );
  end component;

  --Signals
  signal s0: std_logic;
  signal c0: std_logic;
  signal s1: std_logic;
  signal c1: std_logic;
  
begin
  
  count0: counter3to2Simple port map(q3,q2,q1,s0,c0);
  count1: counter3to2Simple port map(s0,q0,cin,s1,c1);
  
  r0 <= s1;
  r1 <= c1;
  cout <= c0;

end estr;









