
--I2S master to communicate with Digilent's PMOD i2s2 module
--Port descriptions: 
    --clk12M and rst are from the Artix 7 board
    --adc and dac pins go to pmod pins in i2s_top.xcd
    --BRAM port B pins connect to audio proc
    

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity i2s_top is
	port(
    	clk12M : in std_logic;
    	rst : in std_logic;
    	
    	adc_mclk : out std_logic;
    	adc_lrclk : out std_logic;
    	adc_sclk : out std_logic;
    	
    	dac_mclk : out std_logic;
    	dac_lrclk : out std_logic;
    	dac_sclk : out std_logic;
    	
    	sdin : in std_logic;
    	sdout : out std_logic;
    	
		mono_sound : out std_logic_vector(23 downto 0);
		mono_valid : out std_logic

        );
end i2s_top;

architecture str of i2s_top is 

    signal sync_rst_int : std_logic;
    signal mclk_int : std_logic;
    signal lrclk_int : std_logic;
    signal sclk_int : std_logic;
    
    signal sound_rec : std_logic_vector(23 downto 0) := x"000000";
    signal sound_tra : std_logic_vector(23 downto 0) := x"000000";

    signal ready : std_logic := '0';
    signal valid : std_logic := '0';
    
    signal sdout_int : std_logic;
    signal sdin_int : std_logic;

    signal sclk_n : std_logic;

    signal web : std_logic := '0';
    signal enb : std_logic := '0';
    signal dib : std_logic_vector(23 downto 0) := (others => '0');
    signal addrb : std_logic_vector(8 downto 0) := (others => '0');
    
    signal full_int : std_logic := '0';
    signal active_int : std_logic := '0';
    
	signal leftsound : std_logic_vector(23 downto 0) := (others => '0');
	signal rightsound : std_logic_vector(23 downto 0) := (others => '0');
	signal monosound : std_logic_vector(23 downto 0) := (others => '0');
	signal sampled : std_logic := '0';
    
	signal mono_valid_sig : std_logic := '0';
	
	begin
        
    adc_mclk <= mclk_int;
    adc_lrclk <= lrclk_int;
    adc_sclk <= sclk_int;
    
    dac_mclk <= mclk_int;
    dac_lrclk <= lrclk_int;
    dac_sclk <= sclk_int;
    
    sdin_int <= sdin;
    sdout <= sdout_int;

        
    clocks : entity work.i2s_clk_gen port map(
        clk12M => clk12M,
        rst => rst,
        sync_rst => sync_rst_int,
        mclk => mclk_int,
        lrclk => lrclk_int,
        sclk => sclk_int
        );
       
     receive : entity work.i2s_receiver port map(
     
        sclk => sclk_int,
        lrclk => lrclk_int,
 
        sdin_fpga => sdin_int,

             
        soundin => sound_rec,
     
        valid => valid

    );
   
     transmit : entity work.i2s_transmitter port map(
     
       sclk => sclk_int,
       lrclk => lrclk_int,

       sdout_fpga => sdout_int,

            
       soundout => sound_tra,
       ready => ready

   );

	--mono convereter
	process(clk12M)
		variable left_v : std_logic_vector(23 downto 0);
		variable right_v : std_logic_vector(23 downto 0);
	begin
	
		mono_valid_sig <= '0';
	
		if(valid = '0') then
			sampled <= '0';
		
		elsif(valid = '1' and sampled = '0') then
		
			if(lrclk_int = '0') then
			
				leftsound <= sound_rec;
				
				else
				
				--left_v := leftsound(23) & leftsound(23 downto 1);
				--right_v := sound_rec(23) & sound_rec(23 downto 1);
				left_v := leftsound;
				right_v := sound_rec;
				monosound <= std_logic_vector(signed(left_v) + signed(right_v)); 
				mono_valid_sig <= '1';
		
			end if;
			
		end if;
	
	end process;

	sound_tra <= monosound;
	mono_sound <= monosound;
	mono_valid <= mono_valid_sig;

end str;

 		