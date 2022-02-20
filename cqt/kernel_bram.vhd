-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity kernel_bram is
	generic(
		order : integer;
		initfile : string
	);
	port(
		
		clka : in std_logic;
		wea  : in std_logic;
		ena  : in std_logic;
		dia : in signed(63 downto 0);
		doa : out signed(63 downto 0);
		addra : in unsigned(order-1 downto 0);

        clkb : in std_logic;
		web  : in std_logic;
		enb  : in std_logic;
		dib : in signed(63 downto 0);
		dob : out signed(63 downto 0);
		addrb : in unsigned(order-1 downto 0)
		
	);
end kernel_bram;

architecture bhv of kernel_bram is 
    
    type ram_type is array ((2**order)-1 downto 0) of bit_vector(63 downto 0);
    --shared variable bram : ram_type := (others => (others => '0')); --have to use this! otherwise gets undefined
	
	impure function ram_init(filename : string) return ram_type is
	  file ram_file : text open read_mode is filename;
	  variable ram_line : line;
	  variable ram_value : bit_vector(63 downto 0);
	  variable temp : ram_type;
	begin
	  for ram_index in 0 to 2**order - 1 loop
		readline(ram_file, ram_line);
		read(ram_line, ram_value);
		temp(ram_index) := (ram_value);
	  end loop;
	  return temp;
	end function;
	
	shared variable bram : ram_type := ram_init(filename => initfile);
	
begin

    --port A
	process(clka)
	begin
		if(clka'event and clka = '1') then
		  if(ena = '1') then
		      doa <= signed(to_StdLogicVector(bram(to_integer(addra))));

		      if(wea = '1') then
		         bram(to_integer(addra)) := to_BitVector(std_logic_vector(dia));
		      end if;
		  end if;
		end if;
	end process;
     
    --port B
	process(clkb)
	begin
		if(clkb'event and clkb = '1') then
		  if(enb = '1') then
		      dob <= signed(to_StdLogicVector(bram(to_integer(addrb))));
		    
		      if(web = '1') then
		         bram(to_integer(addrb)) := to_BitVector(std_logic_vector(dib));
		      end if;
		  end if;
		end if;
	end process;
   
end bhv;

 		