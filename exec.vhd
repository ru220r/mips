library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

use work.alu; 

entity exec is
	
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
		zero, neg        : out std_logic;
		new_pc           : out std_logic_vector(PC_WIDTH-1 downto 0);		
		memop_in         : in  mem_op_type;
		memop_out        : out mem_op_type;
		jmpop_in         : in  jmp_op_type;
		jmpop_out        : out jmp_op_type;
		wbop_in          : in  wb_op_type;
		wbop_out         : out wb_op_type;
		forwardA         : in  fwd_type;
		forwardB         : in  fwd_type;
		cop0_rddata      : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		mem_aluresult    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		wb_result        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		exc_ovf          : out std_logic);

end exec;

architecture rtl of exec is
	--internal ALU signals 
	-- op is in op_int.aluop 
	signal int_A, int_B, int_R : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); 
	signal int_Z, int_V : std_logic := '0'; 

	--input signals 
	signal int_pc_in : std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0'); 
	signal int_op : exec_op_type; --TODO Default value 
	signal int_memop_in : mem_op_type; 
	signal int_jmpop_in : jmp_op_type; 
	signal int_wbop_in : wb_op_type; 
	--signal int_forwardA : fwd_type; 
	--signal int_forwardB : fwd_type; 
	signal int_cop0_rddata : std_logic_vector(DATA_WIDTH -1 downto 0); 
	--signal int_mem_aluresult : std_logic_vector(DATA_WIDTH-1 downto 0); 
	--signal int_wb_result : std_logic_vector(DATA_WIDTH-1 downto 0); 
	
	signal int_exec_ovf : std_logic; 

begin  -- rtl

	alu_inst : entity alu 
	port map(
		op   => int_op.aluop,
		A => int_A, 
		B => int_B, 
		R => int_R, 
		Z => int_Z, 
		V => int_V
	);

	input: process(clk, reset, flush, stall) 
	begin 
		if(reset = '0') then 
			int_pc_in <= (others => '0'); 
			int_op <= EXEC_NOP; 
			int_memop_in <= MEM_NOP; 
			int_jmpop_in <= JMP_NOP; 
			int_wbop_in <= WB_NOP; 
			int_cop0_rddata <= (others => '0'); 
		
		elsif rising_edge(clk) and stall = '0' then 
			if(flush = '1')then 
				--int_pc_in <= (others => '0'); 
				int_op <= EXEC_NOP; 
				int_memop_in <= MEM_NOP; 
				int_jmpop_in <= JMP_NOP; 
				int_wbop_in <= WB_NOP; 
				int_cop0_rddata <= (others => '0'); 			
			else 
				int_op <= op; 
				int_pc_in <= pc_in; 
				int_memop_in <= memop_in; 
				int_jmpop_in <= jmpop_in; 
				int_wbop_in <= wbop_in; 
				int_cop0_rddata <= cop0_rddata; 
			end if; 	
			pc_out <= pc_in;	
		end if; 


	end process; 

	mux : process(all) 
	begin 
		rs <= int_op.rs; 
		rt <= int_op.rt; 
		
		
		wrdata <= int_op.readdata2;
		if forwardB = FWD_ALU then
			wrdata <= mem_aluresult;
		elsif forwardB = FWD_WB then
			wrdata <= wb_result;
		end if;
		
		-- pipe signals through exec 
		--pc_out <= int_pc_in; 
		memop_out <= int_memop_in; 
		jmpop_out <= int_jmpop_in; 
		wbop_out <= int_wbop_in; 
		
		-- set RD 
		if(int_op.regdst = '0') then 
			rd <= int_op.rd; 
		else 
			rd <= int_op.rt; 
		end if; 
		
		--flags 
		zero <= int_Z; 
		neg <= int_R(DATA_WIDTH -1); 
		
		-- ALU 
		--int_op <= int_op.aluop; 
		
		--<forward stuff implemented>
		int_A <= int_op.readdata1;
		if forwardA = FWD_ALU then
			int_A <= mem_aluresult;
		elsif forwardA = FWD_WB then
			int_A <= wb_result;
		end if;
		aluresult <= int_R; 		

		
		int_B <= int_op.readdata2;
		
		
		if(int_op.aluop = ALU_SLL or int_op.aluop = ALU_SRL or int_op.aluop = ALU_SRA)then -- Shift instruction 
			
			int_B <= int_op.readdata2;--!!!			
			if forwardB = FWD_ALU then
				int_B <= mem_aluresult;
			elsif forwardB = FWD_WB then
				int_B <= wb_result;
			end if;
			
			if(int_op.useamt = '1') then 
				int_A <= int_op.imm; 
			else
				int_A <= int_op.readdata1;
				if forwardA = FWD_ALU then
					int_A <= mem_aluresult;
				elsif forwardA = FWD_WB then
					int_A <= wb_result;
				end if;
			end if; 
		elsif(int_op.useimm = '0' and int_op.useamt = '0') then --R - Format 
			int_B <= int_op.readdata2; 
			if forwardB = FWD_ALU then
				int_B <= mem_aluresult;
			elsif forwardB = FWD_WB then
				int_B <= wb_result;
			end if;
		elsif(int_op.useimm = '1' and int_op.useamt = '0') then -- I-Format 
			int_B <= int_op.imm; 	
		end if; 		
		
		--</forward stuff implemented>
		
		if(int_op.cop0 = '1' and int_wbop_in.regwrite = '1') then ---cop0
			aluresult <= cop0_rddata; 			
		end if; 	
		
		--set new_pc
	
		new_pc <= int_R(PC_WIDTH-1 downto 0); 
		if(int_op.branch ='1') then 
			new_pc <= std_logic_vector(unsigned(int_pc_in) + unsigned(int_op.imm(PC_WIDTH-1 downto 0)));  
		end if; 


		-- if jal or jalr 
		-- if bltzal or bgezal 
		if(int_op.link = '1') then 
			aluresult <= (others => '0');
			aluresult(PC_WIDTH-1 downto 0) <= std_logic_vector(unsigned(pc_in)); 
		end if; 

		-- exc_ovf g
		exc_ovf <= int_V AND int_op.ovf; 
	 
	end process; 
end rtl;
