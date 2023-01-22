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
    org ORG_END - 288
sin:
    .byte $80, $83, $86, $89, $8C, $90, $93, $96,
    .byte $99, $9C, $9F, $A2, $A5, $A8, $AB, $AE,
    .byte $B1, $B3, $B6, $B9, $BC, $BF, $C1, $C4,
    .byte $C7, $C9, $CC, $CE, $D1, $D3, $D5, $D8,
    .byte $DA, $DC, $DE, $E0, $E2, $E4, $E6, $E8,
    .byte $EA, $EB, $ED, $EF, $F0, $F1, $F3, $F4,
    .byte $F5, $F6, $F8, $F9, $FA, $FA, $FB, $FC,
    .byte $FD, $FD, $FE, $FE, $FE, $FF, $FF, $FF,
    .byte $FF, $FF, $FF, $FF, $FE, $FE, $FE, $FD,
    .byte $FD, $FC, $FB, $FA, $FA, $F9, $F8, $F6,
    .byte $F5, $F4, $F3, $F1, $F0, $EF, $ED, $EB,
    .byte $EA, $E8, $E6, $E4, $E2, $E0, $DE, $DC,
    .byte $DA, $D8, $D5, $D3, $D1, $CE, $CC, $C9,
    .byte $C7, $C4, $C1, $BF, $BC, $B9, $B6, $B3,
    .byte $B1, $AE, $AB, $A8, $A5, $A2, $9F, $9C,
    .byte $99, $96, $93, $90, $8C, $89, $86, $83,
    .byte $80, $7D, $7A, $77, $74, $70, $6D, $6A,
    .byte $67, $64, $61, $5E, $5B, $58, $55, $52,
    .byte $4F, $4D, $4A, $47, $44, $41, $3F, $3C,
    .byte $39, $37, $34, $32, $2F, $2D, $2B, $28,
    .byte $26, $24, $22, $20, $1E, $1C, $1A, $18,
    .byte $16, $15, $13, $11, $10, $0F, $0D, $0C,
    .byte $0B, $0A, $08, $07, $06, $06, $05, $04,
    .byte $03, $03, $02, $02, $02, $01, $01, $01,
    .byte $01, $01, $01, $01, $02, $02, $02, $03,
    .byte $03, $04, $05, $06, $06, $07, $08, $0A,
    .byte $0B, $0C, $0D, $0F, $10, $11, $13, $15,
    .byte $16, $18, $1A, $1C, $1E, $20, $22, $24,
    .byte $26, $28, $2B, $2D, $2F, $32, $34, $37,
    .byte $39, $3C, $3F, $41, $44, $47, $4A, $4D,
    .byte $4F, $52, $55, $58, $5B, $5E, $61, $64,
    .byte $67, $6A, $6D, $70, $74, $77, $7A, $7D

    org ORG_END
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
