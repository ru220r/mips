library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity wb is
	
	port (
		clk, reset : in  std_logic;											--Clock, Reset (active low)
		stall      : in  std_logic;											--Stall										
		flush      : in  std_logic;											--Flush
		
		op	   	  : in  wb_op_type; 											--Write-back operation from memory stage
		rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);	   --Destination register from memory stage
		aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);   --Result from ALU
		memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);	--Result from memory load
		
		rd_out     : out std_logic_vector(REG_BITS-1 downto 0); 		--Destination register to register file
		result     : out std_logic_vector(DATA_WIDTH-1 downto 0);   --Result to register file
		regwrite   : out std_logic); 											--Write enable to register file

	end wb;

architecture rtl of wb is

	signal op_sig 				: wb_op_type;
	signal rd_in_sig 			: std_logic_vector(REG_BITS-1 downto 0);
	signal aluresult_sig 	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal memresult_sig 	: std_logic_vector(DATA_WIDTH-1 downto 0);

begin  -- rtl
	
	rd : process(clk, reset, flush)
	begin
		if (reset = '0') then
			op_sig <= WB_NOP;
			rd_in_sig <= (others => '0');
			aluresult_sig <= (others =>'0');
			memresult_sig <= (others => '0');
			
		elsif (rising_edge(clk)) then		
			if (flush = '1') then 
				op_sig <= WB_NOP;
				rd_in_sig <= (others => '0');
				aluresult_sig <= (others =>'0');
				memresult_sig <= (others => '0');
			elsif stall = '0' then
				op_sig <= op;
				rd_in_sig <= rd_in;
				aluresult_sig <= aluresult;
				memresult_sig <= memresult;
			end if;				
		end if;
	end process;
	
	assign : process(all)
	begin
	
		if (op_sig.memtoreg = '1') then
			result <= memresult_sig;
		else
			result <= aluresult_sig;
		end if;
		
		rd_out <= rd_in_sig;
		regwrite <= op_sig.regwrite or op_sig.memtoreg;
			
	end process;
	
	
end rtl;
