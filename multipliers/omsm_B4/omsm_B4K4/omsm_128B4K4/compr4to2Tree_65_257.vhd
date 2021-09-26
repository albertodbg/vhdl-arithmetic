--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compr4to2Tree_65_257 is
	port(
		x0: in std_logic_vector(256 downto 0);
		x1: in std_logic_vector(256 downto 0);
		x2: in std_logic_vector(256 downto 0);
		x3: in std_logic_vector(256 downto 0);
		x4: in std_logic_vector(256 downto 0);
		x5: in std_logic_vector(256 downto 0);
		x6: in std_logic_vector(256 downto 0);
		x7: in std_logic_vector(256 downto 0);
		x8: in std_logic_vector(256 downto 0);
		x9: in std_logic_vector(256 downto 0);
		x10: in std_logic_vector(256 downto 0);
		x11: in std_logic_vector(256 downto 0);
		x12: in std_logic_vector(256 downto 0);
		x13: in std_logic_vector(256 downto 0);
		x14: in std_logic_vector(256 downto 0);
		x15: in std_logic_vector(256 downto 0);
		x16: in std_logic_vector(256 downto 0);
		x17: in std_logic_vector(256 downto 0);
		x18: in std_logic_vector(256 downto 0);
		x19: in std_logic_vector(256 downto 0);
		x20: in std_logic_vector(256 downto 0);
		x21: in std_logic_vector(256 downto 0);
		x22: in std_logic_vector(256 downto 0);
		x23: in std_logic_vector(256 downto 0);
		x24: in std_logic_vector(256 downto 0);
		x25: in std_logic_vector(256 downto 0);
		x26: in std_logic_vector(256 downto 0);
		x27: in std_logic_vector(256 downto 0);
		x28: in std_logic_vector(256 downto 0);
		x29: in std_logic_vector(256 downto 0);
		x30: in std_logic_vector(256 downto 0);
		x31: in std_logic_vector(256 downto 0);
		x32: in std_logic_vector(256 downto 0);
		x33: in std_logic_vector(256 downto 0);
		x34: in std_logic_vector(256 downto 0);
		x35: in std_logic_vector(256 downto 0);
		x36: in std_logic_vector(256 downto 0);
		x37: in std_logic_vector(256 downto 0);
		x38: in std_logic_vector(256 downto 0);
		x39: in std_logic_vector(256 downto 0);
		x40: in std_logic_vector(256 downto 0);
		x41: in std_logic_vector(256 downto 0);
		x42: in std_logic_vector(256 downto 0);
		x43: in std_logic_vector(256 downto 0);
		x44: in std_logic_vector(256 downto 0);
		x45: in std_logic_vector(256 downto 0);
		x46: in std_logic_vector(256 downto 0);
		x47: in std_logic_vector(256 downto 0);
		x48: in std_logic_vector(256 downto 0);
		x49: in std_logic_vector(256 downto 0);
		x50: in std_logic_vector(256 downto 0);
		x51: in std_logic_vector(256 downto 0);
		x52: in std_logic_vector(256 downto 0);
		x53: in std_logic_vector(256 downto 0);
		x54: in std_logic_vector(256 downto 0);
		x55: in std_logic_vector(256 downto 0);
		x56: in std_logic_vector(256 downto 0);
		x57: in std_logic_vector(256 downto 0);
		x58: in std_logic_vector(256 downto 0);
		x59: in std_logic_vector(256 downto 0);
		x60: in std_logic_vector(256 downto 0);
		x61: in std_logic_vector(256 downto 0);
		x62: in std_logic_vector(256 downto 0);
		x63: in std_logic_vector(256 downto 0);
		x64: in std_logic_vector(256 downto 0);
		s: out std_logic_vector(256 downto 0);
		c: out std_logic_vector(256 downto 0)
	);
end compr4to2Tree_65_257;

architecture estr of compr4to2Tree_65_257 is

	--Components

	component compr4to2 is
		generic(
			N: integer
		);
		port(
			q0: in std_logic_vector((N-1) downto 0);
			q1: in std_logic_vector((N-1) downto 0);
			q2: in std_logic_vector((N-1) downto 0);
			q3: in std_logic_vector((N-1) downto 0);
			cin: in std_logic;
			r0: out std_logic_vector((N-1) downto 0);
			r1: out std_logic_vector((N-1) downto 0);
			cout: out std_logic
		);
	end component;

	--Types

	type arrayResult2D is array (0 to 64) of std_logic_vector(256 downto 0);
	type arrayResult3D is array (0 to 6) of arrayResult2D;--Array de (levels+1) x (numOps) x (sizeOps)

	--Signals

	signal matrix: arrayResult3D;
	signal zero257: std_logic_vector(256 downto 0);
	signal zero1: std_logic;

	signal cout_1_0: std_logic;
	signal cout_1_1: std_logic;
	signal cout_1_2: std_logic;
	signal cout_1_3: std_logic;
	signal cout_1_4: std_logic;
	signal cout_1_5: std_logic;
	signal cout_1_6: std_logic;
	signal cout_1_7: std_logic;
	signal cout_1_8: std_logic;
	signal cout_1_9: std_logic;
	signal cout_1_10: std_logic;
	signal cout_1_11: std_logic;
	signal cout_1_12: std_logic;
	signal cout_1_13: std_logic;
	signal cout_1_14: std_logic;
	signal cout_1_15: std_logic;
	signal cout_1_16: std_logic;
	signal cout_2_0: std_logic;
	signal cout_2_1: std_logic;
	signal cout_2_2: std_logic;
	signal cout_2_3: std_logic;
	signal cout_2_4: std_logic;
	signal cout_2_5: std_logic;
	signal cout_2_6: std_logic;
	signal cout_2_7: std_logic;
	signal cout_2_8: std_logic;
	signal cout_3_0: std_logic;
	signal cout_3_1: std_logic;
	signal cout_3_2: std_logic;
	signal cout_3_3: std_logic;
	signal cout_3_4: std_logic;
	signal cout_4_0: std_logic;
	signal cout_4_1: std_logic;
	signal cout_4_2: std_logic;
	signal cout_5_0: std_logic;
	signal cout_5_1: std_logic;
	signal cout_6_0: std_logic;
	signal shMatrix_1_1: std_logic_vector(256 downto 0);
	signal shMatrix_1_3: std_logic_vector(256 downto 0);
	signal shMatrix_1_5: std_logic_vector(256 downto 0);
	signal shMatrix_1_7: std_logic_vector(256 downto 0);
	signal shMatrix_1_9: std_logic_vector(256 downto 0);
	signal shMatrix_1_11: std_logic_vector(256 downto 0);
	signal shMatrix_1_13: std_logic_vector(256 downto 0);
	signal shMatrix_1_15: std_logic_vector(256 downto 0);
	signal shMatrix_1_17: std_logic_vector(256 downto 0);
	signal shMatrix_1_19: std_logic_vector(256 downto 0);
	signal shMatrix_1_21: std_logic_vector(256 downto 0);
	signal shMatrix_1_23: std_logic_vector(256 downto 0);
	signal shMatrix_1_25: std_logic_vector(256 downto 0);
	signal shMatrix_1_27: std_logic_vector(256 downto 0);
	signal shMatrix_1_29: std_logic_vector(256 downto 0);
	signal shMatrix_1_31: std_logic_vector(256 downto 0);
	signal shMatrix_1_33: std_logic_vector(256 downto 0);
	signal shMatrix_2_1: std_logic_vector(256 downto 0);
	signal shMatrix_2_3: std_logic_vector(256 downto 0);
	signal shMatrix_2_5: std_logic_vector(256 downto 0);
	signal shMatrix_2_7: std_logic_vector(256 downto 0);
	signal shMatrix_2_9: std_logic_vector(256 downto 0);
	signal shMatrix_2_11: std_logic_vector(256 downto 0);
	signal shMatrix_2_13: std_logic_vector(256 downto 0);
	signal shMatrix_2_15: std_logic_vector(256 downto 0);
	signal shMatrix_2_17: std_logic_vector(256 downto 0);
	signal shMatrix_3_1: std_logic_vector(256 downto 0);
	signal shMatrix_3_3: std_logic_vector(256 downto 0);
	signal shMatrix_3_5: std_logic_vector(256 downto 0);
	signal shMatrix_3_7: std_logic_vector(256 downto 0);
	signal shMatrix_3_9: std_logic_vector(256 downto 0);
	signal shMatrix_4_1: std_logic_vector(256 downto 0);
	signal shMatrix_4_3: std_logic_vector(256 downto 0);
	signal shMatrix_4_5: std_logic_vector(256 downto 0);
	signal shMatrix_5_1: std_logic_vector(256 downto 0);
	signal shMatrix_5_3: std_logic_vector(256 downto 0);
	signal shMatrix_6_1: std_logic_vector(256 downto 0);


begin

	zero1 <= '0';
	zero257 <= (OTHERS => '0');

	--Mapping level 0
	matrix(0)(0) <= x0;
	matrix(0)(1) <= x1;
	matrix(0)(2) <= x2;
	matrix(0)(3) <= x3;
	matrix(0)(4) <= x4;
	matrix(0)(5) <= x5;
	matrix(0)(6) <= x6;
	matrix(0)(7) <= x7;
	matrix(0)(8) <= x8;
	matrix(0)(9) <= x9;
	matrix(0)(10) <= x10;
	matrix(0)(11) <= x11;
	matrix(0)(12) <= x12;
	matrix(0)(13) <= x13;
	matrix(0)(14) <= x14;
	matrix(0)(15) <= x15;
	matrix(0)(16) <= x16;
	matrix(0)(17) <= x17;
	matrix(0)(18) <= x18;
	matrix(0)(19) <= x19;
	matrix(0)(20) <= x20;
	matrix(0)(21) <= x21;
	matrix(0)(22) <= x22;
	matrix(0)(23) <= x23;
	matrix(0)(24) <= x24;
	matrix(0)(25) <= x25;
	matrix(0)(26) <= x26;
	matrix(0)(27) <= x27;
	matrix(0)(28) <= x28;
	matrix(0)(29) <= x29;
	matrix(0)(30) <= x30;
	matrix(0)(31) <= x31;
	matrix(0)(32) <= x32;
	matrix(0)(33) <= x33;
	matrix(0)(34) <= x34;
	matrix(0)(35) <= x35;
	matrix(0)(36) <= x36;
	matrix(0)(37) <= x37;
	matrix(0)(38) <= x38;
	matrix(0)(39) <= x39;
	matrix(0)(40) <= x40;
	matrix(0)(41) <= x41;
	matrix(0)(42) <= x42;
	matrix(0)(43) <= x43;
	matrix(0)(44) <= x44;
	matrix(0)(45) <= x45;
	matrix(0)(46) <= x46;
	matrix(0)(47) <= x47;
	matrix(0)(48) <= x48;
	matrix(0)(49) <= x49;
	matrix(0)(50) <= x50;
	matrix(0)(51) <= x51;
	matrix(0)(52) <= x52;
	matrix(0)(53) <= x53;
	matrix(0)(54) <= x54;
	matrix(0)(55) <= x55;
	matrix(0)(56) <= x56;
	matrix(0)(57) <= x57;
	matrix(0)(58) <= x58;
	matrix(0)(59) <= x59;
	matrix(0)(60) <= x60;
	matrix(0)(61) <= x61;
	matrix(0)(62) <= x62;
	matrix(0)(63) <= x63;
	matrix(0)(64) <= x64;

	--Mapping ith levels
	--Level 1
	compr1_0: compr4to2 generic map(257)
		port map(matrix(0)(0),matrix(0)(1),matrix(0)(2),matrix(0)(3),zero1,matrix(1)(0),matrix(1)(1),cout_1_0);
	shMatrix_1_1 <= matrix(1)(1)(255 downto 0) & zero1;
	compr1_1: compr4to2 generic map(257)
		port map(matrix(0)(4),matrix(0)(5),matrix(0)(6),matrix(0)(7),zero1,matrix(1)(2),matrix(1)(3),cout_1_1);
	shMatrix_1_3 <= matrix(1)(3)(255 downto 0) & zero1;
	compr1_2: compr4to2 generic map(257)
		port map(matrix(0)(8),matrix(0)(9),matrix(0)(10),matrix(0)(11),zero1,matrix(1)(4),matrix(1)(5),cout_1_2);
	shMatrix_1_5 <= matrix(1)(5)(255 downto 0) & zero1;
	compr1_3: compr4to2 generic map(257)
		port map(matrix(0)(12),matrix(0)(13),matrix(0)(14),matrix(0)(15),zero1,matrix(1)(6),matrix(1)(7),cout_1_3);
	shMatrix_1_7 <= matrix(1)(7)(255 downto 0) & zero1;
	compr1_4: compr4to2 generic map(257)
		port map(matrix(0)(16),matrix(0)(17),matrix(0)(18),matrix(0)(19),zero1,matrix(1)(8),matrix(1)(9),cout_1_4);
	shMatrix_1_9 <= matrix(1)(9)(255 downto 0) & zero1;
	compr1_5: compr4to2 generic map(257)
		port map(matrix(0)(20),matrix(0)(21),matrix(0)(22),matrix(0)(23),zero1,matrix(1)(10),matrix(1)(11),cout_1_5);
	shMatrix_1_11 <= matrix(1)(11)(255 downto 0) & zero1;
	compr1_6: compr4to2 generic map(257)
		port map(matrix(0)(24),matrix(0)(25),matrix(0)(26),matrix(0)(27),zero1,matrix(1)(12),matrix(1)(13),cout_1_6);
	shMatrix_1_13 <= matrix(1)(13)(255 downto 0) & zero1;
	compr1_7: compr4to2 generic map(257)
		port map(matrix(0)(28),matrix(0)(29),matrix(0)(30),matrix(0)(31),zero1,matrix(1)(14),matrix(1)(15),cout_1_7);
	shMatrix_1_15 <= matrix(1)(15)(255 downto 0) & zero1;
	compr1_8: compr4to2 generic map(257)
		port map(matrix(0)(32),matrix(0)(33),matrix(0)(34),matrix(0)(35),zero1,matrix(1)(16),matrix(1)(17),cout_1_8);
	shMatrix_1_17 <= matrix(1)(17)(255 downto 0) & zero1;
	compr1_9: compr4to2 generic map(257)
		port map(matrix(0)(36),matrix(0)(37),matrix(0)(38),matrix(0)(39),zero1,matrix(1)(18),matrix(1)(19),cout_1_9);
	shMatrix_1_19 <= matrix(1)(19)(255 downto 0) & zero1;
	compr1_10: compr4to2 generic map(257)
		port map(matrix(0)(40),matrix(0)(41),matrix(0)(42),matrix(0)(43),zero1,matrix(1)(20),matrix(1)(21),cout_1_10);
	shMatrix_1_21 <= matrix(1)(21)(255 downto 0) & zero1;
	compr1_11: compr4to2 generic map(257)
		port map(matrix(0)(44),matrix(0)(45),matrix(0)(46),matrix(0)(47),zero1,matrix(1)(22),matrix(1)(23),cout_1_11);
	shMatrix_1_23 <= matrix(1)(23)(255 downto 0) & zero1;
	compr1_12: compr4to2 generic map(257)
		port map(matrix(0)(48),matrix(0)(49),matrix(0)(50),matrix(0)(51),zero1,matrix(1)(24),matrix(1)(25),cout_1_12);
	shMatrix_1_25 <= matrix(1)(25)(255 downto 0) & zero1;
	compr1_13: compr4to2 generic map(257)
		port map(matrix(0)(52),matrix(0)(53),matrix(0)(54),matrix(0)(55),zero1,matrix(1)(26),matrix(1)(27),cout_1_13);
	shMatrix_1_27 <= matrix(1)(27)(255 downto 0) & zero1;
	compr1_14: compr4to2 generic map(257)
		port map(matrix(0)(56),matrix(0)(57),matrix(0)(58),matrix(0)(59),zero1,matrix(1)(28),matrix(1)(29),cout_1_14);
	shMatrix_1_29 <= matrix(1)(29)(255 downto 0) & zero1;
	compr1_15: compr4to2 generic map(257)
		port map(matrix(0)(60),matrix(0)(61),matrix(0)(62),matrix(0)(63),zero1,matrix(1)(30),matrix(1)(31),cout_1_15);
	shMatrix_1_31 <= matrix(1)(31)(255 downto 0) & zero1;
	compr1_16: compr4to2 generic map(257)
		port map(matrix(0)(64),zero257,zero257,zero257,zero1,matrix(1)(32),matrix(1)(33),cout_1_16);
	shMatrix_1_33 <= matrix(1)(33)(255 downto 0) & zero1;
	--Level 2
	compr2_0: compr4to2 generic map(257)
		port map(matrix(1)(0),shMatrix_1_1,matrix(1)(2),shMatrix_1_3,zero1,matrix(2)(0),matrix(2)(1),cout_2_0);
	shMatrix_2_1 <= matrix(2)(1)(255 downto 0) & zero1;
	compr2_1: compr4to2 generic map(257)
		port map(matrix(1)(4),shMatrix_1_5,matrix(1)(6),shMatrix_1_7,zero1,matrix(2)(2),matrix(2)(3),cout_2_1);
	shMatrix_2_3 <= matrix(2)(3)(255 downto 0) & zero1;
	compr2_2: compr4to2 generic map(257)
		port map(matrix(1)(8),shMatrix_1_9,matrix(1)(10),shMatrix_1_11,zero1,matrix(2)(4),matrix(2)(5),cout_2_2);
	shMatrix_2_5 <= matrix(2)(5)(255 downto 0) & zero1;
	compr2_3: compr4to2 generic map(257)
		port map(matrix(1)(12),shMatrix_1_13,matrix(1)(14),shMatrix_1_15,zero1,matrix(2)(6),matrix(2)(7),cout_2_3);
	shMatrix_2_7 <= matrix(2)(7)(255 downto 0) & zero1;
	compr2_4: compr4to2 generic map(257)
		port map(matrix(1)(16),shMatrix_1_17,matrix(1)(18),shMatrix_1_19,zero1,matrix(2)(8),matrix(2)(9),cout_2_4);
	shMatrix_2_9 <= matrix(2)(9)(255 downto 0) & zero1;
	compr2_5: compr4to2 generic map(257)
		port map(matrix(1)(20),shMatrix_1_21,matrix(1)(22),shMatrix_1_23,zero1,matrix(2)(10),matrix(2)(11),cout_2_5);
	shMatrix_2_11 <= matrix(2)(11)(255 downto 0) & zero1;
	compr2_6: compr4to2 generic map(257)
		port map(matrix(1)(24),shMatrix_1_25,matrix(1)(26),shMatrix_1_27,zero1,matrix(2)(12),matrix(2)(13),cout_2_6);
	shMatrix_2_13 <= matrix(2)(13)(255 downto 0) & zero1;
	compr2_7: compr4to2 generic map(257)
		port map(matrix(1)(28),shMatrix_1_29,matrix(1)(30),shMatrix_1_31,zero1,matrix(2)(14),matrix(2)(15),cout_2_7);
	shMatrix_2_15 <= matrix(2)(15)(255 downto 0) & zero1;
	compr2_8: compr4to2 generic map(257)
		port map(matrix(1)(32),shMatrix_1_33,zero257,zero257,zero1,matrix(2)(16),matrix(2)(17),cout_2_8);
	shMatrix_2_17 <= matrix(2)(17)(255 downto 0) & zero1;
	--Level 3
	compr3_0: compr4to2 generic map(257)
		port map(matrix(2)(0),shMatrix_2_1,matrix(2)(2),shMatrix_2_3,zero1,matrix(3)(0),matrix(3)(1),cout_3_0);
	shMatrix_3_1 <= matrix(3)(1)(255 downto 0) & zero1;
	compr3_1: compr4to2 generic map(257)
		port map(matrix(2)(4),shMatrix_2_5,matrix(2)(6),shMatrix_2_7,zero1,matrix(3)(2),matrix(3)(3),cout_3_1);
	shMatrix_3_3 <= matrix(3)(3)(255 downto 0) & zero1;
	compr3_2: compr4to2 generic map(257)
		port map(matrix(2)(8),shMatrix_2_9,matrix(2)(10),shMatrix_2_11,zero1,matrix(3)(4),matrix(3)(5),cout_3_2);
	shMatrix_3_5 <= matrix(3)(5)(255 downto 0) & zero1;
	compr3_3: compr4to2 generic map(257)
		port map(matrix(2)(12),shMatrix_2_13,matrix(2)(14),shMatrix_2_15,zero1,matrix(3)(6),matrix(3)(7),cout_3_3);
	shMatrix_3_7 <= matrix(3)(7)(255 downto 0) & zero1;
	compr3_4: compr4to2 generic map(257)
		port map(matrix(2)(16),shMatrix_2_17,zero257,zero257,zero1,matrix(3)(8),matrix(3)(9),cout_3_4);
	shMatrix_3_9 <= matrix(3)(9)(255 downto 0) & zero1;
	--Level 4
	compr4_0: compr4to2 generic map(257)
		port map(matrix(3)(0),shMatrix_3_1,matrix(3)(2),shMatrix_3_3,zero1,matrix(4)(0),matrix(4)(1),cout_4_0);
	shMatrix_4_1 <= matrix(4)(1)(255 downto 0) & zero1;
	compr4_1: compr4to2 generic map(257)
		port map(matrix(3)(4),shMatrix_3_5,matrix(3)(6),shMatrix_3_7,zero1,matrix(4)(2),matrix(4)(3),cout_4_1);
	shMatrix_4_3 <= matrix(4)(3)(255 downto 0) & zero1;
	compr4_2: compr4to2 generic map(257)
		port map(matrix(3)(8),shMatrix_3_9,zero257,zero257,zero1,matrix(4)(4),matrix(4)(5),cout_4_2);
	shMatrix_4_5 <= matrix(4)(5)(255 downto 0) & zero1;
	--Level 5
	compr5_0: compr4to2 generic map(257)
		port map(matrix(4)(0),shMatrix_4_1,matrix(4)(2),shMatrix_4_3,zero1,matrix(5)(0),matrix(5)(1),cout_5_0);
	shMatrix_5_1 <= matrix(5)(1)(255 downto 0) & zero1;
	compr5_1: compr4to2 generic map(257)
		port map(matrix(4)(4),shMatrix_4_5,zero257,zero257,zero1,matrix(5)(2),matrix(5)(3),cout_5_1);
	shMatrix_5_3 <= matrix(5)(3)(255 downto 0) & zero1;
	--Level 6
	compr6_0: compr4to2 generic map(257)
		port map(matrix(5)(0),shMatrix_5_1,matrix(5)(2),shMatrix_5_3,zero1,matrix(6)(0),matrix(6)(1),cout_6_0);
	shMatrix_6_1 <= matrix(6)(1)(255 downto 0) & zero1;

	--Outputs mapping

	s <= matrix(6)(0);
	c <= matrix(6)(1);

end estr;


--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compr4to2Tree_65_257_tb is
	port(
		x0: in std_logic_vector(256 downto 0);
		x1: in std_logic_vector(256 downto 0);
		x2: in std_logic_vector(256 downto 0);
		x3: in std_logic_vector(256 downto 0);
		x4: in std_logic_vector(256 downto 0);
		x5: in std_logic_vector(256 downto 0);
		x6: in std_logic_vector(256 downto 0);
		x7: in std_logic_vector(256 downto 0);
		x8: in std_logic_vector(256 downto 0);
		x9: in std_logic_vector(256 downto 0);
		x10: in std_logic_vector(256 downto 0);
		x11: in std_logic_vector(256 downto 0);
		x12: in std_logic_vector(256 downto 0);
		x13: in std_logic_vector(256 downto 0);
		x14: in std_logic_vector(256 downto 0);
		x15: in std_logic_vector(256 downto 0);
		x16: in std_logic_vector(256 downto 0);
		x17: in std_logic_vector(256 downto 0);
		x18: in std_logic_vector(256 downto 0);
		x19: in std_logic_vector(256 downto 0);
		x20: in std_logic_vector(256 downto 0);
		x21: in std_logic_vector(256 downto 0);
		x22: in std_logic_vector(256 downto 0);
		x23: in std_logic_vector(256 downto 0);
		x24: in std_logic_vector(256 downto 0);
		x25: in std_logic_vector(256 downto 0);
		x26: in std_logic_vector(256 downto 0);
		x27: in std_logic_vector(256 downto 0);
		x28: in std_logic_vector(256 downto 0);
		x29: in std_logic_vector(256 downto 0);
		x30: in std_logic_vector(256 downto 0);
		x31: in std_logic_vector(256 downto 0);
		x32: in std_logic_vector(256 downto 0);
		x33: in std_logic_vector(256 downto 0);
		x34: in std_logic_vector(256 downto 0);
		x35: in std_logic_vector(256 downto 0);
		x36: in std_logic_vector(256 downto 0);
		x37: in std_logic_vector(256 downto 0);
		x38: in std_logic_vector(256 downto 0);
		x39: in std_logic_vector(256 downto 0);
		x40: in std_logic_vector(256 downto 0);
		x41: in std_logic_vector(256 downto 0);
		x42: in std_logic_vector(256 downto 0);
		x43: in std_logic_vector(256 downto 0);
		x44: in std_logic_vector(256 downto 0);
		x45: in std_logic_vector(256 downto 0);
		x46: in std_logic_vector(256 downto 0);
		x47: in std_logic_vector(256 downto 0);
		x48: in std_logic_vector(256 downto 0);
		x49: in std_logic_vector(256 downto 0);
		x50: in std_logic_vector(256 downto 0);
		x51: in std_logic_vector(256 downto 0);
		x52: in std_logic_vector(256 downto 0);
		x53: in std_logic_vector(256 downto 0);
		x54: in std_logic_vector(256 downto 0);
		x55: in std_logic_vector(256 downto 0);
		x56: in std_logic_vector(256 downto 0);
		x57: in std_logic_vector(256 downto 0);
		x58: in std_logic_vector(256 downto 0);
		x59: in std_logic_vector(256 downto 0);
		x60: in std_logic_vector(256 downto 0);
		x61: in std_logic_vector(256 downto 0);
		x62: in std_logic_vector(256 downto 0);
		x63: in std_logic_vector(256 downto 0);
		x64: in std_logic_vector(256 downto 0);
		z: out std_logic_vector(256 downto 0);
		cout: out std_logic
	);
end compr4to2Tree_65_257_tb;

architecture tb of compr4to2Tree_65_257_tb is

	--Components

	component compr4to2Tree_65_257 is
	port(
		x0: in std_logic_vector(256 downto 0);
		x1: in std_logic_vector(256 downto 0);
		x2: in std_logic_vector(256 downto 0);
		x3: in std_logic_vector(256 downto 0);
		x4: in std_logic_vector(256 downto 0);
		x5: in std_logic_vector(256 downto 0);
		x6: in std_logic_vector(256 downto 0);
		x7: in std_logic_vector(256 downto 0);
		x8: in std_logic_vector(256 downto 0);
		x9: in std_logic_vector(256 downto 0);
		x10: in std_logic_vector(256 downto 0);
		x11: in std_logic_vector(256 downto 0);
		x12: in std_logic_vector(256 downto 0);
		x13: in std_logic_vector(256 downto 0);
		x14: in std_logic_vector(256 downto 0);
		x15: in std_logic_vector(256 downto 0);
		x16: in std_logic_vector(256 downto 0);
		x17: in std_logic_vector(256 downto 0);
		x18: in std_logic_vector(256 downto 0);
		x19: in std_logic_vector(256 downto 0);
		x20: in std_logic_vector(256 downto 0);
		x21: in std_logic_vector(256 downto 0);
		x22: in std_logic_vector(256 downto 0);
		x23: in std_logic_vector(256 downto 0);
		x24: in std_logic_vector(256 downto 0);
		x25: in std_logic_vector(256 downto 0);
		x26: in std_logic_vector(256 downto 0);
		x27: in std_logic_vector(256 downto 0);
		x28: in std_logic_vector(256 downto 0);
		x29: in std_logic_vector(256 downto 0);
		x30: in std_logic_vector(256 downto 0);
		x31: in std_logic_vector(256 downto 0);
		x32: in std_logic_vector(256 downto 0);
		x33: in std_logic_vector(256 downto 0);
		x34: in std_logic_vector(256 downto 0);
		x35: in std_logic_vector(256 downto 0);
		x36: in std_logic_vector(256 downto 0);
		x37: in std_logic_vector(256 downto 0);
		x38: in std_logic_vector(256 downto 0);
		x39: in std_logic_vector(256 downto 0);
		x40: in std_logic_vector(256 downto 0);
		x41: in std_logic_vector(256 downto 0);
		x42: in std_logic_vector(256 downto 0);
		x43: in std_logic_vector(256 downto 0);
		x44: in std_logic_vector(256 downto 0);
		x45: in std_logic_vector(256 downto 0);
		x46: in std_logic_vector(256 downto 0);
		x47: in std_logic_vector(256 downto 0);
		x48: in std_logic_vector(256 downto 0);
		x49: in std_logic_vector(256 downto 0);
		x50: in std_logic_vector(256 downto 0);
		x51: in std_logic_vector(256 downto 0);
		x52: in std_logic_vector(256 downto 0);
		x53: in std_logic_vector(256 downto 0);
		x54: in std_logic_vector(256 downto 0);
		x55: in std_logic_vector(256 downto 0);
		x56: in std_logic_vector(256 downto 0);
		x57: in std_logic_vector(256 downto 0);
		x58: in std_logic_vector(256 downto 0);
		x59: in std_logic_vector(256 downto 0);
		x60: in std_logic_vector(256 downto 0);
		x61: in std_logic_vector(256 downto 0);
		x62: in std_logic_vector(256 downto 0);
		x63: in std_logic_vector(256 downto 0);
		x64: in std_logic_vector(256 downto 0);
		s: out std_logic_vector(256 downto 0);
		c: out std_logic_vector(256 downto 0)
	);
	end component;

	component kogge_stone is
		generic(N: integer;
			S: integer);--Number of stages
		port(
			a: in std_logic_vector((N-1) downto 0);
			b: in std_logic_vector((N-1) downto 0);
			cin: in std_logic;
			z: out std_logic_vector((N-1) downto 0);
			cout: out std_logic
		);
	end component;

	--Signals

	signal cin_ks: std_logic;
	signal cout_ks: std_logic;
	signal s: std_logic_vector(256 downto 0);
	signal c: std_logic_vector(256 downto 0);
	signal ns: std_logic_vector(257 downto 0);
	signal nc: std_logic_vector(257 downto 0);
	signal nz: std_logic_vector(257 downto 0);

begin

	tree: compr4to2Tree_65_257 port map(x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20,x21,x22,x23,x24,x25,x26,x27,x28,x29,x30,x31,x32,x33,x34,x35,x36,x37,x38,x39,x40,x41,x42,x43,x44,x45,x46,x47,x48,x49,x50,x51,x52,x53,x54,x55,x56,x57,x58,x59,x60,x61,x62,x63,x64,s,c);

	ns <= '0' & s;
	nc <= c & '0';

	cin_ks <= '0';
	ks: kogge_stone generic map(258,9)
			port map(ns,nc,cin_ks,nz,cout_ks);

	z <= nz(256 downto 0);
	cout <= nz(257);

end tb;
