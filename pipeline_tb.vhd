library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity pipeline_tb is
end entity;


architecture beh of pipeline_tb is
	constant CLK_PERIOD : time := 20 ns;

	signal clk			: std_logic;
	signal reset		: std_logic := '1';
	signal mem_in		: mem_in_type;
	signal mem_out 	: mem_out_type;
	signal instr		: std_logic_vector(INTR_COUNT-1 downto 0) := (others => '0');

	
	signal stop_clock : boolean := false;
begin

	mem_in.rddata <= "10010010001101001101011001111000";	
	pipeline_inst: entity work.pipeline(rtl)
	port map
	(
		clk		=>	clk,
		reset 	=>	reset,
		mem_in   => mem_in,
		mem_out  => mem_out,
		intr     => instr
	);
	
	/*ram_inst: entity work.ocram_altera(syn)
	PORT map
	(
		address	=> mem_out.address(9 downto 0),
		byteena	=> mem_out.byteena,
		clock		=> clk,
		data		=> mem_out.wrdata,
		wren		=> mem_out.wr,
		q			=> mem_in.rddata
	);*/

	
	stall_pr:  process
	begin
		mem_in.busy <= '0';
		reset <= '0';
		wait for CLK_PERIOD *1.5;
		reset <= '1';
		wait for CLK_PERIOD *10.2;
		--instr(0) <= '1';
		wait for CLK_PERIOD *200;
		instr(0) <= '0';
		wait for CLK_PERIOD *20;
		--instr(1) <= '1';
		wait for CLK_PERIOD *2;
		--instr(1) <= '0';
		wait;
	end process;
	
	

	generate_clk : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD / 2;
			wait for CLK_PERIOD;
		end loop;
		wait;
	end process;

end architecture;