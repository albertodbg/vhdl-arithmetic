--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--This module implements a 128x128 radix-8 omsMult with k=3;

entity omsMultB8_128_3 is
	port(
		Xs: in std_logic_vector(127 downto 0);
		Ys: in std_logic_vector(127 downto 0);
		Ts: in std_logic_vector(129 downto 0);
		Gx: in std_logic_vector(41 downto 0);
		Px: in std_logic_vector(41 downto 0);
		Gy: in std_logic_vector(41 downto 0);
		Py: in std_logic_vector(41 downto 0);
		Gt: in std_logic_vector(42 downto 0);
		Pt: in std_logic_vector(42 downto 0);
		Zs: out std_logic_vector(255 downto 0);
		Zc: out std_logic_vector(255 downto 0)
	);
end omsMultB8_128_3;

architecture estr of omsMultB8_128_3 is

	--Component declarations

	component onTheFlyCorrecterBooth8_2 is
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
			Ts: in std_logic_vector((N+1) downto 0);
			Gx: in std_logic_vector((N/K-1) downto 0);
			Px: in std_logic_vector((N/K-1) downto 0);
			Gy: in std_logic_vector((N/K-1) downto 0);
			Py: in std_logic_vector((N/K-1) downto 0);
			Gt: in std_logic_vector(((N+2)/K-1) downto 0);
			Pt: in std_logic_vector(((N+2)/K-1) downto 0);
			X: out std_logic_vector((N-1) downto 0);--X real multiplicand
			T: out std_logic_vector((N+1) downto 0);--T real multiple
			YBooth_sel: out std_logic_vector((3*(N/3)+2) downto 0);--Y Booth selection signals
			YBooth_signs: out std_logic_vector((N/3) downto 0)--Y Booth sign signals
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

	component compr4to2Tree_44_256 is
		port(
			x0: in std_logic_vector(255 downto 0);
			x1: in std_logic_vector(255 downto 0);
			x2: in std_logic_vector(255 downto 0);
			x3: in std_logic_vector(255 downto 0);
			x4: in std_logic_vector(255 downto 0);
			x5: in std_logic_vector(255 downto 0);
			x6: in std_logic_vector(255 downto 0);
			x7: in std_logic_vector(255 downto 0);
			x8: in std_logic_vector(255 downto 0);
			x9: in std_logic_vector(255 downto 0);
			x10: in std_logic_vector(255 downto 0);
			x11: in std_logic_vector(255 downto 0);
			x12: in std_logic_vector(255 downto 0);
			x13: in std_logic_vector(255 downto 0);
			x14: in std_logic_vector(255 downto 0);
			x15: in std_logic_vector(255 downto 0);
			x16: in std_logic_vector(255 downto 0);
			x17: in std_logic_vector(255 downto 0);
			x18: in std_logic_vector(255 downto 0);
			x19: in std_logic_vector(255 downto 0);
			x20: in std_logic_vector(255 downto 0);
			x21: in std_logic_vector(255 downto 0);
			x22: in std_logic_vector(255 downto 0);
			x23: in std_logic_vector(255 downto 0);
			x24: in std_logic_vector(255 downto 0);
			x25: in std_logic_vector(255 downto 0);
			x26: in std_logic_vector(255 downto 0);
			x27: in std_logic_vector(255 downto 0);
			x28: in std_logic_vector(255 downto 0);
			x29: in std_logic_vector(255 downto 0);
			x30: in std_logic_vector(255 downto 0);
			x31: in std_logic_vector(255 downto 0);
			x32: in std_logic_vector(255 downto 0);
			x33: in std_logic_vector(255 downto 0);
			x34: in std_logic_vector(255 downto 0);
			x35: in std_logic_vector(255 downto 0);
			x36: in std_logic_vector(255 downto 0);
			x37: in std_logic_vector(255 downto 0);
			x38: in std_logic_vector(255 downto 0);
			x39: in std_logic_vector(255 downto 0);
			x40: in std_logic_vector(255 downto 0);
			x41: in std_logic_vector(255 downto 0);
			x42: in std_logic_vector(255 downto 0);
			x43: in std_logic_vector(255 downto 0);
			s: out std_logic_vector(255 downto 0);
			c: out std_logic_vector(255 downto 0)
		);
	end component;

	--Type declarations

	type ppMatrix is array (0 to 42) of std_logic_vector(129 downto 0);--128+2
	type ppMatrix2 is array (0 to 43) of std_logic_vector(255 downto 0);--Math.ceil((128+1)/3)

	--Signal declarations

	signal X: std_logic_vector(127 downto 0);
	signal zero130: std_logic_vector(129 downto 0);
	signal x1: std_logic_vector(129 downto 0);
	signal doublex1: std_logic_vector(129 downto 0);
	signal threex1: std_logic_vector(129 downto 0);
	signal quadx1: std_logic_vector(129 downto 0);
	signal cin_thr: std_logic;
	signal cout_thr: std_logic;
	signal sel: std_logic_vector(128 downto 0);
	signal signs: std_logic_vector(42 downto 0);
	signal ext_signs: std_logic_vector(42 downto 0);--For negative multipliers
	signal pp: ppMatrix;
	signal ppAux: ppMatrix;
	signal ppSign: ppMatrix;
	signal pp2: ppMatrix2;
	signal cout: std_logic;
	signal s1: std_logic_vector(255 downto 0);
	signal c1: std_logic_vector(255 downto 0);

	signal T: std_logic_vector(129 downto 0);

begin

	--Booth encoding, given by the on-the-fly correcter
	otf_corr: onTheFlyCorrecterBooth8_2 generic map(128,3,7,2,6)
		port map(Xs,Ys,Ts,Gx,Px,Gy,Py,Gt,Pt,X,T,sel,signs);

	--X mantissas
	zero130 <= (OTHERS => '0');
	x1 <= X(127) & X(127) & X;--In order to make doublex1 >=0 and minusDoublex1 <0
	doublex1 <= x1(128 downto 0) & '0';
	quadx1 <= X & "00";

	threex1 <= T;

	--Mux5to1
	muxGen:
	for i in 0 to 42 generate
		muxStage: mux5to1 generic map(130)
			port map(zero130,x1,doublex1,threex1,quadx1,sel((3*i+2) downto (3*i)),ppAux(i));
		ppSign(i) <= (OTHERS => signs(i));
		pp(i) <= ppAux(i) xor ppSign(i);
		ext_signs(i) <= ((signs(i) xnor X(127)) and 
			not(not(sel(3*i+2)) and not(sel(3*i+1)) and not(sel(3*i)) and signs(i))) or 
			(not(sel(3*i+2)) and not(sel(3*i+1)) and not(sel(3*i)) and not(signs(i)));
	end generate muxGen;

	--Complete partial products
	pp2(0)(255 downto 134) <= (OTHERS => '0');
	pp2(0)(133 downto 0) <= ext_signs(0) & not(ext_signs(0)) & not(ext_signs(0)) & not(ext_signs(0)) & pp(0);
	complGen:
	for i in 1 to 42 generate
		ifGenlt41:
		if (i<41) generate
		--MS '0's
		pp2(i)(255 downto (130 + 3*i + 3)) <= (OTHERS => '0');
		--Hot 1's
			pp2(i)(130 + 3*i + 2) <= '1';
		end generate ifGenlt41;
		--not(signs)
		ifGenlt42:
		if (i<42) generate
			pp2(i)((130 + 3*i + 1) downto (130 + 3*i)) <= '1' & ext_signs(i);
			--Copy operand
			pp2(i)((130 + 3*i - 1) downto (3*i)) <= pp(i);
		end generate ifGenlt42;
		ifGeneq42:
		if (i=42) generate
			--i=42 ==> overflow
			--Copy operand
			pp2(i)((130 + 3*i-2) downto (3*i)) <= pp(i)(128 downto 0);
		end generate ifGeneq42;
		--'0' and signs
		pp2(i)((3*i-1) downto (3*i-3)) <= "00" & signs(i-1);
		--LS '0's
		ifGengt1:
		if (i>1) generate
			pp2(i)((3*i-4) downto 0) <= (OTHERS => '0');
		end generate ifGengt1;
	end generate complGen;

	--Completing antepenultimate and penultimate rows
	pp2(41)(255) <= '1';--Hot one
	pp2(42)(255) <= pp(42)(129);--pp last bit

	pp2(43) <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & signs(42) & "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

	--[4:2] tree
	tree: compr4to2Tree_44_256 port map(pp2(0),pp2(1),pp2(2),pp2(3),pp2(4),pp2(5),
			pp2(6),pp2(7),pp2(8),pp2(9),pp2(10),pp2(11),pp2(12),pp2(13),pp2(14),pp2(15),
			pp2(16),pp2(17),pp2(18),pp2(19),pp2(20),pp2(21),pp2(22),pp2(23),pp2(24),pp2(25),
			pp2(26),pp2(27),pp2(28),pp2(29),pp2(30),pp2(31),pp2(32),pp2(33),pp2(34),pp2(35),
			pp2(36),pp2(37),pp2(38),pp2(39),pp2(40),pp2(41),pp2(42),pp2(43),s1,c1);

	Zs <= s1;
	Zc <= c1;--Beware: carry must be shifted one position to the left

end estr;
