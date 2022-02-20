octavedata = zeros(8, 256);
octaveidx  = zeros(8, 1);
readidx = [1,2,4,8,16,32,64,128];
readreset = readidx;
%%% cqt kernel
minfreqs = [27.5, 55, 110, 220, 440, 880, 1760, 3520];
maxfreqs = [55, 110, 220, 440, 880, 1760, 3520, 7040];
samplerates = [187.5, 375, 750, 1500, 3000, 6000, 12000, 24000];

bins = 12;
q = 2*1.10;
Q = q/(2^(1/bins)-1);
K = ceil(bins* log2(maxfreqs./ minfreqs));
fftLen = 2.^nextpow2(ceil(Q*samplerates./minfreqs));

tempKernel = zeros(fftLen(1), 1);
sparKernel = [];
for k = K:-1:1;
    len = ceil(Q*samplerates(1)/(minfreqs(1)*2^((k-1)/bins)));
    
    %window = kaiser(len,1);
    %window = gausswin(len);
    %window = ones(len, 1);
    
    window = hamming(len);
    thresh = 0.0054;
    
    tempKernel(1:len) = ...
           window/len .* exp(2*pi*1i*Q*(0:len-1)'/len);
    specKernel = fft(tempKernel);
    specKernel(find(abs(specKernel)<=thresh))=0;
    sparKernel = sparse([specKernel sparKernel]);
    
end

sparKernel = conj(sparKernel) ./ fftLen(1);

modlength = fftLen(1)/1 - 1;
input = zeros(8, modlength + 1);
output = zeros(1, 8*bins);
%%%

totallength = 262144;
burstlength = 65536;
numiter = totallength / 256;

sounddata =  cos(2*pi*(0:burstlength-1)*27.5/48000) + ...
             cos(2*pi*(0:burstlength-1)*55/48000)   + ...
             cos(2*pi*(0:burstlength-1)*110/48000)  + ...
             cos(2*pi*(0:burstlength-1)*220/48000)  + ...
             cos(2*pi*(0:burstlength-1)*440/48000)  + ...
             cos(2*pi*(0:burstlength-1)*880/48000)  + ...
             cos(2*pi*(0:burstlength-1)*1760/48000) + ...
             cos(2*pi*(0:burstlength-1)*3520/48000);
     
inputdata = [sounddata, zeros(1,burstlength), sounddata, zeros(1, burstlength)];
         
fir_num = Hlp.numerator;
fir_den = [1, zeros(1, length(Hlp.numerator)-1)];
    
fir_dly = zeros(8, length(fir_num));

time = 1;
ttt = 1;

spect = zeros(numiter, 88);

oct = zeros(1, totallength);
fir_check = zeros(1, totallength);

for jj = 0:numiter-1
    inputgrain = inputdata((jj*256)+1 : ((jj+1)*256));

    %downsample to get each octave
    for ii = 8:-1:1
        if(ii == 8)
            to_filter = inputgrain;
        else
            to_filter = fir_temp;

        end

        tt = [fir_dly(ii, :), to_filter];

        fir_temp = filter(fir_num, fir_den, [fir_dly(ii,:), to_filter]);


        fir_dly(ii,:) = tt(length(tt) - length(fir_num) + 1 : length(tt));

        fir_temp = fir_temp(length(fir_temp) - length(to_filter) + 1 : length(fir_temp));
        fir_temp = downsample(fir_temp, 2);
        
        for iii = 1:length(fir_temp)
            octavedata(ii, octaveidx(ii)+1) = fir_temp(iii);
            octaveidx(ii) = octaveidx(ii) + 1;

            if(octaveidx(ii) == 256)
               octaveidx(ii) = 0;
            end
            
            if(ii == 8)
                fir_check(ttt) = fir_temp(iii);
                ttt = ttt + 1;
            end 
        end
    end
    
    %oct(((time-1)*256) +1: (time)*256) = octavedata(1, :);

    %read data from circ buffer
    for i = 1:8
       
        for ii = 1:256
            input(i, ii) = octavedata(i, readidx(i)+1);
            readidx(i) = readidx(i) + 1;
            if(readidx(i) == 256)
                readidx(i) = 0;
            end
        end
          
    end
       
    breakpoint = 1;
    
    for i = 1:8
        readidx(i) = readidx(i) + readreset(i);
        if(readidx(i) >= 256) 
           readidx(i) = 0;
        end
    end
    
    
    
    %do fft
    for i = 1:8
       temp = fft(input(i, :), fftLen(i)) * sparKernel;
       output(1, 12*(i-1) + 1: 12*i) = temp;
    end
    
    %store data for spectogram
    spect(time, :) = abs(output(1:88));
    time = time + 1;
    
end

%3d plot
%[x_3d, y_3d] = meshgrid(1:88, 1:numiter);
%z_3d = spect(:,:);

[x_3d, y_3d] = meshgrid(1:12, 1:256);
z_3d = spect((1:256),(1:12));


close all;
figure
h = surf(x_3d, y_3d, z_3d);
set(h, 'LineStyle', 'none');
shading interp