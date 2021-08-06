
--------------------------------------------------------------------------------
--                                LIBRARIES                                   --
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------

entity top is
	port (
		--50 MHz clock input
		clk      : in  std_logic;

		-- push buttons, switches and LEDs
		keys     : in std_logic_vector(3 downto 0);
		switches : in std_logic_vector(17 downto 0);
		ledg     : out std_logic_vector(8 downto 0) := (others => '0');
		ledr     : out std_logic_vector(17 downto 0) := (others => '0');
	
		--Seven segment digit
		hex0 : out std_logic_vector(6 downto 0);
		hex1 : out std_logic_vector(6 downto 0);
		hex2 : out std_logic_vector(6 downto 0);
		hex3 : out std_logic_vector(6 downto 0);
		hex4 : out std_logic_vector(6 downto 0);
		hex5 : out std_logic_vector(6 downto 0);
		hex6 : out std_logic_vector(6 downto 0);
		hex7 : out std_logic_vector(6 downto 0);

		-- external interface to SRAM
		sram_dq   : inout std_logic_vector(15 downto 0);
		sram_addr : out std_logic_vector(19 downto 0);
		sram_ub_n : out std_logic;
		sram_lb_n : out std_logic;
		sram_we_n : out std_logic;
		sram_ce_n : out std_logic;
		sram_oe_n : out std_logic;
		
		-- LCD interface
		nclk    : out std_logic;
		hd      : out std_logic;
		vd      : out std_logic;
		den     : out std_logic;
		r       : out std_logic_vector(7 downto 0);
		g       : out std_logic_vector(7 downto 0);
		b       : out std_logic_vector(7 downto 0);
		grest   : out std_logic;
		sda     : out std_logic;
		
		--interface to snes controller
		snes_clk   : out std_logic;
		snes_latch : out std_logic;
		snes_data  : in std_logic;
		
		--uart
		tx      : out std_logic;
		rx      : in std_logic;
	
		-- ex2
		sda_audio		: inout std_logic;
		scl_audio		: inout std_logic;
		
		bclk				: out std_logic;
		daclrck  		: out std_logic;
		dacdat			: out std_logic;
		mclk				: out std_logic
		
	);
end entity;

architecture arch of top is

begin 

	asdf_inst: entity work.regfile(rtl)
	port map
	(
		clk, reset  => '0',
		stall       => '0',
		rdaddr1		=> (others => '0'),
		rdaddr2 		=> (others => '0'),
		rddata1		=> open,
		rddata2 		=> open,
		wraddr		=> (others => '0'),
		wrdata		=> (others => '0'),
		regwrite    => '0'
	);

end architecture;