library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity alu is
	port (
		op   : in  alu_op_type;
		A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		Z    : out std_logic;
		V    : out std_logic);

end alu;

architecture rtl of alu is
	constant zero : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); 
		function calcZeroFlag(op : alu_op_type; a : std_logic_vector; b: std_logic_vector) return std_logic is variable result : std_logic := '0'; 	
	begin 
		if(op = ALU_SUB) then 
			if(a = b) then 
				result := '1'; 
			end if; 
		else 
			if(a = zero) then 
				result := '1'; 
			end if; 
		end if; 
		
		return result; 
	
	end function; 
	
	function calcOverflowFlag(op : alu_op_type; a : std_logic_vector; b: std_logic_vector) return std_logic is variable result : std_logic := '0'; 
	begin 
		if(op = ALU_ADD) then 
			if(signed(a) >= 0 AND signed(b) >= 0 AND (signed(a) + signed(b)) < 0) then 
				result := '1';
			elsif(signed(a) < 0 AND signed(b) < 0 AND (signed(a) + signed(b)) >= 0) then 
				result := '1'; 
			end if; 
		elsif(op = ALU_SUB) then 
			if(signed(a) >= 0 AND signed(b) < 0 AND (signed(a) - signed(b)) < 0) then 
				result := '1';
			elsif(signed(a) < 0 AND signed(b) >= 0 AND (signed(a) - signed(b)) >= 0) then 
				result := '1'; 
			end if; 
		end if; 
		
		return result; 
	
	end function; 
begin  -- rtl
	output : process(all) 
	begin 
		case op is 
			when ALU_NOP => 
				R <= A; 
			
			when ALU_LUI => 
				R <= std_logic_vector(shift_left(unsigned(B), 16)); 
			
			when ALU_SLT => 
				if(signed(A) < signed(B)) then 
					R(DATA_WIDTH-1 downto 1) <= (others => '0');
					R(0) <= '1'; 
				else 
					R <= (others => '0'); 
				end if; 
				
			when ALU_SLTU => 
				if(unsigned(A) < unsigned(B)) then 
					R(DATA_WIDTH-1 downto 1) <= (others => '0');
					R(0) <= '1'; 
				else 
					R <= (others => '0'); 
				end if; 
			
			when ALU_SLL => 
				R <= std_logic_vector(shift_left(unsigned(B), to_integer(unsigned(A(4 downto 0))))); --Kontrollieren 
			
			when ALU_SRL => 
				R <= std_logic_vector(shift_right(unsigned(B), to_integer(unsigned(A(4 downto 0))))); -- Konrollieren  
				
			when ALU_SRA => 
				if(B(DATA_WIDTH -1) = '1') then 
					R <= std_logic_vector(shift_right(unsigned(B), to_integer(unsigned(A(4 downto 0)))));
					R(DATA_WIDTH -1 downto (DATA_WIDTH -1 - to_integer(unsigned(A(4 downto 0))))) <= (others => '1'); 
				else 
					R <= std_logic_vector(shift_right(unsigned(B), to_integer(unsigned(A(4 downto 0)))));
				end if; 
			
			when ALU_ADD => 
				R <= std_logic_vector(signed(A) + signed(B)); 
			
			when ALU_SUB => 
				R <= std_logic_vector(signed(A) - signed(B)); 
			
			when ALU_AND => 
				R <= A AND B; 
				
			when ALU_OR => 
				R <= A OR B; 
				
			when ALU_XOR => 
				R <= A XOR B; 
				
			when ALU_NOR => 
				R <= A NOR B; 
				
		end case; 
		Z <= calcZeroFlag(op,A,B); 
		V <= calcOverflowFlag(op,A,B); 
	end process; 


end rtl;
