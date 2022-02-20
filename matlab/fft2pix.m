fullscale = 2796202;
pixelheight = 320;
fs = 48000;
x = fullscale*cos(2*pi*440*(0:1023)/fs);
y = abs(fft(x))/(1024/2); %shift right (512)
y = abs(fft(x)/(1024/2)); %same result as above

%pixels = y*pixelheight / fullscale;
%pixels = y/8192; %shift right (8192)


pixels = (abs(fft(x))) / ( (1024/2) * (8192));



%shift fft magnitudes right by 9 + 13 = 22 times

plot(pixels)
