--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a 16x16 radix-8 Booth multiplier
-- We return the two n-bit outputs produced by the partial product matrix
-- reduction tree, implemented with a [4:2] compressors tree
-- This implementation works with signed inputs
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a 16x16 boothMult

entity booth8Mult_16 is
	port(
		X: in std_logic_vector(15 downto 0);
		Y: in std_logic_vector(15 downto 0);
		Zs: out std_logic_vector(31 downto 0);
		Zc: out std_logic_vector(31 downto 0)
	);
end booth8Mult_16;

architecture estr of booth8Mult_16 is

	--Component declarations

	component booth8Enc is
		generic(
			N: integer
		);
		port(
			x: in std_logic_vector((N-1) downto 0);
			sel: out std_logic_vector((3*(N/3)+2) downto 0);
			signs: out std_logic_vector((N/3) downto 0)
		);
	end component;

	component mux5to1 is
		generic(
			N: integer
		);
		port(
			x0: in std_logic_vector((N-1) downto 0);
			x1: in std_logic_vector((N-1) downto 0);
			x2: in std_logic_vector((N-1) downto 0);
			x3: in std_logic_vector((N-1) downto 0);
			x4: in std_logic_vector((N-1) downto 0);
			ctrl: in std_logic_vector(2 downto 0);
			z: out std_logic_vector((N-1) downto 0)
		);
	end component;

	component kogge_stone is
		generic(
			N: integer;
			S: integer --Number of stages=log(N)
		);
			port(
			a: in std_logic_vector((N-1) downto 0);
			b: in std_logic_vector((N-1) downto 0);
			cin: in std_logic;
			z: out std_logic_vector((N-1) downto 0);
			cout: out std_logic
		);
	end component;

	component compr4to2Tree_7_32 is
		port(
			x0: in std_logic_vector(31 downto 0);
			x1: in std_logic_vector(31 downto 0);
			x2: in std_logic_vector(31 downto 0);
			x3: in std_logic_vector(31 downto 0);
			x4: in std_logic_vector(31 downto 0);
			x5: in std_logic_vector(31 downto 0);
			x6: in std_logic_vector(31 downto 0);
			s: out std_logic_vector(31 downto 0);
			c: out std_logic_vector(31 downto 0)
		);
	end component;

	--Type declarations

	type ppMatrix is array (0 to 5) of std_logic_vector(17 downto 0);--16+2
	type ppMatrix2 is array (0 to 6) of std_logic_vector(31 downto 0);--Math.ceil((16+1)/3)

	--Signal declarations

	signal zero18: std_logic_vector(17 downto 0);
	signal x1: std_logic_vector(17 downto 0);
	signal doublex1: std_logic_vector(17 downto 0);
	signal threex1: std_logic_vector(17 downto 0);
	signal quadx1: std_logic_vector(17 downto 0);
	signal cin_thr: std_logic;
	signal cout_thr: std_logic;
	signal sel: std_logic_vector(17 downto 0);
	signal signs: std_logic_vector(5 downto 0);
	signal ext_signs: std_logic_vector(5 downto 0);--For negative multipliers
	signal pp: ppMatrix;
	signal ppAux: ppMatrix;
	signal ppSign: ppMatrix;
	signal pp2: ppMatrix2;
	signal cout: std_logic;
	signal s1: std_logic_vector(31 downto 0);
	signal c1: std_logic_vector(31 downto 0);

begin

	--Booth encoding
	b_enc: booth8Enc generic map(16)
		port map(Y,sel,signs);

	--X mantissas
	zero18 <= (OTHERS => '0');
	x1 <= X(15) & X(15) & X;--In order to make doublex1 >=0 and minusDoublex1 <0
	doublex1 <= x1(16 downto 0) & '0';
	quadx1 <= X & "00";

	cin_thr <= '0';
	thr_add: kogge_stone generic map(18,5)
		port map(x1,doublex1,cin_thr,threex1,cout_thr);
        --threex1 <= (OTHERS => '0');

	--Mux5to1
	muxGen:
	for i in 0 to 5 generate
		muxStage: mux5to1 generic map(18)
			port map(zero18,x1,doublex1,threex1,quadx1,sel((3*i+2) downto (3*i)),ppAux(i));
		ppSign(i) <= (OTHERS => signs(i));
		pp(i) <= ppAux(i) xor ppSign(i);
		ext_signs(i) <= ((signs(i) xnor X(15)) and 
			not(not(sel(3*i+2)) and not(sel(3*i+1)) and not(sel(3*i)) and signs(i))) or 
			(not(sel(3*i+2)) and not(sel(3*i+1)) and not(sel(3*i)) and not(signs(i)));
	end generate muxGen;

	--Complete partial products
	pp2(0)(31 downto 22) <= (OTHERS => '0');
	pp2(0)(21 downto 0) <= ext_signs(0) & not(ext_signs(0)) & not(ext_signs(0)) & not(ext_signs(0)) & pp(0);
	complGen:
	for i in 1 to 5 generate
		ifGenlt4:
		if (i<4) generate
		--MS '0's
		pp2(i)(31 downto (18 + 3*i + 3)) <= (OTHERS => '0');
		--Hot 1's
			pp2(i)(18 + 3*i + 2) <= '1';
		end generate ifGenlt4;
		--not(signs)
		ifGenlt5:
		if (i<5) generate
			pp2(i)((18 + 3*i + 1) downto (18 + 3*i)) <= '1' & ext_signs(i);
			--Copy operand
			pp2(i)((18 + 3*i - 1) downto (3*i)) <= pp(i);
		end generate ifGenlt5;
		ifGeneq5:
		if (i=5) generate
			--i=5 ==> overflow
			--Copy operand
			pp2(i)((18 + 3*i-2) downto (3*i)) <= pp(i)(16 downto 0);
		end generate ifGeneq5;
		--'0' and signs
		pp2(i)((3*i-1) downto (3*i-3)) <= "00" & signs(i-1);
		--LS '0's
		ifGengt1:
		if (i>1) generate
			pp2(i)((3*i-4) downto 0) <= (OTHERS => '0');
		end generate ifGengt1;
	end generate complGen;

	pp2(6) <= "0000000000000000" & signs(5) & "000000000000000";

	--[4:2] tree
	tree: compr4to2Tree_7_32 port map(pp2(0),pp2(1),pp2(2),pp2(3),pp2(4),pp2(5),
			pp2(6),s1,c1);

	Zs <= s1;
	Zc <= c1;--Beware: carry must be shifted one position to the left

end estr;
