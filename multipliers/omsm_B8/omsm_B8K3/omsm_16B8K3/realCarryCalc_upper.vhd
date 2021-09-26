--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements the lower carry calculation part, which is the part responsible for performing the first part of the carries calculation
-- The output is then another set of (G,P) signals
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida and S. Ogrenci-Memik, "A Combined Arithmetic-High-Level Synthesis Solution to Deploy Partial Carry-Save Radix-8 Booth
-- Multipliers in Datapaths," in IEEE Transactions on Circuits and Systems I: Regular Papers, vol. 66, no. 2, pp. 742-755, Feb. 2019. doi:
-- 10.1109/TCSI.2018.2866172
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity realCarryCalc_upper is
        generic(
          N: integer;
          S: integer--Number of stages to complete, lower than LOG_N
        );
        port(
          G_in: in std_logic_vector((N-1) downto 0);
          P_in: in std_logic_vector((N-1) downto 0);
          G_out: out std_logic_vector((N-1) downto 0);
          P_out: out std_logic_vector((N-1) downto 0)
        );
end realCarryCalc_upper;


architecture estr of realCarryCalc_upper is

    --Types
   
   type matrix is array(0 to S) of std_logic_vector((N-1) downto 0);
    
   --Signals
   
   signal psMatrix: matrix;
   signal gsMatrix: matrix;

begin

   --Stage 0
   --In this stage we copy the propagates and generates signals,
   
   gsMatrix(0)(0) <= G_in(0);
   psMatrix(0)(0) <= P_in(0);
   
   genStage0:
   for i in 1 to (N-1) generate
     gsMatrix(0)(i) <= G_in(i);
     psMatrix(0)(i) <= P_in(i);
   end generate genStage0;
    
   --StagesI
   genStagesI:
   for i in 1 to S generate
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
   
   --CopyOutput
   G_out <= gsMatrix(S);
   P_out <= psMatrix(S);

end estr;







