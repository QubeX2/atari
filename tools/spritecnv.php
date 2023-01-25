#!/usr/bin/env php
<?php

if($argc == 2) {
    $obj = json_decode($argv[1]);
    $colors = [];
    if($obj) {
        foreach($obj->sprites as $sidx => $sprite) {
            printf("\nsprite%dHeight EQU %d\n", $sidx, $obj->height);
            printf("sprite%d:\n", $sidx);
            foreach($sprite->pixels as $psidx => $pixels) {
                printf("\t.byte #%%");
                $z = array_values(array_filter($pixels));
                $cidx = $z[0] ?? false;
                $colors[] = $cidx === false ? '#$00' : sprintf("#$%02x", $obj->colors->{$cidx});
                foreach($pixels as $pidx => $pixel) {
                    $line = sprintf("%d, ", $pixel > 1 ? 1 : $pixel);
                    echo rtrim($line, ' ,');
                }
                printf("\n");
            }
            printf("colors%d:\n", $sidx);
            foreach($colors as $color) {
                printf("\t.byte #$%s\n", $color);
            }
            printf("\n");
        }
    }
}