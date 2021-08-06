    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity memu is
	port (
		op   : in  mem_op_type;
		A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		M    : out mem_out_type;
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		XL   : out std_logic;
		XS   : out std_logic);
end memu;

--type memtype_type is (
--		MEM_W,
--		MEM_H,
--		MEM_HU,
--		MEM_B,
--		MEM_BU);

--DATA_WIDTH_BITS  : integer := 5;
--DATA_WIDTH       : integer := 2**DATA_WIDTH_BITS; 32
--ADDR_WIDTH       : integer := 21;


architecture rtl of memu is


begin  -- rtl

	
-- MAIN PROCESS
	memrw : process (op, A, W, D)
	
	variable load_ex				: std_logic := '0';
	variable store_ex				: std_logic := '0';
	begin
	
	
-- WRITE TO MEMORY
		

		load_ex	:= '0';
		store_ex	:= '0';
		M.address <= A;
		M.wr <= op.memwrite;
		m.rd <= op.memread;
		
		
			
				case op.memtype is
					
					when MEM_B | MEM_BU =>					
						case A(1 downto 0) is
							when "00" =>								
								M.byteena <= "1000";	
								M.wrdata(31 downto 24) <= W(7 downto 0);
								M.wrdata(23 downto 0) <= (others => '-'); --X
							when "01" =>
								M.byteena  <= "0100";
								M.wrdata(31 downto 24) <= (others => '-'); --X
								M.wrdata(23 downto 16) <= W(7 downto 0);
								M.wrdata(15 downto 0) <= (others => '-'); --X
								
							when "10" =>
								M.byteena  <= "0010";
								M.wrdata(31 downto 16) <= (others => '-'); --X
								M.wrdata(15 downto 8) <= W(7 downto 0);
								M.wrdata(7 downto 0) <= (others => '-'); --X
								
							when "11" =>	
								M.byteena  <= "0001";
								M.wrdata(31 downto 8) <= (others => '-'); --X
								M.wrdata(7 downto 0) <= W(7 downto 0);								
							when others =>
								M.byteena  <= "0000";
						end case;
					
					when MEM_H | MEM_HU =>
						case A(1 downto 0) is
							when "00" =>								
								M.byteena  <= "1100";
								M.wrdata(31 downto 16) <= W(15 downto 0); 
								M.wrdata(15 downto 0) <= (others => '-'); --X
							when "01" =>															
								M.byteena  <= "1100";
								M.wrdata(31 downto 16) <= W(15 downto 0); 
								M.wrdata(15 downto 0) <= (others => '-'); --X
							when "10" =>
								M.byteena  <= "0011";
								M.wrdata(31 downto 16) <= (others => '-'); --X
								M.wrdata(15 downto 0) <= W(15 downto 0); 
							when "11" =>
								M.byteena  <= "0011";
								M.wrdata(31 downto 16) <= (others => '-'); --X
								M.wrdata(15 downto 0) <= W(15 downto 0); 
							when others =>
								M.byteena  <= "0000";
						end case;
					when MEM_W =>
						case A(1 downto 0) is
							when "00" =>								
								M.byteena  <= "1111";
								M.wrdata(31 downto 0) <= W(31 downto 0);
							when "01" =>								
								M.byteena  <= "1111";
								M.wrdata(31 downto 0) <= W(31 downto 0);
							when "10" =>								
								M.byteena  <= "1111";
								M.wrdata(31 downto 0) <= W(31 downto 0);
							when "11" =>								
								M.byteena  <= "1111";
								M.wrdata(31 downto 0) <= W(31 downto 0);
							when others =>
								M.byteena  <= "0000";
						end case;					
				end case;
				
			
-- READ FROM MEMORY		
		
				case op.memtype is
					when MEM_B =>
						
						case A(1 downto 0) is
							when "00" =>								
								R(7 downto 0) <=  D(31 downto 24);
								if (D(31)  = '0') then
									R(31 downto 8) <= (others => '0'); 
								else
									R(31 downto 8) <= (others => '1');
								end if;
							when "01" =>								
								R(7 downto 0) <=  D(23 downto 16);
								if (D(23)  = '0') then
									r(31 downto 8) <= (others => '0');
								else
									R(31 downto 8) <= (others => '1');
								end if;
							when "10" =>								
								R(7 downto 0) <=  D(15 downto 8);
								if (D(15)  = '0') then
									R(31 downto 8) <= (others => '0');
								else
									R(31 downto 8) <= (others => '1');
								end if;
							when "11" =>								
								R(7 downto 0) <=  D(7 downto 0);
								if (D(7)  = '0') then
									R(31 downto 8) <= (others => '0');
								else
									R(31 downto 8) <= (others => '1');
								end if;
							when others =>
						end case;
						
					when MEM_BU =>
						case A(1 downto 0) is
							when "00" =>
								R(31 downto 8) <= (others =>'0');
								R(7 downto 0) <=  D(31 downto 24);
							when "01" =>								
								R(31 downto 8) <= (others =>'0');
								R(7 downto 0) <=  D(23 downto 16);
							when "10" =>								
								R(31 downto 8) <= (others =>'0');
								R(7 downto 0) <=  D(15 downto 8);
							when "11" =>								
								R(31 downto 8) <= (others =>'0');
								R(7 downto 0) <=  D(7 downto 0);
							when others =>
						end case;
					when MEM_H =>					
						case A(1 downto 0) is
							when "00" =>								
								R(15 downto 0) <=  D(31 downto 16);
								if (D(31)  = '0') then
									R(31 downto 16) <= (others => '0');
								else
									R(31 downto 16) <= (others => '1');
								end if;
							when "01" =>								
								R(15 downto 0) <=  D(31 downto 16);
								if (D(31)  = '0') then
									R(31 downto 16) <= (others => '0');
								else
									R(31 downto 16) <= (others => '1');
								end if;
							when "10" =>								
								R(15 downto 0) <=  D(15 downto 0);
								if (D(15)  = '0') then
									R(31 downto 16) <= (others => '0');
								else
									R(31 downto 16) <= (others => '1');
								end if;
							when "11" =>															
								R(15 downto 0) <=  D(15 downto 0);
								if (D(15)  = '0') then
									R(31 downto 16) <= (others => '0');
								else
									R(31 downto 16) <= (others => '1');
								end if;
							when others =>
						end case;
					when MEM_HU =>
						case A(1 downto 0) is
							when "00" =>								
								R(31 downto 16) <= (others =>'0');
								R(15 downto 0) <=  D(31 downto 16);
							when "01" =>								
								R(31 downto 16) <= (others =>'0');
								R(15 downto 0) <=  D(31 downto 16);
							when "10" =>								
								R(31 downto 16) <= (others =>'0');
								R(15 downto 0) <=  D(15 downto 0);
							when "11" =>								
								R(31 downto 16) <= (others =>'0');
								R(15 downto 0) <=  D(15 downto 0);
							when others =>
						end case;
					when MEM_W =>	
						case A(1 downto 0) is
							when "00" =>								
								R(31 downto 0) <= D(31 downto 0);
							when "01" =>								
								R(31 downto 0) <= D(31 downto 0);
							when "10" =>								
								R(31 downto 0) <= D(31 downto 0);
							when "11" =>								
								R(31 downto 0) <= D(31 downto 0);
							when others =>
						end case;					
				end case;
--				
--				if (A(20 downto 0) = "000000000000000000000") then				
--					if(op.memread = '1') then
--							load_ex	:= '1';
--					elsif(op.memwrite = '1') then
--							store_ex	 := '1';
--					end if;
--				end if;
				
				if (op.memread = '1' or op.memwrite = '1') then
					
					case op.memtype is
					
						when MEM_B | MEM_BU =>
						
							if (A(20 downto 0) = "000000000000000000000") then				
								if(op.memread = '1') then
										load_ex	:= '1';
								elsif(op.memwrite = '1') then
									store_ex	 := '1';
								end if;
							end if;
							
						
						when MEM_H | MEM_HU =>
							case A(1 downto 0) is
								when "00" =>
									if (A(20 downto 2) = "0000000000000000000") then				
										if(op.memread = '1') then
												load_ex	:= '1';
										elsif(op.memwrite = '1') then
												store_ex	 := '1';
										end if;
									end if;
								when "01" => --EX
									if (op.memread = '1') then
										load_ex := '1';
									elsif (op.memwrite = '1') then 
										store_ex := '1';
									end if;					
								
								when "10" =>
								when "11" => -- EX
									if (op.memread = '1') then
										load_ex := '1';
									elsif (op.memwrite = '1') then 
										store_ex := '1';
									end if;	
								when others =>
							end case;
							
						when MEM_W =>
							case A(1 downto 0) is
								when "00" =>
									if (A(20 downto 2) = "0000000000000000000") then				
										if(op.memread = '1') then
												load_ex := '1';
										elsif(op.memwrite = '1') then
												store_ex := '1';
										end if;
									end if;
								when "01" => --EX
									if (op.memread = '1') then
										load_ex := '1';
									elsif (op.memwrite = '1') then 
										store_ex := '1';
									end if;	
								when "10" => --EX
									if (op.memread = '1') then
										load_ex := '1';
									elsif (op.memwrite = '1') then 
										store_ex := '1';
									end if;	
								when "11" => --EX
									if (op.memread = '1') then
										load_ex := '1';
									elsif (op.memwrite = '1') then 
										store_ex := '1';
									end if;	
								when others =>
							end case;
						when others =>							
						end case;
					
				end if;
				
				if (load_ex = '1' or store_ex = '1') then
					M.rd <= '0';
					M.wr <= '0';
				end if;
					
				XL <= load_ex;
				XS <= store_ex;
	
	end process;
	



end rtl;