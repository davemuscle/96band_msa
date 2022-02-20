-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
         


entity rotary_encoder is
	generic(
		top : integer := 100;
		bottom : integer := 0;
		tick : integer := 1
	);
	port(
		
		clk : in std_logic;
		
		a : in std_logic;
		b : in std_logic;
	
		count  : out integer;
		count_sat : out integer
	
	);
end rotary_encoder;

architecture bhv of rotary_encoder is 
    
	type state_type is ( zero, one, two, three );
	--
	signal q_now : state_type := zero;
	signal q_old : state_type := zero;
	
	signal lead : std_logic;
	
	signal lead_meta : std_logic := '0';
	
	
	signal lead_reg : std_logic := '0';
	signal lead_dly : std_logic := '0';
		
	signal lag : std_logic;
	
	signal lag_meta : std_logic := '0';
	
	signal lag_reg : std_logic := '0';
	signal lag_dly : std_logic := '0';
	
	signal rotary_count : integer := 0;
	signal rotary_count_sat : integer := 0;
	
	signal strobe_up : std_logic := '0';
	signal strobe_down : std_logic := '0';
	
	signal gray : std_logic_vector(1 downto 0) := (others => '0');
	signal gray_old : std_logic_vector(1 downto 0) := (others => '0');

begin

	lead <= a;
	lag <= b;
	
	gray(1) <= lead_reg;
	gray(0) <= lag_reg;
	gray_old(1) <= lead_dly;
	gray_old(0) <= lag_dly;
	
	count <= rotary_count;
	count_sat <= rotary_count_sat;

	--if lead has a falling edge while lag is high -> tick up
	--if lag has a falling edge while lead is high -> tick down
	
	process(clk)
	begin
		if(clk'event and clk = '1') then
		
			--dual flop sync async inputs
			lead_meta <= lead;
			lag_meta <= lag;
			
			lead_reg <= lead_meta;
			lag_reg <= lag_meta;
			
			--delay signal to check past value
			lead_dly <= lead_reg;
			lag_dly <= lag_reg;
			
			q_old <= q_now;
			
			strobe_up <= '0';
			strobe_down <= '0';
			
			case q_now is 
			when zero =>
				
				if(lead_reg = '0' and lead_dly = '1' and lag_reg = '1') then
				
					q_now <= one;
					
				end if;
				
				if(lag_reg = '0' and lag_dly = '1' and lead_reg = '1') then
				
					q_now <= two;
					
				end if;
			
			when one =>
			
				if(q_old = zero) then
					
					if(lag_reg = '0' and lag_dly = '1') then
					
						q_now <= three;
						
					end if;
					
				else
				
					if(lead_reg = '1' and lead_dly = '0') then
					
						q_now <= zero;
						--done, count up 
						strobe_up <= '1';						
						
						if(rotary_count_sat >= top-tick) then
							rotary_count_sat <= top;
						else
							rotary_count_sat <= rotary_count_sat + tick;
						end if;
						
						if(rotary_count = top) then
							rotary_count <= bottom;
						elsif(rotary_count >= top-tick) then
							rotary_count <= top;
						else
							rotary_count <= rotary_count + tick;
						end if;
					
					end if;
				
				end if;
			
			when two =>
			
				if(q_old = zero) then
					if(lead_reg = '0' and lead_dly = '1') then
						q_now <= three;
					end if;
				else
					if(lag_reg = '1' and lag_dly = '0') then
						q_now <= zero;
						--done, count down
						strobe_down <= '1';
						
						if(rotary_count_sat <= bottom+tick) then
							rotary_count_sat <= bottom;
						else
							rotary_count_sat <= rotary_count_sat - tick;
						end if;
						
						if(rotary_count = bottom) then
							rotary_count <= top;
						elsif(rotary_count <= bottom+tick) then
							rotary_count <= bottom;
						else
							rotary_count <= rotary_count - tick;
						end if;
					end if;
					
				end if;
				
			
			when three =>
			
				if(q_old = one) then
					if(lead_reg = '1' and lead_dly = '0') then
						q_now <= two;
					end if;
				else
					if(lag_reg = '1' and lag_dly = '0') then
						q_now <= one;
					end if;
				end if;
			
			when others =>
				--do nothing
			end case;
			

		
		end if;
	end process;
   
end bhv;

 		