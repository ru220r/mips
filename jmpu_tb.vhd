library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity jmpu_tb is
end jmpu_tb;

architecture beh of jmpu_tb is

component jmpu is
	port (
		op   : in  jmp_op_type;
		N, Z : in  std_logic;
		J    : out std_logic);
end component;

	signal op   :   jmp_op_type;
	signal N, Z :   std_logic;
	signal J    :   std_logic;
	
	
begin

	uut :jmpu
		port map(
			op => op,
			N => N,
			Z => Z,
			J => J
		);
	
	process	
	begin
	wait for 10 us;
		N <= '0';
		Z <= '0';
		
		op <= JMP_NOP;
		wait for 100 us;
		op <= JMP_JMP;
		wait for 100 us;
		op <= JMP_BEQ;
		wait for 100 us;
		op <= JMP_BNE;
		wait for 100 us;
		op <= JMP_BLEZ;
		wait for 100 us;
		op <= JMP_BGTZ;
		wait for 100 us;
		op <= JMP_BLTZ;
		wait for 100 us;
		op <= JMP_BGEZ;
		wait for 1000 us;
		
		N <= '0';
		Z <= '1';
		
		op <= JMP_NOP;
		wait for 100 us;
		op <= JMP_JMP;
		wait for 100 us;
		op <= JMP_BEQ;
		wait for 100 us;
		op <= JMP_BNE;
		wait for 100 us;
		op <= JMP_BLEZ;
		wait for 100 us;
		op <= JMP_BGTZ;
		wait for 100 us;
		op <= JMP_BLTZ;
		wait for 100 us;
		op <= JMP_BGEZ;
		wait for 1000 us;
		
		N <= '1';
		Z <= '0';
		
		op <= JMP_NOP;
		wait for 100 us;
		op <= JMP_JMP;
		wait for 100 us;
		op <= JMP_BEQ;
		wait for 100 us;
		op <= JMP_BNE;
		wait for 100 us;
		op <= JMP_BLEZ;
		wait for 100 us;
		op <= JMP_BGTZ;
		wait for 100 us;
		op <= JMP_BLTZ;
		wait for 100 us;
		op <= JMP_BGEZ;
		wait for 1000 us;
		
		N <= '1';
		Z <= '1';
		
		op <= JMP_NOP;
		wait for 100 us;
		op <= JMP_JMP;
		wait for 100 us;
		op <= JMP_BEQ;
		wait for 100 us;
		op <= JMP_BNE;
		wait for 100 us;
		op <= JMP_BLEZ;
		wait for 100 us;
		op <= JMP_BGTZ;
		wait for 100 us;
		op <= JMP_BLTZ;
		wait for 100 us;
		op <= JMP_BGEZ;
		wait for 1000 us;
			
	
	end process;

end beh;