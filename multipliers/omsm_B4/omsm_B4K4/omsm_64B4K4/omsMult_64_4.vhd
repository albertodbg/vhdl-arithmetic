--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a 64x64 omsMult with k=4;

entity omsMult_64_4 is
	port(
		Xs: in std_logic_vector(63 downto 0);
		Ys: in std_logic_vector(63 downto 0);
		Gx: in std_logic_vector(15 downto 0);
		Px: in std_logic_vector(15 downto 0);
		Gy: in std_logic_vector(15 downto 0);
		Py: in std_logic_vector(15 downto 0);
		Zs: out std_logic_vector(127 downto 0);
		Zc: out std_logic_vector(127 downto 0)
	);
end omsMult_64_4;

architecture estr of omsMult_64_4 is

	--Component declarations

	component onTheFlyCorrecter is
		generic(
			N: integer;
			K: integer;
			LOG_N: integer;--Ceiling log(N)
			LOG_K: integer;--Ceiling log(K)
			LOG_N_div_K: integer--Ceiling log(N/K)
		);
		port(
			Xs: in std_logic_vector((N-1) downto 0);
			Ys: in std_logic_vector((N-1) downto 0);
			Gx: in std_logic_vector((N/K-1) downto 0);
			Px: in std_logic_vector((N/K-1) downto 0);
			Gy: in std_logic_vector((N/K-1) downto 0);
			Py: in std_logic_vector((N/K-1) downto 0);
			X: out std_logic_vector((N-1) downto 0);--X real multiplicand
			YBooth_sel: out std_logic_vector((2*(N/2)+1) downto 0);--Y Booth selection signals
			YBooth_signs: out std_logic_vector((N/2) downto 0)--Y Booth sign signals
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

	component compr4to2Tree_33_129 is
		port(
			x0: in std_logic_vector(128 downto 0);
			x1: in std_logic_vector(128 downto 0);
			x2: in std_logic_vector(128 downto 0);
			x3: in std_logic_vector(128 downto 0);
			x4: in std_logic_vector(128 downto 0);
			x5: in std_logic_vector(128 downto 0);
			x6: in std_logic_vector(128 downto 0);
			x7: in std_logic_vector(128 downto 0);
			x8: in std_logic_vector(128 downto 0);
			x9: in std_logic_vector(128 downto 0);
			x10: in std_logic_vector(128 downto 0);
			x11: in std_logic_vector(128 downto 0);
			x12: in std_logic_vector(128 downto 0);
			x13: in std_logic_vector(128 downto 0);
			x14: in std_logic_vector(128 downto 0);
			x15: in std_logic_vector(128 downto 0);
			x16: in std_logic_vector(128 downto 0);
			x17: in std_logic_vector(128 downto 0);
			x18: in std_logic_vector(128 downto 0);
			x19: in std_logic_vector(128 downto 0);
			x20: in std_logic_vector(128 downto 0);
			x21: in std_logic_vector(128 downto 0);
			x22: in std_logic_vector(128 downto 0);
			x23: in std_logic_vector(128 downto 0);
			x24: in std_logic_vector(128 downto 0);
			x25: in std_logic_vector(128 downto 0);
			x26: in std_logic_vector(128 downto 0);
			x27: in std_logic_vector(128 downto 0);
			x28: in std_logic_vector(128 downto 0);
			x29: in std_logic_vector(128 downto 0);
			x30: in std_logic_vector(128 downto 0);
			x31: in std_logic_vector(128 downto 0);
			x32: in std_logic_vector(128 downto 0);
			s: out std_logic_vector(128 downto 0);
			c: out std_logic_vector(128 downto 0)
		);
	end component;

	--Type declarations

	type ppMatrix is array (0 to 32) of std_logic_vector(65 downto 0);--64+2
	type ppMatrix2 is array (0 to 32) of std_logic_vector(128 downto 0);--2*64+1

	--Signal declarations

	signal X: std_logic_vector(63 downto 0);
	signal zero66: std_logic_vector(65 downto 0);
	signal x1: std_logic_vector(65 downto 0);
	signal doublex1: std_logic_vector(65 downto 0);
	signal minusX1: std_logic_vector(65 downto 0);
	signal minusDoublex1: std_logic_vector(65 downto 0);
	signal sel: std_logic_vector(65 downto 0);
	signal signs: std_logic_vector(32 downto 0);
	signal ext_signs: std_logic_vector(32 downto 0);--For negative multipliers
	signal pp: ppMatrix;
	signal ppAux: ppMatrix;
	signal ppSign: ppMatrix;
	signal pp2: ppMatrix2;
	signal cout: std_logic;
	signal s1: std_logic_vector(128 downto 0);
	signal c1: std_logic_vector(128 downto 0);

begin

	--Booth encoding, given by the on-the-fly correcter
	otf_corr: onTheFlyCorrecter generic map(64,4,6,2,4)
		port map(Xs,Ys,Gx,Px,Gy,Py,X,sel,signs);

	--X mantissas
	zero66 <= (OTHERS => '0');
	x1 <= X(63) & X(63) & X;--In order to make doublex1 >=0 and minusDoublex1 <0
	doublex1 <= x1(64 downto 0) & '0';
	minusX1 <= not(x1);
	minusDoublex1 <= not(doublex1);

	--Mux3to1
	muxGen:
	for i in 0 to 32 generate
		muxStage: mux3to1 generic map(66)
			port map(zero66,x1,doublex1,sel((2*i+1) downto (2*i)),ppAux(i));
		ppSign(i) <= (OTHERS => signs(i));
		pp(i) <= ppAux(i) xor ppSign(i);
		ext_signs(i) <= ((signs(i) xnor X(63)) and not(not(sel(2*i+1)) and not(sel(2*i)) and signs(i))) or
			(not(sel(2*i+1)) and not(sel(2*i)) and not(signs(i)));
	end generate muxGen;

	--Complete partial products
	pp2(0)(128 downto 69) <= (OTHERS => '0');
	pp2(0)(68 downto 0) <= ext_signs(0) & not(ext_signs(0)) & not(ext_signs(0)) & pp(0);
	complGen:
	for i in 1 to 32 generate
		--MS '0's
		pp2(i)(128 downto (68 + 2*i)) <= (OTHERS => '0');
		--Hot 1's
		ifGenlt31:
		if (i<31) generate
			pp2(i)(68 + 2*i - 1) <= '1';
		end generate ifGenlt31;
		--not(signs)
		ifGenlt32:
		if (i<32) generate
			pp2(i)(66 + 2*i) <= ext_signs(i);
			--Copy operand
			pp2(i)((65 + 2*i) downto (2*i)) <= pp(i);
		end generate ifGenlt32;
		ifGeneq32:
		if (i=32) generate
			--i=32 ==> overflow
			--Copy operand
			pp2(i)((65 + 2*i-1) downto (2*i)) <= (OTHERS => '0');
		end generate ifGeneq32;
		--'0' and signs
		pp2(i)((2*i-1) downto (2*i-2)) <= '0' & signs(i-1);
		--LS '0's
		ifGengt1:
		if (i>1) generate
			pp2(i)((2*i-3) downto 0) <= (OTHERS => '0');
		end generate ifGengt1;
	end generate complGen;

	--[4:2] tree
	tree: compr4to2Tree_33_129 port map(pp2(0),pp2(1),pp2(2),pp2(3),pp2(4),pp2(5),
			pp2(6),pp2(7),pp2(8),pp2(9),pp2(10),pp2(11),pp2(12),pp2(13),pp2(14),pp2(15),
			pp2(16),pp2(17),pp2(18),pp2(19),pp2(20),pp2(21),pp2(22),pp2(23),pp2(24),pp2(25),
			pp2(26),pp2(27),pp2(28),pp2(29),pp2(30),pp2(31),pp2(32),s1,c1);

	Zs <= s1(127 downto 0);
	Zc <= c1(127 downto 0);--Beware: carry must be shifted one position to the left

end estr;
