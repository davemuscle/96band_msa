bins = 12; %12 bins per octave
depth = 2^4; %4 bits for each color

%init matrix
colors = zeros(16, 16, 3);

%setup color matrix
colors(1, :, :) = [jet(bins); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(2, :, :) = [parula(bins); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(3, :, :) = [hsv(bins); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(4, :, :) = [hot(bins); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(5, :, :) = [cool(bins); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(6, :, :) = [spring(bins); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(7, :, :) = [summer(bins); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(8, :, :) = [autumn(bins); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(9, :, :) = [winter(bins); zeros(2^(nextpow2(bins)) - bins, 3)];

temp = gray(bins + 1);
colors(10, :, :) = [temp(2:bins+1, :); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(11, :, :) = [bone(bins); zeros(2^(nextpow2(bins)) - bins, 3)];

temp = copper(bins + 1);

colors(12, :, :) = [temp(2:bins+1,:); zeros(2^(nextpow2(bins)) - bins, 3)];
colors(13, :, :) = [pink(bins); zeros(2^(nextpow2(bins)) - bins, 3)];

%green phosphor display
colors(14, : ,:) = [4*ones(16,1), 14*ones(16,1), 0*ones(16,1)]./(depth-1);

%amber phosphor display
colors(15, :, :) = [15*ones(16,1), 8*ones(16,1), 1*ones(16,1)]./(depth-1);

%blue phosphor display
colors(16, :, :) = [2*ones(16,1), 14*ones(16,1), 15*ones(16,1)]./(depth-1);

%convert to 4 bit rgb
colors(:,:,:) = round(colors(:,:,:) * (depth-1)); 

%init bram
color_vector = uint8(zeros(16*16, 3));

for k = 1:16
    for i = 1:16
       for j = 1:3
           color_vector((k-1)*16 +i, j) = colors(k, i, j);
       end
    end
end

reds = [color_vector(:,1); zeros(2^nextpow2(length(color_vector))-length(color_vector),1)];
greens = [color_vector(:,2); zeros(2^nextpow2(length(color_vector))-length(color_vector),1)];
blues = [color_vector(:,3); zeros(2^nextpow2(length(color_vector))-length(color_vector),1)];


bram = {256, 1};

%position data as: 
%[11:8 red]
%[7:4  green]
%[3:0  blue]

for i = 1:length(reds)
    bram{i} = [dec2bin(reds(i),4), dec2bin(greens(i),4), dec2bin(blues(i),4)];
end

fid = fopen(['colorLUTs.data'], 'wt');
fprintf(fid, '%s\n', bram{:});
fclose(fid);


