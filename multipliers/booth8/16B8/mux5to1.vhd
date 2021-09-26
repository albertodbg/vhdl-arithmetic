--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a 5to1 multiplexer for n-bit inputs
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mux5to1 is
  generic(
    N: integer
  );
	port(
		x0: in std_logic_vector((N-1) downto 0);
		x1: in std_logic_vector((N-1) downto 0);
		x2: in std_logic_vector((N-1) downto 0);
		x3: in std_logic_vector((N-1) downto 0);
		x4: in std_logic_vector((N-1) downto 0);
		ctrl: in std_logic_vector(2 downto 0);
		z: out std_logic_vector((N-1) downto 0)
	);
end mux5to1;

architecture estr of mux5to1 is

  --Components
  component mux5to1Simple is
	 port(
		x0: in std_logic;
		x1: in std_logic;
		x2: in std_logic;
		x3: in std_logic;
		x4: in std_logic;
		ctrl: in std_logic_vector(2 downto 0);
		z: out std_logic
	 );
  end component;

  --Signals

begin
  
  genMuxes:
  for i in 0 to (N-1) generate
    muxSimple: mux5to1Simple port map(x0(i),x1(i),x2(i),x3(i),x4(i),
              ctrl,z(i));
  end generate genMuxes;
    
end estr;












