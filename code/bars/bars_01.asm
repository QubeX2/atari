;====================================================================
; Atari 2600 Startup
;====================================================================
    processor 6502

    include "../_inc/vcs.h"
    include "../_inc/macro.h"

;====================================================================
; Variables
;====================================================================
ORG_END         EQU $fffc
BAR_HEIGHT      EQU 16
BAR_OFFSET      EQU 8

    seg.u vars
    org $80

BarPos .byte
SinPos .byte

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

    ldy #179
    sty SinPos
    lda sintable,y
    sta BarPos

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
    txa
    sec
    sbc BarPos
    cmp #BAR_HEIGHT
    bcc drawb
    lda #$00
    sta COLUBK

drawb
    tay
    lda barclrs,y
    sta WSYNC
    sta COLUBK
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

    ldx SinPos
    dex
    stx SinPos
    bne cnt
    lda #180
    sta SinPos
cnt:
    lda sintable,x
    sta BarPos

    jmp frame        ; repeat frame
;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
    org ORG_END - 180 - 16
sintable:
    .byte $04, $06, $09, $0c, $0f, $12, $15, $18, $1b, $1e, $21, $24, $27, $2a, $2d, $2f
    .byte $32, $35, $38, $3b, $3e, $40, $43, $46, $49, $4b, $4e, $51, $53, $56, $58, $5b
    .byte $5e, $60, $63, $65, $67, $6a, $6c, $6e, $71, $73, $75, $77, $7a, $7c, $7e, $80
    .byte $82, $84, $86, $88, $89, $8b, $8d, $8f, $90, $92, $94, $95, $97, $98, $9a, $9b
    .byte $9c, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a8, $a9, $aa, $aa
    .byte $ab, $ab, $ac, $ac, $ad, $ad, $ad, $ad, $ad, $ad, $ad, $ad, $ad, $ad, $ad, $ad
    .byte $ad, $ac, $ac, $ab, $ab, $aa, $aa, $a9, $a8, $a8, $a7, $a6, $a5, $a4, $a3, $a2
    .byte $a1, $a0, $9f, $9e, $9c, $9b, $9a, $98, $97, $95, $94, $92, $90, $8f, $8d, $8b
    .byte $89, $88, $86, $84, $82, $80, $7e, $7c, $7a, $77, $75, $73, $71, $6e, $6c, $6a
    .byte $67, $65, $63, $60, $5e, $5b, $59, $56, $53, $51, $4e, $4b, $49, $46, $43, $40
    .byte $3e, $3b, $38, $35, $32, $2f, $2d, $2a, $27, $24, $21, $1e, $1b, $18, $15, $12
    .byte $0f, $0c, $09, $06

barclrs:
    .byte $00,$81,$82,$82,$83,$83,$84,$86
    .byte $87,$8a,$8b,$8f,$83,$82,$81,$00

    org ORG_END
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
