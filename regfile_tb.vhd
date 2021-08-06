library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;

entity regfile_tb is
end entity;


architecture beh of regfile_tb is
	constant CLK_PERIOD : time := 20 ns;

	signal clk 			: std_logic;
	signal reset		: std_logic := '1';
	signal stall      : std_logic := '0';
	signal rdaddr1		: std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal rdaddr2 	: std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal rddata1		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal rddata2 	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal wraddr, wraddr_next		: std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal wrdata, wrdata_next		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal regwrite   : std_logic := '1';

	
	signal stop_clock : boolean := false;
begin

	
	regfile_inst: entity work.regfile(rtl)
	port map
	(
		clk			=> clk,
		reset       => reset,
		stall       => stall,
		rdaddr1		=> rdaddr1,
		rdaddr2 		=> rdaddr2,
		rddata1		=> rddata1,
		rddata2 		=> rddata2,
		wraddr		=> wraddr,
		wrdata		=> wrdata,
		regwrite    => regwrite
	);

	rdaddr1 <= "10000";
	--wraddr <= "01001";
	
	stall_pr:  process
	begin
		/*wait for CLK_PERIOD * 1.5;
		stall<='0';
		rdaddr1<="00000";
		rdaddr2<="00000";
		wraddr<="00000"; 
		wrdata<="11111111111111111111111111111111";
		regwrite<='1';
		wait for CLK_PERIOD * 1;*/
		rdaddr2 <= "00000";
		wait for CLK_PERIOD * 100;
		stall <= '0';
		--wrdata <= "11111111111111111111111111111111";
		wait for CLK_PERIOD * 100;
		stall <= '1';
		wait for CLK_PERIOD * 100;		
		stall <= '0';
		wait for CLK_PERIOD * 118.5;
		rdaddr2 <= "10000";
		--regwrite <= '0';
		wait for CLK_PERIOD * 100;
		rdaddr2 <= "01000";
		wait for CLK_PERIOD * 1;
		rdaddr2 <= "01001";
		wait for CLK_PERIOD * 1;
		rdaddr2 <= "01010";
		wait for CLK_PERIOD * 1;
		rdaddr2 <= "00000";
		/*wraddr <= "10101";
		wrdata<= "01010101101010100101010110101010";*/
		wait;
	end process;
	
	pdate : process(all)
	begin
		if rising_edge(clk) then
			wraddr <= wraddr_next;
			wrdata <= wrdata_next;
		end if;
	end process;
	
	gen: process(all)
	begin
		wraddr_next <= std_logic_vector(unsigned(wraddr)+1);
		wrdata_next <= std_logic_vector(unsigned(wrdata)+1);
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