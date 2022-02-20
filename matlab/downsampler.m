N = 256;
fs = 48000;
fout = 24000;
M = 12;
L = 5;


x = cos(2*pi*440*(0:N-1)/fs);
xx = cos(2*pi*500*(0:N-1)/fs);

z = x + xx;

denoms = [1, zeros(1, length(Num)-1)];


%interp = upsample(z, 5);

filtered = filter(Num, denoms, z);

decim = downsample(filtered, 2);

figure
plot(decim)
%plot(abs(fft(decim)))
