--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a [4:2] compressor unit for n-bit operands
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compr4to2 is
  generic(
    N: integer
  );
	port(
	  q0: in std_logic_vector((N-1) downto 0);
		q1: in std_logic_vector((N-1) downto 0);
		q2: in std_logic_vector((N-1) downto 0);
		q3: in std_logic_vector((N-1) downto 0);
		cin: in std_logic;
		r0: out std_logic_vector((N-1) downto 0);
		r1: out std_logic_vector((N-1) downto 0);
		cout: out std_logic
	);
end compr4to2;

architecture estr of compr4to2 is

  --Components
  component compr4to2Simple is
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
  end component;
  
  --Signals
  signal cs: std_logic_vector(N downto 0);
  
begin
  
  cs(0) <= cin;
  
  genCells:
  for i in 0 to (N-1) generate
    celli: compr4to2Simple port map(q0(i),q1(i),q2(i),q3(i),cs(i),
              r0(i),r1(i),cs(i+1));
  end generate genCells;
  
  cout <= cs(N);

end estr;











