library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity decode_tb is
end entity;


architecture beh of decode_tb is
	constant CLK_PERIOD : time := 20 ns;

	signal clk 			: std_logic;
	signal reset		: std_logic := '1';
	signal stall      : std_logic := '0';
	signal regwrite   : std_logic := '1';
	signal flush		: std_logic := '0';
	signal wraddr, wraddr_next		: std_logic_vector(REG_BITS-1 downto 0) := (others => '0');	
	signal wrdata, wrdata_next		: std_logic_vector(DATA_WIDTH-1 downto 0) := ((10) => '1', others => '0');		
	signal pc, pc_next: std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
	signal instr	   : std_logic_vector(INSTR_WIDTH-1 downto 0);
	
	
	signal exec_op   	: exec_op_type;
	signal jmp_op    	: jmp_op_type;
	signal mem_op    	: mem_op_type;
	signal wb_op     	: wb_op_type;
	signal exec_dec   : std_logic;
	
	
	alias opcode    	: std_logic_vector(5 downto 0)  is instr(31 downto 26);
   alias rs        	: std_logic_vector(4 downto 0)  is instr(25 downto 21);
   alias rt		    	: std_logic_vector(4 downto 0)  is instr(20 downto 16);
	alias rd_I	    	: std_logic_vector(4 downto 0)  is instr(20 downto 16);
   alias rd_R        : std_logic_vector(4 downto 0)  is instr(15 downto 11);
   alias Ird       	: std_logic_vector(4 downto 0)  is instr(20 downto 16);
   alias shamt     	: std_logic_vector(4 downto 0)  is instr(10 downto 6);
   alias func      	: std_logic_vector(5 downto 0)  is instr(5 downto 0);
   alias addr_imm   	: std_logic_vector(15 downto 0) is instr(15 downto 0);
	alias targ_addr	 	: std_logic_vector(25 downto 0) is instr(25 downto 0);
	
	
	signal stop_clock : boolean := false;
begin
	
	regfile_inst: entity work.decode(rtl)
	port map(
		clk		=> clk,
		reset 	=> reset,
		stall    => stall,
		flush    => flush,
		pc_in    => pc,
		instr	   => instr,
		wraddr   => wraddr,
		wrdata   => wrdata,
		regwrite => regwrite,
		pc_out   => open,
		exec_op  => exec_op,
		cop0_op  => open,
		jmp_op   => jmp_op,
		mem_op   => mem_op,
		wb_op    => wb_op,
		exc_dec  => exec_dec
	);
	
	stall_pr:  process
	begin
		wait for CLK_PERIOD*0.5; 
		regwrite <= '1'; -- fill regs
		wait for CLK_PERIOD*31;	-- SLL
		regwrite <= '0'; 
		opcode <= "000000";
		rd_R <= "00001";
		rt <= "10001";
		rs <= "01000";
		shamt <= "00001";
		func <= "000000";
		wait for CLK_PERIOD*1; -- SRL	
		opcode <= "000000";
		rd_R <= "00010";
		rt <= "10010";
		rs <= "01001";
		shamt <= "00001";
		func <= "000010";
		wait for CLK_PERIOD*1; -- SRA
		opcode <= "000000";
		rd_R <= "00011";
		rt <= "10011";
		rs <= "01010";
		shamt <= "00001";
		func <= "000011";
		wait for CLK_PERIOD*1; -- SLLV
		opcode <= "000000";
		rd_R <= "00100";
		rt <= "10100";
		rs <= "00001";
		shamt <= "00000";
		func <= "000100";
		wait for CLK_PERIOD*1; -- SRLV
		opcode <= "000000";
		rd_R <= "00101";
		rt <= "10101";
		rs <= "00001";
		shamt <= "00000";
		func <= "000110";
		wait for CLK_PERIOD*1; -- SRAV
		opcode <= "000000";
		rd_R <= "00110";
		rt <= "10110";
		rs <= "00001";
		shamt <= "00000";
		func <= "000111";
		wait for CLK_PERIOD*1; -- JR
		opcode <= "000000";
		rd_R <= "00100";
		rt <= "00100";
		rs <= "00111";
		shamt <= "00000";
		func <= "001000";
		wait for CLK_PERIOD*1; -- JALR
		opcode <= "000000";
		rd_R <= "00100";
		rt <= "00100";
		rs <= "01000";
		shamt <= "00000";
		func <= "001001";
		wait for CLK_PERIOD*1; -- ADD
		opcode <= "000000";
		rd_R <= "01001";
		rt <= "01001";
		rs <= "01001";
		shamt <= "00000";
		func <= "100000";
		wait for CLK_PERIOD*1; -- ADDU
		opcode <= "000000";
		rd_R <= "01010";
		rt <= "01010";
		rs <= "01010";
		shamt <= "00000";
		func <= "100001";
		wait for CLK_PERIOD*1; -- SUB
		opcode <= "000000";
		rd_R <= "01011";
		rt <= "01011";
		rs <= "01011";
		shamt <= "00000";
		func <= "100010";
		wait for CLK_PERIOD*1; -- SUBU
		opcode <= "000000";
		rd_R <= "01100";
		rt <= "01100";
		rs <= "01100";
		shamt <= "00000";
		func <= "100011";
		wait for CLK_PERIOD*1; -- AND
		opcode <= "000000";
		rd_R <= "01101";
		rt <= "01101";
		rs <= "01101";
		shamt <= "00000";
		func <= "100100";
		wait for CLK_PERIOD*1; -- OR		
		opcode <= "000000";
		rd_R <= "01110";
		rt <= "01110";
		rs <= "01110";
		shamt <= "00000";
		func <= "100101";
		wait for CLK_PERIOD*1; -- XOR
		opcode <= "000000";
		rd_R <= "01111";
		rt <= "01111";
		rs <= "01111";
		shamt <= "00000";
		func <= "100110";
		wait for CLK_PERIOD*1; -- NOR
		opcode <= "000000";
		rd_R <= "10000";
		rt <= "10000";
		rs <= "10000";
		shamt <= "00000";
		func <= "100111";
		wait for CLK_PERIOD*1; -- SLT
		opcode <= "000000";
		rd_R <= "10001";
		rt <= "10001";
		rs <= "10001";
		shamt <= "00000";
		func <= "101010";
		wait for CLK_PERIOD*1; -- SLTU
		opcode <= "000000";
		rd_R <= "10010";
		rt <= "10010";
		rs <= "10010";
		shamt <= "00000";
		func <= "101011";
		wait for CLK_PERIOD*10; -- BLTZ
		opcode <= "000001";
		rs <= "10011";
		rd_I <= "00000";		
		addr_imm <= "0000000000000001";		
		wait for CLK_PERIOD*1; -- BGEZ
		opcode <= "000001";
		rs <= "10100";
		rd_I <= "00001";		
		addr_imm <= "1111111111111111";		
		wait for CLK_PERIOD*1; -- BLTZAL
		opcode <= "000001";
		rs <= "10101";
		rd_I <= "10000";		
		addr_imm <= "1111111111111110";		
		wait for CLK_PERIOD*1; -- BGEZAL
		opcode <= "000001";
		rs <= "10110";
		rd_I <= "10001";		
		addr_imm <= "1111111111111100";		
		wait for CLK_PERIOD*10; -- J
		opcode <= "000010";
		targ_addr <= "00000000000000000000000001";
		wait for CLK_PERIOD*1; -- JAL
		opcode <= "000011";
		targ_addr <= "00000000000000000000000010";		
		wait for CLK_PERIOD*10; -- BEQ
		opcode <= "000100";
		rs <= "10111";
		rd_I <= "11000";	
		addr_imm <= "1111111111111110";
		wait for CLK_PERIOD*1; -- BNE
		opcode <= "000101";
		rs <= "11000";
		rd_I <= "11001";	
		addr_imm <= "0000000000000001";
		wait for CLK_PERIOD*1; -- BLEZ
		opcode <= "000110";
		rs <= "11001";
		rd_I <= "11010";	
		addr_imm <= "0000000000000010";
		wait for CLK_PERIOD*1; -- BGTZ
		opcode <= "000111";
		rs <= "11010";
		rd_I <= "11011";	
		addr_imm <= "0000000000000100";
		wait for CLK_PERIOD*10; -- ADDI
		opcode <= "001000";
		rs <= "11011";
		rd_I <= "11100";	
		addr_imm <= "0000000000000001";
		wait for CLK_PERIOD*1; -- ADDIU
		opcode <= "001001";
		rs <= "11100";
		rd_I <= "11101";	
		addr_imm <= "1111111111111111";
		wait for CLK_PERIOD*1; -- SLTI
		opcode <= "001010";
		rs <= "11101";
		rd_I <= "11110";	
		addr_imm <= "1111111111111111";
		wait for CLK_PERIOD*1; -- SLTIU
		opcode <= "001011";
		rs <= "11110";
		rd_I <= "11111";	
		addr_imm <= "1111111111111111";
		wait for CLK_PERIOD*10; -- ANDI
		opcode <= "001100";
		rs <= "11111";
		rd_I <= "00000";	
		addr_imm <= "0000000001010101";
		wait for CLK_PERIOD*1; -- ORI
		opcode <= "001101";
		rs <= "00000";
		rd_I <= "00001";	
		addr_imm <= "1111111111111111";
		wait for CLK_PERIOD*1; -- XORI
		opcode <= "001110";
		rs <= "00001";
		rd_I <= "00010";	
		addr_imm <= "1010101000000000";
		wait for CLK_PERIOD*1; -- LUI
		opcode <= "001111";
		rs <= "00010";
		rd_I <= "00011";	
		addr_imm <= "1111111100000000";
		wait for CLK_PERIOD*10; -- LB
		opcode <= "100000";
		rs <= "00011";
		rd_I <= "00100";	
		addr_imm <= "1111111111111111";
		wait for CLK_PERIOD*1; -- LH
		opcode <= "100001";
		rs <= "00100";
		rd_I <= "00101";	
		addr_imm <= "0000000000000001";
		wait for CLK_PERIOD*1; -- LW
		opcode <= "100011";
		rs <= "00101";
		rd_I <= "00110";	
		addr_imm <= "0000000000000010";
		wait for CLK_PERIOD*1; -- SB
		opcode <= "101000";
		rs <= "00110";
		rd_I <= "00111";	
		addr_imm <= "0000000000000100";
		wait for CLK_PERIOD*1; -- SH
		opcode <= "101001";
		rs <= "00111";
		rd_I <= "01000";	
		addr_imm <= "1000000000001000";
		wait for CLK_PERIOD*1; -- SW
		opcode <= "101011";
		rs <= "01000";
		rd_I <= "01001";	
		addr_imm <= "1000000000010000";
		wait;
	end process;
	
	pdate : process(all)
	begin
		if rising_edge(clk) then
			wraddr <= wraddr_next;
			wrdata <= wrdata_next;
			pc		 <= pc_next;
		end if;
	end process;
	
	gen: process(all)
	begin
		wraddr_next <= std_logic_vector(unsigned(wraddr)+1);
		wrdata_next <= std_logic_vector(unsigned(wrdata)+1);
		pc_next 		<= std_logic_vector(unsigned(pc)+4);
	end process;
	

	generate_clk : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD / 2;
			wait for CLK_PERIOD;
		end loop;
		wait;
	end process;

end architecture;