-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--draw different boxes on the screen, make sure generic lcd works as expected


entity lcd_demo is
	port(
		clk : in std_logic;
		
		tick : in std_logic;
		
		col_sta : out std_logic_vector(9 downto 0);
		col_end : out std_logic_vector(9 downto 0);
		row_sta : out std_logic_vector(8 downto 0);
		row_end : out std_logic_vector(8 downto 0);
		
		pixel   : out std_logic_vector(15 downto 0);
		pixel_strobe : in std_logic;
		
		valid : out std_logic;
		ready : in std_logic

        );
end lcd_demo;

architecture str of lcd_demo is 

	type state_type is ( idle, getbox, updateloc, drawbox, erasebox);
	signal state : state_type := idle;
	
    constant lcd_width : integer := 800;
	constant lcd_height : integer := 480;
	
	constant box_dimension : integer := 128;
	
	signal tick_dly : std_logic := '0';
	
	--box corner, starts at 40,40 on screen (near bottom left)
	signal box_sw_x : integer := 40;
	signal box_sw_y : integer := 40;
	
	--0 for left, 1 for right
	--0 for down, 1 for up
	signal x_dir : std_logic := '0';
	signal y_dir : std_logic := '0';
	
	
	signal lfsr : std_logic_vector(7 downto 0) := x"BA";
	
	signal box_col_sta : unsigned(9 downto 0) := to_unsigned(40, 10);
	signal box_col_end : unsigned(9 downto 0) := (others => '0');
	signal box_row_sta : unsigned(8 downto 0) := to_unsigned(40, 9);
	signal box_row_end : unsigned(8 downto 0) := (others => '0');
	
	
	
	constant col_zeros : unsigned(9 downto 0) := (others => '0');
	constant row_zeros : unsigned(8 downto 0) := (others => '0');
	constant col_limit : unsigned(9 downto 0) := to_unsigned(lcd_width - box_dimension, 10);
	constant row_limit : unsigned(8 downto 0) := to_unsigned(lcd_height - box_dimension, 9);

	signal dly : std_logic := '0';
	signal ready_dly : std_logic := '0';
	
begin

	process(clk)
	begin
		if(clk'event and clk = '1') then
			
			valid <= '0';
			dly <= '0';
			
			ready_dly <= ready;
			
			--delay tick
			tick_dly <= tick;
			
			--lfsr
			lfsr(7 downto 1) <= lfsr(6 downto 0);
			lfsr(0) <= lfsr(7) xor lfsr(6) xor lfsr(5) xor lfsr(4) xor lfsr(3);
			
			case state is
			when idle =>
				
				valid <= '0';
			
				--look for rising edge of tick
				if(tick = '1' and tick_dly = '0' and ready = '1') then
					state <= getbox;
				end if;
			when getbox =>
				
				--check if box is in bottom left corner of screen
				if(box_sw_x = 0 and box_sw_y = 0) then
					
					x_dir <= lfsr(0);
					y_dir <= lfsr(1);
					
				--check if box is in top left corner
				elsif(box_sw_x = 0 and box_sw_y = to_integer(row_limit)) then
				
				
					x_dir <= lfsr(0);
					y_dir <= lfsr(1);
					
					
				--check if box is in bottom right corner
				elsif(box_sw_x = to_integer(col_limit) and box_sw_y = 0) then
				
					x_dir <= lfsr(0);
					y_dir <= lfsr(1);
				
				--check if box is in top right corner
				elsif(box_sw_x =  to_integer(col_limit) and box_sw_y = to_integer(row_limit)) then
					
					x_dir <= lfsr(0);
					y_dir <= lfsr(1);
					
				end if;
				
				state <= updateloc;
				


				
			when updateloc =>
				--update box location, if in a corner do not move past screen
				if(x_dir = '0' and box_col_sta /= col_zeros) then
					box_col_sta <= box_col_sta - 1;
					box_sw_x <= box_sw_x - 1;
				elsif(x_dir = '1' and box_col_sta < col_limit) then
					box_col_sta <= box_col_sta + 1;
					box_sw_x <= box_sw_x + 1;
				end if;
				
				if(y_dir = '0' and box_row_sta /= row_zeros) then
					box_row_sta <= box_row_sta - 1;
					box_sw_y <= box_sw_y - 1;
				elsif(x_dir = '1' and box_row_sta < row_limit) then
					box_row_sta <= box_row_sta + 1;
					box_sw_y <= box_sw_y + 1;
				end if;
			
				state <= erasebox;
				
				
				pixel <= x"0000";
				
				col_sta <= std_logic_vector(box_col_sta);
				col_end <= std_logic_vector(box_col_sta + box_dimension);
				
				row_sta <= std_logic_vector(box_row_sta);
				row_end <= std_logic_vector(box_row_sta + box_dimension);
					
				valid <= '1';
				
			when erasebox =>
				
				if(ready = '1' and ready_dly = '0') then
					state <= drawbox;
					valid <= '1';
					pixel <= x"F800";
					col_sta <= std_logic_vector(box_col_sta);
					col_end <= std_logic_vector(box_col_sta + box_dimension);
					
					row_sta <= std_logic_vector(box_row_sta);
					row_end <= std_logic_vector(box_row_sta + box_dimension);
				end if;
			
			when drawbox =>
			
				if(ready = '1' and ready_dly = '0') then
					state <= idle;
				end if;
			
			when others =>
			end case;
			
			
		end if;
	end process;
	

end str;