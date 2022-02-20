fid_real = fopen('output_real.txt', 'r');
fid_imag = fopen('output_imag.txt', 'r');

reals=fscanf(fid_real, '%d');
imags=fscanf(fid_imag, '%d');

fclose(fid_real);
fclose(fid_imag);

scale = 2^15;
kernelgain = 256;
inputlength = 1;
complex = (reals/(scale*kernelgain)) + j*(imags/(scale*kernelgain));

figure
stem(abs(complex))
title('vhdl output')