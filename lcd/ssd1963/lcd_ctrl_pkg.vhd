library IEEE;
use IEEE.std_logic_1164.all;

package lcd_ctrl_pkg is

	

	constant lcd_set_col : std_logic_vector(7 downto 0) := x"2A";
	constant lcd_set_row : std_logic_vector(7 downto 0) := x"2B";
	constant lcd_set_pix : std_logic_vector(7 downto 0) := x"2C";

	type lcd_ctrl_set_xy_arr_type is array(0 to 10) of std_logic_vector(8 downto 0);

	

    --should make rom max a power of 2
	--have to edit the table values to match this
    constant lcd_ctrl_rom_max : integer := 64;

	--18 bit rom to be inferred on a bram tile
    type rom is array(0 to lcd_ctrl_rom_max-1) of std_logic_vector(17 downto 0);

	--rom data is packed as:
	--[17]: 0 = lcd function, 1 = delay in ms
	--[16]: 0 = lcd command,  1 = lcd data parameter
	--[15:0] = lcd input
    constant lcd_ctrl_rom : rom := 
        (
			"00" & x"00E2", --PLL multiplier
            "01" & x"001D", --10 MHz * (29 + 1) / (2 + 1) = 100 MHz PLL
            "01" & x"0002", 
			"01" & x"0054",
			
            "00" & x"00E0", --PLL enable, use reference clock
			"01" & x"0001",
			"10" & x"000A", --wait 10 ms
			
			"00" & x"00E0", --PLL enable, use PLL clock
			"01" & x"0003", 
            "10" & x"000A", --wait 10 ms
			
			"00" & x"0001", --software reset
            "10" & x"0064", --wait 100 ms
			
            "00" & x"00E6", --PLL setting for pixel clock for 60 fps
			"01" & x"0005", --100 MHz PLL to get 33.3 MHz PCLK
            "01" & x"0053",
			"01" & x"00F7",
			
            "00" & x"00B0", --LCD spec
			"01" & x"0000", --TFT bit width, no dither. sync polarities = 0x00 good
            "01" & x"0000", --tft mode, not serial
			"01" & x"0003", --hdp = 800-1
            "01" & x"001F",
			"01" & x"0001",
            "01" & x"00DF", --vdp = 480-1
			"01" & x"0000",
			
            "00" & x"00B4", --hsync
			"01" & x"0004", --ht = 1056-1
            "01" & x"001F",
			"01" & x"0000", --hps = blank? = 46  
            "01" & x"002E",
			"01" & x"0001", --hpw = 1 ?
            "01" & x"0000", --lps=0?
			"01" & x"0000",
            "01" & x"0000",
			
			"00" & x"00B6",	--vsync		
            "01" & x"0002", --vt = 525-1
			"01" & x"000C", 
            "01" & x"0000", --vps = blank? = 23
			"01" & x"0017",
            "01" & x"0001", --vpw = 1?
			"01" & x"0000", --vertical display period start position
            "01" & x"0000",
			
			"00" & x"00B8", 
            "01" & x"0007", --gpio3 = input, gpio2:0 output
			"01" & x"0001", --gpio0 normal
			
			"00" & x"00BA", --gpio[3:0] out 1
            "01" & x"0007",
			

			
            "00" & x"0036",
			"01" & x"0000", --rotation
			
            "00" & x"003A", --pixel format?
			"01" & x"0050",
			
			
            "00" & x"00F0",
			"01" & x"0003", --rgb 565
			
            "10" & x"000A", --delay 10 ms
		
			"00" & x"0000", --nop
			"00" & x"0011", --sleep out + display on
			"10" & x"000D", --delay 15 ms
			
			--BACKLIGHT
            "00" & x"00BE",
			"01" & x"0006",
            "01" & x"00F0",
			"01" & x"0001",
            "01" & x"00F0",
			"01" & x"0000",
            "01" & x"0000",
			



             
            "00" & x"FFFF"
             );  


end package lcd_ctrl_pkg;