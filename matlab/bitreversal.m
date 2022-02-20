function [ bababooey ] = bitreversal(bits, N )

    bababooey = bits;

    for g = 1:log2(N)
        
        b_t = bitget(bits, g);
        bababooey = bitset(bababooey, log2(N)-(g-1), b_t);
        
    end 

end
