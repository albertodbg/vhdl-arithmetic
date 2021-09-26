--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a Kogge-Stone adder returning the (G,P) vectors as well
-- A detailed explanation can be found in
-- A. A. Del Barrio, R. Hermida and S. Ogrenci-Memik, "A Combined Arithmetic-High-Level Synthesis Solution to Deploy Partial Carry-Save Radix-8 Booth
-- Multipliers in Datapaths," in IEEE Transactions on Circuits and Systems I: Regular Papers, vol. 66, no. 2, pp. 742-755, Feb. 2019. doi:
-- 10.1109/TCSI.2018.2866172
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gp_kogge_stone is
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
end gp_kogge_stone;


architecture estr of gp_kogge_stone is
   
   --Types
   
   type matrix is array(0 to S) of std_logic_vector((N-1) downto 0);
    
   --Signals
   signal carrys: std_logic_vector((N-1) downto 0);
   
   signal psMatrix: matrix;
   signal gsMatrix: matrix;
    
begin
    
   --Stage 0
   psMatrix(0)(0) <= (a(0) xor b(0));
   gsMatrix(0)(0) <= (a(0) and b(0)) or (a(0) and cin) or (b(0) and cin);
   z(0) <= psMatrix(0)(0) xor cin;
   genStage0:
   for i in 1 to (N-1) generate
      psMatrix(0)(i) <= a(i) xor b(i);
      gsMatrix(0)(i) <= a(i) and b(i);
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
   
   --CopyLastCarrys
   copyLastCarrys:
   for i in 0 to (N-1) generate
      carrys(i) <= gsMatrix(S)(i);
   end generate copyLastCarrys;
   
   --Output
   cout <= carrys(N-1);
   genOutput:
   for i in 1 to (N-1) generate
      z(i) <= a(i) xor b(i) xor carrys(i-1);
   end generate genOutput;
   
   --Group Generates and Propagates signals
   G <= gsMatrix(S)(N-1);
   P <= psMatrix(S)(N-1);
    
end estr;







