-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--writes and reads 64 bit words to external sram (1 byte wide)


entity sram_ctrl is
	port(
		
		clk : in std_logic; --max of 100 MHz? minimum 8 ns read/write times
		rst : in std_logic;
		
		in_data_reg : in std_logic_vector(63 downto 0);
		out_data_reg : out std_logic_vector(63 downto 0);
		in_addr : in unsigned(15 downto 0);
		in_wr : in std_logic;
		in_rd : in std_logic;
		wr_done : out std_logic;
		rd_done : out std_logic;
		
		MemDB : inout std_logic_vector(7 downto 0);
		MemAdr : out unsigned(18 downto 0);
		RamOEn : out std_logic;
		RamWEn : out std_logic;
		RamCEn : out std_logic
		
		
	);
end sram_ctrl;

architecture bhv of sram_ctrl is 

	type state_type is ( reset,
						 idle,
						 readsetup,
						 readbyte,
						 write_control_setup,
						 write_data_setup,
						 writebyte
						);
						
	signal state : state_type := reset;
	
	signal byte_cnt : integer := 0;
	signal byte_sel : unsigned(2 downto 0) := (others => '0');

	signal byte : std_logic_vector(7 downto 0) := (others => '0');
	signal tri_en : std_logic := '0';

begin


	MemAdr <= in_addr & byte_sel;
	--will have read priority, so if in_we and in_oe are true then it only reads
	
	MemDB <= byte when tri_en = '1' else (others => 'Z');
	
	process(clk)
	begin
	
		if(clk'event and clk = '1') then
		
			if(rst = '1') then
				state <= reset;
			
			else
				case state is
				when reset =>
					RamCEn <= '1';
					RamOEn <= '1';
					RamWEn <= '1';
					wr_done <= '0';
					rd_done <= '0';
					if(rst = '0') then
						state <= idle;
					else
						state <= reset;
					end if;
					
				when idle =>
					wr_done <= '0';
					rd_done <= '0';
					RamCEn <= '1';
					RamOEn <= '1';
					RamWEn <= '1';
					if(in_rd = '1') then
					
						--read setup
						state <= readsetup;

						byte_sel <= (others => '0');
						byte_cnt <= 0;
						
					elsif(in_wr = '1') then
					
						--write setup
						state <= write_control_setup;

						byte_sel <= (others => '0');
						byte_cnt <= 0;
						
					else
						state <= idle;
					end if;
					
				when readsetup =>
					
					RamCEn <= '0';
					RamWEn <= '1';
					RamOEn <= '0';
					
					state <= readbyte;
				
					
				when readbyte =>
				
					out_data_reg(8*(byte_cnt+1)-1 downto (8*(byte_cnt))) <= MemDB;
					
					if(byte_cnt = 7) then
						byte_sel <= (others => '0');
						rd_done <= '1';
						byte_cnt <= 0;
						state <= idle;
					else
						byte_sel <= byte_sel + 1;
						byte_cnt <= byte_cnt + 1;
						state <= readbyte;
					end if;
						
				when write_control_setup =>

					RamCEn <= '0';
					RamWEn <= '0';
					RamOEn <= '1';
					
					tri_en <= '0';

					state <= write_data_setup;
					byte <= in_data_reg(8*(byte_cnt+1)-1 downto (8*(byte_cnt)));

				when write_data_setup =>
				
					tri_en <= '1';
					state <= writebyte;
					
				when writebyte =>
		
					tri_en <= '1';
					
					RamWEn <= '1';
					
					if(byte_cnt = 7) then
						byte_sel <= (others => '0');
						wr_done <= '1';
						byte_cnt <= 0;
						state <= idle;
						tri_en <= '0';
					else
						byte_sel <= byte_sel + 1;
						byte_cnt <= byte_cnt + 1;
						state <= write_control_setup;
					end if;
				
				when others =>
				end case;
				
			end if;
		
		end if;
	
	end process;
	

   
end bhv;