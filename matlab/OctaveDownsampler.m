data_size = 32;
oct_ord = 2;
oct = zeros(2^oct_ord, data_size);

x = 32768*[1:16, 1:16];
f = [0.5, 0.25, -0.25, 0.25];

for i = 0:(2^oct_ord)-1
    if(i == 0)
        temp = filter(f,1,x);
        temp = downsample([0, temp], 2);
        leng = (data_size)/(2^(i+1));
        oct(1, 1:leng) = temp(2:2+leng-1);
    else
        temp = filter(f,1,oct(i,:));
        temp = downsample([0, temp], 2);
        leng = (data_size)/(2^(i+1));
        oct(i+1, 1:leng) = temp(2:2+leng-1);
    end

    

end


y = filter(f, 1, x);
y_down = downsample([0,y],2);
y_down = y_down(2:9);

yy = filter(f,1,y_down);
yy_down = downsample([0,yy], 2);
yy_down = yy_down(2:5);

