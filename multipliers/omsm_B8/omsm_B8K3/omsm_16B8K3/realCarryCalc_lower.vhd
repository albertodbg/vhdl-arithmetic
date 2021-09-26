--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements the lower carry calculation part, which is the part generating the final carries
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida and S. Ogrenci-Memik, "A Combined Arithmetic-High-Level Synthesis Solution to Deploy Partial Carry-Save Radix-8 Booth
-- Multipliers in Datapaths," in IEEE Transactions on Circuits and Systems I: Regular Papers, vol. 66, no. 2, pp. 742-755, Feb. 2019. doi:
-- 10.1109/TCSI.2018.2866172
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity realCarryCalc_lower is
        generic(
          N: integer;
          S: integer;--Number of required stages for the upper part, S < LOG_N
          LOG_N: integer
        );
        port(
          G: in std_logic_vector((N-1) downto 0);
          P: in std_logic_vector((N-1) downto 0);
          corrCarrys: out std_logic_vector((N-1) downto 0)
        );
end realCarryCalc_lower;


architecture estr of realCarryCalc_lower is

    --Types
   
   type matrix is array(S to LOG_N) of std_logic_vector((N-1) downto 0);
    
   --Signals
   
   signal psMatrix: matrix;
   signal gsMatrix: matrix;

begin

   --Stage 0
   --In this stage we copy the propagates and generates signals,
   
   gsMatrix(S)(0) <= G(0);
   psMatrix(S)(0) <= P(0);
   
   genStage0:
   for i in 1 to (N-1) generate
     gsMatrix(S)(i) <= G(i);
     psMatrix(S)(i) <= P(i);
   end generate genStage0;
    
   --StagesI
   genStagesI:
   for i in (S+1) to LOG_N generate
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







