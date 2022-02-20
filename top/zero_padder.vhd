library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
         
entity zero_padder is
	generic(
		input_length_log2 : integer;
		output_length_log2 : integer
	);
	port(

		d_i : in signed(31 downto 0);
		addr_o : out unsigned(input_length_log2-1 downto 0);

		d_o : out signed(31 downto 0);
		addr_i : in unsigned(output_length_log2-1 downto 0)
		
	);
end zero_padder;

architecture bhv of zero_padder is 
      
begin

	process(addr_i, d_i)
	begin
	
		if(addr_i < to_unsigned((2**input_length_log2), output_length_log2)) then
			d_o <= d_i;
			addr_o <= addr_i(input_length_log2 - 1 downto 0);
		else
			d_o <= (others => '0');
			addr_o <= (others => '0');
		end if;
	
	end process;
   
end bhv;

 		