#!/bin/bash
# create sintable
angle=0
step=1
amplitude=170
offset=4
PI=3.14159
width=16
clear
awk 'BEGIN {printf "    .byte "}'
while [ $angle -le 179 ]
do
    if ! (($angle % $width)) && (($angle > 0)); then
        awk 'BEGIN {printf "\n    .byte "}'
    fi

    awk -v ang=$angle -v pi=$PI -v amp=$amplitude -v ofs=$offset 'BEGIN {printf "$%02x", (sin(ang*(pi/180))*amp)+ofs}'
    angle=$((angle+step))
    
    if (($angle % $width)); then
        awk 'BEGIN {printf ", "}'
    fi

done