
   
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--mclk should probably be 12.288 MHz * 2
--at 12 MHz, 12/8 = 1.5 which is not the BW for 24bits
--12.288 MHz * 2 - 12 * 51.2 * / 25
--have to use MMCM then

--How to use:
--Connect to BRAM



entity i2s_master is
	port(
    	mclk_i : in std_logic;
    	
    	sclk_o : out std_logic;
		lrclk_o : out std_logic;
    	
    	sd_i : in std_logic;
    	sd_o : out std_logic;
		
		rec_reg_o : out signed(23 downto 0);
		
		tra_reg_i : in signed(23 downto 0);
		
		stb_o : out std_logic

        );
end i2s_master;

architecture str of i2s_master is 


	--sclk fully toggles once per 8 mclks
	signal sclk : std_logic := '0';
	
	--lrclk fully toggles once per 64 sclks
	signal lrclk : std_logic := '0';

	--counters 
	signal mclk_count : integer := 0;
	signal sclk_count : integer := 0;

	--receiver signals
	signal rec_lrclk_dly : std_logic := '0';
	signal rec_start : std_logic := '0';
	signal rec_done  : std_logic := '0';
	signal rec_count : integer := 0;
	signal rec_reg   : signed(23 downto 0) := (others => '0');
	
	--transmitter signals
	signal tra_lrclk_dly : std_logic := '0';
	signal tra_start : std_logic := '0';
	signal tra_done : std_logic := '0';
	signal tra_count : integer := 0;
	signal tra_reg : signed(23 downto 0) := (others => '0');

	
	begin
	
	--pins go to outputs
	sclk_o <= sclk;
	lrclk_o <= lrclk;
	
	--generate sclk
	process(mclk_i)
	begin
	
		if(mclk_i'event and mclk_i = '1') then
		
			if(mclk_count = 4-1) then
				sclk <= not sclk;
				mclk_count <= 0;
			else

				mclk_count <= mclk_count + 1;
			end if;
		
		end if;
	
	end process;
	
	--generate lrclk
	process(mclk_i)
	begin
	
		if(mclk_i'event and mclk_i = '1') then
		
			if(sclk_count = 256-1) then
				lrclk <= not lrclk;
				sclk_count <= 0;
			else
				sclk_count <= sclk_count + 1;
			end if;
		
		end if;
	
	end process;
	
	--receiver process
	process(sclk)
	begin
	
		if(sclk'event and sclk = '1') then
		
			rec_lrclk_dly <= lrclk;
			
			if(lrclk /= rec_lrclk_dly) then
			
				--start deserializing data
				rec_start <= '1';
				rec_count <= 0;
			
			end if;
		
			if(rec_start = '1') then
			
					rec_reg(0) <= sd_i;
					rec_reg(23 downto 1) <= rec_reg(22 downto 0);
					
					rec_count <= rec_count + 1;
			
			end if;
		
			if(rec_count = 24-1) then
			
					rec_count <= 0;
					rec_done <= '1';
					rec_start <= '0';
			
			end if;
				
			stb_o <= '0';
			
			if(rec_done = '1') then
			
				rec_done <= '0';
				stb_o <= '1';
				rec_reg_o <= rec_reg;
			
			end if;
		
		end if;
	
	
	end process;

	--transmitter process
	process(sclk)
	begin
	
		if(sclk'event and sclk = '1') then
		
			tra_lrclk_dly <= lrclk;
							
			if(lrclk /= tra_lrclk_dly) then
			
				tra_start <= '1';
				tra_count <= 0;
				
				tra_reg <= tra_reg_i;
			
			end if;
		
			if(tra_start = '1') then
			
				if(tra_count = 24 - 1) then
				
					tra_start <= '0';
					tra_count <= 0;
					tra_done <= '1';
				else
					tra_reg(23 downto 1) <= tra_reg(22 downto 0);
					tra_reg(0) <= '0';
					tra_count <= tra_count + 1;
				end if;
			
			end if;
		
			if(tra_done = '1') then
				tra_done <= '0';
			end if;
		
		end if;
	
		--setup data on falling edge
		if(sclk'event and sclk = '0') then
		
			if(tra_start = '1') then
			
				sd_o <= tra_reg(23);

			
			end if;
			
		
		end if;
	
	end process;
	
end str;

 		