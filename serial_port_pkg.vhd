library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package serial_port_pkg is
	/*component serial_port is
		
		generic (
			clk_freq	  : integer;
			baud_rate	  : integer;
			sync_stages	  : integer;
			tx_fifo_depth : integer;
			rx_fifo_depth : integer);

		port (
			clk		: in  std_logic;
			res_n	: in  std_logic;
			address : in  std_logic_vector(0 downto 0);
			wr		: in  std_logic;
			wr_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			rd		: in  std_logic;
			rd_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
			tx		: out std_logic;
			rx		: in  std_logic);

	end component;*/
	component serial_port is
		generic (
			clk_freq	  : integer;
			baud_rate	  : integer;
			sync_stages	  : integer;
			tx_fifo_depth : integer;
			rx_fifo_depth : integer
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			rx : in std_logic;
			tx : out std_logic;
			tx_data : in std_logic_vector(7 downto 0);
			tx_wr : in std_logic;
			tx_free : out std_logic;
			rx_rd : in std_logic;
			rx_data : out std_logic_vector(7 downto 0);
			rx_data_empty : out std_logic;
			rx_data_full : out std_logic
		);
	end component;
end package;

