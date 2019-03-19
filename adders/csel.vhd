--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This is a generic n-bit Carry-Select Adder without cin.
-- This implementation is based on RCA modules
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity csel is
   generic(N: integer);
	port(
		a: in std_logic_vector((N-1) downto 0);
		b: in std_logic_vector((N-1) downto 0);
		z: out std_logic_vector((N-1) downto 0);
		cout: out std_logic
	);
end csel;


architecture estr of csel is
    
    --Components
    
    component rca_cin is
      generic(N: integer);
	     port(
		    a: in std_logic_vector((N-1) downto 0);
		    b: in std_logic_vector((N-1) downto 0);
		    cin: in std_logic;
		    z: out std_logic_vector((N-1) downto 0);
		    cout: out std_logic
		   );
    end component;
    
    component mux2to1 is
      generic(N: integer);
      	port(
      		a: in std_logic_vector((N-1) downto 0);
      		b: in std_logic_vector((N-1) downto 0);
      		ctrl: in std_logic;
      		z: out std_logic_vector((N-1) downto 0)
      	);
    end component;
    
    component mux2to1Simple is
      	port(
      		a: in std_logic;
      		b: in std_logic;
      		ctrl: in std_logic;
      		z: out std_logic
      	);
    end component;
    
    --Signals
    signal zero1: std_logic;
    signal one1: std_logic;
    signal msCin: std_logic;
    signal msCout0: std_logic;
    signal msCout1: std_logic;
    signal msZ0: std_logic_vector((N/2-1) downto 0);
    signal msZ1: std_logic_vector((N/2-1) downto 0);

    
begin
    
    zero1 <= '0';
    one1 <= '1';
    
    lsPart: rca_cin generic map(N/2)
                port map(a((N/2-1) downto 0),b((N/2-1) downto 0),zero1,z((N/2-1) downto 0),msCin);
                
    msPart0: rca_cin generic map(N/2)
                port map(a(N-1 downto N/2),b(N-1 downto N/2),zero1,msZ0,msCout0);
                
    msPart1: rca_cin generic map(N/2)
                port map(a(N-1 downto N/2),b(N-1 downto N/2),one1,msZ1,msCout1);
                
    mux: mux2to1 generic map(N/2)
                port map(msZ0,msZ1,msCin,z(N-1 downto N/2));
    
    muxCout: mux2to1Simple port map(msCout0,msCout1,msCin,cout);
    
end estr;





