function cq= constQ(x, sparKernel) % x must be a row vector
cq= fft(x,size(sparKernel,1)) * (1 .* sparKernel);