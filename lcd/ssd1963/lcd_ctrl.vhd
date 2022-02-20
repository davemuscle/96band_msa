-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--lcd controller
--driver: SSD1963
--screen: 7inch sainsmart
--max freq: 
--dimensions: 800x480

--screen will be referenced in widescreen mode: 
--eg: --------------
--    |			   |   ^		(pins on this side)
--	  |0,0	       |  480
--    --------------   
--          800    >

use work.lcd_ctrl_pkg.all;

entity lcd_ctrl is
	generic(
		clock_rate : integer
		);
	port(
		
		clk : in std_logic;
		rst : in std_logic;
		
		--0(inclusive) to 800(exclusive)
		col_sta : in std_logic_vector(9 downto 0);
		col_end : in std_logic_vector(9 downto 0);
		
		--0(inclusive) to 480(exclusive)
		row_sta : in std_logic_vector(8 downto 0);
		row_end : in std_logic_vector(8 downto 0);
		
		pixel : in std_logic_vector(15 downto 0);
		pixel_strobe : out std_logic;
		
		valid : in std_logic;
		ready : out std_logic := '0';
		
		lcd_rst : out std_logic;
		
		lcd_wr  : out std_logic;
		lcd_cs  : out std_logic;
		lcd_rs  : out std_logic;
		lcd_db  : out std_logic_vector(15 downto 0)
		
        );
end lcd_ctrl;

architecture arch of lcd_ctrl is
   
   type state_type is (    fpga_reset,
						
						   hardware_reset,
						   
						   lcd_init_fetch,
						   lcd_init_decode,
						   lcd_init_setup,
						   lcd_init_hold,
						   lcd_init_done,
						   
						   lcd_clr_scrn_fetch,
						   lcd_clr_scrn_setup,
						   lcd_clr_scrn_hold,
						   
						   lcd_idle,
						   lcd_set_xy_fetch,
						   lcd_set_xy_setup,
						   lcd_set_xy_hold,
						   lcd_pixel_setup,
						   lcd_pixel_hold
                      );
                      
    signal state : state_type := fpga_reset;
	
	signal lcd_ctrl_set_xy_arr : lcd_ctrl_set_xy_arr_type := ( 0 =>  '0' & lcd_set_col,
															   5 =>  '0' & lcd_set_row,
															   10 => '0' & lcd_set_pix,
															   others => ( 8 => '1', others => '0'));

	signal lcd_set_xy_idx : integer range 0 to 10 := 0;


	--active high
	signal rst_buf : std_logic := '0';
	signal rst_sync : std_logic := '0';
	
	--rom signals
	signal rom_en : std_logic := '0';
	signal rom_out : std_logic_vector(17 downto 0) := (others => '0');
	signal rom_idx : integer range 0 to lcd_ctrl_rom_max := 0;

	--hardware reset
	signal hw_rst_done : std_logic := '0';
	signal hw_rst_stage : integer range 0 to 2 := 0;
	signal lcd_rst_int : std_logic := '0';
	
	signal hw_dly_en : std_logic := '0';
	signal hw_dly_en_dly : std_logic := '0';
	signal hw_dly_done  : std_logic := '0';
	signal hw_dly_ms   : integer := 0;
	
	signal hw_dly_max : integer := 0;
	signal hw_dly_cnt : integer := 0;

	--active low reset, pulse high->low->high
	--wait x 50 ms in between each
	constant rst_vec : std_logic_vector(2 downto 0) := "101";
	
	signal pixel_count : integer := 0;
	
	signal dly : std_Logic := '0';
	

begin



	--fsm
	process(clk)
		variable col_end_sub1 : std_logic_vector(9 downto 0);
		variable row_end_sub1 : std_logic_vector(8 downto 0);
	begin
		if(clk'event and clk = '1') then
			if(rst_sync = '1') then
				state <= fpga_reset;
			else
				case state is 
				when fpga_reset =>
					if(rst_sync = '0') then 
						state <= hardware_reset; 
						hw_rst_stage <= 0;
						hw_dly_en <= '0';
					end if;
				when hardware_reset =>

					pixel_strobe <= '0';


					lcd_wr <= '1';
					lcd_cs <= '1';
					lcd_rs <= '0';
					
					rom_idx <= 0;
					rom_en <= '0';

					--set reset value
					lcd_rst <= rst_vec(hw_rst_stage);
					
					--turn on delay
					hw_dly_en <= '1';
					hw_dly_ms <= 100;
					
					--if delay done, increment hw_rst_stage or go to lcd_init
					if(hw_dly_done = '1') then
						hw_dly_en <= '0';
						if(hw_rst_stage = 2) then
							state <= lcd_init_fetch;
														
							hw_rst_stage <= 0;
						else
							hw_rst_stage <= hw_rst_stage + 1;
						end if;
					end if;
					
				when lcd_init_fetch =>
				
					--fetch instruction from ROM
					rom_en <= '1';
					
					if(rom_en = '1') then
						rom_en <= '0';
						rom_idx <= rom_idx + 1;
						state <= lcd_init_decode;
					end if;
					
					
				when lcd_init_decode =>
					
					--look at what you grabbed from rom
					--if [16] = 0 then command
					--if [16] = 1 then data
					--if [17] = 1 then delay
					
					if(rom_out(17) = '1') then
					
						--run delay
						hw_dly_en <= '1';
						hw_dly_ms <= to_integer(unsigned(rom_out(15 downto 0)));
						
						--bring cs high while waiting
						lcd_cs <= '1';
						
						if(hw_dly_done = '1') then
							hw_dly_en <= '0';
							state <= lcd_init_fetch;
						end if;
					else
						state <= lcd_init_setup;
						if(rom_out(16) = '0') then
							--send command
							--bring cs high
							lcd_cs <= '1';
							
							--if EOT
							if(rom_out(15 downto 0) = x"FFFF") then
								
								state <= lcd_init_done;
								
							end if;
						else
							--send parameter
							--keep cs low
						end if;
						
					end if;
					
				when lcd_init_setup =>
				
					lcd_cs <= '0';
					lcd_db <= rom_out(15 downto 0);
					lcd_rs <= rom_out(16);
					lcd_wr <= '0';
					state <= lcd_init_hold;
					dly <= '0';
					
				when lcd_init_hold =>
				
					if(dly = '0') then
						dly <= '1';
					else
						lcd_wr <= '1';
						state <= lcd_init_fetch;
					end if;
		
				when lcd_init_done =>
				
					state <= lcd_idle;
					
				when lcd_idle =>
				
					ready <= '1';
					if(valid = '1') then
					
						--calculate column and row end minus one
						if(col_end = std_logic_vector(to_unsigned(0, 10))) then
							col_end_sub1 := (others => '0');
						else
							col_end_sub1 := std_logic_vector(unsigned(col_end) - 1);
						end if;
						if(row_end = std_logic_vector(to_unsigned(0, 9))) then
							row_end_sub1 := (others => '0');
						else
							row_end_sub1 := std_logic_vector(unsigned(row_end) - 1);
						end if;
					
						--sample the input parameters and put them into a little array
						ready <= '0';
						lcd_ctrl_set_xy_arr(1) <= '1' & "000000" & col_sta(9 downto 8);
						lcd_ctrl_set_xy_arr(2) <= '1' & col_sta(7 downto 0);
						lcd_ctrl_set_xy_arr(3) <= '1' & "000000" & col_end_sub1(9 downto 8);
						lcd_ctrl_set_xy_arr(4) <= '1' & col_end_sub1(7 downto 0);
						
						lcd_ctrl_set_xy_arr(6) <= '1' & "0000000" & row_sta(8 downto 8);
						lcd_ctrl_set_xy_arr(7) <= '1' & row_sta(7 downto 0);
						lcd_ctrl_set_xy_arr(8) <= '1' & "0000000" & row_end_sub1(8 downto 8);
						lcd_ctrl_set_xy_arr(9) <= '1' & row_end_sub1(7 downto 0);
						
						state <= lcd_set_xy_fetch;
						lcd_set_xy_idx <= 0;
						
						--calculate how many pixels we will send
						pixel_count <= to_integer(unsigned(col_end) - unsigned(col_sta)) *
									   to_integer(unsigned(row_end) - unsigned(row_sta));
						
					end if;
					
				when lcd_set_xy_fetch =>
				
					lcd_db(15 downto 8) <= (others => '0');
					lcd_db(7 downto 0)  <= lcd_ctrl_set_xy_arr(lcd_set_xy_idx)(7 downto 0);
					lcd_rs <= lcd_ctrl_set_xy_arr(lcd_set_xy_idx)(8);
					if(lcd_ctrl_set_xy_arr(lcd_set_xy_idx)(8) = '0') then
						--if instruction, bring cs high
						lcd_cs <= '1';
						
					end if;
					
					state <= lcd_set_xy_setup;

				when lcd_set_xy_setup =>
				
					lcd_cs <= '0';
					lcd_wr <= '0';
					state <= lcd_set_xy_hold;
					dly <= '0';
		
				when lcd_set_xy_hold =>
				

					lcd_wr <= '1';
					if(lcd_set_xy_idx < 10) then
						--if less than 10, increment and send next instruction for column/row
						lcd_set_xy_idx <= lcd_set_xy_idx + 1;
						state <= lcd_set_xy_fetch;
					else
						--start sending pixels
						state <= lcd_pixel_setup;
					end if;


				when lcd_pixel_setup =>
				
					--read pixel from input port and pull strobe high
					--this will let upstream driver know that pixel has been sampled
					lcd_db <= pixel;
					lcd_rs <= '1';
					lcd_cs <= '0';
					pixel_strobe <= '1';
					lcd_wr <= '0';
					state <= lcd_pixel_hold;

				when lcd_pixel_hold =>
				
					pixel_strobe <= '0';
					lcd_wr <= '1';
					
					--check if written the last pixel
					--the value should be pixel_count - 1, since at this point the value is zero

					pixel_count <= pixel_count - 1;

					if(pixel_count = 1) then
						ready <= '1';
						state <= lcd_idle;
						lcd_cs <= '1';
					else
						state <= lcd_pixel_setup;
					end if;
				when others =>
				
				end case;
			end if;
			
		
		end if;
	end process;

	--move rst to clock domain
	process(clk)
	begin
		if(clk'event and clk = '1') then
			rst_buf <= rst;
			rst_sync <= rst_buf;
		end if;
	end process;
	
	--delay block
	process(clk)
	begin
		if(clk'event and clk = '1') then
			hw_dly_en_dly <= hw_dly_en;
			hw_dly_done <= '0';
			if(hw_dly_en = '1' and hw_dly_en_dly = '0') then
				hw_dly_max <= clock_rate * hw_dly_ms / 1000; --convert to number of clocks for delay in ms
				hw_dly_cnt <= 0;
			elsif(hw_dly_en = '1') then
				if(hw_dly_cnt >= hw_dly_max) then
					hw_dly_cnt <= 0;
					hw_dly_done <= '1';
				else
					hw_dly_cnt <= hw_dly_cnt + 1;
				end if;
			end if;
			
		end if;
	end process;

	--rom reader, infers BRAM
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(rom_en = '1') then
				rom_out <= lcd_ctrl_rom(rom_idx);
			end if;
		end if;
	end process;



end arch;

 		