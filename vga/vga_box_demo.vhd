-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--draw different boxes on the screen, make sure vga port works

--inputs: 
	--blanking period signal
	--pixel clock
--outputs:
	--color


--rising edge of blanking period notes a new box needs to be ready
--falling edge of blanking period notes pixels need to start changing

--vertical blanks determine box update

use work.vga_timing_gen_pkg.all;

entity vga_box_demo is
	port(
		clk : in std_logic;
		
		hblank : in std_logic;
		vblank : in std_logic;
		
		red : out std_logic_vector(3 downto 0);
		grn : out std_logic_vector(3 downto 0);
		blu : out std_logic_vector(3 downto 0)

        );
end vga_box_demo;

architecture str of vga_box_demo is 

	type state_type is ( waitforframe, pushpixels, waitforline, pollbox, movebox );
	signal state : state_type := waitforframe;
	
	constant box_dim : integer range 0 to 1023 := 500;
	
	signal tick_dly : std_logic := '0';
	
	--0 for left, 1 for right
	--0 for down, 1 for up
	signal x_dir : std_logic := '0';
	signal y_dir : std_logic := '0';
	
	
	signal lfsr : std_logic_vector(15 downto 0) := x"BABA";
	
	--box position
	signal box_x1 : integer range 0 to h_active := 80;
	signal box_x2 : integer range 0 to h_active := 80 + box_dim;
	signal box_y1 : integer range 0 to v_active := 80;
	signal box_y2 : integer range 0 to v_active := 80 + box_dim;
	
	signal dly : std_logic := '0';
	signal ready_dly : std_logic := '0';
	
	signal red_prc : std_logic_vector(3 downto 0) := (others => '0');
	signal grn_prc : std_logic_vector(3 downto 0) := (others => '0');
	signal blu_prc : std_logic_vector(3 downto 0) := (others => '0');
	
	signal red_reg : std_logic_vector(3 downto 0) := (others => '1');
	signal grn_reg : std_logic_vector(3 downto 0) := (others => '0');
	signal blu_reg : std_logic_vector(3 downto 0) := (others => '0');
	
	signal vblank_dly : std_logic := '0';
	signal hblank_dly : std_logic := '0';

	signal h_count : integer range 0 to h_active := 0;
	signal v_count : integer range 0 to v_active := 0;
	
begin

	red <= red_prc when (hblank = '0' and vblank = '0') else (others => '0');
	grn <= grn_prc when (hblank = '0' and vblank = '0') else (others => '0');
	blu <= blu_prc when (hblank = '0' and vblank = '0') else (others => '0');

	process(clk)
	begin
		
		if(clk'event and clk = '1') then
			
			vblank_dly <= vblank;
			hblank_dly <= hblank;
			
			lfsr(15 downto 1) <= lfsr(14 downto 0);
			lfsr(0) <= lfsr(11) xor lfsr(9) xor lfsr(8) xor lfsr(7) xor lfsr(3) xor lfsr(2);

			
			case state is 
			when waitforframe =>
				--if this true, start of new frame
				if(vblank_dly = '1' and vblank = '0' and hblank_dly = '1' and hblank = '0') then
					state <= pushpixels;
					h_count <= 0;
					v_count <= 0;
				end if;
				
			when pushpixels =>
				
				if(hblank_dly = '0' and hblank = '1') then
					state <= waitforline;
					v_count <= v_count + 1;
					h_count <= 0;
				else
					
					h_count <= h_count + 1;
					if((h_count >= box_x1 and h_count <= box_x2) and (v_count >= box_y1 and v_count <= box_y2)) then
						red_prc <= red_reg;
						grn_prc <= grn_reg;
						blu_prc <= blu_reg;
					else
						red_prc <= (others => '0');
						grn_prc <= (others => '0');
						blu_prc <= (others => '0');
					end if;
					
				end if;
				
			when waitforline =>
			
				if(hblank_dly = '1' and hblank = '0') then
					state <= pushpixels;
				end if;
				
				if(vblank_dly = '0' and vblank = '1') then
					--state <= pollbox;
					--not moving box: temp(removeme)
					state <= waitforframe;
					v_count <= 0;
				end if;
				
			when pollbox =>

				--check if we're on an edge of the screen
				if(box_x1 = 0 or box_x2 = h_active - 1 or box_y1 = 0 or box_y2 = v_active-1) then
					
					--update direction
					x_dir <= lfsr(1);
					y_dir <= lfsr(14);
					
					red_reg <= lfsr(4 downto 1);
					grn_reg <= lfsr(9 downto 6);
					blu_reg <= lfsr(14 downto 11);
				end if;
				
				state <= movebox;
				
			when movebox =>
			
				--update box coords
				if(x_dir = '0') then
					--move box left
					if(box_x1 /= 0) then
						box_x1 <= box_x1 - 1;
						box_x2 <= box_x2 - 1;
					end if;
				else
					--move box right
					if(box_x2 /= h_active - 1) then
						box_x1 <= box_x1 + 1;
						box_x2 <= box_x2 + 1;
					end if;
				end if;
					
				if(y_dir = '0') then
					--move box up
					if(box_y1 /= 0) then
						box_y1 <= box_y1 - 1;
						box_y2 <= box_y2 - 1;
					end if;
				else
					--move box down
					if(box_y2 /= v_active - 1) then
						box_y1 <= box_y1 + 1;
						box_y2 <= box_y2 + 1;
					end if;
				end if;

				state <= waitforframe;
				

				
				
			when others =>
			end case;
		
		
		
		end if;
		
	end process;


end str;