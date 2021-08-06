library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity wb_tb is
end wb_tb;

architecture beh of wb_tb is

	component wb is
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
	end component;
		
	signal clk 			:  std_logic := '0';
	signal reset	   :  std_logic := '0';										
	signal stall      :  std_logic;										
	signal flush      :  std_logic;										
	
	signal op	      :  wb_op_type; 										
	signal rd_in      :  std_logic_vector(REG_BITS-1 downto 0);	
	signal aluresult  :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal memresult  :  std_logic_vector(DATA_WIDTH-1 downto 0);
	
	signal rd_out     :  std_logic_vector(REG_BITS-1 downto 0); 	
	signal result     :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal regwrite   :  std_logic;			
	
	signal stop_clk   : std_logic := '0';
	
	constant CLOCK_PERIOD : time := 25 ns;
	
	
begin 

	uut : wb
		port map(
			op => op,
			clk => clk,
			reset => reset,
			stall => stall,
			flush => flush,
			rd_in => rd_in,
			aluresult => aluresult,
			memresult => memresult,
			rd_out => rd_out,
			result => result,
			regwrite => regwrite		
			);
			
	clock : process(clk)
	begin
		if (stop_clk = '0') then
			clk <= not clk after CLOCK_PERIOD;
		end if;
	end process;
	
	wb_process : process
	begin
		stall <= '0';
		flush <= '0';
		
		aluresult <= "11110000111100001111000011110000";
		memresult <= "00000000111111110000000011111111";
		
		rd_in <= (others => '1');
		op.memtoreg <= '0';
		op.regwrite <=  '0';
		
		wait for 100*CLOCK_PERIOD;
		
		reset <= '1';
		op.regwrite <= '1';
		
		wait for 500*CLOCK_PERIOD;
		
		op.memtoreg <= '1';
		
		wait for 500*CLOCK_PERIOD;
		
	end process;
end beh;