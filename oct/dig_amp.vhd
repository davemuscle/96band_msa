library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

--Reads block data and multiplies it


entity dig_amp is
	generic(
		order : integer := 7
	);
	port(
		
		clk : in std_logic;
		
		full_i : in std_logic;
		full_o : out std_logic;
		
		mult : in unsigned(11 downto 0);
		
		en_o : out std_logic;
		addr_o    : out unsigned(order-1 downto 0);
		data_i : in signed(31 downto 0);
		
		en_i : in std_logic;
		addr_i : in unsigned(order - 1 downto 0);
		data_o : out signed(31 downto 0)
		
	);
end dig_amp;

architecture bhv of dig_amp is 
    
	--ram signals-------------------------------------------------------------
	signal ram_ena   : std_logic := '0';
	signal ram_wra   : std_logic := '0';
	signal ram_addra : unsigned(order - 1 downto 0) := (others => '0');
	signal ram_dia   : signed(31 downto 0) := (others => '0');
	signal ram_doa   : signed(31 downto 0) := (others => '0');
	
	signal ram_enb   : std_logic := '0';
	signal ram_addrb : unsigned(order - 1 downto 0) := (others => '0');
	signal ram_dob   : signed(31 downto 0) := (others => '0');
	-----------------------------------------------------------------------------------

	
	
	--control signals------------------------------------------------------------------
	constant pipe_length : integer range 0 to 15 := 8;
	signal   pipe   : std_logic_vector(pipe_length - 1 downto 0) := (others => '0');
	-----------------------------------------------------------------------------------

	signal write_en : std_logic := '0';
	
	signal product : signed(44 downto 0) := (others => '0');
	
	--multiplier is [0] [int, 4 bits], [frac, 8 bits]
	
	--shift right by 8 bits
	signal mult_ext : signed(12 downto 0) := (others => '0');
	
begin

	mult_ext  <= signed('0' & mult);

	process(clk)
	begin
		if(clk'event and clk = '1') then
			
			full_o <= '0';
			
			pipe(pipe_length-1 downto 1) <= pipe(pipe_length-2 downto 0);


			if(full_i = '1') then
				pipe(0) <= '1';
				ram_ena <= '1';
				en_o <= '1';
				--reset addresses
				ram_addra <= (others => '0');
			end if;
			
			--clock one setup read from both ram
			
			--clock two calculate product, setup write
			if(pipe(1) = '1') then
				ram_wra <= '1';
			end if;
			
			product <= mult_ext * data_i;
			
			--clock three increment address, check if finished
			if(pipe(2) = '1') then
				
				pipe <= (others => '0');
				
				ram_wra <= '0';
				
				ram_addra <= ram_addra + 1;
				if(ram_addra = to_unsigned(2**order - 1, order)) then
					pipe(0) <= '0';
					full_o <= '1';
					
					en_o <= '0';
					ram_ena <= '0';
					
				else
					pipe(0) <= '1';

				end if;
				
			end if;
		
		end if;
	end process;
	
	addr_o <= ram_addra;
	ram_dia <= product(39 downto 8); --shift right by 8
   
    data_o <= ram_dob;
	ram_addrb <= addr_i;
	ram_enb <= en_i;
   
   
	--ram for product data
	mult_ram : entity work.fft_bram
	generic map(
		order => order
	)
	port map(
		clka => clk,
		wea => ram_wra,
		ena => ram_ena,
		dia => ram_dia,
		doa => ram_doa,
		addra => ram_addra,

		clkb => clk,
		web => '0',
		enb => ram_enb,
		dib => (others => '0'),
		dob => ram_dob,
		addrb => ram_addrb
	);
   
   
end bhv;