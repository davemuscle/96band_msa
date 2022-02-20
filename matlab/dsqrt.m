x = 268435456;

mask = 2^30;

root = 0;
remainder = x;

while(mask)
   
    if((root + mask) <= remainder)
        remainder = remainder - (root + mask);
        root = root + (2*mask);
    end
    if(root < 2)
        root = 0;
    else
        root = root / 2;
    end
    if(mask < 4)
        mask = 0;
    else
        mask = mask /4;
    end
    
    
    
end

root
remainder