-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity cqt_bin_displayer is
	generic(
		binorder : integer;
		bins     : integer;
		colorLUTfile : string;
		bin_width : integer
	);
	port(
		
	    clk : in std_logic;
		rst : in std_logic;
		
		mag_done : in std_logic;
		
		color_offset : in integer;
		
		
		rect_valid : out std_logic;
		rect_ready : in std_logic;
		
		screen_done : out std_logic;
		
		addr : out unsigned(binorder-1 downto 0);
		en   : out std_logic;
		fft_data : in unsigned(31 downto 0);
		
		column_sta : out std_logic_vector(9 downto 0);
		column_end : out std_logic_vector(9 downto 0);
		row_sta : out std_logic_vector(8 downto 0);
		row_end : out std_logic_vector(8 downto 0);
		
		pixel : out std_logic_vector(15 downto 0)
		
        );
end cqt_bin_displayer;

architecture arch of cqt_bin_displayer is

   type state_type is (	   fpga_reset,
						   wait_init,
                           init,
                           wait_bin,
						   
                           draw_color,
                           draw_blank,
                           do_math,
						   get_bin 
        
                      );
                      
    signal state : state_type := fpga_reset;
	

	-- constant lcd_width : unsigned(9 downto 0) := "1100100000"; --800 = 0x320
	-- constant lcd_height : unsigned(8 downto 0) := "111100000"; --480 = 0x1E0
	constant lcd_width : unsigned(9 downto 0) := "1100011111"; --800 = 0x320
	constant lcd_height : unsigned(8 downto 0) := "111011111"; --480 = 0x1E0
	
	
	signal pixel_start : unsigned(9 downto 0) := (others => '0');
	
	signal clk_dly : std_logic := '0';
	
	signal addr_int : unsigned(binorder-1 downto 0) := (others => '0');
	
	signal bin_height : unsigned(8 downto 0) := (others => '0');
	signal blank_start : unsigned(8 downto 0) := (others => '0');
	signal blank_end : unsigned(8 downto 0) := (others => '0');
	signal zeros : unsigned(8 downto 0) := (others => '0');
	
	type pixel_array is array(0 to bins-1) of unsigned(8 downto 0);
	signal pixels : pixel_array := (others => (others => '0'));
	
	signal pixel_idx : integer := 0;
	
	signal div : integer := 0;
	
    type ram_type is array ((bins)-1 downto 0) of bit_vector(15 downto 0);
	
	impure function ram_init(filename : string) return ram_type is
	  file ram_file : text open read_mode is filename;
	  variable ram_line : line;
	  variable ram_value : bit_vector(15 downto 0);
	  variable temp : ram_type;
	begin
	  for ram_index in 0 to bins - 1 loop
		readline(ram_file, ram_line);
		read(ram_line, ram_value);
		temp(ram_index) := (ram_value);
	  end loop;
	  return temp;
	end function;
	
	shared variable colorLUT : ram_type := ram_init(filename => colorLUTfile);

	signal color_read_en : std_logic := '0';
	signal color_read_addr : unsigned(binorder - 1 downto 0) := (others => '0');
	signal color_read_data : std_logic_vector(15 downto 0) := (others => '0');
	
	signal color_read_addr_offset : unsigned(binorder-1 downto 0) := (others => '0');

begin

	addr <= addr_int;

	process(color_read_addr, color_offset)
	begin
		
		--add the offset to the color address, take modulo
		
		color_read_addr_offset <= to_unsigned((((to_integer(color_read_addr)) + color_offset) mod bins),  binorder);
		
	end process;

	process(clk)
		variable bin_height_v : unsigned(31 downto 0) := (others => '0');
		variable bin_height_v_int : integer := 0;
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
						
						if(rect_ready = '0') then

							rect_valid <= '0';
						
							state <= wait_bin;
							clk_dly <= '0';
							
						end if;
					end if;
					
				when wait_bin =>
				
					screen_done <= '0';
					clk_dly <= '0';
					
					pixel_start <= (0 => '1', others => '0');
					
					if(mag_done = '1') then
					
						pixel_idx <= 0;
						
						en <= '0';
						addr_int <= (others => '0');
						state <= get_bin;
					
					end if;
		
				when get_bin =>
					
					--get bin
					--get color value
					
					if(clk_dly <= '0') then
					
						en <= '1';
						--addr_int <= addr_int + 1; --starts at 1
						clk_dly <= '1';
						
						color_read_en <= '1';
						
						else
						
						color_read_en <= '0';
						
						clk_dly <= '0';
						en <= '0';
						state <= do_math;
					
					end if;
					
				when do_math =>
				
					en <= '0';
				
					pixel_idx <= pixel_idx + 1;
				
					--used to be 12+8 downto 12 for low freq max
					--bin_height_v := fft_data(11+8 downto 11); --converts bin mag to pixels
					--bin_height_v := fft_data(12+8 downto 12);

					--give this divide more clock cycles
					bin_height_v_int := to_integer(fft_data) / 256;
							
					if(bin_height_v_int >= to_integer(lcd_height)) then
					
						--rise pixels towards top of screen
						if(pixels(pixel_idx) >= to_integer(lcd_height) - 64) then
						
							pixels(pixel_idx) <= lcd_height;
							blank_start <= (others => '0');
							blank_end <= (others => '0');
							bin_height <= lcd_height;
							
						else
							
							pixels(pixel_idx) <= pixels(pixel_idx) + 64;
							blank_start <= pixels(pixel_idx) + 64;
							blank_end <= lcd_height;
							bin_height <= pixels(pixel_idx) + 64;
							
						end if;
						
					elsif(bin_height_v_int >= to_integer(pixels(pixel_idx))) then
						
						if(bin_height_v_int <= 64) then
						
							--small value, just rise to bin
							pixels(pixel_idx) <= to_unsigned(bin_height_v_int, 9);
							blank_start <=  to_unsigned(bin_height_v_int, 9);
							blank_end <= lcd_height;
							bin_height <=  to_unsigned(bin_height_v_int, 9);
							
						elsif(pixels(pixel_idx) >= to_unsigned(bin_height_v_int - 64,9)) then
						
							--rise to bin height
							pixels(pixel_idx) <= to_unsigned(bin_height_v_int, 9);
							pixels(pixel_idx) <= to_unsigned(bin_height_v_int, 9);
							blank_start <=  to_unsigned(bin_height_v_int, 9);
							blank_end <= lcd_height;
							bin_height <=  to_unsigned(bin_height_v_int, 9);
						
						else
						
							--rise toward bin height
							pixels(pixel_idx) <= pixels(pixel_idx) + 64;
							blank_start <= pixels(pixel_idx) + 64;
							blank_end <= lcd_height;
							bin_height <= pixels(pixel_idx) + 64;
							
						end if;
						
					else
						
							--decay
							blank_start <= pixels(pixel_idx);
							bin_height <= pixels(pixel_idx);
							
							if(pixels(pixel_idx) > 10) then
								pixels(pixel_idx) <= pixels(pixel_idx) - 10;
							else
								pixels(pixel_idx) <= (others => '0');
							end if;
						
						--end if;
								

						blank_end <= lcd_height;
					
					end if;
					
					-- if(bin_height_v_int >= to_integer(lcd_height)) then
					
						-- bin_height <= lcd_height;
						-- blank_start <= (others => '0');
						-- blank_end <= (others => '0');
						
					-- else
						
						-- if(bin_height_v_int = 0) then
								-- blank_start <= zeros;
								-- bin_height <= zeros;
							-- else
								-- blank_start <= to_unsigned(bin_height_v_int, 9);
								-- bin_height <= to_unsigned(bin_height_v_int, 9);
						-- end if;
						-- blank_end <= lcd_height;
					
					-- end if;
					
					state <= draw_color;
					
				when draw_color =>
				
					if(bin_height = zeros) then
					
						state <= draw_blank;
						
						else
						
						if(rect_ready = '1') then
						
							rect_valid <= '1';
							column_sta <= std_logic_vector(pixel_start);
							column_end <= std_logic_vector(pixel_start + to_unsigned(bin_width, 10));
							row_sta <= (others => '0');
							row_end <= std_logic_vector(bin_height);
							pixel <= color_read_data;
							
							clk_dly <= '1';
						
						end if;
						
					end if;
					
					if(clk_dly = '1') then
						
						if(rect_ready = '0') then
							rect_valid <= '0';
							clk_dly <= '0';
							state <= draw_blank;
						end if;

						
					end if;
					
				when draw_blank =>
				
					if((blank_start = zeros) and (blank_end = zeros)) then
					
						--skip blank
						clk_dly <= '1';
						
						else
						
						if(rect_ready = '1') then
						
							rect_valid <= '1';
							column_sta <= std_logic_vector(pixel_start);
							column_end <= std_logic_vector(pixel_start + to_unsigned(bin_width, 10));
							row_sta <= std_logic_vector(blank_start);
							row_end <= std_logic_vector(blank_end);
							pixel <= x"0000";
							
							clk_dly <= '1';
							
						end if;
					
					end if;
					
					if(clk_dly = '1') then
					
						if(rect_ready = '0') then
					
							rect_valid <= '0';
							clk_dly <= '0';
						
							if(addr_int = to_unsigned(bins-1, binorder)) then
							
								state <= wait_bin;
								screen_done <= '1';
								
								addr_int <= (others => '0');
							
							else
							
								addr_int <= addr_int + 1;
							
								state <= get_bin;
								
								pixel_start <= pixel_start + to_unsigned(bin_width + 1, 10);
								
							
							end if;
					
						end if;
					
					end if;
					
				when others =>
				end case;
					
			end if;
		
		
		
		end if;
	
	end process;

	--todo: change back for multiple colors
	--color_read_addr <= addr_int;
	color_read_addr <= (others => '0');

	color_reader : process(clk)
	begin
	
		if(clk'event and clk = '1') then
		
			if(color_read_en = '1') then
				color_read_data <= to_StdLogicVector(colorLUT(to_integer(color_read_addr_offset(binorder-1 downto 0))));
			end if;
		
		end if;
	
	end process;
	

end arch;

 		