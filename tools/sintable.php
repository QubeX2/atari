#!/usr/bin/env php
<?php

$angle = 0;
$length = 127;
$step = 179/$length;
$amplitude = 170;
$offset = 4;
$PI = 3.14159;
$width = 16;
echo "sintable:\n";
echo "    .byte ";
$count = 0;
for($angle = 0;$angle < 180; $angle += $step) {
    if(!($angle % $width) && $angle > 0) {
        echo "\n    .byte ";
    }
    if(($angle % $width)) {
        echo ", ";
    }
    printf("$%02x", (sin($angle*($PI/180))*$amplitude) + $offset);
    $count++;
}
echo "\nSinLength EQU " . $count . "\n";
