%Generate twiddle factors
function [] = gentwids(N)

costwids = cos(2*pi*(0:N-1)/N);
sintwids = sin(2*pi*(0:N-1)/N);


for i = 1:N

    if(abs(costwids(i)) < 10^-5)
        
        costwids(i) = 0;
    end

    if(abs(sintwids(i)) < 10^-5)
        
        sintwids(i) = 0;
        
    end

end

cos_scaled = costwids * 65536;
sin_scaled = sintwids * 65536;

csvwrite(['cos', num2str(N), '.txt'], cos_scaled');
csvwrite(['sin', num2str(N), '.txt'], sin_scaled');