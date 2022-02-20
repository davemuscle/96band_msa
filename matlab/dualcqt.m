
bins = 12;
Q= 1/(2^(1/bins)-1);

%upper cqt
fs1 = 48000;
minfreq1 = 880;
maxfreq1 = 14080;

%lower cqt
fs2 = 3000;
minfreq2 = 55;
maxfreq2 = 880;
%

% fs2 = fs1;
% minfreq2 = 880;
% maxfreq2 = 8000;

kernelgain = 1024;
scalefactor = 32768;
outscale = 1024;

kernel1 = sparKernel(minfreq1, maxfreq1, bins, fs1, 0.0124);
%kernel1 = sparKernel(minfreq1, maxfreq1, bins, fs1);

fft_len1 = 2^nextpow2( ceil(Q*fs1/minfreq1) );

kernel2 = sparKernel(minfreq2, maxfreq2, bins, fs2, 0.0124);
%kernel2 = sparKernel(minfreq2, maxfreq2, bins, fs2);

fft_len2 = 2^nextpow2( ceil(Q*fs2/minfreq2) );


input1 = cos(2*pi*4000*(0:256-1)/fs1) + ...
         cos(2*pi*12000*(0:256-1)/fs1); 
     
input2 = cos(2*pi*100*(0:256-1)/fs2);
         %cos(2*pi*440*(0:256-1)/fs2);
     
data1 = [input1, input1, input1, zeros(1,256)];
data2 = [input2, input2, input2, zeros(1,256)];

data1 = data1 * (2^15)-1;
data2 = data2 * (2^15)-1;
    
cq1 = constQ(data1,kernel1*kernelgain); %make kernel larger for scaling
cq1 = cq1 / 1; %scale to match input range. 
%dividing by the fft length will give a result that is 1/4 of the max input
%eg: max input is a sine from -32000 to 32000,
%    output will be a peak at the frequency with a value of ~8000

cq2 = constQ(data2,kernel2*kernelgain); %make kernel larger for scaling
cq2 = cq2 / 1; %scale to match input range

figure
plot([abs(cq2), abs(cq1)])


%plot(abs(cq1))


%generate bit text files now
%genKernel(minfreq1, maxfreq1, bins, kernel1);
%genKernel(minfreq2, maxfreq2, bins, kernel2);
