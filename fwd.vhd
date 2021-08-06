library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity fwd is
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
	
end fwd;

architecture rtl of fwd is
	
	signal rd_mem_out_latched,
			 rd_exec_out_latched,
			 rs_decode_out_latched, rt_decode_out_latched : std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal regwrite_mem_out_latched,
			 regwrite_exec_out_latched: std_logic := '0';		
	
begin  -- rtl

	update: process(all)
	begin
		if reset = '0' then
			rd_mem_out_latched 			<= (others => '0');
			rd_exec_out_latched			<= (others => '0');
			rs_decode_out_latched		<= (others => '0');
			rt_decode_out_latched		<= (others => '0');
			regwrite_mem_out_latched	<= '0';
			regwrite_exec_out_latched	<= '0';
		else
			if rising_edge(clk) and stall = '0' then
				rd_mem_out_latched 			<= rd_mem_out;
				rd_exec_out_latched			<= rd_exec_out;
				rs_decode_out_latched		<= rs_decode_out;
				rt_decode_out_latched		<= rt_decode_out;
				regwrite_mem_out_latched	<= regwrite_mem_out;
				regwrite_exec_out_latched	<= regwrite_exec_out;
			end if;
		end if;
	end process;

	output: process(all)
	begin
		forwardA <= FWD_NONE;
		forwardB <= FWD_NONE;

		if regwrite_mem_out_latched = '1' then -- rd gets written back
			if unsigned(rd_mem_out_latched) /= 0 then
				if unsigned(rs_decode_out_latched) = unsigned(rd_mem_out_latched) then
					forwardA <= FWD_WB;
				end if;
				if unsigned(rt_decode_out_latched) = unsigned(rd_mem_out_latched) then
					forwardB <= FWD_WB;
				end if;
			end if;
		end if;


		if regwrite_exec_out_latched = '1' then -- rd gets written back
			if unsigned(rd_exec_out_latched) /= 0 then
				if unsigned(rs_decode_out_latched) = unsigned(rd_exec_out_latched) then
					forwardA <= FWD_ALU;
				end if;
				if unsigned(rt_decode_out_latched) = unsigned(rd_exec_out_latched) then
					forwardB <= FWD_ALU;
				end if;
			end if;
		end if;			
		
		
	end process;
end rtl;
