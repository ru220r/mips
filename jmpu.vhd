library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity jmpu is

	port (
		op   : in  jmp_op_type;
		N, Z : in  std_logic;
		J    : out std_logic);
	end jmpu;

--type jmp_op_type is (
--		JMP_NOP,
--		JMP_JMP,
--		JMP_BEQ,
--		JMP_BNE,
--		JMP_BLEZ,
--		JMP_BGTZ,
--		JMP_BLTZ,
--		JMP_BGEZ);

architecture rtl of jmpu is

	signal N_sig : std_logic;
	signal Z_sig : std_logic;
	signal J_sig : std_logic;

begin  -- rtl

	process(Z_sig, N_sig, op)
	begin
		case op is
			when JMP_NOP =>
				J_sig <= '0';
			when JMP_JMP =>
				J_sig <= '1';
			when JMP_BEQ =>
				J_sig <= Z_sig;
			when JMP_BNE =>
				J_sig <= not Z_sig;
			when JMP_BLEZ =>
				J_sig <= N_sig or Z_sig;
			when JMP_BGTZ =>
				J_sig <= not (N_sig or Z_sig);				
			when JMP_BLTZ =>
				J_sig <= N_sig;
			when JMP_BGEZ =>
				J_sig <= not N_sig;
			when others =>
		end case;
	end process;
	
	N_sig <= N;
	Z_sig <= Z;
	J <= J_sig;

end rtl;
