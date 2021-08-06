library ieee;
use ieee.std_logic_1164.all;

use work.core_pack.all;
use work.op_pack.all;

entity pipeline is
	
	port (
		clk, reset : in	 std_logic;
		mem_in     : in  mem_in_type;
		mem_out    : out mem_out_type;
		intr       : in  std_logic_vector(INTR_COUNT-1 downto 0) := "000"
	); 

end pipeline;

architecture rtl of pipeline is

	--Signals
	  signal clk_sig : std_logic;
	  signal reset_sig : std_logic;
	  signal stall_sig : std_logic := '0';
	  signal flush_decode_sig, flush_exec_sig, flush_mem_sig, flush_wb_sig : std_logic := '0';
	  
	  signal mem_data_sig : std_logic_vector(DATA_WIDTH-1 downto 0);
	  
	  --signals to fetch stage (fs)
	  signal pcsrc_sig_fs 		: std_logic;
	  signal pc_in_sig_fs		: std_logic_vector(PC_WIDTH-1 downto 0);
	  
	  --signals to decode stage (ds)
	  signal pc_in_sig_ds	 : std_logic_vector(PC_WIDTH-1 downto 0);
	  signal instr_sig_ds	 : std_logic_vector(INSTR_WIDTH-1 downto 0);
	  signal wraddr_sig_ds	 : std_logic_vector(REG_BITS-1 downto 0);
	  signal wrdata_sig_ds	 : std_logic_vector(DATA_WIDTH-1 downto 0);
	  signal regwrite_sig_ds : std_logic;
	  
	  --signals to execute stage (es)
	  signal op_sig_es 		 : exec_op_type;
	  signal pc_in_es 		 : std_logic_vector(PC_WIDTH-1 downto 0);
	  signal memop_in_sig_es : mem_op_type;
	  signal jmpop_in_sig_es : jmp_op_type;
	  signal wbop_in_sig_es  : wb_op_type;
	  signal forwardA_sig_es : fwd_type;
	  signal forwardB_sig_es : fwd_type;
	  signal cop0_rddata_sig_es : std_logic_vector(DATA_WIDTH-1 downto 0);
	  signal mem_aluresult_sig_es : std_logic_vector(DATA_WIDTH-1 downto 0);
	  signal wb_result_sig_es : std_logic_vector(DATA_WIDTH-1 downto 0);
	  --signals from the execute stage
	  signal rs_sig_out_es : std_logic_vector(REG_BITS-1 downto 0);
	  signal rt_sig_out_es : std_logic_vector(REG_BITS-1 downto 0);
	  
	  --signals to memory stage (ms)
	  signal mem_op_sig_ms		 : mem_op_type;
	  signal jmp_op_sig_ms		 : jmp_op_type;
	  signal wrdata_sig_ms		 : std_logic_vector(DATA_WIDTH-1 downto 0);
	  signal zero_sig_ms	 		 : std_logic;
	  signal neg_sig_ms 	 		 : std_logic;
	  signal new_pc_in_sig_ms   : std_logic_vector(PC_WIDTH-1 downto 0);
	  signal pc_in_sig_ms		 : std_logic_vector(PC_WIDTH-1 downto 0);
	  signal rd_in_sig_ms		 : std_logic_vector(REG_BITS-1 downto 0);	
	  signal aluresult_in_sig_ms : std_logic_vector(DATA_WIDTH-1 downto 0);
	  signal wbop_in_sig_ms 	 : wb_op_type;
	  
	  -- signals to writeback stage (wbs)
	  signal op_sig_wbs 			 : wb_op_type;
	  signal aluresult_sig_wbs : std_logic_vector(DATA_WIDTH-1 downto 0);
	  signal memresult_sig_wbs : std_logic_vector(DATA_WIDTH-1 downto 0);
	  signal rd_in_sig_wbs 			: std_logic_vector(REG_BITS-1 downto 0);
	
	  -- signals for coprocessor 
	  signal cop0_op_sig_dec : cop0_op_type; 
	  signal exception_decode, exception_load, exception_ovf, exception_store : std_logic; 
	  signal pc_out_sig_mem : std_logic_vector(PC_WIDTH-1 downto 0); 
	  signal pc_in_sig_fetch: std_logic_vector(PC_WIDTH -1 downto 0); 
	  signal pcsrc_exc_sig : std_logic; 
	  --signal write_to_cop0_sig : std_logic_vector(DATA_WIDTH-1 downto 0);
	
	-- component fetch stage
	component fetch is
		port (
			clk, reset : in	 std_logic;
			stall      : in  std_logic;
			pcsrc	   : in	 std_logic;
			pcsrc_exc	   : in	 std_logic;
			pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
			pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
			instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0));
	end component;
	
	--component decode stage (ds)
	
	component decode is
		port (
			clk, reset : in  std_logic;
			stall      : in  std_logic;
			flush      : in  std_logic;
			pc_in      : in  std_logic_vector(PC_WIDTH-1 downto 0);
			instr	   : in  std_logic_vector(INSTR_WIDTH-1 downto 0);
			wraddr     : in  std_logic_vector(REG_BITS-1 downto 0);
			wrdata     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			regwrite   : in  std_logic;
			pc_out     : out std_logic_vector(PC_WIDTH-1 downto 0);
			exec_op    : out exec_op_type;
			cop0_op    : out cop0_op_type;
			jmp_op     : out jmp_op_type;
			mem_op     : out mem_op_type;
			wb_op      : out wb_op_type;
			exc_dec    : out std_logic);
	end component;
	
	--component execute stage (es)
	
	component exec is
		port (
			clk, reset       : in  std_logic;
			stall      		 : in  std_logic;
			flush            : in  std_logic;
			pc_in            : in  std_logic_vector(PC_WIDTH-1 downto 0);
			op	   	         : in  exec_op_type;
			pc_out           : out std_logic_vector(PC_WIDTH-1 downto 0);
			rd, rs, rt       : out std_logic_vector(REG_BITS-1 downto 0);
			aluresult	     : out std_logic_vector(DATA_WIDTH-1 downto 0);
			wrdata           : out std_logic_vector(DATA_WIDTH-1 downto 0);
			zero, neg         : out std_logic;
			new_pc           : out std_logic_vector(PC_WIDTH-1 downto 0);		
			memop_in         : in  mem_op_type;
			memop_out        : out mem_op_type;
			jmpop_in         : in  jmp_op_type;
			jmpop_out        : out jmp_op_type;
			wbop_in          : in  wb_op_type;
			wbop_out         : out wb_op_type;
			forwardA         : in  fwd_type;
			forwardB         : in  fwd_type;
			cop0_rddata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			mem_aluresult    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			wb_result        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			exc_ovf          : out std_logic);	
	end component;
	
	-- Component memory stage	
	component mem is
		port (
			clk, reset    : in  std_logic;
			stall         : in  std_logic;
			flush         : in  std_logic;		
			
			mem_op        : in  mem_op_type; 										
			jmp_op        : in  jmp_op_type;											
			pc_in         : in  std_logic_vector(PC_WIDTH-1 downto 0);		
			rd_in         : in  std_logic_vector(REG_BITS-1 downto 0); 		
			aluresult_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);	
			wrdata        : in  std_logic_vector(DATA_WIDTH-1 downto 0);	
			zero, neg     : in  std_logic; 											
			new_pc_in     : in  std_logic_vector(PC_WIDTH-1 downto 0);		
			pc_out        : out std_logic_vector(PC_WIDTH-1 downto 0);		
			pcsrc         : out std_logic; 											
			rd_out        : out std_logic_vector(REG_BITS-1 downto 0);		
			aluresult_out : out std_logic_vector(DATA_WIDTH-1 downto 0);	
			memresult     : out std_logic_vector(DATA_WIDTH-1 downto 0);	
			new_pc_out    : out std_logic_vector(PC_WIDTH-1 downto 0); 		
			wbop_in       : in  wb_op_type; 											
			wbop_out      : out wb_op_type; 											
			mem_out       : out mem_out_type;										
			mem_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0);	
			exc_load      : out std_logic;											
			exc_store     : out std_logic 											
			);
	end component;
	
	--Component write-back stage
	component wb is
		port (
			clk, reset : in  std_logic;											
			stall      : in  std_logic;											
			flush      : in  std_logic;	
			op	   	  : in  wb_op_type; 											
			rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);	   
			aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);   
			memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			rd_out     : out std_logic_vector(REG_BITS-1 downto 0); 		
			result     : out std_logic_vector(DATA_WIDTH-1 downto 0);   
			regwrite   : out std_logic); 											
	end component;
	
	component ctrl is
		port (		
		pcsrc 			: in std_logic;									-- from mem
		stall 			: in std_logic;
		flush_decode	: out std_logic;
		flush_exec		: out std_logic;
		flush_mem		: out std_logic;
		flush_wb		: out std_logic;
		clk, reset		: in std_logic;
		--pc_out 			: out std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
		pcsrc_exc		: out std_logic;  

		cop0_op			: in COP0_OP_TYPE; 
		write_to_cop0  : in std_logic_vector(DATA_WIDTH -1 downto 0) := (others => '0');
		cop0_wrdata 	: out std_logic_vector(DATA_WIDTH -1 downto 0);

		--exceptions of each state & interrupt
		exception_ovf 	: in std_logic; 
		exception_dec   : in std_logic; 
		exception_load	: in std_logic; 
		exception_str	: in std_logic; 
		interrupt 		: in std_logic_vector(INTR_COUNT -1 downto 0); 

		--program counter of each state 
		pc_fetch		: in std_logic_vector(PC_WIDTH-1 downto 0); 
		pc_decode		: in std_logic_vector(PC_WIDTH-1 downto 0);
		pc_exec			: in std_logic_vector(PC_WIDTH-1 downto 0);
		pc_mem			: in std_logic_vector(PC_WIDTH-1 downto 0);
		pc_jmp 			: in std_logic_vector(PC_WIDTH-1 downto 0);
		
		jmpop_exec_in : in jmp_op_type;
		jmpop_decode_in : in jmp_op_type
	
	);
	end component;
	
	component fwd is
		port (
		clk, reset, stall	: in std_logic;
		rd_mem_out			: in std_logic_vector(REG_BITS-1 downto 0);
		rd_exec_out 		: in std_logic_vector(REG_BITS-1 downto 0); 
		rs_decode_out  	: in std_logic_vector(REG_BITS-1 downto 0); 
		rt_decode_out  	: in std_logic_vector(REG_BITS-1 downto 0); 
		regwrite_mem_out 	: in std_logic;
		regwrite_exec_out	: in std_logic;
		forwardA				: out fwd_type;
		forwardB				: out fwd_type
		);
	end component;
	
begin  -- rtl
		
	stall_sig <= mem_in.busy;
	mem_data_sig <= mem_in.rddata;
	
	fetch_inst : fetch
		port map(
			--inputs
			clk 			=> clk_sig,
			reset 		=> reset_sig,
			stall 		=> stall_sig or mem_in.busy,
			pcsrc 		=> pcsrc_sig_fs,
			pcsrc_exc	=> pcsrc_exc_sig,
			pc_in 		=> pc_in_sig_fs,
			--outputs
			pc_out 		=> pc_in_sig_ds,
			instr 		=> instr_sig_ds
		);
		
	decode_inst : decode
		port map (
			--inputs
			clk 			=> clk_sig,	
			reset			=> reset_sig,	
			stall 		=> stall_sig or mem_in.busy,	
			pc_in 		=> pc_in_sig_ds,
			instr 		=> instr_sig_ds,
			wraddr		=> wraddr_sig_ds,
			wrdata 		=> wrdata_sig_ds,
			regwrite		=> regwrite_sig_ds,			
			flush			=> flush_decode_sig,
			--outputs
			pc_out 		=> pc_in_es,
			exec_op 		=> op_sig_es,
			cop0_op		=> cop0_op_sig_dec,
			jmp_op 		=> jmpop_in_sig_es,
			mem_op 		=> memop_in_sig_es,
			wb_op 		=> wbop_in_sig_es,
			exc_dec		=> exception_decode
		);
		
	exec_inst : exec
		port map(
			--inputs
			clk 			=> clk_sig,
			reset 		=> reset_sig,
			stall 		=> stall_sig or mem_in.busy,
			op 			=> op_sig_es,
			pc_in			=> pc_in_es,
			memop_in		=> memop_in_sig_es,
			jmpop_in 	=> jmpop_in_sig_es,
			wbop_in 		=> wbop_in_sig_es,
			forwardA 	=> forwardA_sig_es,
			forwardB 	=> forwardB_sig_es,
			cop0_rddata => cop0_rddata_sig_es,
			mem_aluresult => aluresult_sig_wbs,
			wb_result 	=> wrdata_sig_ds,
			flush			=> flush_exec_sig,
			--outputs
			rd 			=> rd_in_sig_ms,
			rs				=> rs_sig_out_es, 
			rt 			=> rt_sig_out_es,
			aluresult 	=> aluresult_in_sig_ms,
			wrdata 		=> wrdata_sig_ms,
			zero 			=> zero_sig_ms,
			neg 			=> neg_sig_ms,
			new_pc 		=> new_pc_in_sig_ms,
			pc_out		=> pc_in_sig_ms,
			memop_out	=> mem_op_sig_ms,
			jmpop_out 	=> jmp_op_sig_ms,
			wbop_out 	=> wbop_in_sig_ms,
			exc_ovf 		=> exception_ovf
		
		);
	
	mem_inst : mem
		port map(
			--inputs
			clk 			=> clk_sig,
			reset			=> reset_sig,
			stall 		=> stall_sig or mem_in.busy,
			mem_data		=> mem_data_sig,
			mem_op 		=> mem_op_sig_ms,
			jmp_op 		=> jmp_op_sig_ms,		 
			wrdata 		=> wrdata_sig_ms,		 
			zero 			=> zero_sig_ms,	 		 
			neg 			=> neg_sig_ms, 	 		 
			new_pc_in	=> new_pc_in_sig_ms,   
			pc_in 		=> pc_in_sig_ms,		 
			rd_in 		=> rd_in_sig_ms,		 
			aluresult_in => aluresult_in_sig_ms,
			wbop_in 		=> wbop_in_sig_ms, 	 	
			flush 		=> flush_mem_sig,
			-- outputs
			memresult 	=> memresult_sig_wbs,
			pcsrc 		=> pcsrc_sig_fs,
			new_pc_out 	=> pc_in_sig_fs,
			pc_out 		=> pc_out_sig_mem,
			rd_out 		=> rd_in_sig_wbs,
			aluresult_out => aluresult_sig_wbs,
			wbop_out		=> op_sig_wbs,
			mem_out 		=> mem_out,
			exc_load 	=> exception_load,
			exc_store 	=> exception_store
			
			
		);
	
	wb_inst : wb 
		port map(
			-- inputs
			clk 			=> clk_sig,
			reset 		=> reset_sig,
			stall 		=> stall_sig or mem_in.busy,
			flush 		=> flush_wb_sig,
			op 			=> op_sig_wbs,
			aluresult 	=> aluresult_sig_wbs,
			memresult 	=> memresult_sig_wbs,
			rd_in 		=> rd_in_sig_wbs,
			--outputs
			result		=> wrdata_sig_ds, --result to regfile
			regwrite 	=> regwrite_sig_ds, --write enable to regfile
			rd_out 		=> wraddr_sig_ds --dest register to regfile
		);

		clk_sig <= clk;
		reset_sig <= reset;
		
		--stall wenn mem_in.busy is asserted
		
	ctrl_inst : ctrl
		port map(		
		pcsrc 			=> pcsrc_sig_fs,
		stall 			=> mem_in.busy,
		flush_decode	=> flush_decode_sig,
		flush_exec		=> flush_exec_sig,
		flush_mem		=> flush_mem_sig,
		flush_wb		=> flush_wb_sig,
		clk 			=> clk_sig,
		reset			=> reset_sig,
		--pc_out 			=> pc_in_sig_fetch,
		pcsrc_exc 		=> pcsrc_exc_sig,   		--!!!!!!!
		cop0_op			=> cop0_op_sig_dec,
		write_to_cop0  => wrdata_sig_ms,
		cop0_wrdata 	=> cop0_rddata_sig_es, 
		--exceptions of each state & interrupt
		exception_ovf 	=> exception_ovf,
		exception_dec   => exception_decode, 
		exception_load	=> exception_load,
		exception_str	=> exception_store,
		interrupt 		=> intr, 
		--program counter of each state 
		pc_fetch		=> pc_in_sig_ds, 
		pc_decode		=> pc_in_es, 
		pc_exec			=> pc_in_sig_ms, 
		pc_mem			=> pc_out_sig_mem, 
		pc_jmp 			=> pc_in_sig_fs,
		
		
		jmpop_exec_in => jmp_op_sig_ms,
		jmpop_decode_in => jmpop_in_sig_es
		);
	
	fwd_inst : fwd
		port map(				
		clk					=> clk_sig,
		reset					=> reset_sig,
		stall					=> stall_sig or mem_in.busy,
		rd_mem_out			=> rd_in_sig_wbs,	
		rd_exec_out 		=> rd_in_sig_ms,		
		rs_decode_out  	=> op_sig_es.rs,
		rt_decode_out  	=> op_sig_es.rt,
		regwrite_mem_out 	=> op_sig_wbs.regwrite or op_sig_wbs.memtoreg, 			 --!!!
		regwrite_exec_out	=> wbop_in_sig_ms.regwrite or wbop_in_sig_ms.memtoreg, --!!!
		forwardA				=> forwardA_sig_es,
		forwardB				=> forwardB_sig_es
		);
end rtl;
