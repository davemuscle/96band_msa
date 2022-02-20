N = 1024;
fs = 24000;
scale = 2^15;
input =  cos(2*pi*3729*(0:N-1)/fs);
    
input = input * (scale);
input = round(input) * 1; %scale factor

dlmwrite('sinwav440.txt', input', 'precision', 32);