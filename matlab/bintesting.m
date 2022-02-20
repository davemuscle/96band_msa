start = 5;
inc = 6;
t = zeros(1,32);

for i = 1:32
    t(i) = start*48000/4096;
    inc = inc + 1;
    start = start + inc;
end 

plot(t)