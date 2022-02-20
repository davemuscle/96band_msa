
N = nextpow2(length(Hlp.numerator));

fir_vec = {};

%fir = int16([Num.*32768, zeros(1,N-length(Num))]);
fir = int32([Hlp.numerator.*(2^31), zeros(1,N-length(Hlp.numerator))]);


fir_vec = cellstr(dec2bin(typecast(fir, 'uint32'),32));

fid = fopen(['downsampler_fir.data'], 'wt');
fprintf(fid, '%s\n', fir_vec{:});
fclose(fid);
