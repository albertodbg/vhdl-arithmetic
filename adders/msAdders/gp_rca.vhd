--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gp_rca is
   generic(N: integer;
           S: integer);--Number of stages=log(N)
	port(
		a: in std_logic_vector((N-1) downto 0);
		b: in std_logic_vector((N-1) downto 0);
		cin: in std_logic;
		G: out std_logic;--Group generate signal
		P: out std_logic;--Group propagate signal
		z: out std_logic_vector((N-1) downto 0);
		cout: out std_logic
	);
end gp_rca;


architecture estr of gp_rca is

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
   signal carrys: std_logic_vector((N-1) downto 0);
   
begin
    
   --Cell 0
    
    cell0: adderCell port map(a(0),b(0),cin,z(0),carrys(0));
    
    --Cells i
    
    genFor: 
    for i in 1 to (N-1) generate
       celli: adderCell port map(a(i),b(i),carrys(i-1),z(i),carrys(i));
    end generate genFor;
    
    cout <= carrys(N-1);
   
   --Group Generates and Propagates signals
   --We force the propagate to '0' and the G to the cout (which is the same)
   G <= carrys(N-1);
   P <= '0';
    
end estr;







