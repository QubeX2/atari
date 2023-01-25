#!/usr/bin/env php
<?php

if($argc == 2) {
    $obj = json_decode($argv[1]);
    $colors = [];
    if($obj) {
        foreach($obj->sprites as $sidx => $sprite) {
            printf("\nSprite%dHeight EQU %d\n", $sidx, $obj->height + 1);
            printf("Sprite%d:\n", $sidx);
            printf("\t.byte #%%00000000\n");
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
            printf("Sprite%dColors:\n", $sidx);
            printf("\t.byte #$00\n");
            foreach($colors as $color) {
                printf("\t.byte %s\n", $color);
            }
            printf("\n");
        }
    }
}