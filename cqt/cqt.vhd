-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Reads FFT data on one port
--Reads spectral kernel on another port
--Matrix multiply to get bin outputs

entity cqt is
	generic(
		SIM   : integer;
		order : integer; --order = log2(fft_size)
		kernel_order : integer;
		kernel_elements : integer;
		numbinslog2 : integer;
		numbins : integer
		);
	port(
	    clk : in std_logic;
		
		cqt_start : in std_logic;
		cqt_busy : out std_logic;
		cqt_done : out std_logic;
		
		kernel_load : out std_logic;
		kernel_ready : in std_logic;
		
		overflow : out std_logic;
	
		--for FFT
		fft_en   : out std_logic;
		fft_addr : out unsigned(order - 1 downto 0);
		fft_data : in signed(63 downto 0);

		
		--for kernel
		kernel_en   : out std_logic;
		kernel_addr : out unsigned(kernel_order - 1 downto 0);
		kernel_data   : in signed(63 downto 0);
		

		--for cqt output
		cqt_en : in std_logic;
		cqt_addr : in unsigned(numbinslog2 - 1 downto 0);
		cqt_data : out signed(63 downto 0)
		

        );
end cqt;

architecture str of cqt is 

	type state_type is ( idle,
						 waitkernel,
						 
						 
						 
						 getkernel,
						 checkbin,
						 getfft,
						 mac1, mac2,
						 store,
						 done
						);
						
	signal state : state_type := idle;

	signal bin_ram_wr : std_logic := '0';
	signal bin_ram_addr : unsigned(numbinslog2 - 1 downto 0) := (others => '0');
	signal bin_ram_data : signed(63 downto 0) := (others => '0');
	signal bin_ram_real, bin_ram_imag : signed(47 downto 0) := (others => '0');
	signal mult_realximag, mult_realxreal : signed(47 downto 0) := (others => '0');
	signal mult_imagximag, mult_imagxreal : signed(47 downto 0) := (others => '0');
	
	signal kernel_cnt : integer := 0;
	
	signal kernel_sel : std_logic := '0';
	signal kernel_read_addr : unsigned(kernel_order - 1 downto 0) := (others => '0');
	--signal kernel_full_addr : unsigned(order downto 0) := (others => '0');
	signal kernel_read_en : std_logic := '0';
	
	signal fft_read_addr : unsigned(order - 1 downto 0) := (others => '0');
	signal fft_read_en : std_logic := '0';
	
	signal binnum : unsigned(15 downto 0) := (others => '0');
	signal activebin : unsigned(15 downto 0) := (0 => '1', others => '0');
	signal fftnum : unsigned(15 downto 0) := (others => '0');

	signal fft_real_sig : signed(31 downto 0);
	signal fft_imag_sig : signed(31 downto 0);
	signal kernel_real_sig : signed(15 downto 0);

	signal kernel_imag_sig : signed(15 downto 0);

	signal final_store : std_logic := '0';

	signal first_read : std_logic := '0';


	signal ov : std_logic := '0';

begin


	overflow <= ov;

	process(clk)
	
		variable fft_real : signed(31 downto 0) := (others => '0');
		variable fft_imag : signed(31 downto 0) := (others => '0');
		variable kernel_real : signed(15 downto 0) := (others => '0');
		variable kernel_imag : signed(15 downto 0) := (others => '0');
	
	begin
	
		if(clk'event and clk = '1') then
		
			--overflow check
			if((bin_ram_real(47) = '0' and bin_ram_real(46) = '1') or
			   (bin_ram_real(47) = '1' and bin_ram_real(46) = '0')) then
		
				ov <= '1';
				
			end if;
			
			--overflow check
			if((bin_ram_imag(47) = '0' and bin_ram_imag(46) = '1') or
			   (bin_ram_imag(47) = '1' and bin_ram_imag(46) = '0')) then
		
				ov <= '1';
				
			end if;
					
		
			case state is 
			when idle =>
				
				cqt_busy <= '0';
				cqt_done <= '0';
				kernel_load <= '0';
			
				if(cqt_start = '1') then
					state <= waitkernel;
					
					kernel_load <= '1';
					
					kernel_sel <= '0'; --reset kernel select to zero
					
					activebin <= (0 => '1', others => '0'); --reset to zero
					
					cqt_busy <= '1';
					
					first_read <= '1';
					
				end if;
			
			when waitkernel =>
			
				kernel_load <= '0';
			
				if(kernel_ready = '1') then
				
					kernel_read_en <= '1';
					kernel_read_addr <= (others => '0');
					state <= getkernel;
					
				end if;
				
			when getkernel =>
				
				state <= checkbin;
				
			when checkbin =>
			
				if(first_read = '1') then
					
					first_read <= '0';
					activebin <= unsigned(kernel_data(63 downto 48));
					state <= getfft;
					
				else
				
					if(unsigned(kernel_data(63 downto 48)) /= activebin) then
					
						state <= store;
	
					else
					
						state <= getfft;
						
					end if;
				
				end if;
				
				binnum <= unsigned(kernel_data(63 downto 48));
				fftnum <= unsigned(kernel_data(47 downto 32));
										
			when store =>
			
				bin_ram_wr <= '1';
				bin_ram_addr <= activebin(numbinslog2 -1 downto 0) - 1; --fixing MATLAB indexing


				bin_ram_data <= bin_ram_real(46 downto 15) & bin_ram_imag(46 downto 15); --divide by 32K?

				--bin_ram_data <= bin_ram_real(31 downto 0) & bin_ram_imag(31 downto 0); -- no divide for easy sim
				
				if(bin_ram_wr = '1') then
					activebin <= binnum;
					bin_ram_wr <= '0';
					bin_ram_real <= (others => '0');
					bin_ram_imag <= (others => '0');
					bin_ram_data <= (others => '0');
					
					if(final_store = '1') then
						final_store <= '0';
						cqt_done <= '1';
						state <= idle;
					else
						state <= getfft;
					end if;
					
				end if;
				
			when getfft =>
			
				fft_read_en <= '1';
				fft_read_addr <= fftnum(order-1 downto 0) - 1; --fixing MATLAB indexing
				
				if(fft_read_en = '1') then
				
				
					fft_read_en <= '0';
					
					--read finished
					state <= mac1;
				
				end if;
			
			when mac1 =>
			
				fft_real := fft_data(63 downto 32);
				fft_imag := fft_data(31 downto 0);
				kernel_real := kernel_data(31 downto 16);
				kernel_imag := kernel_data(15 downto 0);
			
				--complex multiply and accumulate, legacy code:
				--bin_ram_real <= bin_ram_real + ((fft_real * kernel_real) - (fft_imag * kernel_imag));
				--bin_ram_imag <= bin_ram_imag + ((fft_imag * kernel_real) + (fft_real * kernel_imag));

				
				mult_realxreal <= fft_real*kernel_real;
				mult_realximag <= fft_real*kernel_imag;
				mult_imagxreal <= fft_imag*kernel_real;
				mult_imagximag <= fft_imag*kernel_imag;
				
				state <= mac2;
				
			when mac2 =>
				
				--add with an extra bit for sign / overflow check
				bin_ram_real <= bin_ram_real + 
								mult_realxreal - 
								mult_imagximag;
				
				bin_ram_imag <= bin_ram_imag + 
							    mult_imagxreal + 
								mult_realximag;
				
				
				if(kernel_read_addr = to_unsigned(kernel_elements-1, kernel_order)) then
					kernel_read_addr <= (others => '0');
					state <= store;
					final_store <= '1';
				else
					kernel_read_addr <= kernel_read_addr + 1;
					state <= getkernel;
				end if;
				
			when others =>
			end case;
		
		end if;
	
	end process;

	kernel_addr <= kernel_read_addr;
	kernel_en <= kernel_read_en;
	
	fft_addr <= fft_read_addr;
	fft_en <= fft_read_en;
	
	BIN_RAM : entity work.fft_bram64
	generic map(
		order => numbinslog2
	)
	port map(
		clka => clk,
		wea  => bin_ram_wr,
		ena  => bin_ram_wr,
		dia => bin_ram_data,
		doa => open,
		addra => bin_ram_addr,

		--only reading port B
        clkb => clk,
		web  => '0',
		enb  => cqt_en,
		dib => x"0000000000000000",
		dob => cqt_data,
		addrb => cqt_addr
	);
	
	

end str;
