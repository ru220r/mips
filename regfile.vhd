library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;


entity regfile is	
	
	port (
		clk				  : in  std_logic;
		reset		        : in  std_logic;
		stall            : in  std_logic;
		rdaddr1, rdaddr2 : in  std_logic_vector(REG_BITS-1 downto 0);
		rddata1, rddata2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wraddr			  : in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata			  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite         : in  std_logic
	);

end regfile;

architecture rtl of regfile is
	
	signal rdaddr1_latched, rdaddr2_latched: std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal registers : REG_FILE_OUT := (others => (others => '0'));
		
begin  -- rtl
	
	update: process (all)
	begin		
		if reset = '0' then
			rdaddr1_latched <= (others => '0');			
			rdaddr2_latched <= (others => '0');					
		else 
			if rising_edge(clk) and stall = '0' then			
				rdaddr1_latched <= rdaddr1;			
				rdaddr2_latched <= rdaddr2;					
			end if;
			if rising_edge(clk) and regwrite = '1' and stall = '0' and wraddr /= "00000" then
				registers(to_integer(unsigned(wraddr))) <= wrdata;
			end if;
		end if;
	end process;
	
	output: process(all)
	begin
		rddata1 <= registers(to_integer(unsigned(rdaddr1_latched)));
		rddata2 <= registers(to_integer(unsigned(rdaddr2_latched)));
		
		if stall = '0' and regwrite = '1' and wraddr /= "00000" then
			if wraddr = rdaddr1_latched then
				rddata1 <= wrdata;
			end if;
			if wraddr = rdaddr2_latched then
				rddata2 <= wrdata;
			end if;
		end if;
	
	end process;
	
end rtl;