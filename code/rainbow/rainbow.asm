;====================================================================
; Atari 2600 Startup
;====================================================================
    processor 6502

    include "../_inc/vcs.h"
    include "../_inc/macro.h"

    seg code
    org $f000       ; define the code origin at $f000

start:
    CLEAN_START     ; macro to safely clear the memory

;====================================================================
; Main
;====================================================================
main:
    lda #2
    sta VBLANK      ;turn on VBLANK
    sta VSYNC       ;turn on VSYNC

    ; VSYNC 3 scanlines
    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC       ;turn of VSYNC

    ; VBLANK 37 scanlines 
    ldx #37
loopvb:
    sta WSYNC       ;hit WSYNC and wait for next scanline
    dex
    bne loopvb

    lda #0
    sta VBLANK

    ; DISPLAY 192 visible scanlines
    ldx #192
loopm:
    stx COLUBK      ;set the bg color
    sta WSYNC
    dex
    bne loopm

    ; OVERSCAN 30 scanlines 
    lda #2
    sta VBLANK

    ldx #30
loopos:
    sta WSYNC       ;hit WSYNC and wait for next scanline
    dex
    bne loopos

    jmp main        ; repeat from start

;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
    org $fffc
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
