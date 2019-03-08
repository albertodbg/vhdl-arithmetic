--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This is a barrel shifter with bidirectional left/right shift
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This is a barrel shifter with bidirectional left/right shift

entity barrelShifterLR is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
	  lr: in std_logic;--1=left,0=right
	  shiftAm: in std_logic_vector((LOG_N-1) downto 0);
	  shX: out std_logic_vector((N-1) downto 0)
	);
end barrelShifterLR;

architecture estr of barrelShifterLR is
  
  --Components
  component mux2to1Simple is
	 port(
		  x0: in std_logic;
		  x1: in std_logic;
		  ctrl: in std_logic;
		  z: out std_logic
	 );
  end component;

  --Types
  
  type matrix is array(0 to LOG_N+2) of std_logic_vector((N-1) downto 0);
  
  --Signals
  
  signal muxMat: matrix;
  signal zero1: std_logic;
  
begin
  
  zero1 <= '0';
  
  --Stage 0
  muxMat(0) <= x;   
  
  --Stage 1
  --Left swapping if necessary
  genLeftInit:
  for j in 0 to (N-1) generate
    muxL_Init: mux2to1Simple port map(muxMat(0)(j),muxMat(0)(N-j-1),lr,muxMat(1)(j));
  end generate genLeftInit;
    
   
  --StagesI
  genStagesI:
  for i in 2 to (LOG_N+1) generate
     genStageI:
     for j in 0 to (N-1) generate
        ifgenCte:
        if ((j + 2**(i-2)) > (N-1)) generate
           muxMat(i)(j) <= muxMat(i-1)(j) and not(shiftAm(i-2));
        end generate ifgenCte;
        ifgenSh:
        if ((j + 2**(i-2)) <= (N-1)) generate
          muxSh: mux2to1Simple port map(muxMat(i-1)(j),muxMat(i-1)(j+2**(i-2)),
              shiftAm(i-2),muxMat(i)(j));  
        end generate ifgenSh;
     end generate genStageI;
  end generate genStagesI;
  
  --Stage LOG_N+2
  --Left swapping if necessary
  genLeftFin:
  for j in 0 to (N-1) generate
    muxL_Init: mux2to1Simple port map(muxMat(LOG_N+1)(j),muxMat(LOG_N+1)(N-j-1),lr,muxMat(LOG_N+2)(j));
  end generate genLeftFin;
  
  shX <= muxMat(LOG_N+2);
  
end estr;
















