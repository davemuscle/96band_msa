N = 1024;
fs = 48000;
x = sin(2*pi*100*(0:N-1)/fs) + sin(2*pi*1000*(0:N-1)/fs) + sin(2*pi*16000*(0:N-1)/fs);
y = abs(fft(x));
y = y(2:N/2); % skip DC
freqs = (1:N/2 - 1)*fs/N;
bumba = 10;
logs = ((log10(freqs) - log10(bumba)) / (log10(fs/2) - log10(bumba)));
logs2 = ((log2(freqs) - log2(bumba)) / (log2(fs/2) - log2(bumba)));
pixels = round(logs*480);
pixels2 = round(logs2*480);
%stem(freqs,y);
%stem(logs, y);
%stem(pixels, y)
stem(pixels2, y)


%averaging on same pixel columns
for n = 1:511
   
    
    
end