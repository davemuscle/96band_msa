-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--lcd controller to turn on ILI9486 and draw rectangles

--column_end = 320, row_end = 480 (exclusive)        
--if want to fill screen: 
--column_sta = row_sta = 0 (inclusive)

entity lcd_ctrl is
	port(
		
		clk : in std_logic;
		rst : in std_logic;
		
		
		column_sta : in std_logic_vector(8 downto 0);
		column_end : in std_logic_vector(8 downto 0);
		row_sta : in std_logic_vector(8 downto 0);
		row_end : in std_logic_vector(8 downto 0);
		
		pixel : in std_logic_vector(15 downto 0);
		
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

    type controller_state is (fpga_reset, lcd_reset, lcd_sleepout, lcd_init, lcd_predraw, lcd_draw);
   -- signal state : controller_state;
   
   type new_state_type is (fpga_reset,

                           lcd_reset,
                           
                           lcd_init_fetch,
                           lcd_init_setup,
                           lcd_init_hold,
            
                           lcd_draw_ready,
						   lcd_draw_proc,
                           lcd_draw_dim_fetch,
                           lcd_draw_dim_setup,
                           lcd_draw_dim_hold,
 
                           lcd_draw_pixel_command_setup,
                           lcd_draw_pixel_command_hold,
                           lcd_draw_pixel_setup,
                           lcd_draw_pixel_hold
                      );
                      
    signal state : new_state_type := fpga_reset;
    
    signal delay_num_clocks : integer := 0;
    
	signal pixel_reg : std_logic_vector(15 downto 0) := (others => '0');
	signal column_sta_reg : std_logic_vector(8 downto 0) := (others => '0');
	signal column_end_reg : std_logic_vector(8 downto 0) := (others => '0');
	signal row_sta_reg    : std_logic_vector(8 downto 0) := (others => '0');
	signal row_end_reg    : std_logic_vector(8 downto 0) := (others => '0');
	signal column_size : integer := 0;
	signal row_size : integer := 0;
	signal pixel_count : integer := 0;
  

    constant clk_cnt_50ms : integer := 2000000; --keep at 150000 for 1.5M input clk
    --constant clk_cnt_50ms : integer := 20; --comment this in for testbench


    
    constant rom_max : integer := 59;
    signal rom_idx : integer range 0 to rom_max-1;
    
    type rom_array is array(0 to rom_max-1) of std_logic_vector(16 downto 0);
	signal rom_en : std_logic := '0';
	signal rom_out : std_logic_vector(16 downto 0) := (others => '0');
	
	signal init_done : std_logic := '0';
    signal cs_gate : std_logic := '0';
	signal lcd_cs_t : std_logic := '0';
	signal cs_force : std_logic := '0';
	
	signal lcd_db_t : std_logic_vector(15 downto 0) := (others => '0');
	
    constant ROM : rom_array := 
        (
             "0" & x"0000", --nops
   			 "0" & x"0011", --sleep out          
             "0" & x"0028", --display off
             
             "0" & x"00C0", --power1
             "1" & x"000D",
             "1" & x"000D",
             
             "0" & x"00C1", --power2
             "1" & x"0043",
             "0" & x"00C2", --power3
             "1" & x"0000",
             
             "0" & x"00C5", --vcom control
             "1" & x"0000",
             "1" & x"0048",

             "0" & x"00B6", --display control
             "1" & x"0000",
             "1" & x"0022", --was 0x22
             "1" & x"003B",
             
             "0" & x"00E0", --positive gamma control
             "1" & x"000F",
             "1" & x"0024",
             "1" & x"001C",
             "1" & x"000A",
             "1" & x"000F",
             "1" & x"0008",
             "1" & x"0043",
             "1" & x"0088",
             "1" & x"0032",
             "1" & x"000F",
             "1" & x"0010",
             "1" & x"0006",
             "1" & x"000F",
             "1" & x"0007",
             "1" & x"0000",
             
             "0" & x"00E1", --negative gamma control
             "1" & x"000F",
             "1" & x"0038",
             "1" & x"0030",
             "1" & x"0009",
             "1" & x"000F",
             "1" & x"000F",
             "1" & x"004E",
             "1" & x"0077",
             "1" & x"003C",
             "1" & x"0007",
             "1" & x"0010",
             "1" & x"0005",
             "1" & x"0023",
             "1" & x"001B",
             "1" & x"0000",
             
             
             "0" & x"0020", --display inversion off
             
             "0" & x"00B1", --framerate control
             "1" & x"00C0", --81 Hz = C, default = A (70 Hz)
             "1" & x"0011", --default
             
             "0" & x"0036", --memory access control (RGB ordering)
             "1" & x"00EA", --0xAA for old lcd ctrl, 0x0A for new

             "0" & x"003A", --pixel format
             "1" & x"0055",       
             
             "0" & x"0029", --display on
             

             
             "0" & x"FFFF"
             );  
begin

	--rom process
	process(clk)
	begin
	
		if(clk'event and clk = '1') then
		
			if(rom_en = '1') then
			
				rom_out <= ROM(rom_idx);
			
			end if;
		
		end if;
	
	end process;

	lcd_wr <= clk;
	lcd_cs_t <= clk and cs_gate;
	lcd_cs <= lcd_cs_t or cs_force;

	process(clk)
	begin
	
		if(clk'event and clk = '0') then
		
			lcd_db <= lcd_db_t;
			
		end if;
	
	end process;

    --main fsm process
    process(clk)
        variable rom_out_v : std_logic_vector(16 downto 0);
        variable ram_out_v : std_logic_vector(8 downto 0);
        variable pixel_cnt : integer := 0;
		variable col_size : integer := 0;
		variable row_size : integer := 0;
        variable column_end_sub1_v : std_logic_vector(8 downto 0);
        variable row_end_sub1_v : std_logic_vector(8 downto 0);
    begin
    
        if(clk'event and clk = '1') then
        
            if(rst = '1') then
            
                state <= fpga_reset;
            
            else
            
                case state is
                when fpga_reset =>
            
                    ready <= '0';
                    rom_idx <= 0;
                    lcd_rst <= '1';
                    --lcd_cs <= '1';
                    lcd_rs <= '0';
                    lcd_db_t <= (others => '0');
					cs_force <= '1';
                
                    if(rst = '1') then
                        state <= fpga_reset;
                    else
                        state <= lcd_reset;
						delay_num_clocks <= 0;
                    end if;
                
                when lcd_reset =>
               
					cs_force <= '1';
					delay_num_clocks <= delay_num_clocks + 1;
					
					case delay_num_clocks is
						when 0 => 
							lcd_rst <= '1';
						when clk_cnt_50ms =>
							lcd_rst <= '0';
						when 2*clk_cnt_50ms =>
							lcd_rst <= '1';
						when 3*clk_cnt_50ms =>
							rom_idx <= 0;
							rom_en <= '1';
						when (3*clk_cnt_50ms) + 1 =>
							state <= lcd_init_fetch;
						when others =>
					end case;
        
                when lcd_init_fetch =>
					
					cs_force <= '0';
				
					--rom has been read from, data is in rom_out
				
					--lcd_cs <= '0'; --testing keeping cs low for full init
					
					--check if EOT
					if(rom_idx = rom_max-1) then
					
						--last write, next clock throw cs high and switch states
						rom_en <= '0';

						lcd_rs <= rom_out(16);
						lcd_db_t <= rom_out(15 downto 0);

						rom_idx <= 0;
						init_done <= '1';

						
						else
						
						--output on bus
						lcd_rs <= rom_out(16);
						lcd_db_t <= rom_out(15 downto 0);
						rom_idx <= rom_idx + 1;
					
					end if;
                    
					if(rom_out(16) = '0') then
						cs_gate <= '1';
						else
						cs_gate <= '0';
					end if;
					
					if(init_done = '1') then
					
						state <= lcd_draw_ready;
						--lcd_cs <= '1';
						lcd_db_t <= (others => '0');
						lcd_rs <= '0';
						init_done <= '0';
					
					end if;
					
                when lcd_draw_ready =>

					cs_force <= '1';
					
					--if valid signal is true in this state:
					--sample the pixel, column, and row data on the inputs
					--start process of sending out rectangle
					if(valid = '1') then
				
						pixel_reg <= pixel;
						pixel_count <= to_integer(unsigned(column_end) - unsigned(column_sta)) * 
									   to_integer(unsigned(row_end) - unsigned(row_sta));
						column_sta_reg <= column_sta;
						column_end_reg <= std_logic_vector(unsigned(column_end) - 1);
						row_sta_reg <= row_sta;
						row_end_reg <= std_logic_vector(unsigned(row_end) - 1);
						
						state <= lcd_draw_proc;
						delay_num_clocks <= 0;

						ready <= '0';
						
					else
						
						ready <= '1';
				
					end if;

				when lcd_draw_proc =>
				
					cs_force <= '0';
				
					delay_num_clocks <= delay_num_clocks + 1;
					cs_gate <= '0';
					
					case delay_num_clocks is
						when 0 =>
							lcd_rs <= '0';
							--lcd_cs <= '0';
							lcd_db_t <= x"002A"; --column command
							cs_gate <= '1';
						when 1 =>
							lcd_rs <= '1';
							lcd_db_t <= (0 => column_sta_reg(8), others => '0');
						when 2 =>
							lcd_db_t(15 downto 8) <= (others => '0');
							lcd_db_t(7 downto  0) <= column_sta_reg(7 downto 0);
						when 3 =>
							lcd_db_t <= (0 => column_end_reg(8), others => '0');
						when 4 =>
							lcd_db_t(15 downto 8) <= (others => '0');
							lcd_db_t(7 downto  0) <= column_end_reg(7 downto 0);
						when 5 =>
							lcd_rs <= '0';
							lcd_db_t <= x"002B"; --column command
							cs_gate <= '1';
						when 6 =>
							lcd_rs <= '1';
							lcd_db_t <= (0 => row_sta_reg(8), others => '0');
						when 7 =>
							lcd_db_t(15 downto 8) <= (others => '0');
							lcd_db_t(7 downto  0) <= row_sta_reg(7 downto 0);
						when 8 =>
							lcd_db_t <= (0 => row_end_reg(8), others => '0');
						when 9 =>
							lcd_db_t(15 downto 8) <= (others => '0');
							lcd_db_t(7 downto  0) <= row_end_reg(7 downto 0);
						when 10 =>
							lcd_rs <= '0';
							lcd_db_t <= x"002C"; --memory write
							cs_gate <= '1';
						when others =>
							lcd_db_t <= pixel_reg;
							lcd_rs <= '1';
							if(pixel_count = 0) then
								--done
								--lcd_cs <= '1';
								cs_force <= '1';
								ready <= '1';
								state <= lcd_draw_ready;
								
							else
							
								pixel_count <= pixel_count - 1;
								
							end if;
						end case;	

            
				when others =>
				end case;
                
            
            end if;
        
        
		end if;
        
	end process;

end arch;

 		