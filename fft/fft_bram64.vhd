-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
         
--inferred bram
--1024 by 32 for signed, Q15.16

entity fft_bram64 is
	generic(
		order : integer
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
end fft_bram64;

architecture bhv of fft_bram64 is 
    
    type ram_type is array ((2**order)-1 downto 0) of signed(63 downto 0);
    shared variable bram : ram_type := (others => (others => '0')); --have to use this! otherwise gets undefined
	
begin

    --port A
	process(clka)
	begin
		if(clka'event and clka = '1') then
		  if(ena = '1') then
		      doa <= bram(to_integer(addra));

		      if(wea = '1') then
		         bram(to_integer(addra)) := dia;
		      end if;
		  end if;
		end if;
	end process;
     
    --port B
	process(clkb)
	begin
		if(clkb'event and clkb = '1') then
		  if(enb = '1') then
		      dob <= bram(to_integer(addrb));
		    
		      if(web = '1') then
		         bram(to_integer(addrb)) := dib;
		      end if;
		  end if;
		end if;
	end process;
   
end bhv;

 		