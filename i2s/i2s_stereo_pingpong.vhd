
   
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Going to store data as:
-- L, R, L, R and flip between two buffers.

entity i2s_stereo_pingpong is
	generic(
		buffersizelog2 : integer
	);
	port(
		rst_i : in std_logic;
    	sclk_i : in std_logic;
		lrclk_i : in std_logic;
		
		rec_reg_i : in signed(23 downto 0);
		tra_reg_o : out signed(23 downto 0);
		stb_i : in std_logic;
		full_o : out std_logic;
		
		proc_clk_i : in std_logic;
		proc_en_i : in std_logic;
		proc_wr_i : in std_logic;
		proc_addr_i : in unsigned(buffersizelog2 - 1 downto 0);
		proc_data_i : in signed(23 downto 0);
		proc_data_o : out signed(23 downto 0)

        );
end i2s_stereo_pingpong;

architecture str of i2s_stereo_pingpong is 

	type state_type is (
						reset, 
						ping_wait_left,
						ping_wait_right,
						ping_store_left,
						ping_read_left,
						ping_store_right,
						ping_read_right,
						pong_wait_left,
						pong_wait_right,
						pong_store_left,
						pong_read_left,
						pong_store_right,
						pong_read_right,
						
						ping_out_left,
						ping_out_right,
						pong_out_left,
						pong_out_right

	);

	signal state : state_type := reset;
	
	--pingpong signals

	--if 0 -> i2s fill / read ping, proc fill/read pong
	--if 1 -> i2s fill / read pong, proc fill/read ping
	signal buffer_sel : std_logic := '0';

	signal full : std_logic := '0';
	
	signal clk_dly : std_logic := '0';
	

	--bram signals
	signal ping_ena : std_logic := '0';
	signal ping_wra : std_logic := '0';
	signal ping_addra : unsigned(buffersizelog2 - 1 downto 0) := (others => '0');
	signal ping_dia : signed(31 downto 0) := (others => '0');
	signal ping_doa : signed(31 downto 0) := (others => '0');

	signal pong_ena : std_logic := '0';
	signal pong_wra : std_logic := '0';
	signal pong_addra : unsigned(buffersizelog2 - 1 downto 0) := (others => '0');
	signal pong_dia : signed(31 downto 0) := (others => '0');
	signal pong_doa : signed(31 downto 0) := (others => '0');
	
	signal ping_enb : std_logic := '0';
	signal ping_wrb : std_logic := '0';
	signal ping_addrb : unsigned(buffersizelog2 - 1 downto 0) := (others => '0');
	signal ping_dib : signed(31 downto 0) := (others => '0');
	signal ping_dob : signed(31 downto 0) := (others => '0');
	
	signal pong_enb : std_logic := '0';
	signal pong_wrb : std_logic := '0';
	signal pong_addrb : unsigned(buffersizelog2 - 1 downto 0) := (others => '0');
	signal pong_dib : signed(31 downto 0) := (others => '0');
	signal pong_dob : signed(31 downto 0) := (others => '0');

	
	begin
	

	process(sclk_i)
	begin
		if(sclk_i'event and sclk_i = '1') then
		
			full <= '0';
		
			if(rst_i = '1') then
			
				state <= reset;
			
			else
			
				case state is
				when reset =>
					
					ping_addra <= (others => '0');
					pong_addra <= (others => '0');
					ping_ena <= '0';
					pong_ena <= '0';
					buffer_sel <= '0';
					if(rst_i = '0') then
						state <= ping_wait_left;
					else
						state <= reset;
					end if;
				
				when ping_wait_left =>
				
					if(stb_i = '1' and lrclk_i = '0') then
						state <= ping_store_left;
						else
						state <= ping_wait_left;
					end if;
					
					clk_dly <= '0';
					
				when ping_store_left =>
					clk_dly <= '1';
					ping_ena <= '1';
					ping_wra <= '1';
					if(clk_dly = '1') then
						clk_dly <= '0';
						ping_ena <= '0';
						ping_wra <= '0';
						ping_addra <= ping_addra + 1;
						state <= ping_read_right;
					else
						state <= ping_store_left;
					end if;
					
				when ping_read_right =>
					clk_dly <= '1';
					ping_ena <= '1';
					ping_wra <= '0';
					
					if(clk_dly = '1') then
					
						clk_dly <= '0';
						ping_ena <= '0';
						ping_wra <= '0';
						
						--this was too early 
						--tra_reg_o <= ping_doa(23 downto 0);
						
						state <= ping_out_right;
					else
						state <= ping_read_right;
					end if;
				
				when ping_out_right =>
				
					tra_reg_o <= ping_doa(23 downto 0);
					state <= ping_wait_right;
				
				when ping_wait_right =>
					if(stb_i = '1' and lrclk_i = '1') then
						state <= ping_store_right;
						else
						state <= ping_wait_right;
					end if;
					
					clk_dly <= '0';
				
				when ping_store_right =>
					clk_dly <= '1';
					ping_ena <= '1';
					ping_wra <= '1';
					if(clk_dly = '1') then
						clk_dly <= '0';
						ping_ena <= '0';
						ping_wra <= '0';
						--check if final write into buffer
						if(ping_addra = to_unsigned((2**buffersizelog2)-1, buffersizelog2)) then
							--switch buffers
							state <= pong_read_left;
							buffer_sel <= not buffer_sel;
							full <= '1';
							pong_addra <= (others => '0');
							else
							ping_addra <= ping_addra + 1;
							state <= ping_read_left;
						end if;
					else
						state <= ping_store_right;
					end if;
				
				
				when ping_read_left =>
					clk_dly <= '1';
					ping_ena <= '1';
					ping_wra <= '0';
					
					if(clk_dly = '1') then
					
						clk_dly <= '0';
						ping_ena <= '0';
						ping_wra <= '0';
						
						--tra_reg_o <= ping_doa(23 downto 0);
						
						state <= ping_out_left;
					else
						state <= ping_read_left;
					end if;
					
				when ping_out_left =>
					
					tra_reg_o <= ping_doa(23 downto 0);
					state <= ping_wait_left;
					
				when pong_wait_left =>
				
					if(stb_i = '1' and lrclk_i = '0') then
						state <= pong_store_left;
						else
						state <= pong_wait_left;
					end if;
					
					clk_dly <= '0';
				
				when pong_store_left =>
					clk_dly <= '1';
					pong_ena <= '1';
					pong_wra <= '1';
					if(clk_dly = '1') then
						clk_dly <= '0';
						pong_ena <= '0';
						pong_wra <= '0';
						pong_addra <= pong_addra + 1;
						state <= pong_read_right;
					else
						state <= pong_store_left;
					end if;
					
				when pong_read_right =>
					clk_dly <= '1';
					pong_ena <= '1';
					pong_wra <= '0';
					
					if(clk_dly = '1') then
					
						clk_dly <= '0';
						pong_ena <= '0';
						pong_wra <= '0';
						
						--tra_reg_o <= pong_doa(23 downto 0);
						
						state <= pong_out_right;
					else
						state <= pong_read_right;
					end if;
				
				when pong_out_right =>
				
					tra_reg_o <= pong_doa(23 downto 0);
					state <= pong_wait_right;
				
				when pong_wait_right =>
					if(stb_i = '1' and lrclk_i = '1') then
						state <= pong_store_right;
						else
						state <= pong_wait_right;
					end if;
					
					clk_dly <= '0';
					
				when pong_store_right =>
					clk_dly <= '1';
					pong_ena <= '1';
					pong_wra <= '1';
					if(clk_dly = '1') then
						clk_dly <= '0';
						pong_ena <= '0';
						pong_wra <= '0';
						--check if final write into buffer
						if(pong_addra = to_unsigned((2**buffersizelog2)-1, buffersizelog2)) then
							--switch buffers
							state <= ping_read_left;
							buffer_sel <= not buffer_sel;
							full <= '1';
							ping_addra <= (others => '0');
							
							else
							pong_addra <= pong_addra + 1;
							state <= pong_read_left;
							end if;
					else
						state <= pong_store_right;
					end if;
					
				when pong_read_left =>
				
					clk_dly <= '1';
					pong_ena <= '1';
					pong_wra <= '0';
					
					if(clk_dly = '1') then
					
						clk_dly <= '0';
						pong_ena <= '0';
						pong_wra <= '0';
						
						--tra_reg_o <= pong_doa(23 downto 0);
						
						state <= pong_out_left;
					else
						state <= pong_read_left;
					end if;
				
				when pong_out_left =>
				
					tra_reg_o <= pong_doa(23 downto 0);
					state <= pong_wait_left;

				
				when others =>
				end case;
			
			end if;
		
		end if;
	end process;
	
	--sign extend i2s input to BRAM
	process(rec_reg_i)
	begin
	
		for i in 1 to 8 loop
		
			ping_dia(23+i) <= rec_reg_i(23);
			pong_dia(23+i) <= rec_reg_i(23);
		
		
		end loop;
	
		ping_dia(23 downto 0) <= rec_reg_i;
		pong_dia(23 downto 0) <= rec_reg_i;
	
	end process;
	
	--sign extend proc input to BRAM
	process(proc_data_i)
	begin

		for i in 1 to 8 loop
		
			ping_dib(23+i) <= proc_data_i(23);
			pong_dib(23+i) <= proc_data_i(23);
		
		
		end loop;
	
		ping_dib(23 downto 0) <= proc_data_i;
		pong_dib(23 downto 0) <= proc_data_i;
		
	end process;
	
	--mux proc control signals into BRAMs
	--when buffer_sel = 0, read/write PONG
	--when buffer_sel = 1, read/write PING
	
	ping_wrb <= proc_wr_i when buffer_sel = '1' else '0';
	ping_enb <= proc_en_i when buffer_sel = '1' else '0';
	
	pong_wrb <= proc_wr_i when buffer_sel = '0' else '0';
	pong_enb <= proc_en_i when buffer_sel = '0' else '0';
	
	--addresses
	ping_addrb <= proc_addr_i;
	pong_addrb <= proc_addr_i;
	
	--mux outputs
	
	proc_data_o <= ping_dob(23 downto 0) when buffer_sel = '1' else pong_dob(23 downto 0);
	
	full_o <= full;
	
	--bram instantations, 2048 size since I want to use 768 samples
	ping : entity work.i2s_bram
	generic map(
		order => buffersizelog2
	)
	port map(
		clka => sclk_i,
		wea  => ping_wra,
		ena  => ping_ena,
		dia  => ping_dia,
		doa  => ping_doa,
		addra => ping_addra,

        clkb  => proc_clk_i,
		web  =>  ping_wrb,
		enb  => ping_enb,
		dib  => ping_dib,
		dob  => ping_dob,
		addrb => ping_addrb
	);
	
	pong : entity work.i2s_bram
	generic map(
		order => buffersizelog2
	)
	port map(
		clka => sclk_i,
		wea  => pong_wra,
		ena  => pong_ena,
		dia  => pong_dia,
		doa  => pong_doa,
		addra => pong_addra,

        clkb  => proc_clk_i,
		web  =>  pong_wrb,
		enb  => pong_enb,
		dib  => pong_dib,
		dob  => pong_dob,
		addrb => pong_addrb
	);
	
end str;

 		