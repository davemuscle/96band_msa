%fid_real = fopen('output_real.txt', 'r');
%fid_imag = fopen('output_imag.txt', 'r');

fid_abs = fopen('out_file.txt', 'r');
mags = fscanf(fid_abs, '%d');

%reals=fscanf(fid_real, '%d');
%imags=fscanf(fid_imag, '%d');

%fclose(fid_real);
%fclose(fid_imag);
fclose(fid_abs);

scale = 2^15;
kernelgain = 256;
inputlength = 1;
%complex = (reals/(scale*kernelgain)) + j*(imags/(scale*kernelgain));

complex = mags / (scale*kernelgain);

time_max = floor((length(mags))/96);
%time_max = 256;

vhdl_spect = zeros(time_max, 96);

for time = 1:time_max
    low_bound = ((time-1)*96) + 1;
    high_bound = time*96;
    vhdl_spect(time, :) = abs(complex(low_bound : high_bound));
end
%3d plot
[x_3d, y_3d] = meshgrid(1:96, 1:time_max);
z_3d = vhdl_spect(:,:);

figure
h = surf(x_3d, y_3d, z_3d);
set(h, 'LineStyle', 'none');
shading interp
title('vhdl out')