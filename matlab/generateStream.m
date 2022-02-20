
scale = 2^15;
 
input = inputdata(1:256*256);

input = input * (scale);
input = round(input); %scale factor

dlmwrite('inputstream.txt', input', 'precision', 32);