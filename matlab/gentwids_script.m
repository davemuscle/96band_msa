

for ii = 1:13
    N = 2^ii;
    
    cos_vec = {};
    sin_vec = {};

    costwids = cos(2*pi*(0:N-1)/N);
    sintwids = sin(2*pi*(0:N-1)/N);


    for i = 1:N

        if(abs(costwids(i)) < 10^-5)

            costwids(i) = 0;
        end

        if(abs(sintwids(i)) < 10^-5)

            sintwids(i) = 0;

        end

    end

    cos_scaled = costwids * 16384;
    sin_scaled = sintwids * 16384;
    cos_scaled = round(cos_scaled);
    sin_scaled = round(sin_scaled);

    t = zeros(1,N);
    
    for i = 1:N
        
        if(cos_scaled(i) < 0)
            t(i) = uint16(-1*cos_scaled(i));
            t(i) = bitxor(t(i), uint16((2^16)-1));
            t(i) = t(i) + 1;
            
            
        else
            
            t(i) = int16(cos_scaled(i));

        end 
        
        cos_vec = cellstr(dec2bin(t,16));
        
    end
    
    for i = 1:N
        
        if(sin_scaled(i) < 0)
            t(i) = uint16(-1*sin_scaled(i));
            t(i) = bitxor(t(i), uint16((2^16)-1));
            t(i) = t(i) + 1;
            
            
        else
            
            t(i) = int16(sin_scaled(i));

        end 
        
        sin_vec = cellstr(dec2bin(t,16));
        
    end

    fid = fopen(['cos', num2str(N), '.data'], 'wt');
    fprintf(fid, '%s\n', cos_vec{:});
    fclose(fid);

    fid = fopen(['sin', num2str(N), '.data'], 'wt');
    fprintf(fid, '%s\n', sin_vec{:});
    fclose(fid);  
    
    %csvwrite(['cos', num2str(N), '.txt'], cos_scaled');
    %csvwrite(['sin', num2str(N), '.txt'], sin_scaled');
    
end