x = 1:8;

N = 8;
numstages = log2(N);


%fill ping
ram = x;



%first fill stage
a_rd = uint32(0);
b_rd = uint32(1);
for i = 1:N/2
    a_rd_rv = bitreversal(a_rd, N);
    b_rd_rv = bitreversal(b_rd, N);
    
    in_a = x(a_rd_rv + 1);
    in_b = x(b_rd_rv + 1);
    
    ram(a_rd + 1) = in_a + in_b;
    ram(b_rd + 1) = in_a - in_b;
    
    a_rd = a_rd + 2;
    b_rd = b_rd + 2;
    
end

stage0_image = ram;

twids = cos((0:(N-1))*2*pi/N) -1i*sin((0:(N-1))*2*pi/N);
stage = 1;
while(stage < numstages)
  
    a_rd = uint32(0);
    b_rd = uint32(1);
    
    for n = 0:2:(N-1)  

        a_rd_rv = bitreversal(a_rd, 2^(stage + 1));
        b_rd_rv = bitreversal(b_rd, 2^(stage + 1));

        a_twid = a_rd_rv*N/(2^(stage + 1));
        b_twid = b_rd_rv*N/(2^(stage + 1));
        a_wr = a_rd_rv;
        b_wr = b_rd_rv; 

        
        a_twid = bitand(a_twid, (N-1));
        b_twid = bitand(b_twid, (N-1));

        a_read = ram(a_rd_rv + 1);
        b_read = ram(b_rd_rv + 1);
        
        a_twid_val = twids(a_twid + 1);
        b_twid_val = twids(b_twid + 1);
        
        a_res = a_read + a_twid_val*b_read;
        b_res = a_read + b_twid_val*b_read;
        
        ram(a_wr + 1) = a_res;
        ram(b_wr + 1) = b_res;
             

      
        a_rd = a_rd + 2;
        b_rd = b_rd + 2;
        
    end
    
    stage = stage + 1;
    
    
end
