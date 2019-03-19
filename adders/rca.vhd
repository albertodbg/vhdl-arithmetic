--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This is a generic n-bit Ripple-Carry Adder without cin
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rca is
   generic(N: integer);
	port(
		a: in std_logic_vector((N-1) downto 0);
		b: in std_logic_vector((N-1) downto 0);
		z: out std_logic_vector((N-1) downto 0);
		cout: out std_logic
	);
end rca;


architecture estr of rca is
    
    --Components
    
    component adderCell is
	 port(
		 a: in std_logic;
		 b: in std_logic;
		 cin: in std_logic;
		 z: out std_logic;
		 cout: out std_logic
	 );
    end component;
    
    --Signals
    signal zero1: std_logic;
    signal carrys: std_logic_vector((N-1) downto 0);
    
begin
    
    zero1 <= '0';
    
    --Celda 0
    
    cell0: adderCell port map(a(0),b(0),zero1,z(0),carrys(0));
    
    --Celdas i
    
    genFor: 
    for i in 1 to (N-1) generate
       celli: adderCell port map(a(i),b(i),carrys(i-1),z(i),carrys(i));
    end generate genFor;
    
    cout <= carrys(N-1);
    
end estr;

