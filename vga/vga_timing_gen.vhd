--2/8/2020
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--vga timing
--put screen resolution information in pkg

use work.vga_timing_gen_pkg.all;

entity vga_timing_gen is
	port(
		pclk : in std_logic;

		vsync : out std_logic;
		vsync_n : out std_logic; 
		hsync : out std_logic; 
		hsync_n : out std_logic;
		
		--hblank and vblank are 1 during blanking period
		hblank : out std_logic; 
		vblank : out std_logic
		
        );
end vga_timing_gen;

architecture arch of vga_timing_gen is

	signal h_count : unsigned(15 downto 0) := (others => '0');
	signal v_count : unsigned(15 downto 0) := (others => '0');
	
	
begin
	
	process(pclk)
	begin
		--pixel clock rising edge
		if(pclk'event and pclk = '1') then
		
			--increment counts
			if(h_count = to_unsigned(h_total-1, 16)) then
				--reset
				h_count <= (others => '0');
	
				if(v_count = to_unsigned(v_total-1, 16)) then
					v_count <= (others => '0');
				else
					v_count <= v_count + 1;
				end if;
			else
				h_count <= h_count + 1;
			end if;
		


		
		
		end if;
	
	end process;
	
	--update hsync
	process(h_count)
	begin
		--sync marker
		if(h_count < to_unsigned(h_active + h_frontporch, 16)) then
			hsync <= '1';
			hsync_n <= '0';
		elsif(h_count >= to_unsigned(h_active + h_frontporch + h_syncwidth, 16)) then
			hsync <= '1';
			hsync_n <= '0';
		else
			hsync <= '0';
			hsync_n <= '1';
		end if;
		
		--blanking period
		if(h_count < to_unsigned(h_active, 16)) then
			hblank <= '0';
		else
			hblank <= '1';
		end if;

	end process;

	--update vsync
	process(v_count)
	begin
		if(v_count < to_unsigned(v_active + v_frontporch, 16)) then
			vsync <= '1';
			vsync_n <= '0';
		elsif(v_count >= to_unsigned(v_active + v_frontporch + v_syncwidth, 16)) then
			vsync <= '1';
			vsync_n <= '0';
		else
			vsync <= '0';
			vsync_n <= '1';
		end if;
		
		--blanking period
		if(v_count < to_unsigned(v_active, 16)) then
			vblank <= '0';
		else
			vblank <= '1';
		end if;
		
	end process;

end arch;	