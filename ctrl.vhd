library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity ctrl is
	
	port (		
		pcsrc 			: in std_logic;									-- from mem
		stall 			: in std_logic;
		flush_decode	: out std_logic;
		flush_exec		: out std_logic;
		flush_mem		: out std_logic;
		flush_wb		: out std_logic;
		clk, reset		: in std_logic;
		--pc_out 			: out std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
		pcsrc_exc 		: out std_logic := '0';  

		cop0_op			: in COP0_OP_TYPE; 
		write_to_cop0  : in std_logic_vector(DATA_WIDTH -1 downto 0) := (others => '0');
		cop0_wrdata 	: out std_logic_vector(DATA_WIDTH -1 downto 0) := (others => '0');

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
		
		
		--jmpop for determining if instruction is in branch delay slot
		jmpop_exec_in : in jmp_op_type;
		jmpop_decode_in : in jmp_op_type
	
	);

end ctrl;

architecture rtl of ctrl is
	
	signal pcsrc_latched, pcsrc_latched_2 	: std_logic := '0';
	signal cop0_B 			: std_logic := '0'; 
	signal cop0_pen			: std_logic_vector(2 downto 0); 
	signal cop0_exc			: std_logic_vector(3 downto 0); 
	signal cop0_I			: std_logic := '0'; 
	
	constant STATUS : std_logic_vector(REG_BITS-1 downto 0) := "01100";
	constant CAUSE 	: std_logic_vector(REG_BITS-1 downto 0) := "01101";
	constant EPC 	: std_logic_vector(REG_BITS-1 downto 0) := "01110";
	constant NPC 	: std_logic_vector(REG_BITS-1 downto 0) := "01111";

	constant EXC_INT_CONST  	: std_logic_vector(3 downto 0) := "0000";
	constant EXC_LOAD_CONST 	: std_logic_vector(3 downto 0) := "0100";
	constant EXC_STORE_CONST 	: std_logic_vector(3 downto 0) := "0101";
	constant EXC_DECODE_CONST 	: std_logic_vector(3 downto 0) := "1010";
	constant EXC_OVF_CONST  	: std_logic_vector(3 downto 0) := "1100";

	signal int_exc_ovf, int_exc_dec, int_exc_load, int_exc_load_2, int_exc_str, int_exc_str_2 	: std_logic := '0'; 
	signal int_pc_fetch, int_pc_decode, int_pc_exec, int_pc_mem, int_pc_jmp, int_pc_jmp_2, int_pc_mem_2: std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0'); 
	signal cop0_status, cop0_cause, cop0_epc, cop0_npc 			: std_logic_vector(REG_BITS-1 downto 0); 
	signal int_cause, int_epc, int_npc 				: std_logic_vector(31 downto 0) := (others => '0'); 
	signal int_status : std_logic_vector(31 downto 0) := ((0) => '1', others => '0'); 
	signal int_status_next, int_cause_next, int_epc_next, int_npc_next 				: std_logic_vector(31 downto 0) := (others => '0'); 
	signal int_pcsrc 											: std_logic; 
	signal int_exc, int_exc_next 							: std_logic_vector(3 downto 0) := "1111"; 
	signal int_interrupt, int_interrupt_2, int_interrupt_rising_edge_next, int_interrupt_rising_edge	: std_logic_vector(2 downto 0) := (others => '0'); 
	
	signal int_jmp_op_exec, int_jmp_op_exec_2, int_jmp_op_exec_3, int_jmp_op_decode : jmp_op_type := JMP_NOP;
	
	signal int_cop0_op : COP0_OP_TYPE := COP0_NOP; 

begin  -- rtl
	branch_flush: process(clk, reset)
	begin
		if reset = '0' then
			pcsrc_latched <= '0';
		else
			if rising_edge(clk) then
				pcsrc_latched <= pcsrc;
				pcsrc_latched_2 <= pcsrc_latched;
			end if;
		end if;
	end process;
	
	
	out_pr: process(all)
	begin
		flush_decode	<= '0';
		flush_exec		<= '0';
		flush_mem		<= '0';
		flush_wb		<= '0';
		if(pcsrc_latched = '1') then
			flush_exec 		<= '1';
			flush_mem		<= '1';			
		end if;
		if (int_exc_dec = '1' and pcsrc_latched /= '1' and pcsrc_latched_2 /= '1') then -- !!!
			flush_decode 	<= '1';
			flush_exec 		<= '1';
			flush_mem 		<= '1';
		end if;
		if (int_exc_ovf = '1' and pcsrc_latched_2 /= '1') then -- !!!
			flush_decode 	<= '1';
			flush_exec 		<= '1';
			flush_mem 		<= '1';
			flush_wb 		<= '1';
		end if;
		if ((int_exc_load = '1' and not int_exc_str_2 = '1' and not int_exc_load_2 = '1') or (int_exc_str = '1' and not int_exc_str_2 = '1' and not int_exc_load_2 = '1')) then -- memory error 
			flush_decode  	<= '1'; 
			flush_exec 		<= '1'; 
			flush_mem 		<= '1'; 
			flush_wb 		<= '1'; 
		end if; 
		if (int_interrupt_rising_edge /= "000" or 
				int_cause(12 downto 10) /= "000") and int_status(0) = '1' and int_jmp_op_decode = JMP_NOP and int_jmp_op_exec = JMP_NOP and int_jmp_op_exec_2 = JMP_NOP then
			flush_decode  	<= '1'; 			
			flush_exec 		<= '1';
		end if;
	end process;

	cop0_sync : process(all)
	begin 
		if reset = '0' then 

			int_exc_ovf <= '0'; 
			int_exc_dec <= '0'; 
			int_exc_load <= '0'; 
			int_exc_str <= '0'; 

			int_pc_fetch <= (others => '0'); 
			int_pc_decode <= (others => '0'); 
			int_pc_exec <= (others => '0'); 
			int_pc_mem <= (others => '0'); 
			int_pc_mem_2 <= (others => '0'); 

			int_pcsrc <= '0'; 
			int_cause <= (others => '0'); 
			int_epc <= (others => '0'); 
			int_npc <= (others => '0'); 
			int_status <= ((0) => '1', others => '0'); 		
			int_interrupt <= (others => '0');
			int_interrupt_2 <= (others => '0');
			
			int_pc_jmp <= (others => '0');
			int_pc_jmp_2 <= (others => '0');
			
			int_jmp_op_exec <= JMP_NOP;
			int_jmp_op_exec_2 <= JMP_NOP;
			int_jmp_op_exec_3 <= JMP_NOP;
			
			int_jmp_op_decode <= JMP_NOP;
			
			int_cop0_op <= COP0_NOP;

		elsif rising_edge(clk) and stall = '0' then 
			int_exc_dec <= exception_dec; 
			int_exc_load <= exception_load; 
			int_exc_ovf <= exception_ovf; 
			int_exc_str <= exception_str; 
			int_exc_load_2 <= int_exc_load;
			int_exc_str_2 <= int_exc_str;

			int_pcsrc <= pcsrc; 
			int_exc <= int_exc_next; 
			int_interrupt <= interrupt; 
			int_interrupt_2 <= int_interrupt; 
			int_interrupt_rising_edge <= int_interrupt_rising_edge_next; 

			int_pc_fetch <= pc_fetch; 
			int_pc_decode <= pc_decode; 
			int_pc_exec <= pc_exec; 
			int_pc_mem <= pc_mem;
			int_pc_mem_2 <= int_pc_mem;  
			int_pc_jmp <= pc_jmp; 
			int_pc_jmp_2 <= int_pc_jmp;

			int_cause <= int_cause_next; 
			int_epc <= int_epc_next; 
			int_npc <= int_npc_next;  
			int_status <= int_status_next;  
			
			int_jmp_op_exec <= jmpop_exec_in;
			int_jmp_op_exec_2 <= int_jmp_op_exec;
			int_jmp_op_exec_3 <= int_jmp_op_exec_2;
			
			int_jmp_op_decode <= jmpop_decode_in;
			
			int_cop0_op <= cop0_op;
		end if; 
	end process; 

	cop0_proc : process(all)
	begin 
		int_cause_next <= int_cause; 
		int_status_next <= int_status; 
		int_epc_next <= int_epc; 
		int_npc_next <= int_npc; 
		cop0_wrdata <= (others => '0'); 
				
		int_exc_next <= (others => '1'); -- all 0s would be valid code
		
		int_interrupt_rising_edge_next <= int_interrupt_rising_edge or ((not int_interrupt_2(2) and int_interrupt(2)) & (not int_interrupt_2(1) and int_interrupt(1)) & (not int_interrupt_2(0) and int_interrupt(0)));
		--interrupt_next <= interrupt;

		if(int_cop0_op.wr = '0') then 
			case int_cop0_op.addr is 
				when STATUS => 
					cop0_wrdata <= int_status; -- Interrupts not enabled! 
				when CAUSE => 
					cop0_wrdata <= int_cause;  
				when EPC => 
					cop0_wrdata <= int_epc; 
				when NPC => 
					cop0_wrdata <= int_npc; 
				when others => -- do nothing
					cop0_wrdata <= (others => '0'); 
			end case; 
		else 
			case int_cop0_op.addr is 
				when STATUS => 
					int_status_next <= write_to_cop0; 
				when CAUSE => 
					int_cause_next <= write_to_cop0; 
				when EPC => 
					int_epc_next <= write_to_cop0; 
				when NPC => 
					int_npc_next  <= write_to_cop0; 
				when others => -- do nothing
				
			end case; 
		end if; 

		if((int_exc_dec = '1' and pcsrc_latched /= '1' and pcsrc_latched_2 /= '1') or  (int_exc_ovf = '1' and pcsrc_latched_2 /= '1') or 
			(int_exc_load = '1'  and not int_exc_load_2 = '1' and not int_exc_str_2 = '1') or 
			(int_exc_str = '1' and not int_exc_str_2 = '1' and not int_exc_load_2 = '1') or 
			(((int_interrupt_rising_edge /= "000") or 
				int_cause(12 downto 10) /= "000") and int_status(0) = '1' and int_jmp_op_decode = JMP_NOP and int_jmp_op_exec = JMP_NOP and int_jmp_op_exec_2 = JMP_NOP)) then 
			pcsrc_exc <= '1'; 
		else 
			pcsrc_exc <= '0';
		end if; 
		
		
		if (int_exc_ovf = '1' and pcsrc_latched_2 /= '1') then 		--Overflow exception 
			int_cause_next(5 downto 2) <= "1100";
			if int_jmp_op_exec_2 /= JMP_NOP then
				int_cause_next(31) <= '1';
			end if;
			int_epc_next <= "000000000000000000" & int_pc_mem; 
			if(int_pcsrc = '1') then 
				int_npc_next <= "000000000000000000" & int_pc_jmp; 
			else 
				int_npc_next <= "000000000000000000" & pc_mem; 
			end if; 
		elsif(int_exc_dec = '1' and pcsrc_latched /= '1' and pcsrc_latched_2 /= '1') then  		-- Decoding exception
			int_cause_next(5 downto 2) <= "1010";
			if int_jmp_op_exec /= JMP_NOP then
				int_cause_next(31) <= '1';
			end if;
			int_epc_next <= "000000000000000000" & pc_mem; 
			if(pcsrc = '1') then 
				int_npc_next <= "000000000000000000" & pc_jmp; 
			else 
				int_npc_next <= "000000000000000000" & pc_exec; 
			end if; 
		elsif (int_exc_load = '1'  and not int_exc_load_2 = '1' and not int_exc_str_2 = '1') then 	--Load exception 
			int_cause_next(5 downto 2) <= "0100";
			if int_jmp_op_exec_3 /= JMP_NOP then
				int_cause_next(31) <= '1';
			end if;
			int_epc_next<= "000000000000000000" & int_pc_mem_2;
			if(pcsrc_latched_2 = '1') then 
				int_npc_next <= "000000000000000000" & int_pc_decode; 
			else 
				int_npc_next <= "000000000000000000" & int_pc_mem; 
			end if; 
		
		elsif (int_exc_str = '1' and not int_exc_str_2 = '1' and not int_exc_load_2 = '1') then 		--Store exception 
			int_cause_next(5 downto 2) <= "0101";
			if int_jmp_op_exec_3 /= JMP_NOP then
				int_cause_next(31) <= '1';
			end if;

			int_epc_next <= "000000000000000000" & int_pc_mem_2; 
			if(pcsrc_latched_2 = '1') then 
				int_npc_next <= "000000000000000000" & int_pc_decode; 
			else 
				int_npc_next <= "000000000000000000" & int_pc_mem; 
			end if; 
		elsif ((int_interrupt_rising_edge /= "000") or 
				int_cause(12 downto 10) /= "000") and int_status(0) = '1' and int_jmp_op_decode = JMP_NOP and int_jmp_op_exec = JMP_NOP and int_jmp_op_exec_2 = JMP_NOP then -- Interrupt			
			int_status_next(0) <= '0';
			int_interrupt_rising_edge_next <= ((not int_interrupt_2(2) and int_interrupt(2)) & (not int_interrupt_2(1) and int_interrupt(1)) & (not int_interrupt_2(0) and int_interrupt(0)));
			int_cause_next(12 downto 10) <= (int_cause(12 downto 10) or int_interrupt_rising_edge);
			if(pcsrc_latched = '1') then 
				int_epc_next<= "000000000000000000" & int_pc_jmp;
				int_npc_next<= "000000000000000000" & int_pc_jmp;
			else 
				int_epc_next<= "000000000000000000" & int_pc_decode;
				int_npc_next<= "000000000000000000" & int_pc_decode;
			end if;
		else
			
		end if; 
	end process; 
end rtl;
