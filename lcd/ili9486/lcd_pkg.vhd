library IEEE;
use IEEE.std_logic_1164.all;

package lcd_init_isr is

type baba is (a, b); --std_logic_vector(8 downto 0);

type rom_array is array(0 to 2) of std_logic_vector(8 downto 0);

constant ROM : rom_array := 
    (
         X"0C3",
         X"000",
         X"000"
         );         

end package lcd_init_isr;