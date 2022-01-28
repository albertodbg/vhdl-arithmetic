--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a Correction Carry Tree Anticipator for a MS implementation

entity realCarryCalc is
        generic(
          N: integer;
          LOG_N: integer--Ceiling log(N)
        );
        port(
          compl: in std_logic;
          G: in std_logic_vector((N-1) downto 0);
          P: in std_logic_vector((N-1) downto 0);
          corrCarrys: out std_logic_vector((N-1) downto 0)
        );
end realCarryCalc;


architecture estr of realCarryCalc is

    --Types
   
   type matrix is array(0 to LOG_N) of std_logic_vector((N-1) downto 0);
    
   --Signals
   
   signal psMatrix: matrix;
   signal gsMatrix: matrix;

begin

   --Stage 0
   --In this stage we copy the propagates and generates signals,
   
   --gsMatrix(0)(0) <= G(0) or (P(0) and compl);
   gsMatrix(0)(0) <= G(0);
   psMatrix(0)(0) <= P(0);
   
   genStage0:
   for i in 1 to (N-1) generate
     gsMatrix(0)(i) <= G(i);
     psMatrix(0)(i) <= P(i);
   end generate genStage0;
    
   --StagesI
   genStagesI:
   for i in 1 to LOG_N generate
      genStageI:
      for j in 0 to (N-1) generate
         ifgenCopy:
         if (j < 2**(i-1)) generate
            psMatrix(i)(j) <= psMatrix(i-1)(j);
            gsMatrix(i)(j) <= gsMatrix(i-1)(j);
         end generate ifgenCopy;
         ifgenCalculate:
         if (j >= 2**(i-1)) generate
            psMatrix(i)(j) <= psMatrix(i-1)(j) and psMatrix(i-1)(j-2**(i-1));
            gsMatrix(i)(j) <= gsMatrix(i-1)(j) or (gsMatrix(i-1)(j-2**(i-1)) and psMatrix(i-1)(j));
         end generate ifgenCalculate;
      end generate genStageI;
   end generate genStagesI;
   
   --CopyLastCarrys
   copyLastCarrys:
   for i in 0 to (N-1) generate
      corrCarrys(i) <= gsMatrix(LOG_N)(i);
   end generate copyLastCarrys;

end estr;





