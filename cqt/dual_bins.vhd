-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dual_bins is
	generic(
		inputorder : integer;
		inputnumbins : integer;
		outputorder : integer;
		outputnumbins : integer
		);
	port(
	    clk : in std_logic;
		
		start : in std_logic;
		done : out std_logic;
	
		--cqt -> dual bins

		cqt_en : out std_logic;
		cqt_addr : out unsigned(inputorder - 1 downto 0);
		cqt_data : in signed(63 downto 0);
		
		--dual bins -> cqt mag
		read_en : in std_logic;
		read_addr : in unsigned(outputorder - 1 downto 0);
		read_data : out signed(63 downto 0)
		
		

        );
end dual_bins;

architecture str of dual_bins is 

	signal start_dly : std_logic := '0';
	signal start_reg : std_logic := '0';
	
	signal fill : std_logic := '0';
	signal fill_dly : std_logic := '0';
	
	signal inner_read_addr : unsigned(inputorder - 1 downto 0) := (others => '0');
	signal fill_en : std_logic;
	signal read_full_addr : unsigned(outputorder-1 downto 0) := (others => '0');
	
	signal clk_dly : std_logic := '0';
	signal clk_dly2 : std_logic := '0';

begin

	process(clk)
	begin
		if(clk'event and clk = '1') then
		
			start_reg <= start;
			start_dly <= start_reg;
		
			fill_dly <= fill;
			
			done <= '0';
			
			if(start_dly = '0' and start_reg = '1') then
				inner_read_addr <= (others => '0');
				fill <= '1';
			end if;
			
			if(fill_dly = '1') then
			
				if(inner_read_addr = to_unsigned(inputnumbins - 1, inputorder)) then
					fill <= '0';
					inner_read_addr <= (others => '0');
				else
					inner_read_addr <= inner_read_addr + 1;
				end if;
			
				if(read_full_addr = to_unsigned(outputnumbins - 1, outputorder)) then
					read_full_addr <= (others => '0');
					done <= '1';
				else
					read_full_addr <= read_full_addr + 1;
				end if;
				
				fill_dly <= '0';
				
				
			end if;
			
		
		end if;
	end process;

	fill_en <= fill;

	cqt_addr <= inner_read_addr;
	cqt_en <= fill_en;
	
	
	BIN_RAM : entity work.fft_bram64
	generic map(
		order => outputorder
	)
	port map(
		--write to port A
		clka => clk,
		wea  => fill_en,
		ena  => fill_en,
		dia => cqt_data,
		doa => open,
		addra => read_full_addr,

		--read from port B
        clkb => clk,
		web  => '0',
		enb  => read_en,
		dib => x"0000000000000000",
		dob => read_data,
		addrb => read_addr
	);
	
	

end str;
