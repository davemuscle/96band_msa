fid_real = fopen('output_file.txt', 'r');

output_downsampler=fscanf(fid, '%d');

fclose(fid);

scale = 1;
inputlength = 1;

figure
plot(output_downsampler)
title('vhdl output')