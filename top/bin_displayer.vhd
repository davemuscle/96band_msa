-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity bin_displayer is
	generic(
		binorder : integer
	);
	port(
		
	    clk : in std_logic;
		rst : in std_logic;
		
		mag_done : in std_logic;
		
		rect_valid : out std_logic;
		rect_ready : in std_logic;
		
		screen_done : out std_logic;
		
		addr : out unsigned(binorder-1 downto 0);
		en   : out std_logic;
		fft_data : in unsigned(31 downto 0);
		
		column_sta : out std_logic_vector(8 downto 0);
		column_end : out std_logic_vector(8 downto 0);
		row_sta : out std_logic_vector(8 downto 0);
		row_end : out std_logic_vector(8 downto 0);
		
		pixel : out std_logic_vector(15 downto 0)
		
        );
end bin_displayer;

architecture arch of bin_displayer is

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
	
	constant lcd_width : unsigned(8 downto 0) := "111100000"; --480 = 0x1E0
	constant lcd_height : unsigned(8 downto 0) := "101000000"; --320 = 0x140
    
	signal clk_dly : std_logic := '0';
	
	signal addr_int : unsigned(binorder-1 downto 0) := (others => '0');
	
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
						
						if(rect_ready = '0') then

							rect_valid <= '0';
						
							state <= wait_bin;
							clk_dly <= '0';
							
						end if;
					end if;
					
				when wait_bin =>
				
					screen_done <= '0';
					clk_dly <= '0';
					
					if(mag_done = '1') then
					
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
						state <= do_math;
					
					end if;
					
				when do_math =>
				
					en <= '0';
				
					--used to be 13+8 downto 13
					bin_height_v := fft_data(13+8 downto 13); --converts bin mag to pixels
					
					if(bin_height_v >= lcd_height) then
					
						bin_height <= lcd_height;
						blank_start <= (others => '0');
						blank_end <= (others => '0');
						
					else
						
						if(bin_height_v = zeros) then
								blank_start <= zeros;
								bin_height <= zeros;
							else
								blank_start <= bin_height;
								bin_height <= bin_height_v;
						end if;
						blank_end <= lcd_height;
					
					end if;
					
					state <= draw_color;
					
				when draw_color =>
				
					if(bin_height = zeros) then
					
						state <= draw_blank;
						
						else
						
						if(rect_ready = '1') then
						
							rect_valid <= '1';
							column_sta <= std_logic_vector(to_unsigned(to_integer(addr_int),9));
							column_end <= std_logic_vector(to_unsigned(to_integer(addr_int + 1),9));
							row_sta <= (others => '0');
							row_end <= std_logic_vector(bin_height);
							pixel <= x"F800";
							
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
							column_sta <= std_logic_vector(to_unsigned(to_integer(addr_int),9));
							column_end <= std_logic_vector(to_unsigned(to_integer(addr_int + 1),9));
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
						
							if(addr_int = to_unsigned(2**binorder - 1, binorder)) then
							
								state <= wait_bin;
								screen_done <= '1';
							
							else
							
								state <= get_bin;
							
							end if;
					
						end if;
					
					end if;
					
				when others =>
				end case;
					
			end if;
		
		
		
		end if;
	
	end process;



end arch;

 		