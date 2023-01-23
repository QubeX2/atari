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
BAR_COUNT       EQU 8

    seg.u vars
    org $80

BarPos .byte $00,$00,$00,$00,$00,$00,$00,$00
SinPos .byte $00

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

    ldy #0
    sty SinPos
    lda sintable,y
    sta BarPos,x
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
    inx
    txa
    and #$7f
    tax
    stx SinPos
    lda sintable,x
    sta BarPos

    jmp frame        ; repeat frame
;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
    org ORG_END - 128 - 16
sintable:
    .byte $04, $08, $0c, $10, $14, $18, $1d, $21, $25, $29, $2d, $31
    .byte $35, $39, $3d, $41, $45, $49, $4c, $50, $54, $57, $5b
    .byte $5f, $62, $66, $69, $6c, $70, $73, $76, $79, $7c, $7f
    .byte $82, $84, $87, $8a, $8c, $8f, $91, $93, $96, $98, $9a, $9c
    .byte $9d, $9f, $a1, $a2, $a4, $a5, $a6, $a7, $a9, $a9, $aa
    .byte $ab, $ac, $ac, $ad, $ad, $ad, $ad, $ad, $ad, $ad, $ad
    .byte $ad, $ac, $ac, $ab, $aa, $a9, $a8, $a7, $a6, $a5, $a3, $a2
    .byte $a0, $9f, $9d, $9b, $99, $97, $95, $93, $90, $8e, $8c
    .byte $89, $86, $84, $81, $7e, $7b, $78, $75, $72, $6f, $6b
    .byte $68, $65, $61, $5e, $5a, $56, $53, $4f, $4b, $47, $44, $40
    .byte $3c, $38, $34, $30, $2c, $28, $24, $1f, $1b, $17, $13
    .byte $0f, $0b, $06

barclrs:
    .byte $00,$81,$82,$82,$83,$83,$84,$86
    .byte $87,$8a,$8b,$8f,$83,$82,$81,$00

    org ORG_END
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
