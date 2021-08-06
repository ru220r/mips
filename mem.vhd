library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity mem is
	
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

end mem;

architecture rtl of mem is

	component jmpu is
		port (
			op   : in  jmp_op_type;
			N, Z : in  std_logic;
			J    : out std_logic
			);
	end component;
	
	component memu is
	port (
		op   : in  mem_op_type;
		A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		D    : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		M    : out mem_out_type;
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		XL   : out std_logic;
		XS   : out std_logic);
	end component;
	
	--sinals for JUMP UNIT
	signal op_j  		 :   jmp_op_type;
	signal N, Z 		 :   std_logic;
	signal J 		    :   std_logic;
	--signals for MEMORY UNIT
	signal op_m, op_m_out :  mem_op_type := MEM_NOP;	
	signal A    		 :  std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal W    		 :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal D    		 :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal M  		    :  mem_out_type;
	signal R  		    :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal XL 		    :  std_logic;
	signal XS   		 :  std_logic;
	
	--signal mem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem_data_in  : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal new_pc_inout : std_logic_vector(PC_WIDTH-1 downto 0);
	signal pc_inout	  : std_logic_vector(PC_WIDTH-1 downto 0);
	signal rd_inout 	  : std_logic_vector(REG_BITS-1 downto 0);
	signal aluresult_inout : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wbop_inout : wb_op_type;
	
	

begin  -- rtl

	jmpu_inst : jmpu
	port map(
		--inputs
		op => op_j,
		N => N,
		Z => Z,
		
		--output
		J => pcsrc
	);
		
	memu_inst: memu	
	port map( 
	
		--inputs
		op => op_m,
		A => A,
		W => W,
		D => mem_data,
		
		--outputs
		M => mem_out,
		R => memresult,
		XL => exc_load,
		XS => exc_store			
	);
	
	rd : process(clk, reset, flush)
		begin
		if (reset = '0') then		
				op_m <= MEM_NOP;
				op_j <= JMP_NOP;				
				pc_inout <= (others => '0');
				rd_inout <= (others => '0');
				aluresult_inout <= (others => '0');
				new_pc_inout <= (others => '0');
				wbop_inout <= WB_NOP;				
				W <= (others => '0');				
				Z <= '0';
				N <= '0';				
				mem_data_in <= (others => '0');	
			
		elsif (rising_edge(clk)) then
		
			if (stall = '1') then									
				op_m.memread <= '0';
				op_m.memwrite <= '0';
			elsif (flush = '1') then 
				op_m  <= MEM_NOP;
				op_j <= JMP_NOP;				
				pc_inout <= (others => '0');
				rd_inout <= (others => '0');
				aluresult_inout <= (others => '0');
				new_pc_inout <= (others => '0');
				wbop_inout <= WB_NOP;				
				W <= (others => '0');				
				Z <= '0';
				N <= '0';				
				mem_data_in <= (others => '0');							
			else	
				op_m  <= mem_op;
				op_j <= jmp_op;				
				pc_inout <= pc_in;
				rd_inout <= rd_in;
				aluresult_inout <= aluresult_in;
				new_pc_inout <= new_pc_in;
				wbop_inout <= wbop_in;		
				W <= wrdata;
				Z <= zero;
				N <= neg;
				
				
			end if;
			
		end if;
	end process;
	
	assign : process (all)
		begin
			
			pc_out <= pc_inout;
			rd_out <= rd_inout;
			aluresult_out <= aluresult_inout;
			new_pc_out <= new_pc_inout;
			wbop_out <= wbop_inout;
			
		-- A ZUWEISEN
			
			A <= aluresult_inout(ADDR_WIDTH-1 downto 0);


			
		end process;
end rtl;
