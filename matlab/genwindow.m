

for ii = 9:13
    N = 2^ii;
    
    window = {};

    kaiser_gen = kaiser(N, 3);
    figure
    plot(kaiser_gen)
    kaiser_gen = kaiser_gen * 32768; %shift 15 bits
    kaiser_gen = round(kaiser_gen);

    t = zeros(1,N);
    
    for i = 1:N
        
        t(i) = uint32(kaiser_gen(i)); 
        
        window = cellstr(dec2bin(t,16));
        
    end

    fid = fopen(['kaiser', num2str(N), '.data'], 'wt');
    fprintf(fid, '%s\n', window{:});
    fclose(fid);

end