--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a 16x16 multiplier based on radix-4 Booth encoding
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mult16 is
        port(
          X: in std_logic_vector(15 downto 0);--X sum component
          Y: in std_logic_vector(15 downto 0);--Y sum component
          Z: out std_logic_vector(31 downto 0)--Z carries component
        );
end mult16;

architecture estr of mult16 is

  --Components declaration

  component boothEnc is
  generic(
    N: integer
  );
	port(
		x: in std_logic_vector((N-1) downto 0);
		sel: out std_logic_vector((2*(N/2)+1) downto 0);
		signs: out std_logic_vector((N/2) downto 0)
	);
  end component;
  
  component mux3to1 is
   generic(
    N: integer
   );
	 port(
		x0: in std_logic_vector((N-1) downto 0);
		x1: in std_logic_vector((N-1) downto 0);
		x2: in std_logic_vector((N-1) downto 0);
		ctrl: in std_logic_vector(1 downto 0);
		z: out std_logic_vector((N-1) downto 0)
	 );
  end component;
  
  component compr4to2Tree_9_33 is
	port(
		x0: in std_logic_vector(32 downto 0);
		x1: in std_logic_vector(32 downto 0);
		x2: in std_logic_vector(32 downto 0);
		x3: in std_logic_vector(32 downto 0);
		x4: in std_logic_vector(32 downto 0);
		x5: in std_logic_vector(32 downto 0);
		x6: in std_logic_vector(32 downto 0);
		x7: in std_logic_vector(32 downto 0);
		x8: in std_logic_vector(32 downto 0);
		s: out std_logic_vector(32 downto 0);
		c: out std_logic_vector(32 downto 0)
	);
  end component;
  
  component kogge_stone is
   generic(N: integer;
           S: integer);--Number of stages=log(N)
	port(
		a: in std_logic_vector((N-1) downto 0);
		b: in std_logic_vector((N-1) downto 0);
		cin: in std_logic;
		z: out std_logic_vector((N-1) downto 0);
		cout: out std_logic
	);
  end component;

  
  --Types
  type ppMatrix is array (0 to 8) of std_logic_vector(17 downto 0);--16+2
  type ppMatrix2 is array (0 to 8) of std_logic_vector(32 downto 0);--2*16+1
    
  --Signal declarations
  
  signal zero18: std_logic_vector(17 downto 0);
  signal x1: std_logic_vector(17 downto 0);
  signal doublex1: std_logic_vector(17 downto 0);
  signal minusX1: std_logic_vector(17 downto 0);
  signal minusDoublex1: std_logic_vector(17 downto 0);
  signal sel: std_logic_vector(17 downto 0);
  signal signs: std_logic_vector(8 downto 0);
  signal ext_signs: std_logic_vector(8 downto 0);--For negative multipliers
  signal pp: ppMatrix;
  signal ppAux: ppMatrix;
  signal ppSign: ppMatrix;
  signal pp2: ppMatrix2;
  signal cout: std_logic;
  signal s1: std_logic_vector(32 downto 0);
  signal c1: std_logic_vector(32 downto 0);
  
  signal Zs: std_logic_vector(31 downto 0);
  signal Zc: std_logic_vector(31 downto 0);
  signal op1: std_logic_vector(31 downto 0);
  signal op2: std_logic_vector(31 downto 0);
  signal zero1: std_logic;
  signal cout_dummy: std_logic;

begin
  
    zero1 <= '0';
    
    --Booth encoding
    bEnc: boothEnc generic map(16)
                  port map(Y,sel,signs);
    
  
    --X mantissas
    zero18 <= (OTHERS => '0');
    x1 <= X(15) & X(15) & X;--In order to make doublex1 >=0 and minusDoublex1 <0
    doublex1 <= x1(16 downto 0) & '0';
    minusX1 <= not(x1);
    minusDoublex1 <= not(doublex1); 
                    
    --Mux3to1
    muxGen:
    for i in 0 to 8 generate
      muxStage: mux3to1 generic map(18)
                      port map(zero18,x1,doublex1,
                        sel((2*i+1) downto (2*i)),ppAux(i));
      ppSign(i) <= (OTHERS => signs(i));
      pp(i) <= ppAux(i) xor ppSign(i);
      ext_signs(i) <= ((signs(i) xnor X(15)) and not(not(sel(2*i+1)) and not(sel(2*i)) and signs(i))) or
            (not(sel(2*i+1)) and not(sel(2*i)) and not(signs(i)));
    end generate muxGen;
    
    --Complete partial products
    pp2(0)(32 downto 21) <= (OTHERS => '0'); 
    pp2(0)(20 downto 0) <= ext_signs(0) & not(ext_signs(0)) & not(ext_signs(0)) & pp(0);
    complGen:
    for i in 1 to 8 generate
      --MS '0's
      pp2(i)(32 downto (18 + 2 + 2*i)) <= (OTHERS => '0');
      --Hot 1's
      ifGenm7:
      if (i<7) generate
        pp2(i)((18 + 2 + 2*i - 1)) <= '1';
      end generate ifGenm7;
      --not(signs)
      ifGenm8:
      if (i<8) generate
        pp2(i)(18 + 2*i) <= ext_signs(i);
        --Copy operand
        pp2(i)((18 - 1 + 2*i) downto (2*i)) <= pp(i);
      end generate ifGenm8;
      ifNGenm8:
      if (i=8) generate
        --i=8 ==> overflow
        --Copy operand
        pp2(i)((18 - 1 + 2*i-1) downto (2*i)) <= (OTHERS => '0');
      end generate ifNGenm8;
      --'0' and signs
      pp2(i)((2*i-1) downto (2*i-2)) <= '0' & signs(i-1);
      --LS '0's
      ifGenM1:
      if (i>1) generate
        pp2(i)((2*i-3) downto 0) <= (OTHERS => '0');
      end generate ifGenM1;
    end generate complGen;
    
    --[4:2] tree
    tree: compr4to2Tree_9_33 port map(pp2(0),pp2(1),pp2(2),pp2(3),
        pp2(4),pp2(5),pp2(6),pp2(7),pp2(8),
        s1,c1);
        
    Zs <= s1(31 downto 0);
    Zc <= c1(31 downto 0);--Beware: carry must be shifted one position to the left
    
    op1 <= Zs;
    op2 <= Zc(30 downto 0) & '0';
    
    --Z <= op1 + op2;
    ks_add: kogge_stone generic map(32,5)
                        port map(op1,op2,zero1,Z,cout_dummy);

end estr;












