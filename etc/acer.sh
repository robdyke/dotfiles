#!/bin/bash
# http://ubuntuhandbook.org/index.php/2017/04/custom-screen-resolution-ubuntu-desktop/

# run on login using "startup applications" in ubuntu

# show displays, available/current modes
#xrandr
# calculate video timings
#cvt 1440 900
# 1440x900 59.89 Hz (CVT 1.30MA) hsync: 55.93 kHz; pclk: 106.50 MHz
# Modeline "1440x900_60.00"  106.50  1440 1528 1672 1904  900 903 909 934 -hsync +vsync

# create new mode
sudo xrandr --newmode "1440x900_60.00"  106.50  1440 1528 1672 1904  900 903 909 934 -hsync +vsync

# add to port
sudo xrandr --addmode DP-1-3 1440x900_60.00

# new set the resolution from settings, or
sudo xrandr --output DP-1-3 --mode 1440x900_60.00
