N = 16;
numstages = log2(N);
stage = 0;

%x = rand(1,N);% + 1i*rand(1,N);
x = 1:16;
%fill ping
ping = x;
pong = zeros(1,N);

a_rd_arr = zeros(numstages, N/2);
b_rd_arr = zeros(numstages, N/2);
a_rv_arr = zeros(numstages, N/2);
b_rv_arr = zeros(numstages, N/2);
a_tw_arr = zeros(numstages, N/2);
b_tw_arr = zeros(numstages, N/2);

twids = cos((0:(N-1))*2*pi/N) -i*sin((0:(N-1))*2*pi/N);

while(stage < numstages)
  
    a_rd = uint32(0);
    b_rd = uint32(1);
    
    for n = 0:2:(N-1)  
        
        if(stage == 0)
            
            a_rd_rv = bitreversal(a_rd, N);
            b_rd_rv = bitreversal(b_rd, N);
        
            a_wr = a_rd;
            b_wr = b_rd;
            
            a_twid = a_rd*N/(2^(stage + 1));
            b_twid = b_rd*N/(2^(stage + 1));
           
            
        else
            a_rd_rv = bitreversal(a_rd, 2^(stage + 1));
            b_rd_rv = bitreversal(b_rd, 2^(stage + 1));
            
            a_twid = a_rd_rv*N/(2^(stage + 1));
            b_twid = b_rd_rv*N/(2^(stage + 1));
            a_wr = a_rd_rv;
            b_wr = b_rd_rv; 
     
        end

        a_twid = bitand(a_twid, (N-1));
        b_twid = bitand(b_twid, (N-1));

        
        if( mod(stage, 2) == 0)
           %even stage
           %read ping, fill pong
           
           pong(a_wr + 1) = ping(a_rd_rv + 1) + twids(a_twid+1)*ping(b_rd_rv + 1);

           pong(b_wr + 1) = ping(a_rd_rv + 1) + twids(b_twid+1)*ping(b_rd_rv + 1);
           
        else
            %odd
            %read pong, fill ping

           
           ping(a_wr + 1) = pong(a_rd_rv + 1) + twids(a_twid + 1)*pong(b_rd_rv + 1);

           
           ping(b_wr + 1) = pong(a_rd_rv + 1) + twids(b_twid + 1)*pong(b_rd_rv + 1);     
        end
        
        %arrays
        a_rd_arr(stage + 1, n/2 + 1) = a_rd;
        b_rd_arr(stage + 1, n/2 + 1) = b_rd;
        a_rv_arr(stage + 1, n/2 + 1) = a_rd_rv;
        b_rv_arr(stage + 1, n/2 + 1) = b_rd_rv;
        a_tw_arr(stage + 1, n/2 + 1) = a_twid;
        b_tw_arr(stage + 1, n/2 + 1) = b_twid;
        
        a_rd = a_rd + 2;
        b_rd = b_rd + 2;
        
    end
    
    stage = stage + 1;
    
    
end

if( mod(numstages, 2) == 0) 
    
    out = ping;
    
else
    
    out = pong;
    
end

max(out - fft(x))