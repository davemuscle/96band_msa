# 96 Note Music Spectrum Analyzer - FPGA

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

**link to video**

