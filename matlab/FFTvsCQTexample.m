%input setup
fs = 4000;                         %sample rate
note = 440;                        %note frequency, A4
input = cos(2*pi*note*(0:511)/fs); %pure tone input

%fft setup
fft_output = zeros(1, length(input)); %output vector
N = length(input);                    %size

%fft direct form = dft (slow)
for k = 0:N-1
    fft_output(k+1) = input * exp(-2*pi*1i*k*(0:N-1)'/N); %complex mult + LUT
end

%cqt setup
minimum_freq = 220;                                        %two full octaves are specified between
maximum_freq = 880;                                        %the min and the max frequencies
bins_per_octave = 12;                                      %12 bins per octave = 1 bin for 1 note
Q = 1/(2^(1/bins_per_octave)-1);                           %Q factor of the filterbank
K = ceil(bins_per_octave*log2(maximum_freq/minimum_freq)); %total num bins
cqt_output = zeros(1,K);

%cqt direct form
%this is the slow way to calculate the cqt
for k = 1:K
   N = round(Q*fs/(minimum_freq*2^((k-1)/bins_per_octave)));    %variable length
   cqt_output(k) = cqt_input(1:N) * exp(-2*pi*1i*Q*(0:N-1)'/N); %same form as fft
end

%plots of obtained data obtained
close all;
figure
%only plotting one image of the spectrum
stem(abs(fft_output(1:length(input)/2)))
title('fft output');
ylabel('magnitude');
xlabel('bin');
figure
stem(abs(cqt_output))
title('cqt output');
ylabel('magnitude');
xlabel('bin');