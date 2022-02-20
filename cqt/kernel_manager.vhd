-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Holds two BRAMs and manages them
--When FFT is busy, mux RAMs to FFT
--Else CQT is busy, mux unused RAM to Ext SRAM & CQT

entity kernel_manager is
	generic(
		order : integer; --order = log2(fft_size)
		kernel_elements : integer;
		kernel0 : string;
		kernel1 : string
		);
	port(
	    clk : in std_logic;
		rst : in std_logic;
		
		fft_busy : in std_logic;
		cqt_busy : in std_logic;
		
		kernel_write : in std_logic;
		kernel_write_done : out std_logic;
		kernel_load : in std_logic;
		kernel_ready : out std_logic;
	
		--for FFT
		fft_ram0_ena   : in std_logic;
		fft_ram0_wra   : in std_logic;
		fft_ram0_addra : in unsigned(order - 1 downto 0);
		fft_ram0_dia   : in signed(63 downto 0);
		fft_ram0_doa   : out signed(63 downto 0);
		
		fft_ram0_enb   : in std_logic;
		fft_ram0_wrb   : in std_logic;
		fft_ram0_addrb : in unsigned(order - 1 downto 0);
		fft_ram0_dib   : in signed(63 downto 0);
		fft_ram0_dob   : out signed(63 downto 0);		
		
		fft_ram1_ena   : in std_logic;
		fft_ram1_wra   : in std_logic;
		fft_ram1_addra : in unsigned(order - 1 downto 0);
		fft_ram1_dia   : in signed(63 downto 0);
		fft_ram1_doa   : out signed(63 downto 0);
		
		fft_ram1_enb   : in std_logic;
		fft_ram1_wrb   : in std_logic;
		fft_ram1_addrb : in unsigned(order - 1 downto 0);
		fft_ram1_dib   : in signed(63 downto 0);
		fft_ram1_dob   : out signed(63 downto 0);
		
		--for CQT calculation
		cqt_ram_en   : in std_logic;
		cqt_ram_addr : in unsigned(order - 1 downto 0);
		cqt_ram_do   : out signed(63 downto 0);
		

		--for external SRAM	(controlled in process)	
		ext_in_data_reg : out std_logic_vector(63 downto 0);
		ext_out_data_reg : in std_logic_vector(63 downto 0);
		ext_in_addr : out unsigned(15 downto 0);
		ext_in_wr : out std_logic;
		ext_in_rd : out std_logic;
		ext_wr_done : in std_logic;
		ext_rd_done : in std_logic
		

        );
end kernel_manager;

architecture str of kernel_manager is 

	type state_type is ( reset,
						 idle,
						 writekernel,
						 wait_cqt,
						 active_cqt,
						 
						 read_kernel,
						 done
						);
						
	signal state : state_type := reset;
					
	--constant kernel_elements : integer := 7843; --hardcode this
					
	signal numstages_even_odd : unsigned(order - 1 downto 0) := (others => '0');
	
	signal zeros : unsigned(order - 1 downto 0) := (others => '0');
	signal ones  : unsigned(order - 1 downto 0) := (others => '1');
	
	signal fft_result_ram : std_logic := '0';

	--signals that connect to directly to block rams
	signal	ram0_ena   : std_logic := '0';
	signal	ram0_wra   :  std_logic := '0';
	signal	ram0_addra :  unsigned(order - 1 downto 0) := (others => '0');
	signal	ram0_dia   :  signed(63 downto 0) := (others => '0');
	signal	ram0_doa   :  signed(63 downto 0) := (others => '0');
		
	signal	ram0_enb   :  std_logic := '0';
	signal	ram0_wrb   :  std_logic := '0';
	signal	ram0_addrb :  unsigned(order - 1 downto 0) := (others => '0');
	signal	ram0_dib   :  signed(63 downto 0) := (others => '0');
	signal	ram0_dob   :  signed(63 downto 0) := (others => '0');	
		
	signal	ram1_ena   :  std_logic := '0';
	signal	ram1_wra   :  std_logic := '0';
	signal	ram1_addra :  unsigned(order - 1 downto 0) := (others => '0');
	signal	ram1_dia   :  signed(63 downto 0) := (others => '0');
	signal	ram1_doa   :  signed(63 downto 0) := (others => '0');
		
	signal	ram1_enb   :  std_logic := '0';
	signal	ram1_wrb   :  std_logic := '0';
	signal	ram1_addrb :  unsigned(order - 1 downto 0) := (others => '0');
	signal	ram1_dib   :  signed(63 downto 0) := (others => '0');
	signal	ram1_dob   :  signed(63 downto 0) := (others => '0');

	--signals used for reading / writing kernel, connect to port A of RAM
	signal kernel_en : std_logic := '0';
	signal kernel_wr : std_logic := '0';
	signal kernel_addr : unsigned(order downto 0) := (others => '0');
	signal kernel_di : signed(63 downto 0) := (others => '0');
	signal kernel_do : signed(63 downto 0) := (others => '0');
	
	--signals that is the output of the mux of kernel/cqt, connect to port A
	signal mng_en : std_logic := '0';
	signal mng_wr : std_logic := '0';
	signal mng_addr : unsigned(order - 1 downto 0) := (others => '0');
	signal mng_di : signed(63 downto 0) := (others => '0');
	signal mng0_do : signed(63 downto 0) := (others => '0');
	signal mng1_do : signed(63 downto 0) := (others => '0');
	
	signal kernel_move : std_logic := '0';
	
	signal kernel_init_done : std_logic := '0';
	signal kernel_sel : std_logic := '0';

	signal fft_ram0_sel : std_logic := '0';
	
	signal fft_ram1_sel : std_logic := '0';

	signal cqt_ram0_sel : std_logic := '0';
	
	signal cqt_ram1_sel : std_logic := '0';


begin

	process(clk)
	begin
	
		if(clk'event and clk = '1') then
		
			ext_in_wr <= '0';
			ext_in_rd <= '0';
		
			if(rst = '1') then
				state <= reset;
			else
				case state is
				when reset =>
					if(rst = '0') then
						state <= idle;
					else
						state <= reset;
					end if;
					
				when idle =>
				
					if(kernel_write = '1') then
						kernel_addr <= (others => '0');
						kernel_sel <= '0';
						kernel_en <= '1'; --setup read from RAM
						kernel_move <= '1';
						kernel_write_done <= '0';
						state <= writekernel;
					end if;
				
				when writekernel =>
					
					kernel_move <= '1';
				
					--bring pulse low
					ext_in_wr <= '0';
					kernel_en <= '0';
					
					if(kernel_en = '1') then
						
						--read from initial ram done
						
						--signal write to external sram
						ext_in_wr <= '1'; 
						
					end if;

					
					if(ext_wr_done = '1') then
						
						--setup next read
						kernel_en <= '1';
						
						if(kernel_addr = to_unsigned((2**order)-1, order+1)) then
							
							--switch kernel rams
							kernel_sel <= '1';
							
							kernel_addr <= kernel_addr + 1;
							
						elsif(kernel_addr = to_unsigned((kernel_elements-1), order+1)) then
						
							--finished writing kernel to sram
							kernel_write_done <= '1';
							state <= wait_cqt;
							kernel_sel <= '0';
							kernel_en <= '0';
							kernel_addr <= (others => '0');
						
						else
						
							kernel_en <= '1';
							kernel_addr <= kernel_addr + 1;
						
						end if;
			
					end if;
					
				when wait_cqt =>
				
					--gives rams to fft / cqt during this
					kernel_move <= '0';
					
					kernel_ready <= '0';
					
					if(kernel_load = '1') then
						kernel_move <= '1';
						state <= read_kernel;
						
						kernel_addr(order) <= kernel_sel;
						kernel_addr(order-1 downto 0) <= (others => '0');
						ext_in_rd <= '1';
						kernel_en <= '1';
						kernel_wr <= '1';
					end if;
					
				when read_kernel =>


					if(ext_rd_done = '1') then
						
						ext_in_rd <= '1';
						kernel_addr <= kernel_addr + 1;
						
						if(kernel_sel = '0') then
		
							if(kernel_addr = to_unsigned((2**order)-1, order+1)) then
								
								kernel_sel <= '1';
								kernel_ready <= '1';
								state <= wait_cqt;
								kernel_en <= '0';
								kernel_wr <= '0';
								
								ext_in_rd <= '0';
								
							end if;
							

						
						else
						
							if(kernel_addr = to_unsigned(kernel_elements-1, order+1)) then
							
								kernel_sel <= '0';
								kernel_ready <= '1';
								state <= wait_cqt;
								kernel_en <= '0';
								kernel_wr <= '0';
								
								ext_in_rd <= '0';
								
							end if;
							
							
						end if;
					
					else
					
						ext_in_rd <= '0';
					
					end if;
					
					
				when others =>
				end case;
			end if;
		
		end if;
	
	end process;

	--for writing to external ram
	ext_in_data_reg <= std_logic_vector(ram0_doa) when kernel_sel = '0' else std_logic_vector(ram1_doa);

	ext_in_addr(15 downto order+1) <= (others => '0');
	ext_in_addr(order downto 0) <= kernel_addr;

	
	mng_en <= kernel_en when kernel_move = '1' else cqt_ram_en;
	mng_wr <= kernel_wr when kernel_move = '1' else '0';
	mng_addr <= kernel_addr(order-1 downto 0) when kernel_move = '1' else cqt_ram_addr;
	mng_di <= signed(ext_out_data_reg);
	
	cqt_ram_do <= ram0_doa when fft_result_ram = '1' else ram1_doa;

	numstages_even_odd <= to_unsigned(order, order);
	fft_result_ram <= numstages_even_odd(0); --when x, mux to RAMx for load
	
	fft_ram0_sel <= (fft_busy and not kernel_move) or (cqt_busy and (not fft_result_ram));
	fft_ram1_sel <= (fft_busy and not kernel_move) or (cqt_busy and fft_result_ram);

	-- --ram signal muxing
	ram0_wra <= fft_ram0_wra when fft_ram0_sel = '1' else mng_wr;
	ram0_ena <= fft_ram0_ena when fft_ram0_sel = '1' else mng_en;
	ram0_addra <= fft_ram0_addra when fft_ram0_sel = '1' else mng_addr;
	ram0_dia <= fft_ram0_dia when fft_ram0_sel = '1' else mng_di;
	
	fft_ram0_doa <= ram0_doa;
	--fft_ram0_doa <= ram0_doa when fft_ram0_sel = '1' else x"0000000000000000";
	
	--mng_do <= ram0_doa when cqt_ram0_sel = '0' else x"0000000000000000";
	
	ram0_wrb <= fft_ram0_wrb when fft_ram0_sel = '1' else '0';
	ram0_enb <= fft_ram0_enb when fft_ram0_sel = '1' else '0';
	ram0_addrb <= fft_ram0_addrb when fft_ram0_sel = '1' else zeros;
	ram0_dib <= fft_ram0_dib when fft_ram0_sel = '1' else x"0000000000000000";
	
	fft_ram0_dob <= ram0_dob;
	--fft_ram0_dob <= ram0_dob when fft_ram0_sel = '1' else x"0000000000000000";
	

	ram1_wra <= fft_ram1_wra when fft_ram1_sel = '1' else mng_wr;
	ram1_ena <= fft_ram1_ena when fft_ram1_sel = '1' else mng_en;
	ram1_addra <= fft_ram1_addra when fft_ram1_sel = '1' else mng_addr;
	ram1_dia <= fft_ram1_dia when fft_ram1_sel = '1' else mng_di;
	
	fft_ram1_doa <= ram1_doa;
	--fft_ram1_doa <= ram1_doa when fft_ram1_sel = '1' else x"0000000000000000";
	
	--mng_do <= ram1_doa when cqt_ram1_sel = '1' else x"0000000000000000";
	
	ram1_wrb <= fft_ram1_wrb when fft_ram1_sel = '1' else '0';
	ram1_enb <= fft_ram1_enb when fft_ram1_sel = '1' else '0';
	ram1_addrb <= fft_ram1_addrb when fft_ram1_sel = '1' else zeros;
	ram1_dib <= fft_ram1_dib when fft_ram1_sel = '1' else x"0000000000000000";
	
	fft_ram1_dob <= ram1_dob;
	--fft_ram1_dob <= ram1_dob when fft_ram1_sel = '1' else x"0000000000000000";

	-- ram0_ena <= kernel_en;
	-- ram0_addra <= kernel_addr(order-1 downto 0);
	
	-- ram1_ena <= kernel_en;
	-- ram1_addra <= kernel_addr(order-1 downto 0);
	
	
	CQT_RAM0 : entity work.kernel_bram
	generic map(
		order => order,
		initfile => kernel0
	)
	port map(
		clka => clk,
		wea  => ram0_wra,
		ena  => ram0_ena,
		dia => ram0_dia,
		doa => ram0_doa,
		addra => ram0_addra,

        clkb => clk,
		web  => ram0_wrb,
		enb  => ram0_enb,
		dib => ram0_dib,
		dob => ram0_dob,
		addrb => ram0_addrb
	);
	
	CQT_RAM1 : entity work.kernel_bram
	generic map(
		order => order,
		initfile => kernel1
	)
	port map(
		clka => clk,
		wea  => ram1_wra,
		ena  => ram1_ena,
		dia => ram1_dia,
		doa => ram1_doa,
		addra => ram1_addra,

        clkb => clk,
		web  => ram1_wrb,
		enb  => ram1_enb,
		dib => ram1_dib,
		dob => ram1_dob,
		addrb => ram1_addrb
	);
	

end str;
