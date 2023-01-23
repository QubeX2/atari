;====================================================================
; Atari 2600 Startup
;====================================================================
    processor 6502

    include "../_inc/vcs.h"
    include "../_inc/macro.h"

;====================================================================
; Variables
;====================================================================
ORG_END = $fffc

    seg.u vars
    org $80

var1        ds 1

;====================================================================
; Code
;====================================================================
    seg code
    org $f000       ; define the code origin at $f000

start:
    CLEAN_START     ; macro to safely clear the memory

;====================================================================
; Init
;====================================================================
    ldx #$80        ; blue color
    stx COLUBK
    lda #$0f        ; white
    sta COLUPF      

;====================================================================
; Main
;  VSYNC and VBLANK
;====================================================================
frame:
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
    REPEAT 37
        sta WSYNC       ;hit WSYNC and wait for next scanline
    REPEND
    lda #0
    sta VBLANK

;====================================================================
; DISPLAY 192 visible scanlines
;====================================================================
    REPEAT 192
        sta WSYNC       ;hit WSYNC and wait for next scanline
    REPEND

;====================================================================
; OVERSCAN 30 scanlines
;====================================================================
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC       ;hit WSYNC and wait for next scanline
    REPEND
    lda #0
    sta VBLANK

    jmp frame        ; repeat frame
;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
    org ORG_END
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
