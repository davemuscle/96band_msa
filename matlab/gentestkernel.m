%generate sparse kernel file

numnonzero = 16;

kernel = zeros(numnonzero, 4);
t = 1;

intkernel = int16(zeros(numnonzero, 4));

kernel_real = 0;
kernel_imag = 0;

%convert kernel int16 and scale fixed point
for i = 1:numnonzero
   
    intkernel(i, 1) = 0;
    intkernel(i, 2) = 0;
    
    %real part
    kernel_real = kernel_real + 1;
    
    intkernel(i, 3) = kernel_real;
        
    %imag part
    kernel_imag = kernel_imag + 1;

    intkernel(i, 4) = kernel_imag;
        
end

%concatenate kernel integers into Nx1 array
catkernel = int64(zeros(1, numnonzero));
for i = 1:numnonzero
   
    catkernel(1, i) = typecast([intkernel(i,4), intkernel(i,3), intkernel(i,2), intkernel(i,1)], 'uint64');
    
end

testkernel = cellstr(dec2bin(catkernel, 64));

testkernel1 = cellstr(dec2bin(catkernel(1:8), 64));
testkernel2 = cellstr(dec2bin(catkernel(9:16), 64));


fid = fopen(['testkernel0.data'], 'wt');
fprintf(fid, '%s\n', testkernel1{:});
fclose(fid);
    
fid = fopen(['testkernel1.data'], 'wt');
fprintf(fid, '%s\n', testkernel2{:});
fclose(fid);