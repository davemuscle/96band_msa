fs = 24000;
binperoct = 12;
minfreq = 3520;
maxfreq = 7040;

kernelgain = 4096;
scalefactor = 32768;
outscale = 4096;
%kernelgain = 1;
%scalefactor = 1;
%outscale = 1;

%this needs to match the length of the fft for low freqs to show up
x = cos(2*pi*(0:outscale-1)*440/fs);
y = cos(2*pi*(0:outscale-1)*880/fs);
z = cos(2*pi*(0:outscale-1)*4400/fs);
u = cos(2*pi*(0:outscale-1)*150/fs);

xx = (x + y + z + u);

thresh = 0.0054;
s = sparKernel(minfreq, maxfreq, binperoct, fs, thresh);
cq = constQ(xx,s*kernelgain); %make kernel larger for scaling
cq = cq / 1024; %scale to match input range
close all;
figure
stem(abs(cq));

%generate sparse kernel file

numbins = ceil( binperoct * log2(maxfreq/minfreq) ); 

numnonzero = nnz(s);

kernel = zeros(numnonzero, 4);
t = 1;

%builds kernel into a reasonable format
for i = 1:numbins
    
    addrs = find(s(:,i));
    
    for j = 1:size(addrs)
        
        kernel(t, 1) = i;
        kernel(t, 2) = addrs(j);
        kernel(t, 3) = real(s(addrs(j), i));
        kernel(t, 4) = imag(s(addrs(j), i));
        
        t = t + 1;
        
    end
    
end 

intkernel = int16(zeros(numnonzero, 4));

%kernelreal = 0;
%kernelimag = 0;

%convert kernel int16 and scale fixed point
for i = 1:numnonzero
   
    intkernel(i, 1) = kernel(i, 1); %note: not fixing bin index, fix in FPGA
    intkernel(i, 2) = kernel(i, 2); %note: not fixing array index, fix in FPGA
    
    %real part
    kernel_real = round(kernelgain*scalefactor*kernel(i,3));
    
    intkernel(i, 3) = kernel_real;
        
    %imag part
    kernel_imag = round(kernelgain*scalefactor*kernel(i,4));

    intkernel(i, 4) = kernel_imag;
        
end

%concatenate kernel integers into Nx1 array
catkernel = int64(zeros(1, numnonzero));
for i = 1:numnonzero
   
    catkernel(1, i) = typecast([intkernel(i,4), intkernel(i,3), intkernel(i,2), intkernel(i,1)], 'uint64');
    
end

catkernelpad = [catkernel, zeros(1, 2*length(s)-length(catkernel))];

bitkernel = cellstr(dec2bin(catkernel, 64));

bitkernel1 = cellstr(dec2bin(catkernelpad(1:length(s)), 64));
bitkernel2 = cellstr(dec2bin(catkernelpad(length(s)+1:2*length(s)), 64));


fid = fopen(['speckernel0.data'], 'wt');
fprintf(fid, '%s\n', bitkernel1{:});
fclose(fid);
    
fid = fopen(['speckernel1.data'], 'wt');
fprintf(fid, '%s\n', bitkernel2{:});
fclose(fid);

    