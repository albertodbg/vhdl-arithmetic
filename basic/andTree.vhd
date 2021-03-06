--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements an and tree for an n-bit value following the 
-- Kogge-Stone code structure
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity andTree is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
		z: out std_logic
	);
end andTree;

architecture estr of andTree is

  --Components
  
  --Types
  type matrixInd is array (0 to LOG_N) of std_logic_vector((N-1) downto 0);
  
  --Signals
  signal matrixMZ: matrixInd;
  
begin
  
  --Tree like calculation
  genStage0:
  for i in 0 to (N-1) generate
    matrixMZ(0)(i) <= x(i);
  end generate genStage0;
  genStagesI:
  for i in 1 to (LOG_N) generate
    genStageI:
    for j in (N-1) downto 0 generate
      ifgenCopy:
      if ((N-1-j) < 2**(i-1)) generate
        matrixMZ(i)(j) <= matrixMZ(i-1)(j);
      end generate ifgenCopy;
      ifgenCalculate:
      if ((N-1-j) >= 2**(i-1)) generate
        matrixMZ(i)(j) <= matrixMZ(i-1)(j) and matrixMZ(i-1)(j+2**(i-1));
      end generate ifgenCalculate;
    end generate genStageI;
  end generate genStagesI;
  
  --Copy result
  z <= matrixMZ(LOG_N)(0);
  
end estr;



















