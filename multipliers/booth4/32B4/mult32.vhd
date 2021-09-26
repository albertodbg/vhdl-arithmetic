--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a 32x32 bit with conventional radix 4 mod. Booth

entity mult32 is
        port(
          X: in std_logic_vector(31 downto 0);--X sum component
          Y: in std_logic_vector(31 downto 0);--Y sum component
          Z: out std_logic_vector(63 downto 0)--Z carries component
        );
end mult32;

architecture estr of mult32 is

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
  
  component compr4to2Tree_17_65 is
	port(
		x0: in std_logic_vector(64 downto 0);
		x1: in std_logic_vector(64 downto 0);
		x2: in std_logic_vector(64 downto 0);
		x3: in std_logic_vector(64 downto 0);
		x4: in std_logic_vector(64 downto 0);
		x5: in std_logic_vector(64 downto 0);
		x6: in std_logic_vector(64 downto 0);
		x7: in std_logic_vector(64 downto 0);
		x8: in std_logic_vector(64 downto 0);
		x9: in std_logic_vector(64 downto 0);
		x10: in std_logic_vector(64 downto 0);
		x11: in std_logic_vector(64 downto 0);
		x12: in std_logic_vector(64 downto 0);
		x13: in std_logic_vector(64 downto 0);
		x14: in std_logic_vector(64 downto 0);
		x15: in std_logic_vector(64 downto 0);
		x16: in std_logic_vector(64 downto 0);
		s: out std_logic_vector(64 downto 0);
		c: out std_logic_vector(64 downto 0)
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
  type ppMatrix is array (0 to 16) of std_logic_vector(33 downto 0);--32+2
  type ppMatrix2 is array (0 to 16) of std_logic_vector(64 downto 0);--2*32+1
    
  --Signal declarations
  
  signal zero34: std_logic_vector(33 downto 0);
  signal x1: std_logic_vector(33 downto 0);
  signal doublex1: std_logic_vector(33 downto 0);
  signal minusX1: std_logic_vector(33 downto 0);
  signal minusDoublex1: std_logic_vector(33 downto 0);
  signal sel: std_logic_vector(33 downto 0);
  signal signs: std_logic_vector(16 downto 0);
  signal ext_signs: std_logic_vector(16 downto 0);--For negative multipliers
  signal pp: ppMatrix;
  signal ppAux: ppMatrix;
  signal ppSign: ppMatrix;
  signal pp2: ppMatrix2;
  signal cout: std_logic;
  signal s1: std_logic_vector(64 downto 0);
  signal c1: std_logic_vector(64 downto 0);
  signal Zs: std_logic_vector(63 downto 0);
  signal Zc: std_logic_vector(63 downto 0);
  signal op1: std_logic_vector(63 downto 0);
  signal op2: std_logic_vector(63 downto 0);
  signal zero1: std_logic;
  signal cout_dummy: std_logic;

begin
  
    zero1 <= '0';
    
    --Booth encoding
    bEnc: boothEnc generic map(32)
                  port map(Y,sel,signs);
    
  
    --X mantissas
    zero34 <= (OTHERS => '0');
    x1 <= X(31) & X(31) & X;--In order to make doublex1 >=0 and minusDoublex1 <0
    doublex1 <= x1(32 downto 0) & '0';
    minusX1 <= not(x1);
    minusDoublex1 <= not(doublex1); 
                    
    --Mux3to1
    muxGen:
    for i in 0 to 16 generate
      muxStage: mux3to1 generic map(34)
                      port map(zero34,x1,doublex1,
                        sel((2*i+1) downto (2*i)),ppAux(i));
      ppSign(i) <= (OTHERS => signs(i));
      pp(i) <= ppAux(i) xor ppSign(i);
      ext_signs(i) <= ((signs(i) xnor X(31)) and not(not(sel(2*i+1)) and not(sel(2*i)) and signs(i))) or
            (not(sel(2*i+1)) and not(sel(2*i)) and not(signs(i)));
    end generate muxGen;
    
    --Complete partial products
    pp2(0)(64 downto 37) <= (OTHERS => '0'); 
    --pp2(0)(36 downto 0) <= not(signs(0)) & signs(0) & signs(0) & pp(0);
    pp2(0)(36 downto 0) <= ext_signs(0) & not(ext_signs(0)) & not(ext_signs(0)) & pp(0);
    complGen:
    for i in 1 to 16 generate
      --MS '0's
      pp2(i)(64 downto (34 + 2 + 2*i)) <= (OTHERS => '0');
      --Hot 1's
      ifGenm15:
      if (i<15) generate
        pp2(i)((34 + 2 + 2*i - 1)) <= '1';
      end generate ifGenm15;
      --not(signs)
      ifGenm16:
      if (i<16) generate
        --pp2(i)(34 + 2*i) <= not(signs(i));
        pp2(i)(34 + 2*i) <= ext_signs(i);
        --Copy operand
        pp2(i)((34 - 1 + 2*i) downto (2*i)) <= pp(i);
      end generate ifGenm16;
      ifNGenm16:
      if (i=16) generate
        --i=16 ==> overflow
        --Copy operand
        --pp2(i)((34 - 1 + 2*i-1) downto (2*i)) <= pp(i)((34-2) downto 0);
        pp2(i)((34 - 1 + 2*i-1) downto (2*i)) <= (OTHERS => '0');
      end generate ifNGenm16;
      --'0' and signs
      pp2(i)((2*i-1) downto (2*i-2)) <= '0' & signs(i-1);
      --LS '0's
      ifGenM1:
      if (i>1) generate
        pp2(i)((2*i-3) downto 0) <= (OTHERS => '0');
      end generate ifGenM1;
    end generate complGen;
    
    --[4:2] tree
    tree: compr4to2Tree_17_65 port map(pp2(0),pp2(1),pp2(2),pp2(3),
        pp2(4),pp2(5),pp2(6),pp2(7),pp2(8),pp2(9),pp2(10),pp2(11),
        pp2(12),pp2(13),pp2(14),pp2(15),pp2(16),s1,c1);
        
    Zs <= s1(63 downto 0);
    Zc <= c1(63 downto 0);--Beware: carry must be shifted one position to the left
    
    op1 <= Zs;
    op2 <= Zc(62 downto 0) & '0';
    
    --Z <= op1 + op2;
    ks_add: kogge_stone generic map(64,6)
                        port map(op1,op2,zero1,Z,cout_dummy);

end estr;










