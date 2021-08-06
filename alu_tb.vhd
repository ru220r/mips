library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity alu_tb is
end alu_tb;
-- not xor oder mult
architecture beh of alu_tb is

    component alu is
        port (
            op   : in  alu_op_type;
            A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
            Z    : out std_logic;
            V    : out std_logic
        );
    end component;

    signal op : alu_op_type;
    signal A, B, R : std_logic_vector;
    signal Z, V : sdt_logic;
    signal stop_clock : std_logic := '0'; 

begin

    uut : alu
    port map(
        op => op,
        A => A,
        B => B,
        R => R,
        Z => Z,
        V => V
    );

    process

        variable var_y : integer := 0;
    begin
        if var_y < 66 then

        end if;
    var_y <= var_y + 2;

    end process;    


end architecture;