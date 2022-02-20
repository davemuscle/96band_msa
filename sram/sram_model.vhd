-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
         
--Just for simulation

entity sram_model is
	port(
		
		MemDB : inout std_logic_vector(7 downto 0);
		MemAdr : in unsigned(18 downto 0);
		RamOEn : in std_logic;
		RamWEn : in std_logic;
		RamCEn : in std_logic
		
	);
end sram_model;

architecture bhv of sram_model is 
    
    type ram_type is array ((2**19)-1 downto 0) of std_logic_vector(7 downto 0);
    shared variable sram : ram_type := (others => (others => '0')); --have to use this! otherwise gets undefined
	
	signal tri_state : std_logic := '0';
	signal byte : std_logic_vector(7 downto 0) := (others => '0');
	
begin
   
   process(MemDB, MemAdr, RamOEn, RamWEn, RamCEn)
   begin
		if(RamCEn = '0') then
		
			tri_state <= '0';
		
			if(RamOEn = '0') then
				byte <= sram(to_integer(MemAdr));
				tri_state <= '1';
			end if;
			
			if(RamWEn = '0') then
				sram(to_integer(MemAdr)) := MemDB;
			end if;
		
		end if;
   end process;
   
   MemDB <= byte when tri_state = '1' else (others => 'Z');
   
end bhv;
