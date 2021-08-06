library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity decode is
	
	port (
		clk, reset 	: in  std_logic;
		stall      	: in  std_logic;
		flush      	: in  std_logic;
		pc_in      	: in  std_logic_vector(PC_WIDTH-1 downto 0);
		instr	     	: in  std_logic_vector(INSTR_WIDTH-1 downto 0);
		wraddr     	: in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata     	: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   	: in  std_logic;
		pc_out     	: out std_logic_vector(PC_WIDTH-1 downto 0);
		exec_op    	: out exec_op_type;
		cop0_op    	: out cop0_op_type;
		jmp_op     	: out jmp_op_type;
		mem_op     	: out mem_op_type;
		wb_op      	: out wb_op_type;
		exc_dec    	: out std_logic
	);

end decode;

architecture rtl of decode is
	
	signal instr_latched : std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
	signal opcode, func : std_logic_vector(5 downto 0) := (others => '0');
	signal rs, rt, rd, shamt : std_logic_vector(4 downto 0) := (others => '0');
	signal addr_imm : std_logic_vector(15 downto 0) := (others => '0');
	signal targ_addr : std_logic_vector(25 downto 0) := (others => '0');
	
	signal imm_sign_ex, imm_zero_ex, imm_sign_ex_sh2, imm_zero_ex_sh2, rddata1, rddata2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
begin  

	regfile_inst: entity work.regfile(rtl)
	port map
	(		
		clk			=> clk,
		reset       => reset,
		stall       => stall,
		rdaddr1 		=> instr(25 downto 21),		
		rdaddr2 		=> instr(20 downto 16),
		rddata1		=> rddata1,
		rddata2 		=> rddata2,
		wraddr		=> wraddr,
		wrdata		=> wrdata,
		regwrite    => regwrite
	);

	opcode <= instr_latched(31 downto 26);
	rs 	 <= instr_latched(25 downto 21);
	rt 	 <= instr_latched(20 downto 16);
	rd 	 <= instr_latched(15 downto 11);
	shamt  <= instr_latched(10 downto 6);
	func   <= instr_latched(5 downto 0);
	addr_imm <= instr_latched(15 downto 0); 
	targ_addr <= instr_latched(25 downto 0); 

	update: process (all)
	begin
		if reset = '0' then
			pc_out <= (others => '0');
			instr_latched <= (others => '0');
		else
			if rising_edge(clk) and stall = '0' then				   					
				pc_out <= pc_in;
				instr_latched <= instr;
			end if;
			if flush = '1' then
				--pc_out <= (others => '0'); 		?
				instr_latched <= (others => '0');
			end if;
		end if;
	end process;
	
	imm_gen_pr: process(all)
	begin	
		imm_zero_ex_sh2 <= "00000000000000" & addr_imm & "00";
		imm_sign_ex_sh2(31 downto 18) <= (others => addr_imm(15));
		imm_sign_ex_sh2(17 downto 0) <= addr_imm & "00";
		imm_zero_ex <= "0000000000000000" & addr_imm;
		imm_sign_ex(31 downto 16) <= (others => addr_imm(15));
		imm_sign_ex(15 downto 0) <= addr_imm;
	end process;
	
	
	decode: process(all)
	begin 
	
		exec_op	<= EXEC_NOP;
		cop0_op  <= COP0_NOP;
		jmp_op   <= JMP_NOP;
		mem_op   <= MEM_NOP;
		wb_op    <= WB_NOP;
		exc_dec 	<= '0';
		if unsigned(instr_latched) = 0 then -- NOP
			exec_op	<= EXEC_NOP;
			cop0_op  <= COP0_NOP;
			jmp_op   <= JMP_NOP;
			mem_op   <= MEM_NOP;
			wb_op    <= WB_NOP;
		else
			exec_op.rs <= rs;
			exec_op.rt <= rt;
			exec_op.rd <= rd;
			case opcode is
				when "000000" => --R-Type				
					exec_op.readdata1 <= rddata1;	
					exec_op.readdata2 <= rddata2;	
					wb_op <= ('0', '1');
					
					case func is
						when "000000" => -- rd = rt << shamt							
							exec_op.aluop <= ALU_SLL;	
							exec_op.rs <= (others => '0');
							exec_op.imm(31 downto 5) <= (others => '0');
							exec_op.imm(4 downto 0) <= shamt;						
							exec_op.useamt <= '1';					
						when "000010" => -- rd = rt(unsigned) >> shamt
							exec_op.aluop <= ALU_SRL;	
							exec_op.rs <= (others => '0');
							exec_op.imm(31 downto 5) <= (others => '0');
							exec_op.imm(4 downto 0) <= shamt;
							exec_op.useamt <= '1';
						when "000011" => -- rd = rt(signed) >> shamt
							exec_op.aluop <= ALU_SRA;												
							exec_op.rs <= (others => '0');
							exec_op.imm(31 downto 5) <= (others => '0');
							exec_op.imm(4 downto 0) <= shamt;
							exec_op.useamt <= '1';
						when "000100" => -- rd = rt << rs(4 downto 0)						
							exec_op.aluop <= ALU_SLL;		
						when "000110" => -- rd = rt(unsigned) >> rs(4 downto 0)
							exec_op.aluop <= ALU_SRL;									
						when "000111" => -- rd = rt(signed) >> rs(4 downto 0)
							exec_op.aluop <= ALU_SRA;
						when "001000" => -- pc = rs				
							jmp_op <= JMP_JMP;
							wb_op <= ('0', '0');
						when "001001" => -- rd = pc+4; pc = rs
							exec_op.aluop <= ALU_NOP;	
							exec_op.link <= '1';
							jmp_op <= JMP_JMP;					
						when "100000" => -- rd = rs + rt, overflow trap
							exec_op.aluop <= ALU_ADD;
							exec_op.ovf <= '1';
						when "100001" => -- rd = rs + rt
							exec_op.aluop <= ALU_ADD;
						when "100010" => -- rd = rs - rt, overflow trap
							exec_op.aluop <= ALU_SUB;
							exec_op.ovf <= '1';
						when "100011" => -- rd = rs - rt
							exec_op.aluop <= ALU_SUB;	
						when "100100" => -- rd = rs & rt
							exec_op.aluop <= ALU_AND;	
						when "100101" => -- rd = rs | rt
							exec_op.aluop <= ALU_OR;	
						when "100110" => -- rd = rs ^ rt
							exec_op.aluop <= ALU_XOR;
						when "100111" => -- rd = ~(rs | rt)
							exec_op.aluop <= ALU_NOR;
						when "101010" => -- rd = (rs < rt) ? 1 : 0, signed
							exec_op.aluop <= ALU_SLT;
						when "101011" => -- rd = (rs < rt) ? 1 : 0, unsigned
							exec_op.aluop <= ALU_SLTU;							
						when others =>
							exec_op	<= EXEC_NOP;						
							exc_dec <= '1';
					end case;
				when "000001" =>
					
					exec_op.readdata1 <= rddata1;									
					exec_op.imm <= imm_sign_ex_sh2;
					exec_op.branch <= '1';				
					
					case rt is -- !!! rt in R-format is rd in I-format
						when "00000" =>
							jmp_op <= JMP_BLTZ;
						when "00001" =>
							jmp_op <= JMP_BGEZ;		
						when "10000" =>
							jmp_op <= JMP_BLTZ;
							exec_op.rd <= "11111";
							exec_op.link <= '1';
							wb_op.regwrite <= '1';
						when "10001" =>
							jmp_op <= JMP_BGEZ;
							exec_op.rd <= "11111";
							exec_op.link <= '1';
							wb_op.regwrite <= '1';
						when others =>
							exec_op	<= EXEC_NOP;						
							exc_dec <= '1';
					end case;
				when "000010" =>	-- pc = address << 2 (0-extension)												
					exec_op.readdata1 <= "0000" & targ_addr & "00";
					
					jmp_op <= JMP_JMP;
				when "000011" => -- r31 = pc + 4; pc = address << 2 (0-extension)
				
					exec_op.readdata1 <= "0000" & targ_addr & "00";
					exec_op.rd <= "11111";
					exec_op.link <= '1';
				
					jmp_op <= JMP_JMP;
					wb_op <= ('0', '1');
				when "000100" => -- BEQ				
					exec_op.rs <= rs;
					exec_op.aluop <= ALU_SUB;
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2 <= rddata2;		
					
					exec_op.imm <= imm_sign_ex_sh2;
					exec_op.branch <= '1';
					jmp_op <= JMP_BEQ;				
					wb_op <= ('0', '0');
				when "000101" => -- BNE
					exec_op.aluop <= ALU_SUB;
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2 <= rddata2;				
					
					exec_op.imm <= imm_sign_ex_sh2;
					exec_op.branch <= '1';
					jmp_op <= JMP_BNE;				
					wb_op <= ('0', '0');
				when "000110" => -- BLEZ
					exec_op.readdata1 <= rddata1;				
									
					exec_op.imm <= imm_sign_ex_sh2;
					exec_op.branch <= '1';
					jmp_op <= JMP_BLEZ;				
					wb_op <= ('0', '0');
				when "000111" => -- BGTZ
					exec_op.readdata1 <= rddata1;			
									
					exec_op.imm <= imm_sign_ex_sh2;
					exec_op.branch <= '1';
					jmp_op <= JMP_BGTZ;				
					wb_op <= ('0', '0');
				when "001000" => -- ADDI overflow trap
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_sign_ex;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					exec_op.ovf <= '1';
					
					wb_op.regwrite <= '1';
				when "001001" => -- ADDIU
					exec_op.aluop <= ALU_ADD;
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_sign_ex;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					
					wb_op.regwrite <= '1';
				when "001010" => -- SLTI
					exec_op.aluop <= ALU_SLT;
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_sign_ex;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';				
					
					wb_op.regwrite <= '1';
				when "001011" => -- SLTIU
					exec_op.aluop <= ALU_SLTU;
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_zero_ex;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';			
					
					wb_op.regwrite <= '1';
				when "001100" => -- ANDI
					exec_op.aluop <= ALU_AND;
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_zero_ex;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';			
					
					wb_op.regwrite <= '1';
				when "001101" => -- ORI
					exec_op.aluop <= ALU_OR;
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_zero_ex;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';			
					
					wb_op.regwrite <= '1';
				when "001110" => -- XORI
					exec_op.aluop <= ALU_XOR;
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_zero_ex;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					
					wb_op.regwrite <= '1';
				when "001111" => -- LUI	
					exec_op.aluop <= ALU_LUI;				
					exec_op.imm <= "0000000000000000" & addr_imm;
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					
					wb_op.regwrite <= '1';
				when "010000" =>
					if rs = "00000" then -- MFC0 read register from cop0
						cop0_op.wr <= '0';
						cop0_op.addr <= rd;
						
						exec_op.rd <= rt;
						exec_op.cop0 <= '1';
						
						wb_op.regwrite <= '1';
					elsif rs = "00100" then -- MTC0 set register in cop0
						cop0_op.wr <= '1';
						cop0_op.addr <= rd;
						
						exec_op.readdata2 <= rddata2;
						exec_op.rt <= rt;
						exec_op.cop0 <= '1';
					else
						exc_dec <= '1';
					end if;
				when "100000" => -- LB
					exec_op.aluop <= ALU_ADD;		
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_sign_ex;	
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_B;				
					wb_op.memtoreg <= '1';
				when "100001" => -- LH
					exec_op.aluop <= ALU_ADD;		
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_sign_ex;				
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_H;				
					wb_op.memtoreg <= '1';
				when "100011" => -- LW
					exec_op.aluop <= ALU_ADD;		
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_sign_ex;				
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_W;				
					wb_op.memtoreg <= '1';
				when "100100" => -- LBU
					exec_op.aluop <= ALU_ADD;		
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_sign_ex;				
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_BU;				
					wb_op.memtoreg <= '1';
				when "100101" => -- LBU
					exec_op.aluop <= ALU_ADD;		
					exec_op.readdata1 <= rddata1;
					exec_op.imm <= imm_sign_ex;				
					exec_op.regdst <= '1';
					exec_op.useimm <= '1';
					
					mem_op.memread <= '1';
					mem_op.memtype <= MEM_HU;				
					wb_op.memtoreg <= '1';
				when "101000" => -- SB
					exec_op.aluop <= ALU_ADD;		
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2 <= rddata2;
					exec_op.imm <= imm_sign_ex;
					exec_op.useimm <= '1';
					
					mem_op.memwrite <= '1';
					mem_op.memtype <= MEM_B;
				when "101001" => -- SH
					exec_op.aluop <= ALU_ADD;		
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2 <= rddata2;
					exec_op.imm <= imm_sign_ex;
					exec_op.useimm <= '1';
					
					mem_op.memwrite <= '1';
					mem_op.memtype <= MEM_H;
				when "101011" => -- SW
					exec_op.aluop <= ALU_ADD;		
					exec_op.readdata1 <= rddata1;
					exec_op.readdata2 <= rddata2;
					exec_op.imm <= imm_sign_ex;
					exec_op.useimm <= '1';
					
					mem_op.memwrite <= '1';
					mem_op.memtype <= MEM_W;
				when others =>				
					exc_dec <= '1';
			end case;
		end if; 
	end process;
	

end rtl;
