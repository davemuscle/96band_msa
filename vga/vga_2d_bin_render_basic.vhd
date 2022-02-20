-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use std.textio.all;
--render fft bins on screen over vga
--basic denotes only using red color for bins
--a more advanced module will be built upon when this works

--inputs: 
	--blanking period signal
	--pixel clock
	--bin data
--outputs:
	--color


--rising edge of blanking period: (inactive period)
	--load bin data into renderer

--falling edge of blanking period: (active period)
	--start outputting pixels

use work.vga_timing_gen_pkg.all;

entity vga_2d_bin_render_basic is
	generic(
		order : integer := 7;
		numbins : integer := 96
	);
	port(
		--pixel clock
		clk : in std_logic;
		
		--input timing information
		hblank : in std_logic;
		vblank : in std_logic;
		hsync : in std_logic;
		vsync : in std_logic;
		
		--input bin data
		valid : in std_logic;
		en_o : out std_logic;
		addr_o : out unsigned(order-1 downto 0);
		data_i : in unsigned(31 downto 0);
		
		--input color map
		color_read_map_sel : in unsigned(3 downto 0);
		
		--output color
		red : out std_logic_vector(3 downto 0);
		grn : out std_logic_vector(3 downto 0);
		blu : out std_logic_vector(3 downto 0);
		
		--output timing information
		vsync_dly : out std_logic;
		hsync_dly : out std_logic

        );
end vga_2d_bin_render_basic;

architecture str of vga_2d_bin_render_basic is 

	
	constant bin_total_width : integer := h_active / numbins; --number of pixels per band
	constant spacing : integer := 1; --number of blank pixels between bands, blanks to the right of bin
	constant bin_width : integer := bin_total_width - spacing; --number of colored width pixels
	
	
	signal red_prc : std_logic_vector(3 downto 0) := (others => '0');
	signal grn_prc : std_logic_vector(3 downto 0) := (others => '0');
	signal blu_prc : std_logic_vector(3 downto 0) := (others => '0');
	
	signal vblank_dly : std_logic := '0';
	signal hblank_dly : std_logic := '0';

	signal h_count, h_count_dly : integer range 0 to h_total := 0;
	signal v_count, v_count_dly : integer range 0 to v_total := 0;
	
	
	signal bin_wr, bin_en : std_logic := '0';
	signal read_addr : unsigned(6 downto 0) := (others => '0');
	signal bin_write_data1, bin_write_data2, bin_read_data1, bin_read_data2 : unsigned(11 downto 0) := (others => '0');
	signal bin_write_addr, bin_read_addr : unsigned(order-1 downto 0) := (others => '0');
	
	signal dec_val_write_addr, dec_val_read_addr : unsigned(order-1 downto 0) := (others => '0');
	signal dec_val_write, dec_val_read : unsigned(11 downto 0) := (others => '0');

	signal dec_val_en, dec_val_wr : std_logic := '0';

	
	signal prev_bin_wr, prev_bin_en : std_logic := '0';
	signal prev_bin_write_data, prev_bin_read_data : unsigned(11 downto 0) := (others => '0');
	signal prev_bin_write_addr, prev_bin_read_addr : unsigned(order-1 downto 0) := (others => '0');
	
	--divide by the kernel gain (256/4 = 64) = SR6
	--this will make the output bins be the same scale as the input signal
	
	--scale further experimentally based on screen output
	--too low: div 8192 (SR13) => SR19 total
	--in total: SR19, (32 - 19) = 13 bits left
	
	--maybe better: div 1024 (SR10) => SR16 total
	
	--then clamp if greater than y_height (1080)
	constant div : integer := 17; --num shift rights
	--div = 17 for 1V to fill screen
	
	signal input_data_shift : unsigned(31 downto 0) := (others => '0');
	signal input_data : unsigned(11 downto 0) := (others => '0');
	constant clamp_cmp : integer range 0 to 4095 := v_active;
	signal input_data_dif, input_data_sub : unsigned(11 downto 0) := (others => '0');
	
	constant latency : integer := 2;
	
	signal load_pipe : std_logic_vector(7 downto 0) := (others => '0');
	signal pixel_pipe : std_logic_vector(7 downto 0) := (others => '0');
	
	signal pixel_count : integer := 0;
	
	signal hblank_pipe, hsync_pipe : std_logic_vector(7 downto 0) := (others => '0');
	signal vblank_pipe, vsync_pipe : std_logic_vector(7 downto 0) := (others => '0');
	
	constant limit : integer range 0 to 1023:= 30; --limit in pixel difference between frames
	
	type prev_data_array is array(7 downto 0) of unsigned(11 downto 0);
	signal prev_data_dly : prev_data_array := (others => (others => '0'));
	signal sub_type : std_logic := '0';
	
	signal bin_diff : unsigned(11 downto 0) := (others => '0');
	
	signal bin_data_adj : unsigned(11 downto 0) := (others => '0');
	signal input_data_dly : prev_data_array := (others => (others => '0'));
	
	
	type rom_type is array (0 to 255) of bit_vector(11 downto 0);
	
	impure function rom_init(filename : string) return rom_type is
	  file rom_file : text open read_mode is filename;
	  variable rom_line : line;
	  variable rom_value : bit_vector(11 downto 0);
	  variable temp : rom_type;
	begin
	  for rom_index in 0 to 255 loop
		readline(rom_file, rom_line);
		read(rom_line, rom_value);
		temp(rom_index) := (rom_value);
	  end loop;
	  return temp;
	end function;
	
	constant colorLUT : rom_type := rom_init(filename => "C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/vga/colorLUTs.data");

	signal color_read_addr : unsigned(7 downto 0) := (others => '0');
	signal color_read_data : std_logic_vector(11 downto 0) := (others => '0');
	
	signal color_read_bin_num : unsigned(3 downto 0) := (others => '0');
	
begin

	red <= red_prc when (hblank_pipe(latency) = '0' and vblank_pipe(latency) = '0') else (others => '0');
	grn <= grn_prc when (hblank_pipe(latency) = '0' and vblank_pipe(latency) = '0') else (others => '0');
	blu <= blu_prc when (hblank_pipe(latency) = '0' and vblank_pipe(latency) = '0') else (others => '0');
	
	vsync_dly <= vsync_pipe(latency);
	hsync_dly <= hsync_pipe(latency);

	process(clk)
	begin
		
		if(clk'event and clk = '1') then
		
			vblank_dly <= vblank;
			hblank_dly <= hblank;
			
			
			--if this true, start of the new frame
			if(vblank_dly = '1' and vblank = '0' and hblank_dly = '1' and hblank = '0') then
				v_count <= 0;
				
				load_pipe <= (others => '0');	
			end if;
			
			--start of new line during active period
			if(hblank_dly = '1' and hblank = '0' and vblank = '0') then
				h_count <= 0;
				pixel_count <= 0;
			
				pixel_pipe(0) <= '1';

				--fetch first bin
				bin_en <= '1';
				
				--reset addresses
				bin_read_addr <= (others => '0');
				color_read_bin_num <= (others => '0');
				
			end if;

			--delay pipeline signal
			pixel_pipe(7 downto 1) <= pixel_pipe(6 downto 0);
			
			--if in horizontal active period, increment h counts
			if(pixel_pipe(0) = '1' and hblank = '0') then
				
				h_count <= h_count + 1;
				pixel_count <= pixel_count + 1;
				if(pixel_count = bin_total_width - 1) then
					--reset
					pixel_count <= 0;
				end if;
					
				if(pixel_count = bin_total_width - 3) then
					--get new bin value
					bin_en <= '1';
				end if;
				
			end if;
			
			--if entering horizontal blanking period, turn off pipe and reset h counts
			if(pixel_pipe(0) = '1' and hblank_dly = '0' and hblank = '1') then
				h_count <= 0;
				pixel_count <= 0;
				v_count <= v_count + 1;
				pixel_pipe(0) <= '0';
			end if;
			
			--one clock to setup
			--(1)
			if(bin_en = '1') then
				--increment read address
				bin_read_addr <= bin_read_addr + 1;
				bin_en <= '0';
				
				color_read_bin_num <= color_read_bin_num + 1;
				if(color_read_bin_num = to_unsigned(12-1,4)) then
					color_read_bin_num <= (others => '0');
				end if;
				
			end if;
			
			--delay blanking signals
			hblank_pipe(0) <= hblank;
			hblank_pipe(7 downto 1) <= hblank_pipe(6 downto 0);
			
			vblank_pipe(0) <= vblank;
			vblank_pipe(7 downto 1) <= vblank_pipe(6 downto 0);
			
			hsync_pipe(0) <= hsync;
			hsync_pipe(7 downto 1) <= hsync_pipe(6 downto 0);
			
			vsync_pipe(0) <= vsync;
			vsync_pipe(7 downto 1) <= vsync_pipe(6 downto 0);
			
			--one clock to determine the color
			--(2)
			if(pixel_pipe(1) = '1') then
				if(pixel_count < bin_total_width - 1) then
					
					if((v_count > to_integer(bin_read_data1)) and (v_count < to_integer(bin_read_data2))) then
					
						red_prc <= color_read_data(11 downto 8);
						grn_prc <= color_read_data(7 downto 4);
						blu_prc <= color_read_data(3 downto 0);
					
					else
					
						red_prc <= (others => '0');
						grn_prc <= (others => '0');
						blu_prc <= (others => '0');
						
					end if;
					
					
				else
				
					red_prc <= (others => '0');
					grn_prc <= (others => '0');
					blu_prc <= (others => '0');
					
				end if;
			end if;
			
			--loading pixel data into buffer-----------
			-------------------------------------------
			
			--vertical sync, load new data into buffer
			if(vblank_dly = '0' and vblank = '1') then
			
				pixel_pipe <= (others => '0');
			
				if(valid = '1') then
					load_pipe(0) <= '1';
					
					read_addr <= (others => '0');
					prev_bin_read_addr <= (others => '0');
					prev_bin_write_addr <= (others => '0');
					bin_write_addr <= (others => '0');
					dec_val_read_addr <= (others => '0');
					dec_val_write_addr <= (others => '0');
					
					pixel_pipe <= (others => '0');
				end if;
				
			end if;
			
			load_pipe(7 downto 1) <= load_pipe(6 downto 0);

			--(0) setup read from external bram + previous frame
			if(load_pipe(0) = '1') then
				en_o <= '1';
				prev_bin_en <= '1';
			else
				en_o <= '0';
				prev_bin_en <= '0';
				
			end if;
	
			--(1) read finished, setup next read
			--do right shift
			if(load_pipe(1) = '1') then
			
				read_addr <= read_addr + 1;	
				prev_bin_read_addr <= prev_bin_read_addr + 1;
				
			end if;
			
			
			
			
			--(2) do right shift, delay prev data
			input_data_shift <= to_unsigned(0, div) & data_i(31 downto div);
			prev_data_dly(0) <= prev_bin_read_data;

			--(3) clamp
			--setup decrement read address
			if(input_data_shift >= to_unsigned((v_active/2)-1, 32)) then
				input_data <= to_unsigned((v_active/2)-1, 12);
			else
				input_data <= input_data_shift(11 downto 0);
			end if;
			
			prev_data_dly(1) <= prev_data_dly(0);
			
			if(load_pipe(3) = '1') then
				dec_val_en <= '1';
			else
				dec_val_en <= '0';
			end if;
			
			--(4) calculate difference between successive bin frame
			--increment decrement read address
			
			if(input_data >= prev_data_dly(1)) then
				sub_type <= '1';
				--bin_diff <= input_data - prev_data_dly(1);
			else
				sub_type <= '0';
				bin_diff <= prev_data_dly(1) - input_data;
			end if;
		
			input_data_dly(0) <= input_data;
			
			prev_data_dly(2) <= prev_data_dly(1);
			
			if(load_pipe(4) = '1') then
				dec_val_read_addr <= dec_val_read_addr + 1;
			end if;
			
			--(5) compare to constant limit
			-- use decrement data here
			bin_data_adj <= input_data_dly(0);
			
			if((to_integer(bin_diff) > limit) and sub_type = '0') then

				if(prev_data_dly(2) < to_unsigned(limit,12)) then
					bin_data_adj <= (others => '0');
				else
					bin_data_adj <= prev_data_dly(2) - to_unsigned(limit, 12);
				end if;

			end if;
		
			
			--(6) convert to pixels, setup write enable
			input_data_dif <= to_unsigned((v_active/2)-1, 12) - bin_data_adj;
			input_data_sub <= to_unsigned((v_active/2),12) + bin_data_adj;
			
			if(load_pipe(6) = '1') then
				bin_wr <= '1';
				prev_bin_wr <= '1';
			else
				bin_wr <= '0';
				prev_bin_wr <= '0';
			end if;
			
			input_data_dly(1) <= bin_data_adj;
			
			--(7) increment write, check if done
			if(load_pipe(7) = '1') then
				bin_write_addr <= bin_write_addr + 1;
				prev_bin_write_addr <= prev_bin_write_addr + 1;
				if(bin_write_addr = to_unsigned(numbins-1, order)) then
					bin_write_addr <= (others => '0');
					prev_bin_write_addr <= (others => '0');
					load_pipe <= (others => '0');
					
					bin_wr <= '0';
					prev_bin_wr <= '0';
					
				end if;
			end if;
			
		
		end if;
		
	end process;
	
	color_read_addr <= color_read_map_sel & color_read_bin_num;
	
	color_reader : process(clk)
	begin
		if(clk'event and clk = '1') then		
			if(bin_en = '1') then
				color_read_data <= to_StdLogicVector(colorLUT(to_integer(color_read_addr)));
			end if;
		end if;
	end process;
	
	
	
	addr_o <= read_addr;
	
	bin_write_data1 <= input_data_dif;
	bin_write_data2 <= input_data_sub;
	
	prev_bin_write_data <= input_data_dly(1);
	
	--frame buffer
	frame1 : entity work.bin_bram
	generic map(
		order => order
	)
	port map(
		clka => clk,
		wea => bin_wr,
		ena => bin_wr,
		dia => bin_write_data1,
		doa => open,
		addra => bin_write_addr,

		clkb => clk,
		web => '0',
		enb => bin_en,
		dib => (others => '0'),
		dob => bin_read_data1,
		addrb => bin_read_addr
	);
	
	frame2 : entity work.bin_bram
	generic map(
		order => order
	)
	port map(
		clka => clk,
		wea => bin_wr,
		ena => bin_wr,
		dia => bin_write_data2,
		doa => open,
		addra => bin_write_addr,

		clkb => clk,
		web => '0',
		enb => bin_en,
		dib => (others => '0'),
		dob => bin_read_data2,
		addrb => bin_read_addr
	);
	
	prev_frame : entity work.bin_bram
	generic map(
		order => order
	)
	port map(
		clka => clk,
		wea => prev_bin_wr,
		ena => prev_bin_wr,
		dia => prev_bin_write_data,
		doa => open,
		addra => prev_bin_write_addr,

		clkb => clk,
		web => '0',
		enb => prev_bin_en,
		dib => (others => '0'),
		dob => prev_bin_read_data,
		addrb => prev_bin_read_addr
	);
	
	dec_vals : entity work.bin_bram
	generic map(
		order => order
	)
	port map(
		clka => clk,
		wea => dec_val_wr,
		ena => dec_val_wr,
		dia => dec_val_write,
		doa => open,
		addra => dec_val_write_addr,

		clkb => clk,
		web => '0',
		enb => dec_val_en,
		dib => (others => '0'),
		dob => dec_val_read,
		addrb => dec_val_read_addr
	);
	
end str;