function genKernel = genKernel(minfreq, maxfreq, binperoct, s, filename)

kernelgain = 256;
scalefactor = 32768;

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
genKernel = kernel;
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

if(length(catkernel) == 2^(nextpow2(length(catkernel))))
      % do nothing
      catkernelpad = catkernel;
else
    catkernelpad = [catkernel, zeros(1, 2^(nextpow2(length(catkernel)))-length(catkernel))];
    
end 

bitkernel = cellstr(dec2bin(catkernelpad, 64));

%bitkernel1 = cellstr(dec2bin(catkernelpad(1:length(s)), 64));
%bitkernel2 = cellstr(dec2bin(catkernelpad(length(s)+1:2*length(s)), 64));


fid = fopen([filename], 'wt');
fprintf(fid, '%s\n', bitkernel{:});
fclose(fid);

%fid = fopen(['speckernel0.data'], 'wt');
%fprintf(fid, '%s\n', bitkernel1{:});
%fclose(fid);
    
%fid = fopen(['speckernel1.data'], 'wt');
%fprintf(fid, '%s\n', bitkernel2{:});
%fclose(fid);
