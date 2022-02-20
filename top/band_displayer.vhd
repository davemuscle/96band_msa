-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity band_displayer is
	port(
		
	    clk : in std_logic;
		rst : in std_logic;
		
		mag_done : in std_logic;
		
		rect_valid : out std_logic;
		rect_ready : in std_logic;
		
		screen_done : out std_logic;
		
		addr : out unsigned(8 downto 0);
		en   : out std_logic;
		fft_data : in unsigned(31 downto 0);
		
		column_sta : out std_logic_vector(8 downto 0);
		column_end : out std_logic_vector(8 downto 0);
		row_sta : out std_logic_vector(8 downto 0);
		row_end : out std_logic_vector(8 downto 0);
		
		pixel : out std_logic_vector(15 downto 0)
		
        );
end band_displayer;

architecture arch of band_displayer is

   type state_type is (	   fpga_reset,
						   wait_init,
                           init,
                           wait_bin,
						   
                           draw_color,
                           draw_blank,
                           do_math,
						   do_avg,
						   get_bandval,
						   get_bin 
        
                      );
                      
    signal state : state_type := fpga_reset;
	
	type band_type is (		bass,
							lows,
							mids,
							highs,
							brilpres,
							done
					  );
					  
    signal band : band_type := bass;

	constant band_width_pixels : integer := 6;
	constant band_empty_pixels : integer := 1;
	signal band_pixel_start : unsigned(8 downto 0) := (others => '0');

	signal band_count : integer := 0;
	signal band_numbins : integer := 0;
	signal band_val : unsigned(31 downto 0) := (others => '0');

	constant lcd_width : unsigned(8 downto 0) := "111100000"; --480 = 0x1E0
	constant lcd_height : unsigned(8 downto 0) := "101000000"; --320 = 0x140
    
	signal clk_dly : std_logic := '0';
	
	signal addr_int : unsigned(8 downto 0) := (others => '0');
	
	signal bin_height : unsigned(8 downto 0) := (others => '0');
	signal blank_start : unsigned(8 downto 0) := (others => '0');
	signal blank_end : unsigned(8 downto 0) := (others => '0');
	signal zeros : unsigned(8 downto 0) := (others => '0');

begin

	addr <= addr_int;

	process(clk)
		variable bin_height_v : unsigned(8 downto 0) := (others => '0');
	begin
	
		if(clk'event and clk = '1') then
		
			if(rst = '1') then
			
				state <= fpga_reset;
			
			else
			
				case state is 
				when fpga_reset =>
					rect_valid <= '0';
					screen_done <= '0';
					clk_dly <= '0';
					addr_int <= (others => '0');
					en <= '0';
					column_sta <= (others => '0');
					row_sta <= (others => '0');
					column_end <= (others => '0');
					row_end <= (others => '0');
					pixel <= (others => '0');
					
					if(rst = '0') then
						state <= init;
					end if;
					
				when init =>
				
					if(rect_ready = '1') then
					
						rect_valid <= '1';
						pixel <= (others => '0');
						column_sta <= (others => '0');
						row_sta <= (others => '0');
						column_end <= std_logic_vector(lcd_width);
						row_end <= std_logic_vector(lcd_height);
					
						clk_dly <= '1';
					
					end if;
					
					if(clk_dly = '1') then
					
						rect_valid <= '0';
					
						state <= wait_bin;
						clk_dly <= '0';
					
					end if;
					
				when wait_bin =>
				
					screen_done <= '0';
					clk_dly <= '0';
					
					band_pixel_start <= (0 => '1', others => '0');
					
					band <= bass;
					band_count <= 0;
					band_numbins <= 0;
					band_val <= (others => '0'); --reset accumulator
					
					if(mag_done = '1' and rect_ready = '1') then
					
						en <= '0';
						addr_int <= (others => '0');
						state <= get_bin;
					
					end if;
		
				when get_bin =>
					
					if(clk_dly <= '0') then
					
						en <= '1';
						addr_int <= addr_int + 1; --starts at 1
						clk_dly <= '1';
						
						else
						
						clk_dly <= '0';
						en <= '0';
						state <= do_math; --todo: change back?
					
					end if;
					
				when get_bandval =>
				
					band_val <= band_val + fft_data;
					state <= do_avg;
					
				when do_avg =>
		
					band_numbins <= band_numbins + 1;
					state <= get_bin;
					
					--shift and add, check if done with band
					
					case band is
					when bass =>
						if(band_numbins = (2 - 1)) then
						
							band_numbins <= 0;
							state <= do_math;
							
							band_val <= '0' & band_val(31 downto 1);
							--divide by 2
							--band_val <= band_val + ('0' & fft_data(31 downto 1));
						
						end if;
					
					when lows =>
					
						state <= do_math;
						--no division
						band_val <= fft_data;
						
					when mids =>
					
						if(band_numbins = (4 - 1)) then
						
							band_numbins <= 0;
							state <= do_math;
							--divide by 4 
							band_val <= "00" & band_val(31 downto 2);
							--band_val <= band_val + ("00" & fft_data(31 downto 2));
						
						end if;
					
					when highs => 
					
						if(band_numbins = (8 - 1)) then
						
							band_numbins <= 0;
							state <= do_math;
							--divide by 8 
							band_val <= "000" & band_val(31 downto 3);
							--band_val <= band_val + ("000" & fft_data(31 downto 3));
						
						end if;
					
					when brilpres =>
					
						if(band_numbins = (64 - 1)) then
						
							band_numbins <= 0;
							state <= do_math;
							--divide by 64
							band_val <= "000000" & band_val(31 downto 6);
							--todo: Fix me (might blow up)
							--band_val <= band_val + ("000000" & fft_data(31 downto 6));
						
						end if;
					
					when others =>
					end case;
				

					
				when do_math =>
				
					en <= '0';
				
					--used to be 13+8 downto 13
					bin_height_v := fft_data(11+8 downto 11); --converts bin mag to pixels
					
					if(bin_height_v >= lcd_height) then
					
						bin_height <= lcd_height;
						blank_start <= (others => '0');
						blank_end <= (others => '0');
						
					elsif(bin_height_v = zeros) then
						blank_start <= zeros;
						bin_height <= zeros;
					else
						--decay
						blank_start <= bin_height;
						bin_height <= bin_height_v;
							
					end if;
					
					blank_end <= lcd_height;

					
					state <= draw_color;
					
					band_count <= band_count + 1;
				
					--band counting
					case band is
					when bass =>
					
						if(band_count = (2 - 1)) then
							
							band_count <= 0;
							band_numbins <= 0;
							band <= lows;
						
						end if;
						
					when lows =>
					
						if(band_count = (32 - 1)) then
						
							band_count <= 0;
							band_numbins <= 0;
							band <= mids;
							
						end if;
						
					when mids =>
					
					
						if(band_count = (16 - 1)) then
						
							band_count <= 0;
							band_numbins <= 0;
							band <= highs;
							
						end if;
							
					when highs =>
					
						if(band_count = (6 - 1)) then
						
							band_count <= 0;
							band_numbins <= 0;
							band <= brilpres;
						
						end if;
					
					when brilpres =>
					
						if(band_count = (4 - 1)) then
						
							band_count <= 0;
							band_numbins <= 0;
							band <= done;
						
						end if;
					
					when others =>
					end case;
					
				when draw_color =>
				

				
					if(bin_height = zeros) then
					
						state <= draw_blank;
						
						else
						
						if(rect_ready = '1') then
						
							rect_valid <= '1';
							column_sta <= std_logic_vector(band_pixel_start);
							column_end <= std_logic_vector(band_pixel_start + to_unsigned(4,9));
							row_sta <= (others => '0');
							row_end <= std_logic_vector(bin_height);
							pixel <= x"F800";
							
							clk_dly <= '1';
						
						end if;
						
					end if;
					
					if(clk_dly = '1') then
						
						rect_valid <= '0';
						clk_dly <= '0';
						state <= draw_blank;
						
					end if;
					
				when draw_blank =>
				
					if((blank_start = zeros) and (blank_end = zeros)) then
					
						--skip blank
						clk_dly <= '1';
						
						else
						
						if(rect_ready = '1') then
						
							rect_valid <= '1';
							column_sta <= std_logic_vector(band_pixel_start);
							column_end <= std_logic_vector(band_pixel_start + to_unsigned(4,9));
							row_sta <= std_logic_vector(blank_start);
							row_end <= std_logic_vector(blank_end);
							pixel <= x"0000";
							
							clk_dly <= '1';
							
						end if;
					
					end if;
					
					if(clk_dly = '1') then
					
						rect_valid <= '0';
						clk_dly <= '0';
						band_val <= (others => '0'); --reset accumulator
						
						if(addr_int = to_unsigned(81, 9)) then
						
							screen_done <= '1';
							state <= wait_bin;
							
							else
							
							band_pixel_start <= band_pixel_start + to_unsigned(4 + 2, 9);
							state <= get_bin;
						
						end if;
						
						
						-- if(band = done) then
						
							-- state <= wait_bin;
							-- screen_done <= '1';
						
						-- else
						
							-- band_pixel_start <= band_pixel_start + to_unsigned(band_width_pixels + 2, 9);
							-- state <= get_bin;
						
						-- end if;
					
					end if;
					
				when others =>
				end case;
					
			end if;
		
		
		
		end if;
	
	end process;



end arch;

 		