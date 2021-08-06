library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity memu_tb is
end memu_tb;

architecture beh of memu_tb is



		signal op   :  mem_op_type;	
		signal A    :  std_logic_vector(ADDR_WIDTH-1 downto 0);
		signal W    :  std_logic_vector(DATA_WIDTH-1 downto 0);
		signal D    :  std_logic_vector(DATA_WIDTH-1 downto 0);
		signal M    :  mem_out_type;
		signal R    :  std_logic_vector(DATA_WIDTH-1 downto 0);
		signal XL   :  std_logic;
		signal XS   :  std_logic;
		
		

component memu is
	port (
		op   : in  mem_op_type;
		A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		M    : out mem_out_type;
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		XL   : out std_logic;
		XS   : out std_logic);
end component;

begin

	uut: memu
	
	port map( 
		op => op,
		A => A,
		W => W,
		D => D,
		M => M,
		R => R,
		XL => XL,
		XS => XS			
	);
	
	stimulus : process
	begin
		wait for 1000 ns;
--		Failed test: op=(0, 0, mem_w) A=000000000000000000000 W=00000000000000000000000000000000 D=00000000000000000000000000000000, 
--result M=(000000000000000000000, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(000000000000000000000, 0, 0, 1111, 00000000000000000000000000000000) R=00000000000000000000000000000000 XL=0 XS=0
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_w;
	A <= "000000000000000000000";
	W <= "00000000000000000000000000000000";
	D <=  "00000000000000000000000000000000";
	wait for 1000 ns;
	
	
--
--Failed test: op=(0, 0, mem_w) A=000010000000000000000 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(000010000000000000000, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(000010000000000000000, 0, 0, 1111, 00000001001000110100010101100111) R=00000001111111101101110000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_w;
	A <= "000010000000000000000";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_w) A=000010000000000000001 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(000010000000000000001, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(000010000000000000001, 0, 0, 1111, 00000001001000110100010101100111) R=00000001111111101101110000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_w;
	A <= "000010000000000000001";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_w) A=000010000000000000010 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(000010000000000000010, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(000010000000000000010, 0, 0, 1111, 00000001001000110100010101100111) R=00000001111111101101110000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_w;
	A <= "000010000000000000010";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_w) A=000010000000000000011 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(000010000000000000011, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(000010000000000000011, 0, 0, 1111, 00000001001000110100010101100111) R=00000001111111101101110000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_w;
	A <= "000010000000000000011";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_h) A=000100000000000000100 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(000100000000000000100, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(000100000000000000100, 0, 0, 1100, 0100010101100111----------------) R=00000000000000000000000111111110 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_h;
	A <= "000100000000000000100";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_h) A=000100000000000000101 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(000100000000000000101, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(000100000000000000101, 0, 0, 1100, 0100010101100111----------------) R=00000000000000000000000111111110 XL=0 XS=0
--;
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_h;
	A <= "000100000000000000101";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_h) A=000100000000000000110 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(000100000000000000110, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(000100000000000000110, 0, 0, 0011, ----------------0100010101100111) R=11111111111111111101110000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_h;
	A <= "000100000000000000110";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_h) A=000100000000000000111 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(000100000000000000111, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(000100000000000000111, 0, 0, 0011, ----------------0100010101100111) R=11111111111111111101110000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_h;
	A <= "000100000000000000111";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_hu) A=001000000000000001000 W=00000001001000110100010101100111 D=11111110000000010010001111011100,
-- result M=(001000000000000001000, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(001000000000000001000, 0, 0, 1100, 0100010101100111----------------) R=00000000000000001111111000000001 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_hu;
	A <= "001000000000000001000";
	W <= "00000001001000110100010101100111";
	D <=  "11111110000000010010001111011100";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_hu) A=001000000000000001001 W=00000001001000110100010101100111 D=11111110000000010010001111011100,
-- result M=(001000000000000001001, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(001000000000000001001, 0, 0, 1100, 0100010101100111----------------) R=00000000000000001111111000000001 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_hu;
	A <= "001000000000000001001";
	W <= "00000001001000110100010101100111";
	D <=  "11111110000000010010001111011100";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_hu) A=001000000000000001010 W=00000001001000110100010101100111 D=11111110000000010010001111011100, 
--result M=(001000000000000001010, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(001000000000000001010, 0, 0, 0011, ----------------0100010101100111) R=00000000000000000010001111011100 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_hu;
	A <= "001000000000000001010";
	W <= "00000001001000110100010101100111";
	D <=  "11111110000000010010001111011100";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_hu) A=001000000000000001011 W=00000001001000110100010101100111 D=11111110000000010010001111011100, 
--result M=(001000000000000001011, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(001000000000000001011, 0, 0, 0011, ----------------0100010101100111) R=00000000000000000010001111011100 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_hu;
	A <= "001000000000000001011";
	W <= "00000001001000110100010101100111";
	D <=  "11111110000000010010001111011100";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_b) A=010000000000000010000 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(010000000000000010000, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0,
-- expected M=(010000000000000010000, 0, 0, 1000, 01100111------------------------) R=00000000000000000000000000000001 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_b;
	A <= "010000000000000010000";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_b) A=010000000000000010001 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(010000000000000010001, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(010000000000000010001, 0, 0, 0100, --------01100111----------------) R=11111111111111111111111111111110 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_b;
	A <= "010000000000000010001";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_b) A=010000000000000010010 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(010000000000000010010, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(010000000000000010010, 0, 0, 0010, ----------------01100111--------) R=11111111111111111111111111011100 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_b;
	A <= "010000000000000010010";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_b) A=010000000000000010011 W=00000001001000110100010101100111 D=00000001111111101101110000100011, 
--result M=(010000000000000010011, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(010000000000000010011, 0, 0, 0001, ------------------------01100111) R=00000000000000000000000000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_b;
	A <= "010000000000000010011";
	W <= "00000001001000110100010101100111";
	D <=  "00000001111111101101110000100011";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_bu) A=100000000000000100000 W=00000001001000110100010101100111 D=11111110000000010010001111011100,
-- result M=(100000000000000100000, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0,
-- expected M=(100000000000000100000, 0, 0, 1000, 01100111------------------------) R=00000000000000000000000011111110 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_bu;
	A <= "100000000000000100000";
	W <= "00000001001000110100010101100111";
	D <=  "11111110000000010010001111011100";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_bu) A=100000000000000100001 W=00000001001000110100010101100111 D=11111110000000010010001111011100, 
--result M=(100000000000000100001, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(100000000000000100001, 0, 0, 0100, --------01100111----------------) R=00000000000000000000000000000001 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_bu;
	A <= "100000000000000100001";
	W <= "00000001001000110100010101100111";
	D <=  "11111110000000010010001111011100";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_bu) A=100000000000000100010 W=00000001001000110100010101100111 D=11111110000000010010001111011100, 
--result M=(100000000000000100010, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(100000000000000100010, 0, 0, 0010, ----------------01100111--------) R=00000000000000000000000000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_bu;
	A <= "100000000000000100010";
	W <= "00000001001000110100010101100111";
	D <=  "11111110000000010010001111011100";
	wait for 1000 ns;
--Failed test: op=(0, 0, mem_bu) A=100000000000000100011 W=00000001001000110100010101100111 D=11111110000000010010001111011100, 
--result M=(100000000000000100011, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU XL=0 XS=0, 
--expected M=(100000000000000100011, 0, 0, 0001, ------------------------01100111) R=00000000000000000000000011011100 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '0';
	op.memtype <= mem_bu;
	A <= "100000000000000100011";
	W <= "00000001001000110100010101100111";
	D <=  "11111110000000010010001111011100";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_w) A=000000000000001000000 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000000001000000, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=01000101011001111000100110101011 XL=0 XS=0, 
--expected M=(000000000000001000000, 1, 0, 1111, 00000001001000110100010101100111) R=01000101011001111000100110101011 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_w;
	A <= "000000000000001000000";
	W <= "00000001001000110100010101100111";
	D <=  "11111110000000010010001111011100";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_w) A=000000000000001000001 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000000001000001, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=01000101011001111000100110101011 XL=1 XS=0, 
--expected M=(000000000000001000001, 0, 0, 1111, 00000001001000110100010101100111) R=01000101011001111000100110101011 XL=1 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_w;
	A <= "000000000000001000001";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_w) A=000000000000001000010 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000000001000010, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=01000101011001111000100110101011 XL=1 XS=0, 
--expected M=(000000000000001000010, 0, 0, 1111, 00000001001000110100010101100111) R=01000101011001111000100110101011 XL=1 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_w;
	A <= "000000000000001000010";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_w) A=000000000000001000011 W=00000001001000110100010101100111 D=01000101011001111000100110101011,
-- result M=(000000000000001000011, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=01000101011001111000100110101011 XL=1 XS=0,
-- expected M=(000000000000001000011, 0, 0, 1111, 00000001001000110100010101100111) R=01000101011001111000100110101011 XL=1 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_w;
	A <= "000000000000001000011";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_h) A=000000000000010000000 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000000010000000, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000100010101100111 XL=0 XS=0, 
--expected M=(000000000000010000000, 1, 0, 1100, 0100010101100111----------------) R=00000000000000000100010101100111 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_h;
	A <= "000000000000010000000";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_h) A=000000000000010000001 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000000010000001, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000100010101100111 XL=1 XS=0,
-- expected M=(000000000000010000001, 0, 0, 1100, 0100010101100111----------------) R=00000000000000000100010101100111 XL=1 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_h;
	A <= "000000000000010000001";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_h) A=000000000000010000010 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000000010000010, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=11111111111111111000100110101011 XL=0 XS=0,
-- expected M=(000000000000010000010, 1, 0, 0011, ----------------0100010101100111) R=11111111111111111000100110101011 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_h;
	A <= "000000000000010000010";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_h) A=000000000000010000011 W=00000001001000110100010101100111 D=01000101011001111000100110101011,
-- result M=(000000000000010000011, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=11111111111111111000100110101011 XL=1 XS=0,
-- expected M=(000000000000010000011, 0, 0, 0011, ----------------0100010101100111) R=11111111111111111000100110101011 XL=1 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_h;
	A <= "000000000000010000011";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_hu) A=000000000000100000000 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000000100000000, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000100010101100111 XL=0 XS=0, 
--expected M=(000000000000100000000, 1, 0, 1100, 0100010101100111----------------) R=00000000000000000100010101100111 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_hu;
	A <= "000000000000100000000";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_hu) A=000000000000100000001 W=00000001001000110100010101100111 D=01000101011001111000100110101011,
-- result M=(000000000000100000001, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000100010101100111 XL=1 XS=0,
-- expected M=(000000000000100000001, 0, 0, 1100, 0100010101100111----------------) R=00000000000000000100010101100111 XL=1 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_hu;
	A <= "000000000000100000001";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_hu) A=000000000000100000010 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000000100000010, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000001000100110101011 XL=0 XS=0, 
--expected M=(000000000000100000010, 1, 0, 0011, ----------------0100010101100111) R=00000000000000001000100110101011 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_hu;
	A <= "000000000000100000010";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_hu) A=000000000000100000011 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000000100000011, 0, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000001000100110101011 XL=1 XS=0, 
--expected M=(000000000000100000011, 0, 0, 0011, ----------------0100010101100111) R=00000000000000001000100110101011 XL=1 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_hu;
	A <= "000000000000100000011";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_b) A=000000000001000000000 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000001000000000, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000000000001000101 XL=0 XS=0,
-- expected M=(000000000001000000000, 1, 0, 1000, 01100111------------------------) R=00000000000000000000000001000101 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_b;
	A <= "000000000001000000000";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_b) A=000000000001000000001 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000001000000001, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000000000001100111 XL=0 XS=0,
-- expected M=(000000000001000000001, 1, 0, 0100, --------01100111----------------) R=00000000000000000000000001100111 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_b;
	A <= "000000000001000000001";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_b) A=000000000001000000010 W=00000001001000110100010101100111 D=01000101011001111000100110101011,
-- result M=(000000000001000000010, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=11111111111111111111111110001001 XL=0 XS=0, 
--expected M=(000000000001000000010, 1, 0, 0010, ----------------01100111--------) R=11111111111111111111111110001001 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_b;
	A <= "000000000001000000010";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_b) A=000000000001000000011 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000001000000011, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=11111111111111111111111110101011 XL=0 XS=0,
-- expected M=(000000000001000000011, 1, 0, 0001, ------------------------01100111) R=11111111111111111111111110101011 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_b;
	A <= "000000000001000000011";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_bu) A=000000000010000000000 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000010000000000, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000000000001000101 XL=0 XS=0, 
--expected M=(000000000010000000000, 1, 0, 1000, 01100111------------------------) R=00000000000000000000000001000101 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_bu;
	A <= "000000000010000000000";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_bu) A=000000000010000000001 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000010000000001, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000000000001100111 XL=0 XS=0, 
--expected M=(000000000010000000001, 1, 0, 0100, --------01100111----------------) R=00000000000000000000000001100111 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_bu;
	A <= "000000000010000000001";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_bu) A=000000000010000000010 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000010000000010, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000000000010001001 XL=0 XS=0, 
--expected M=(000000000010000000010, 1, 0, 0010, ----------------01100111--------) R=00000000000000000000000010001001 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_bu;
	A <= "000000000010000000010";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_bu) A=000000000010000000011 W=00000001001000110100010101100111 D=01000101011001111000100110101011, 
--result M=(000000000010000000011, 1, 0, 0000, UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000000010000000011, 1, 0, 0001, ------------------------01100111) R=00000000000000000000000010101011 XL=0 XS=0
--
	op.memread <= '1';
	op.memwrite <= '0';
	op.memtype <= mem_bu;
	A <= "000000000010000000011";
	W <= "00000001001000110100010101100111";
	D <=  "01000101011001111000100110101011";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_w) A=000000000100000000000 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000000100000000000, 0, 1, 0000, 00000001001000110100010101100111) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000000100000000000, 0, 1, 1111, 00000001001000110100010101100111) R=10101011000000010010001111001101 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_w;
	A <= "000000000100000000000";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_w) A=000000000100000000001 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000000100000000001, 0, 0, 0000, 00000001001000110100010101100111) R=00000000000000000000000010101011 XL=0 XS=1, 
--expected M=(000000000100000000001, 0, 0, 1111, 00000001001000110100010101100111) R=10101011000000010010001111001101 XL=0 XS=1
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_w;
	A <= "000000000100000000001";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_w) A=000000000100000000010 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000000100000000010, 0, 0, 0000, 00000001001000110100010101100111) R=00000000000000000000000010101011 XL=0 XS=1, 
--expected M=(000000000100000000010, 0, 0, 1111, 00000001001000110100010101100111) R=10101011000000010010001111001101 XL=0 XS=1
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_w;
	A <= "000000000100000000010";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_w) A=000000000100000000011 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000000100000000011, 0, 0, 0000, 00000001001000110100010101100111) R=00000000000000000000000010101011 XL=0 XS=1,
-- expected M=(000000000100000000011, 0, 0, 1111, 00000001001000110100010101100111) R=10101011000000010010001111001101 XL=0 XS=1
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_w;
	A <= "000000000100000000011";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_h) A=000000001000000000000 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000001000000000000, 0, 1, 1100, 01000101011001110000000000000000) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000001000000000000, 0, 1, 1100, 0100010101100111----------------) R=11111111111111111010101100000001 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_h;
	A <= "000000001000000000000";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_h) A=000000001000000000001 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000001000000000001, 0, 0, 1100, 01000101011001110000000000000000) R=00000000000000000000000010101011 XL=0 XS=1, 
--expected M=(000000001000000000001, 0, 0, 1100, 0100010101100111----------------) R=11111111111111111010101100000001 XL=0 XS=1
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_h;
	A <= "000000001000000000001";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_h) A=000000001000000000010 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000001000000000010, 0, 1, 0011, 00000000000000000100010101100111) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000001000000000010, 0, 1, 0011, ----------------0100010101100111) R=00000000000000000010001111001101 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_h;
	A <= "000000001000000000010";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 
--Failed test: op=(0, 1, mem_h) A=000000001000000000011 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000001000000000011, 0, 0, 0011, 00000000000000000100010101100111) R=00000000000000000000000010101011 XL=0 XS=1, 
--expected M=(000000001000000000011, 0, 0, 0011, ----------------0100010101100111) R=00000000000000000010001111001101 XL=0 XS=1
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_h;
	A <= "000000001000000000011";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_hu) A=000000010000000000000 W=11111110110111001011101010011000 D=10101011000000010010001111001101, 
--result M=(000000010000000000000, 0, 1, 1100, 10111010100110000000000000000000) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000010000000000000, 0, 1, 1100, 1011101010011000----------------) R=00000000000000001010101100000001 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_hu;
	A <= "000000010000000000000";
	W <= "11111110110111001011101010011000";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_hu) A=000000010000000000001 W=11111110110111001011101010011000 D=10101011000000010010001111001101, 
--result M=(000000010000000000001, 0, 0, 1100, 10111010100110000000000000000000) R=00000000000000000000000010101011 XL=0 XS=1, 
--expected M=(000000010000000000001, 0, 0, 1100, 1011101010011000----------------) R=00000000000000001010101100000001 XL=0 XS=1
--;
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_hu;
	A <= "000000010000000000001";
	W <= "11111110110111001011101010011000";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_hu) A=000000010000000000010 W=11111110110111001011101010011000 D=10101011000000010010001111001101, 
--result M=(000000010000000000010, 0, 1, 0011, 00000000000000001011101010011000) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000010000000000010, 0, 1, 0011, ----------------1011101010011000) R=00000000000000000010001111001101 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_hu;
	A <= "000000010000000000010";
	W <= "11111110110111001011101010011000";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_hu) A=000000010000000000011 W=11111110110111001011101010011000 D=10101011000000010010001111001101, 
--result M=(000000010000000000011, 0, 0, 0011, 00000000000000001011101010011000) R=00000000000000000000000010101011 XL=0 XS=1, 
--expected M=(000000010000000000011, 0, 0, 0011, ----------------1011101010011000) R=00000000000000000010001111001101 XL=0 XS=1
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_hu;
	A <= "000000010000000000011";
	W <= "11111110110111001011101010011000";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_b) A=000000100000000000000 W=00000001001000110100010101100111 D=10101011000000010010001111001101,
-- result M=(000000100000000000000, 0, 1, 1000, 01100111000000000000000000000000) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000100000000000000, 0, 1, 1000, 01100111------------------------) R=11111111111111111111111110101011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_b;
	A <= "000000100000000000000";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_b) A=000000100000000000001 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000100000000000001, 0, 1, 0100, 00000000011001110000000000000000) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000100000000000001, 0, 1, 0100, --------01100111----------------) R=00000000000000000000000000000001 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_b;
	A <= "000000100000000000001";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_b) A=000000100000000000010 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000100000000000010, 0, 1, 0010, 00000000000000000110011100000000) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000100000000000010, 0, 1, 0010, ----------------01100111--------) R=00000000000000000000000000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_b;
	A <= "000000100000000000010";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_b) A=000000100000000000011 W=00000001001000110100010101100111 D=10101011000000010010001111001101, 
--result M=(000000100000000000011, 0, 1, 0001, 00000000000000000000000001100111) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000000100000000000011, 0, 1, 0001, ------------------------01100111) R=11111111111111111111111111001101 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_b;
	A <= "000000100000000000011";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_bu) A=000001000000000000001 W=11111110110111001011101010011000 D=10101011000000010010001111001101, 
--result M=(000001000000000000001, 0, 1, 0100, 00000000100110000000000000000000) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000001000000000000001, 0, 1, 0100, --------10011000----------------) R=00000000000000000000000000000001 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_bu;
	A <= "000001000000000000001";
	W <= "11111110110111001011101010011000";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_bu) A=000001000000000000010 W=11111110110111001011101010011000 D=10101011000000010010001111001101, 
--result M=(000001000000000000010, 0, 1, 0010, 00000000000000001001100000000000) R=00000000000000000000000010101011 XL=0 XS=0, 
--expected M=(000001000000000000010, 0, 1, 0010, ----------------10011000--------) R=00000000000000000000000000100011 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_bu;
	A <= "000001000000000000010";
	W <= "11111110110111001011101010011000";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_bu) A=000001000000000000011 W=11111110110111001011101010011000 D=10101011000000010010001111001101, 
--result M=(000001000000000000011, 0, 1, 0001, 00000000000000000000000010011000) R=00000000000000000000000010101011 XL=0 XS=0,
-- expected M=(000001000000000000011, 0, 1, 0001, ------------------------10011000) R=00000000000000000000000011001101 XL=0 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_bu;
	A <= "000001000000000000011";
	W <= "11111110110111001011101010011000";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(1, 0, mem_w) A=000000000000000000000 W=00000000000000000000000000000000 D=00000000000000000000000000000000,
-- result M=(000000000000000000000, 0, 0, 0001, 00000000000000000000000010011000) R=00000000000000000000000010101011 XL=1 XS=0, 
--expected M=(000000000000000000000, 0, 0, 1111, 00000000000000000000000000000000) R=00000000000000000000000000000000 XL=1 XS=0
--
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_bu;
	A <= "000000000000000000000";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
--Failed test: op=(0, 1, mem_w) A=000000000000000000000 W=00000000000000000000000000000000 D=00000000000000000000000000000000, 
--result M=(000000000000000000000, 0, 0, 0001, 00000000000000000000000010011000) R=00000000000000000000000010101011 XL=0 XS=1, 
--expected M=(000000000000000000000, 0, 0, 1111, 00000000000000000000000000000000) R=00000000000000000000000000000000 XL=0 XS=1
	op.memread <= '0';
	op.memwrite <= '1';
	op.memtype <= mem_bu;
	A <= "000000100000000000011";
	W <= "00000001001000110100010101100111";
	D <=  "10101011000000010010001111001101";
	wait for 1000 ns;
	end process;

end architecture;