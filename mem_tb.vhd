library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity mem_tb is
end mem_tb;

architecture beh of mem_tb is

component mem is 
	port (
		clk, reset    : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;
		mem_op        : in  mem_op_type; 										--Memory operation from execute stage
		jmp_op        : in  jmp_op_type;											--Jump operation from execute stage
		pc_in         : in  std_logic_vector(PC_WIDTH-1 downto 0);		--Program counter from execute stage
		rd_in         : in  std_logic_vector(REG_BITS-1 downto 0); 		--Destination register from execute stage
		aluresult_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);	--Result from ALU from execute stage
		wrdata        : in  std_logic_vector(DATA_WIDTH-1 downto 0);	--Data to be written to memory
		zero, neg     : in  std_logic; 											--Zero flag from ALU/Negative result from ALU
		new_pc_in     : in  std_logic_vector(PC_WIDTH-1 downto 0);		--Jump target from execute stage
		pc_out        : out std_logic_vector(PC_WIDTH-1 downto 0);		--Program counter to write-back stage
		pcsrc         : out std_logic; 											--Asserted if a jump is to be executed
		rd_out        : out std_logic_vector(REG_BITS-1 downto 0);		--Destination register to write-back stage
		aluresult_out : out std_logic_vector(DATA_WIDTH-1 downto 0);	--Result from ALU to write-back stage
		memresult     : out std_logic_vector(DATA_WIDTH-1 downto 0);	--Result of memory load
		new_pc_out    : out std_logic_vector(PC_WIDTH-1 downto 0); 		--Jump target to fetch stage
		wbop_in       : in  wb_op_type; 											--Write-back operation from execute stage
		wbop_out      : out wb_op_type; 											--Write-back operation to write-back stage
		mem_out       : out mem_out_type;										--Memory operation to outside the pipeline
		mem_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0);	--Memory load result from outside the pipeline
		exc_load      : out std_logic;											--Load exception
		exc_store     : out std_logic 											--Store exception
		);
end component;

		constant CLOCK_PERIOD : time := 25 ns;
		signal clk				: std_logic := '0';
		signal  reset    :  std_logic;
		signal stall         :  std_logic;
		signal flush         :  std_logic;
		signal mem_op        :  mem_op_type; 									
		signal jmp_op        :  jmp_op_type;										
		signal pc_in         :  std_logic_vector(PC_WIDTH-1 downto 0);	
		signal rd_in         :  std_logic_vector(REG_BITS-1 downto 0); 	
		signal aluresult_in  :  std_logic_vector(DATA_WIDTH-1 downto 0);
		signal wrdata        :  std_logic_vector(DATA_WIDTH-1 downto 0);
		signal zero, neg     :  std_logic; 										
		signal new_pc_in     :  std_logic_vector(PC_WIDTH-1 downto 0);	
		signal pc_out        :  std_logic_vector(PC_WIDTH-1 downto 0);	
		signal pcsrc         :  std_logic; 										
		signal rd_out        :  std_logic_vector(REG_BITS-1 downto 0);	
		signal aluresult_out :  std_logic_vector(DATA_WIDTH-1 downto 0);
		signal memresult     :  std_logic_vector(DATA_WIDTH-1 downto 0);
		signal new_pc_out    :  std_logic_vector(PC_WIDTH-1 downto 0); 	
		signal wbop_in       :  wb_op_type; 										
		signal wbop_out      :  wb_op_type; 										
		signal mem_out       :  mem_out_type;									
		signal mem_data      :  std_logic_vector(DATA_WIDTH-1 downto 0);
		signal exc_load      :  std_logic;										
		signal exc_store     :  std_logic;	
		signal stop_clk   : std_logic := '0';		

begin

								

	uut : mem 
	port map(
		clk          => clk,   
		reset   =>      reset  ,      
	   stall        => stall  ,      
	   flush   =>      flush,
	   mem_op       => mem_op,       
	   jmp_op       => jmp_op,       
	   pc_in        => pc_in ,       
	   rd_in        => rd_in ,       
	   aluresult_in => aluresult_in ,
	   wrdata       => wrdata     ,  
	   zero => zero,
		neg    =>  neg  ,  
	   new_pc_in    => new_pc_in  ,  
	   pc_out       => pc_out  ,     
	   pcsrc        => pcsrc  ,      
	   rd_out       => rd_out  ,     
	   aluresult_out=> aluresult_out,
	   memresult    => memresult,    
	   new_pc_out   => new_pc_out,   
	   wbop_in      => wbop_in ,     
	   wbop_out     => wbop_out,     
	   mem_out      => mem_out ,     
	   mem_data     => mem_data,     
	   exc_load     => exc_load ,    
	   exc_store    => exc_store    
	
	
	);
	
	clock : process(clk)
	begin
		if (stop_clk = '0') then
			clk <= not clk after CLOCK_PERIOD;
		end if;
	end process;
	
	mem_process : process
	begin
		
		
		wait for 100*CLOCK_PERIOD;
		
		mem_op.memread <= '0';
		mem_op.memwrite <= '0';
		mem_op.memtype <= mem_w;
		aluresult_in(20 downto 0) <= "000000000000000000000";
		wrdata <= "00000000000000000000000000000000";
		mem_data <=  "00000000000000000000000000000000";
		
		wait for 500*CLOCK_PERIOD;
		mem_op.memread <= '0';
		mem_op.memwrite <= '0';
		mem_op.memtype <= mem_bu;
		aluresult_in(20 downto 0) <= "100000000000000100000";
		wrdata <= "00000001001000110100010101100111";
		mem_data <=  "11111110000000010010001111011100";
		
		
		wait for 500*CLOCK_PERIOD;
		
		mem_op.memread <= '0';
		mem_op.memwrite <= '0';
		mem_op.memtype <= mem_hu;
		aluresult_in(20 downto 0) <= "001000000000000001000";
		wrdata <= "00000001001000110100010101100111";
		mem_data <=  "11111110000000010010001111011100";
		
		wait for 500*CLOCK_PERIOD;
		mem_op.memread <= '0';
		mem_op.memwrite <= '0';
		mem_op.memtype <= mem_bu;
		aluresult_in(20 downto 0) <= "100000000000000100010";
		wrdata <= "00000001001000110100010101100111";
		mem_data <=  "11111110000000010010001111011100";
	
		wait for 500*CLOCK_PERIOD;
		
		mem_op.memread <= '0';
		mem_op.memwrite <= '0';
		mem_op.memtype <= mem_bu;
		aluresult_in(20 downto 0) <= "100000000000000100011";
		wrdata <= "00000001001000110100010101100111";
		mem_data <=  "11111110000000010010001111011100";
		wait for 500*CLOCK_PERIOD;
		
		mem_op.memread <= '1';
		mem_op.memwrite <= '0';
		mem_op.memtype <= mem_h;
		aluresult_in(20 downto 0) <= "000000000000010000010";
		wrdata <= "00000001001000110100010101100111";
		mem_data <=  "01000101011001111000100110101011";
		
		wait for 500*CLOCK_PERIOD;
		
		mem_op.memread <= '1';
		mem_op.memwrite <= '0';
		mem_op.memtype <= mem_hu;
		aluresult_in(20 downto 0) <= "000000000000100000000";
		wrdata <= "00000001001000110100010101100111";
		mem_data <=  "01000101011001111000100110101011";
		
		wait for 500*CLOCK_PERIOD;
		
		mem_op.memread <= '0';
		mem_op.memwrite <= '1';
		mem_op.memtype <= mem_w;
		aluresult_in(20 downto 0) <= "000000000100000000010";
		wrdata <= "00000001001000110100010101100111";
		mem_data <=  "10101011000000010010001111001101";
		
		wait for 500*CLOCK_PERIOD;
		
		mem_op.memread <= '1';
		mem_op.memwrite <= '0';
		mem_op.memtype <= mem_hu;
		aluresult_in(20 downto 0) <= "000000000000100000001";
		wrdata <= "00000001001000110100010101100111";
		mem_data <=  "01000101011001111000100110101011";
		
		wait for 500*CLOCK_PERIOD;
		
	end process;

end architecture;