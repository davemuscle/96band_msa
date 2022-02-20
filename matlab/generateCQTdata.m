N = 128;
n = 96;
fs = 24000;

input = zeros(1, N);
scale = 32768;

for i = 0:n-1
   input(i+1) = scale*(i+1);
end

input = round(input) * 1; %scale factor

dlmwrite('screenInput.txt', input', 'precision', 32);