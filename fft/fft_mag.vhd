library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fft_mag is
	generic(
		order : integer --order = log2(fft_size)
		);
	port(
	    clk : in std_logic;
	    
		fft_done : in std_logic;
		mag_done  : out std_logic;

		overflow : out std_logic;
		
		max_bin : out unsigned(order-1 downto 0);
		
		in_qdata : in signed(31 downto 0);
		in_idata : in signed(31 downto 0);
		in_addr : out unsigned(order-1 downto 0);
		in_en   : out std_logic;
		
		out_data : out unsigned(31 downto 0);
		out_addr : in unsigned(order-1 downto 0);
		out_en : in std_logic
	   

        );
end fft_mag;

architecture str of fft_mag is 

	signal proc_rd_en : std_logic := '0';
	signal proc_wr_en : std_logic := '0';
	
	signal proc_rd_addr : unsigned(order - 1 downto 0) := (others => '0');
	signal proc_wr_addr : unsigned(order - 1 downto 0) := (others => '0');

	signal proc_qdata : signed(31 downto 0) := (others => '0');
	signal proc_idata : signed(31 downto 0) := (others => '0');
	signal proc_result : unsigned(31 downto 0) := (others => '0');
	
	signal proc_sum : unsigned(63 downto 0) := (others => '0');

	signal zeros : unsigned(order-1 downto 0) := (others => '0');
	signal ones : unsigned(order-1 downto 0) := (others => '1');
	

	signal sqrt_load : std_logic := '0';
	signal sqrt_done : std_logic := '0';
	signal sqrt_busy : std_logic := '0';
	signal sqrt_res : unsigned(31 downto 0);

	
	signal bin_calc : unsigned(order - 1 downto 0) := (others => '0');
	
	signal prev_result : unsigned(31 downto 0) := (others => '0');
	
	signal out_data_temp : signed(31 downto 0) := (others => '0');
	
	signal tempwrite : signed(31 downto 0) := (others => '0');

	
	
	signal mag_pipe : std_logic_vector(7 downto 0) := (others => '0');
	signal sqrt_done_dly : std_logic := '0';

	signal real_squared : signed(63 downto 0) := (others => '0');
	signal imag_squared : signed(63 downto 0) := (others => '0');
	signal sum_squared  : signed(63 downto 0) := (others => '0');

	signal real_sign : std_logic := '0';
	signal imag_sign  : std_logic := '0';

	signal overflow_int : std_logic := '0';

begin
	
	in_addr <= proc_rd_addr;
	in_en <= proc_rd_en;
	proc_qdata <= in_qdata;
	proc_idata <= in_idata;

	overflow <= overflow_int;

	process(clk) 

		variable bigsum : signed(63 downto 0) := (others => '0');
	begin
	
		if(clk'event and clk = '1') then
		
		
			mag_done <= '0';
		
			mag_pipe(7 downto 1) <= mag_pipe(6 downto 0);
			mag_pipe(0) <= '0';

			sqrt_done_dly <= '0';
			sqrt_load <= '0';
		
			if(fft_done = '1') then
			
				--data has been loaded into bram
				
				mag_pipe(0) <= '1';
				
				--reset addresses
				proc_rd_addr <= (others => '0');
				proc_wr_addr <= (others => '0');
				proc_rd_en <= '1';
				
				--reset max_bin
				bin_calc <= (others => '0');
			
			end if;
		
			if(mag_pipe(0) = '1') then
			
				--ram has been read from
				
				--turn off read since pipe has to be stalled for sqrt
				proc_rd_en <= '0';
			
			end if;
			
			if(mag_pipe(1) = '1') then
			
				real_squared <= proc_qdata * proc_qdata;
				imag_squared <= proc_idata * proc_idata;
		
			end if;
			
			if(mag_pipe(2) = '1') then
			
				real_sign <= real_squared(63);
				imag_sign <= imag_squared(63);

				sum_squared <= real_squared + imag_squared;

				
			end if;
			
			if(mag_pipe(3) = '1') then
				proc_sum <= unsigned(sum_squared);

				sqrt_load <= '1';
				
				if((real_sign = '1' and imag_sign = '1' and sum_squared(63) = '0') or 
				   (real_sign = '0' and imag_sign = '0' and sum_squared(63) = '1')) then
					
						overflow_int <= '1';
						
				end if;
				
			end if;
			--sqrt modules have been loaded
		
			--check if sqrt is finished
			if(sqrt_done = '1') then

				--setup write
				proc_wr_en <= '1';
				proc_result <= sqrt_res;
				
				sqrt_done_dly <= '1';

			end if;
				

			if(sqrt_done_dly = '1') then
			
				proc_wr_en <= '0';
				
				mag_pipe <= (others => '0');
				
				
				
				--setup next read addresses
				proc_rd_en <=  '1';
				proc_rd_addr <= proc_rd_addr + 1;
			

				--max bin calculation
				if(proc_wr_addr = zeros) then

					--don't use dc bin for max bin
					prev_result <= (others => '0');
				
				else
				
					if(proc_result > prev_result) then
					
						prev_result <= proc_result;
						bin_calc <= proc_wr_addr;
					
					end if;
				
				end if;
			
			
				--do write
				--check if end of write
				if(proc_wr_addr = ones) then
				
					mag_done <= '1';
					
					max_bin <= bin_calc;
					--max_freq <= 
				
					
					else
					
					proc_wr_addr <= proc_wr_addr + 1;
				
					proc_rd_en <= '1';
					mag_pipe(0) <= '1';
				
				end if;

			end if;
		end if;
		
	
	end process;
	
	
	SQRT : entity work.sqrt
	port map(
		clk => clk,
		load => sqrt_load,
	    done => sqrt_done,
		busy => sqrt_busy,
		input => proc_sum,
		output => sqrt_res
	);
	
	out_data <= unsigned(out_data_temp);
	tempwrite <= signed(proc_result);
	
	BRAM_mag : entity work.fft_bram
	generic map(
		order => order
	)
	port map(
		clka => clk,
		wea  => proc_wr_en,
		ena  => proc_wr_en,
		dia => tempwrite,
		doa => open,
		addra => proc_wr_addr(order-1 downto 0),

        clkb => clk,
		web  => '0',
		enb  => out_en,
		dib => (others => '0'),
		dob => out_data_temp,
		addrb => out_addr

	);

end str;
