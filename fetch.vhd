library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.imem_altera; 

entity fetch is
	generic(
		imem_altera_path : STRING :="imem.mif"
	); 
	port (
		clk, reset : in	 std_logic;
		stall      : in  std_logic;
		pcsrc	     : in	 std_logic;
		pcsrc_exc : in	 std_logic;
		pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0)
	);

end fetch;

architecture rtl of fetch is

	signal int_pc : std_logic_vector(PC_WIDTH-1 downto 0); 
	signal int_pc_next : std_logic_vector(PC_WIDTH-1 downto 0);

begin  -- rtl

	imeme_altera_inst : entity imem_altera
	port map
	(
		address => int_pc_next(PC_WIDTH-1 downto 2), --without word address 
		clock => clk, 
		q => instr 

	); 

	sync: process(clk, reset)
	begin 
		if (reset = '0') then 
			int_pc <= std_logic_vector(to_signed(-4, PC_WIDTH));
		elsif rising_edge(clk) then 
			int_pc <= int_pc_next; 
		end if; 
	end process; 

	pc_inst : process(all)
	begin 
		int_pc_next <= int_pc; 
		pc_out <= int_pc_next; 

		if(reset = '1' and stall='0') then 
			if pcsrc_exc = '1' then
				int_pc_next <= EXCEPTION_PC; 
			elsif(pcsrc = '1') then 
				int_pc_next <= pc_in; 
			else 
				int_pc_next <= std_logic_vector(unsigned(int_pc) + to_unsigned(4, PC_WIDTH)); 
			end if; 
		end if; 
	end process; 
end rtl;
