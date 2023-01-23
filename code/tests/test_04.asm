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

    ldy #0
again:
    lda sintable,y
    iny
    cmp #180
    bne again

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
    ldx #192

scanl:
    sta WSYNC
    dex
    bne scanl


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
    org ORG_END - 200
sintable:
    .byte $00, $03, $06, $0a, $0d, $10, $14, $17, $1a, $1e, $21, $24, $27, $2b, $2e, $31
    .byte $34, $38, $3b, $3e, $41, $44, $47, $4b, $4e, $51, $54, $57, $5a, $5d, $5f, $62
    .byte $65, $68, $6b, $6e, $70, $73, $76, $78, $7b, $7d, $80, $82, $85, $87, $8a, $8c
    .byte $8e, $90, $93, $95, $97, $99, $9b, $9d, $9f, $a1, $a2, $a4, $a6, $a7, $a9, $ab
    .byte $ac, $ae, $af, $b0, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bb, $bc
    .byte $bd, $bd, $be, $be, $be, $bf, $bf, $bf, $bf, $bf, $bf, $bf, $bf, $bf, $bf, $bf
    .byte $be, $be, $be, $bd, $bd, $bc, $bb, $bb, $ba, $b9, $b8, $b7, $b6, $b5, $b4, $b3
    .byte $b2, $b0, $af, $ae, $ac, $ab, $a9, $a7, $a6, $a4, $a2, $a1, $9f, $9d, $9b, $99
    .byte $97, $95, $93, $90, $8e, $8c, $8a, $87, $85, $82, $80, $7d, $7b, $78, $76, $73
    .byte $70, $6e, $6b, $68, $65, $62, $60, $5d, $5a, $57, $54, $51, $4e, $4b, $47, $44
    .byte $41, $3e, $3b, $38, $34, $31, $2e, $2b, $27, $24, $21, $1e, $1a, $17, $14, $10
    .byte $0d, $0a, $06, $03, $00

    org ORG_END
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
