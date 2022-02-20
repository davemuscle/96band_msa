# 96 Note Music Spectrum Analyzer - FPGA

![GIF](/doc/msa_front.gif)

*Migrated to Git on February 20th, 2022. Updated web page on July 5th, 2020. Original release in
April 2020.*

This project converts your audio into a frequency spectrum and displays it on a VGA monitor in
real-time. The spectrum is mapped to all 96 half-notes in the first eight octaves, and is tuned to
A4 (440 Hz). It provides a visible output of 1920x1080 pixels at 60FPS, including multiple color
palette choices. There is also a choice between using an onboard microphone with auto gain control,
or a line-level input output pair.

All of the code was written in VHDL on an Artix-7. The main DSP technique used was multi-resolution,
constant-Q analysis. A custom PCB was designed at the end of project.

The general timeframe was between December 2019 and April 2020. This includes multiple rewrites of
the entire VHDL codebase, multiple hardware choice changes, and the design of the website.

## Demonstration
CTRL+click the video thumbnails to open in a new tab

| *Music Spectrum Analyzer - OSRS Harmony* |
|:--:|
| [![Image](/doc/vid01_tb.png)](https://youtu.be/-Q9aSZRLyek) |
| *Music Spectrum Analyzer - Ave Maria* |
| [![Image](/doc/vid02_tb.png)](https://youtu.be/DIGgBtx7Qf0) |
| *Music Spectrum Analyzer - Davy Jones Theme* |
| [![Image](/doc/vid03_tb.png)](https://youtu.be/745tQkoyp0c) |

## Implementation
### Hardware Block Diagram

![Image](/doc/msa_block_diagram.png)

### Printed Circuit Board

![Image](/doc/msa_board_pic2.jpg)

### FPGA Design

![Image](/doc/msa_fpga_design.png)

#### Sub-designs
- I2S Master
    - Interface to I2S audio layer, reads and writes one sample of sound.
- I2S PingPong
    - Buffers up a selectable amount of audio in ping-pong fashion. Allows reading and writing
      blocks of sound to the audio layer.
- I2S Stereo2Mono
    - Converts stereo audio to mono audio
- Digital Amplifier
    - Multiplies sound data by a scalar factor based on XADC input
- Multi-Resolution Analysis
    - See below
- VGA Timing Generator
    - Creates sync signals based on screen resolution and framerate.
- VGA 2D Bin Renderer
    - Draws the frequency spectrum on the screen

### DSP Processing

![Image](/doc/msa_dsp.png)

The first portion of the DSP process downsamples the mono audio at 48 kHz into 8 separate octaves.
The downsampled data is buffered up, and a 256-point FFT followed by a Constant-Q transform is
performed on each octave. This downsampling and buffering is what gives us the "multi-resolution"
part of the project. The resulting frequency bins are averaged together to match the monitor's
refresh rate.

![Image](/doc/msa_bufferer.png)

Above is the diagram for the octave bufferer. 512 samples at 48 kHz are sequentially downsampled
until we get to the loweset octave of interest.

### Reasoning behind Multi-Resolution Analysis

We actually perceive sound on a logarithmic scale, and we already are using multi-resolution
analysis! Our ears naturally have good time-localization for high-frequency sounds, and good frequency
resolution for low-frequency sounds. This means we can better determine when high-frequency sounds 
occur (time localization) and we can better distinguish between low frequency sounds (frequency resolution).

Check out the time-frequency tiling diagram:

![Image](/doc/msa_tiling.png)

The x-axis for each box represents a slice of time over which an FFT or some other process is
performed. The y-axis represents the frequency resolution for that time chunk.

The left diagram is how most spectrum analyzers are made -- with just an FFT. All of the tiles have
constant frequency and time resolution. 

The right is how I designed mine, attempting to match how we hear. Recording more samples allows for
a greater frequency resolution, but at the cost of higher latency. This means the lower frequencies
on the screen won't be as responsive as the higher frequencies.

The benefit to downsampling and processing multiple octaves separately is that the same sized FFT
can be used for each octave, and resources aren't wasted on the higher frequencies.

### Reasoning behind the Constant-Q Transform

Take a look at the difference in the piano keys below:

![Image](/doc/ms_piano_keys.png)

The difference between the two lowest notes on an 88-key piano is only 1.6Hz, but for the fifth
octave, the difference in the lowest notes is 26 Hz!

This is because musical notes are logarithmically spaced, just like our hearing.
Each note can be obtained from another note by multiplying by a factor of 2^(1/12).

An FFT isn't great for this, since the frequency bins are arithmetically spaced (50 Hz, 100 Hz, ...)
The Constant-Q transform IS great for this, since we can specify a geometric scale to output our
bins.

The efficient implementation of the Constant-Q transform is pretty straight forward:
Generate the kernel for the transform (a sparse matrix of    coefficients, can be done before
run-time)
Take the FFT of your data 
Apply the generated kernel (this is just a matrix-multiply)

I pasted the code for the direct form of the Constant-Q transform below. If you interested in the
efficient implementation, check out the references.

### MATLAB Code for the Constant-Q Transform (Direct-Form)
```
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
figure %only plotting one image of the spectrum
stem(abs(fft_output(1:length(input)/2)))
title('fft output');
ylabel('magnitude');
xlabel('bin');
figure
stem(abs(cqt_output))
title('cqt output');
ylabel('magnitude');
xlabel('bin');
```
![Image](/doc/FFTvsCQTexample_01.png)
![Image](/doc/FFTvsCQTexample_02.png)

### References
1. [Piano Key Frequencies](https://en.wikipedia.org/wiki/Piano_key_frequencies)
2. [Benjamin Blankertz, Constant-Q Transform](http://doc.ml.tu-berlin.de/bbci/material/publications/Bla_constQ.pdf)
3. [Brown & Puckette , Effecient Constant-Q Transform](http://academics.wellesley.edu/Physics/brown/pubs/effalgV92P2698-P2701.pdf)
4. [Djikstra's Square Root Algorithm](http://lib.tkk.fi/Diss/2005/isbn9512275279/article3.pdf)
5. [VGA Timing](https://projectf.io/posts/video-timings-vga-720p-1080p/)
6. [Artix 7 Board](https://digilent.com/shop/cmod-a7-breadboardable-artix-7-fpga-module/)
7. [Website Inspiration, 96khz.org](http://www.96khz.org/projects.htm)
