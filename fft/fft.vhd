library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Radix 2 Fixed Point FFT
--Single Block RAM of N size
	--To add: twiddle factor rom reduction
	
--General flow of this algorithm
	--Step1: (fill)
		--Read data from internal BRAM
		--Read it in bitreversed order
		--Perform the first stage two point butterfly (just + and -)
		--Store into RAM in natural order
		
	--Step2: (fft)
		--Perform each stage of the FFT
			--a stage consists of running through two point butterflies
			--the only difference between successive states is the twiddle address generation
			
	--Step3: (finished)
		--Pulse the done signal and let the RAM be read from
		
		
entity fft is
	generic(
		order : integer; --order = log2(fft_size)
		coslutfile : string;
		scale_on_stage : string; --NONE, BOTH, EVEN, ODD
		ram_loc : string --INT, EXT
		);
	port(
	    clk : in std_logic;
	    
		start : in std_logic;
		done  : out std_logic;
		
		loading  : out std_logic;
		busy  : out std_logic;
		
		overflow : out std_logic;
		
		in_qdata : in signed(31 downto 0);
		in_idata : in signed(31 downto 0);
		in_addr : out unsigned(order-1 downto 0);
		in_en   : out std_logic;
		
		out_qdata : out signed(31 downto 0);
		out_idata : out signed(31 downto 0);
		out_addr : in unsigned(order-1 downto 0);
		out_en : in std_logic;
		
		--external block ram ports
		ext_ram_wra : out std_logic;
		ext_ram_ena : out std_logic;
		ext_ram_dia : out signed(63 downto 0);
		ext_ram_doa : in signed(63 downto 0);
		ext_ram_addra : out unsigned(order-1 downto 0);
		
		ext_ram_wrb : out std_logic;
		ext_ram_enb : out std_logic;
		ext_ram_dib : out signed(63 downto 0);
		ext_ram_dob : in signed(63 downto 0);
		ext_ram_addrb : out unsigned(order-1 downto 0)

		

        );
end fft;

architecture str of fft is 

	--signals for pipelining-------------------------------------------------------
	signal start_dly : std_logic := '0';
	signal pipe_latch : std_logic := '0';
	constant pipe_len : integer := 16;
	signal pipe  : std_logic_vector(pipe_len - 1 downto 0) := (others => '0');
	-------------------------------------------------------------------------------

	--control signals--------------------------------------------------------------
	signal stage : integer range 0 to order := 0;
	signal toggle_a_b : std_logic := '0';
	signal load_en : std_logic := '0';
	-------------------------------------------------------------------------------

	--signals controlled by FFT----------------------------------------------------
	signal read_addr, write_addr : unsigned(order - 1 downto 0) := (others => '0');
	signal read_en, write_en   : std_logic := '0';
	-------------------------------------------------------------------------------
	
	--bit reversals and address delays---------------------------------------------
	signal read_addr_rv, write_addr_rv : unsigned(order - 1 downto 0) := (others => '0');
	signal write_addr_dly, read_addr_dly : unsigned(order-1 downto 0) := (others => '0');
	signal read_addr_rv_dly1, read_addr_rv_dly2 : unsigned(order - 1 downto 0) := (others => '0');
	-------------------------------------------------------------------------------

	--data input and delays--------------------------------------------------------
	signal a_q_data, a_q_data_dly : signed(31 downto 0) := (others => '0');
	signal a_i_data, a_i_data_dly : signed(31 downto 0) := (others => '0');
	signal b_q_data : signed(31 downto 0) := (others => '0');
	signal b_i_data : signed(31 downto 0) := (others => '0');
	-------------------------------------------------------------------------------
	
	--complex math, results and delays------------------------------------------------
	signal cm_a_ac, cm_a_ad, cm_a_bc, cm_a_bd : signed(47 downto 0) := (others => '0');
	signal cm_b_ac, cm_b_ad, cm_b_bc, cm_b_bd : signed(47 downto 0) := (others => '0');
	
	signal a_q_result : signed(32 downto 0) := (others => '0');
	signal a_i_result : signed(32 downto 0) := (others => '0');
	signal b_q_result, b_q_result_dly : signed(32 downto 0) := (others => '0');
	signal b_i_result, b_i_result_dly : signed(32 downto 0) := (others => '0');
	----------------------------------------------------------------------------------

	--RAM connect signals-------------------------------------------------------
	signal ram_wra, ram_wrb : std_logic := '0';
	signal ram_ena, ram_enb : std_logic := '0';
	signal ram_dia, ram_dib : signed(63 downto 0) := (others => '0');
	signal ram_doa, ram_dob : signed(63 downto 0) := (others => '0');
	signal ram_addra, ram_addrb : unsigned(order-1 downto 0) := (others => '0');
	----------------------------------------------------------------------------

	--twiddle factor addresses and data-----------------------------------------
	signal twid_en : std_logic := '0';
	
	signal in_a_qtwid : signed(15 downto 0) := (others => '0');
	signal in_a_itwid : signed(15 downto 0) := (others => '0');
	signal in_b_qtwid : signed(15 downto 0) := (others => '0');
	signal in_b_itwid : signed(15 downto 0) := (others => '0');
	
	signal twid_addr_mult : unsigned(2*order - 1 downto 0) := (others => '0');
	signal twid_addr_pre : unsigned(order - 1 downto 0) := (others => '0');
	signal twid_addr_cos, twid_addr_sin : unsigned(order - 1 downto 0) := (others => '0');
	-----------------------------------------------------------------------------
	
	signal mult_in_signs1 : std_logic_vector(7 downto 0) := (others => '0');
	signal mult_in_signs2 : std_logic_vector(7 downto 0) := (others => '0');
	signal mult_out_signs : std_logic_vector(7 downto 0) := (others => '0');
	
	signal ov : std_logic_vector(3 downto 0) := (others => '0');
	signal ov_latch : std_logic := '0';
	
	signal ram_dib_temp1, ram_dib_temp2 : signed(63 downto 0) := (others => '0');
	
	constant shift : unsigned(order - 1 downto 0) := to_unsigned(((2**order)/4),order);
	
begin
	
	
	--mux data going into process between external port and internal ram
	b_q_data <= in_qdata when stage = 0 else ram_doa(63 downto 32);
	b_i_data <= in_idata when stage = 0 else ram_doa(31 downto 0);

	twid_addr_pre(order - 1 downto 0) <= read_addr_dly when stage = 0 else read_addr_rv;

	process(a_q_result, a_i_result, b_q_result, b_i_result)
	begin
		ov(0) <= a_q_result(32) xor a_q_result(31);
		ov(1) <= a_i_result(32) xor a_i_result(31);
		ov(2) <= b_q_result(32) xor b_q_result(31);
		ov(3) <= b_i_result(32) xor b_i_result(31);
	end process;
	
	overflow <= ov_latch;
	
	process(clk)
	begin
		if(clk'event and clk = '1') then
			
			done <= '0';
			
			--delay the start signals
			start_dly <= start;
			
			--delay the input data for reading
			a_q_data <= b_q_data;
			a_i_data <= b_i_data;
	
			--delay once again for complex add
			a_q_data_dly <= a_q_data;
			a_i_data_dly <= a_i_data;

			
			--complex multiplies + adds
			--(a + jb) * (c - jd) = b_data * twiddle
			-- = a*c + j*(bc - ad) + bd
			--calculate the multiplies in one clock, and the add / sub in the next
			cm_a_ac <= b_q_data * in_a_qtwid;
			cm_a_ad <= b_q_data * in_a_itwid;
			cm_a_bc <= b_i_data * in_a_qtwid;
			cm_a_bd <= b_i_data * in_a_itwid;
			
			cm_b_ac <= b_q_data * in_b_qtwid;
			cm_b_ad <= b_q_data * in_b_itwid;
			cm_b_bc <= b_i_data * in_b_qtwid;
			cm_b_bd <= b_i_data * in_b_itwid;
			
			--adds and subtracts
			a_q_result <= (a_q_data_dly(31) & a_q_data_dly) + cm_a_ac(46 downto 14) + cm_a_bd(46 downto 14);
			a_i_result <= (a_i_data_dly(31) & a_i_data_dly) + cm_a_bc(46 downto 14) - cm_a_ad(46 downto 14);

			b_q_result <= (a_q_data_dly(31) & a_q_data_dly) + cm_b_ac(46 downto 14) + cm_b_bd(46 downto 14);
			b_i_result <= (a_i_data_dly(31) & a_i_data_dly) + cm_b_bc(46 downto 14) - cm_b_ad(46 downto 14);
			
			--bit reversal on the read address, based on stage
			read_addr_rv <= read_addr;
			for i in 0 to order-1 loop
				if(stage = 0) then
					read_addr_rv(order-1 - i) <= read_addr(i);
				else
					read_addr_rv(stage - i) <= read_addr(i);
					if(i = stage) then
						exit;
					end if;
				end if;
			end loop;
					
			--bit reversal on the write address, based on stage
			write_addr_rv <= write_addr;
			for i in 0 to order-1 loop
				if(stage = 0) then
					write_addr_rv(order-1 - i) <= write_addr(i);
				else
					write_addr_rv(stage - i) <= write_addr(i);
					if(i = stage) then
						exit;
					end if;
				end if;
			end loop;
					
			
			--generate the twiddle address for nth stage (above 0)
			--multiply by the FFT size (shift right by order)
			twid_addr_mult(order - 1 downto 0) <= (others => '0');
			twid_addr_mult(2*order - 1 downto order) <= twid_addr_pre;
			
			--shift right, based on stage (divide proportional to stage)
			twid_addr_cos <= twid_addr_mult(stage + 1 + (order - 1) downto stage + 1);
		
			twid_addr_sin <= twid_addr_mult(stage + 1 + (order - 1) downto stage + 1) - shift;
		
			--twiddle delay
			in_a_qtwid <= in_b_qtwid;
			in_a_itwid <= in_b_itwid;
			
			--delay read address
			read_addr_dly <= read_addr;
			
			read_addr_rv_dly1 <= read_addr_rv;
			read_addr_rv_dly2 <= read_addr_rv_dly1;
			
			--delay write address
			write_addr_dly <= write_addr;

			--delay the result for writing
			b_q_result_dly <= b_q_result;
			b_i_result_dly <= b_i_result;
			
			--overflow flipflop set
			for i in 0 to 3 loop
				if(ov(i) = '1') then
					ov_latch <= '1';
				end if;
			end loop;
			
			----------------------------------------------------
			--register the start signal on a rising edge
			if(start_dly = '0' and start = '1') then
				pipe_latch <= '1';
				
				--reset the fill stage addresses
				read_addr <= (others => '0');
				write_addr <= (others => '0');
				
				--reset load signal
				load_en <= '0';
				busy <= '1';
				loading <= '0';
				
			end if;
			
			--pipeline the start signal enable
			pipe(0) <= pipe_latch;
			pipe(pipe_len - 1 downto 1 ) <= 
					pipe(pipe_len - 2 downto 0);
			
			--fill + first stage control pipelining
				if(pipe(0) = '1') then
				
					--this will setup the read
					read_en   <= '1';

				end if;
				
				if(pipe(1) = '1') then
					read_addr <= read_addr + 1;	
				end if;
		
				if(pipe(6) = '1') then					
					--setup write
					write_en <= '1';

				end if;
				
				if(pipe(7) = '1') then
					write_addr <= write_addr + 1;

				end if;
				
				if(pipe(8) = '1') then
					toggle_a_b <= not toggle_a_b;

					if(write_addr_dly = to_unsigned(2**order - 1, order)) then

						pipe <= (others => '0');
						pipe_latch <= '0';
						write_en <= '0';
						read_en <= '0';
						
						if(stage = order-1) then
							done <= '1';
							load_en <= '1';
							loading <= '1';
							busy <= '0';
							stage <= 0;
							
						else
							stage <= stage + 1;
							pipe_latch <= '1';
							--reset the fill stage addresses
							read_addr <= (others => '0');
							write_addr <= (others => '0');
				
						end if;
						
					else
						write_addr <= write_addr + 1;
					end if;
					
				end if;
		
		end if;
	end process;
	


	out_qdata <= ram_doa(63 downto 32);
	out_idata <= ram_doa(31 downto 0);
	

	ram_addrb <= write_addr_dly when stage = 0 else write_addr_rv;
	ram_enb <= write_en when load_en = '0' else out_en;
	ram_wrb <= write_en;
	
	in_addr <= read_addr_rv_dly2;
	in_en <= read_en when stage = 0 else '0';
	twid_en <= read_en;
	
	--read port, muxed with external reader
	ram_addra <= out_addr when load_en = '1' else read_addr_rv_dly2;
	ram_ena <= out_en when load_en = '1' else read_en;
	ram_wra <= '0';
	
	--generate the scaling for the input to the block ram
	--NONE = no scaling
	--BOTH = divide by 2 on each stage
	--EVEN = divide by 2 on even stages (approx equal to 1/sqrt(2) each stage)
	--ODD = divide by 2 on odd stages (approx equal to 1/sqrt(2) each stage)

	WRITE_DATA_GEN_NONE : if scale_on_stage = "NONE" generate
	
		ram_dib(31 downto 0) <= a_i_result(31 downto 0) when toggle_a_b = '0' else b_i_result_dly(31 downto 0);
		ram_dib(63 downto 32) <= a_q_result(31 downto 0) when toggle_a_b = '0' else b_q_result_dly(31 downto 0);
	
	end generate WRITE_DATA_GEN_NONE;
	
	WRITE_DATA_GEN_BOTH : if scale_on_stage = "BOTH" generate
	
		ram_dib(31 downto 0) <= a_i_result(31) & a_i_result(31 downto 1) when toggle_a_b = '0' else b_i_result_dly(31) & b_i_result_dly(31 downto 1);
		ram_dib(63 downto 32) <= a_q_result(31) & a_q_result(31 downto 1) when toggle_a_b = '0' else b_q_result_dly(31) & b_q_result_dly(31 downto 1);
	
	end generate WRITE_DATA_GEN_BOTH;
	
	WRITE_DATA_GEN_EVEN : if scale_on_stage = "EVEN" generate

		ram_dib_temp1(31 downto 0) <= a_i_result(31) & a_i_result(31 downto 1) when toggle_a_b = '0' else b_i_result_dly(31) & b_i_result_dly(31 downto 1);
		ram_dib_temp1(63 downto 32) <= a_q_result(31) & a_q_result(31 downto 1) when toggle_a_b = '0' else b_q_result_dly(31) & b_q_result_dly(31 downto 1);

		ram_dib_temp2(31 downto 0) <= a_i_result(31 downto 0) when toggle_a_b = '0' else b_i_result_dly(31 downto 0);
		ram_dib_temp2(63 downto 32) <= a_q_result(31 downto 0) when toggle_a_b = '0' else b_q_result_dly(31 downto 0);
	
		ram_dib <= ram_dib_temp1 when (stage mod 2 = 0) else ram_dib_temp2;

	end generate WRITE_DATA_GEN_EVEN;
	
	WRITE_DATA_GEN_ODD : if scale_on_stage = "ODD" generate
	
		ram_dib_temp1(31 downto 0) <= a_i_result(31) & a_i_result(31 downto 1) when toggle_a_b = '0' else b_i_result_dly(31) & b_i_result_dly(31 downto 1);
		ram_dib_temp1(63 downto 32) <= a_q_result(31) & a_q_result(31 downto 1) when toggle_a_b = '0' else b_q_result_dly(31) & b_q_result_dly(31 downto 1);

		ram_dib_temp2(31 downto 0) <= a_i_result(31 downto 0) when toggle_a_b = '0' else b_i_result_dly(31 downto 0);
		ram_dib_temp2(63 downto 32) <= a_q_result(31 downto 0) when toggle_a_b = '0' else b_q_result_dly(31 downto 0);
	
		ram_dib <= ram_dib_temp1 when (stage mod 2 = 1) else ram_dib_temp2;
		
	end generate WRITE_DATA_GEN_ODD;
	
	RAM_GEN_INT : if ram_loc = "INT" generate
	
		--generate and connect internal ram
		FFT_RAM : entity work.fft_bram64 
		generic map(
			order => order
		)
		port map(
			clka => clk,
			wea  => ram_wra,
			ena  => ram_ena,
			dia => ram_dia,
			doa => ram_doa,
			addra => ram_addra,

			clkb => clk,
			web  => ram_wrb,
			enb  => ram_enb,
			dib => ram_dib,
			dob => ram_dob,
			addrb => ram_addrb
		);
	
	end generate RAM_GEN_INT;

	RAM_GEN_EXT : if ram_loc = "EXT" generate
		--connect internal ram signals to external port
		ext_ram_wra <= ram_wra;
		ext_ram_ena <= ram_ena;
		ext_ram_addra <= ram_addra;
		ext_ram_dia <= ram_dia;
		ram_doa <= ext_ram_doa;
		
		ext_ram_wrb <= ram_wrb;
		ext_ram_enb <= ram_enb;
		ext_ram_addrb <= ram_addrb;
		ext_ram_dib <= ram_dib;
		ram_dob <= ext_ram_dob;
	end generate RAM_GEN_EXT;

	TWIDDLES: entity work.fft_twiddles
	generic map(
		order => order,
		coslutfile => coslutfile
	)
	port map(
		clk => clk,
		en => twid_en,
		addr_cos => twid_addr_cos,
		addr_sin => twid_addr_sin,
		cos => in_b_qtwid,
		sin => in_b_itwid
	);

	
end str;
