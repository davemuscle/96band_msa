-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
         
--inferred brom
--for holding Q2.14 cosine twiddle factors

entity fft_twiddles is
	generic(
		order : integer;
		coslutfile : string
	);
	port(
		
		clk : in std_logic;
		
		en : in std_logic;
		addr_cos : in unsigned(order-1 downto 0);
		addr_sin : in unsigned(order-1 downto 0);

		cos : out signed(15 downto 0);
		sin : out signed(15 downto 0)
		
        );
end fft_twiddles;

architecture bhv of fft_twiddles is 
    
    type rom_type is array(0 to 2**order - 1) of bit_vector(15 downto 0);

	impure function rom_init(filename : string) return rom_type is
	  file rom_file : text open read_mode is filename;
	  variable rom_line : line;
	  variable rom_value : bit_vector(15 downto 0);
	  variable temp : rom_type;
	begin
	  for rom_index in 0 to 2**order - 1 loop
		readline(rom_file, rom_line);
		read(rom_line, rom_value);
		temp(rom_index) := (rom_value);
	  end loop;
	  return temp;
	end function;
	
	constant cosine : rom_type := rom_init(filename => coslutfile);
	
	
begin

	process(clk)
	begin
	
		if(clk'event and clk = '1') then
		
			if(en = '1') then
			
				cos <= signed(to_StdLogicVector(cosine(to_integer(addr_cos))));
				sin <= signed(to_StdLogicVector(cosine(to_integer(addr_sin))));
			
			end if;
		
		end if;
	
	end process;
   
   
end bhv;

 		