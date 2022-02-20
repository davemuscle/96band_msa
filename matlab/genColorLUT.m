numbins = 80;
maxredblue = (2^5) - 1;
maxgreen = (2^6) - 1;

temp = 3.1;

red_mod = 2*maxredblue / (numbins / temp);
green_mod = 2*maxgreen / (numbins / temp);
blue_mod = red_mod;

red = maxredblue;
green = 0;
blue = 0;

stage = 0;
colormat = zeros(numbins, 3);

i = 1;

while(i <= numbins)
    
    colormat(i, 1) = red;
    colormat(i, 2) = green;
    colormat(i, 3) = blue;
    
    if(stage == 0)
        
        green = green + green_mod;
        
        if(green >= maxgreen)
            
            green = maxgreen;
            stage = 1;
        end
    elseif(stage == 1)
    
        red = red - red_mod;
        
        if(red <= 0.001)
            
            red = 0;
            stage = 2;
            
        end 
        
    elseif(stage == 2)
        
        blue = blue + blue_mod;
        
        if(blue >= maxredblue)
            
            blue = maxredblue;
            stage = 3;
            
        end
        
    elseif(stage == 3)
    
        green = green - green_mod;
        
        if(green <= 0.001)
                
            green = 0;
            stage = 4;
            
        end 
        
    elseif(stage == 4)
        
        red = red + red_mod;
        
        if(red >= maxredblue)
            
            red = maxredblue;
            stage = 5;
            
        end
        
    elseif(stage == 5)
        
        blue = blue - blue_mod;
        
        if(blue <= 0.001) 
            
            blue = 0;
            
        end
        

    end
        
    i = i + 1;
    
    
end
    
colormat = round(colormat);
colormat_int = uint16(zeros(1,numbins));

for i = 1:numbins
temp = colormat(i,1) * (2^11) + colormat(i,2)*(2^5) + colormat(i,3);
colormat_int(1,i) = uint16(temp);
end

bitcolorlut = cellstr(dec2bin(colormat_int, 16));
fid = fopen(['colorLUT.data'], 'wt');
fprintf(fid, '%s\n', bitcolorlut{:});
fclose(fid);

subplot(3,1,1);
plot(colormat(:,1));
title('red');

subplot(3,1,2);
plot(colormat(:,2));
title('green');

subplot(3,1,3);
plot(colormat(:,3));
title('blue');