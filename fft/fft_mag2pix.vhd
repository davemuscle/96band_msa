library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--reads magnitude BRAM, 
--converts to pixels for LCD
--sends each line to LCD controller

--crosses clock domain from fft -> lcd with a BRAM

entity fft_mag2pix is

	port(
	    fft_clk : in std_logic;
		lcd_clk : in std_logic;
		
		mag_done : in std_logic;
		
		rect_ready : out std_logic;
		rect_done : in std_logic;
		
		screen_done : out std_logic;
		error : out std_logic;
		
		addr : out unsigned(8 downto 0);
		en   : out std_logic;
		fft_data : in unsigned(31 downto 0);
		
		column_sta : out std_logic_vector(8 downto 0);
		column_end : out std_logic_vector(8 downto 0);
		row_sta : out std_logic_vector(8 downto 0);
		row_end : out std_logic_vector(8 downto 0);
		
		pixel : out std_logic_vector(15 downto 0)

        );
end fft_mag2pix;

architecture str of fft_mag2pix is 

	signal load_begin : std_logic := '0';
	signal load_begin_dly : std_logic := '0';
	signal proc_begin : std_logic := '0';
	
	--signal pixel_height : unsigned(8 downto 0) := (others => '0');
	
	signal blank_start : unsigned(8 downto 0) := (others => '0');
	signal blank_end   : unsigned(8 downto 0) := (others => '0');
	
	constant h320 : unsigned(8 downto 0) := "101000000";
	
	signal draw_color : std_logic := '0';
	signal draw_blank : std_logic := '0';
	signal read_enable : std_logic := '0';
	signal check : unsigned(8 downto 0) := "111100000";
	
	signal fft_addr : unsigned(8 downto 0) := (others => '0');
	signal fft_en : std_logic := '0';
	
	signal pixelheight_sig : unsigned(8 downto 0) := (others => '0');
	
	signal read_done : std_logic := '0';
	
	signal delay_clk : std_logic := '0';
	
begin

	addr <= fft_addr;
	en <= fft_en;

	process(fft_clk)
		variable pixel_height : unsigned(8 downto 0) := (others => '0');
	begin
	
		if(fft_clk'event and fft_clk = '1') then
			
			pixelheight_sig <= pixel_height;
		
			load_begin_dly <= load_begin;
		
			if(mag_done = '1') then
			
				if(load_begin = '1' or proc_begin = '1') then
					error <= '1';
				else
					error <= '0';	
				end if;
			
				load_begin <= '1';
				
				--setup first read
				fft_addr <= (0 => '1', others => '0');
				fft_en <= '1';
				read_enable <= '1';
				
			end if;
		
			if(read_enable = '1') then
			
				read_done <= '1';
			
				else
				
				read_done <= '0';
			
			end if;
		
			if(read_done = '1' and rect_done = '1') then
			
				screen_done <= '0';
			
				read_done <= '0';
				read_enable <= '0';
			
				--read done
				fft_en <= '0';
				
				--shift right 13 times, div 8192
				pixel_height := fft_data(13+8 downto 13);
				
				if(pixel_height > h320) then
					pixel_height := h320; --saturate
				end if;
				
				column_sta <= std_logic_vector(fft_addr);
				column_end <= std_logic_vector(fft_addr + 1);
				row_sta <= (others => '0');
				row_end <= std_logic_vector(pixel_height);
				pixel <= x"F800";
				
				rect_ready <= '1';
				delay_clk <= '1';
				
			end if;
			
			if(delay_clk = '1') then
			
				draw_color <= '1';
			
			end if;
			
			if(draw_color = '1') then
			
				rect_ready <= '0';
			
				if(rect_done = '1') then
				
					if(pixel_height = h320) then
					
						--don't draw blank_end
						draw_blank <= '0';
						
						rect_ready <= '0';
						
						if(fft_addr = check) then
						
							fft_addr <= (others => '0');
						
							screen_done <= '1';
							load_begin <= '0';
							read_enable <= '0';
							
							else
							
							read_enable <= '1';
							fft_en <= '1';
							fft_addr <= fft_addr + 1;
						
						end if;
						
					elsif(pixel_height = h320 - 1) then
					
						--draw one row of blank_end
						row_sta <= std_logic_vector(h320);
						row_end <= std_logic_vector(h320);
						
						draw_blank <= '1';
						pixel <= x"0000";
						
						rect_ready <= '1';
					
					else
					
						row_sta <= std_logic_vector(pixel_height + 1);
						row_end <= std_logic_vector(h320);
						draw_blank <= '1';
						pixel <= x"0000";
						
						rect_ready <= '1';
					
					end if;
					
					draw_color <= '0';
				
				end if;
			
			end if;
			
			if(draw_blank = '1') then
			
				rect_ready <= '0';
			
				if(rect_done = '1') then
				
					draw_blank <= '0';
				
					if(fft_addr = check) then
					
						fft_addr <= (others => '0');
					
						screen_done <= '1';
						load_begin <= '0';
						read_enable <= '0';
						
						else
						
						read_enable <= '1';
						fft_en <= '1';
						fft_addr <= fft_addr + 1;
					
					end if;
				
				end if;
			
			end if;
		
		end if;
	end process;

end str;
