;====================================================================
; Atari 2600 Startup
;====================================================================
    processor 6502

    include "../_inc/vcs.h"
    include "../_inc/macro.h"

;====================================================================
; Variables
;====================================================================
ORG_END     EQU $fffc
P0Height    EQU 9

    seg.u vars
    org $80

Player0YPos .byte
Player0XPos .byte
SinPos      .byte

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
    ldx #$00        ; blue color
    stx COLUBK
    lda #$0f        ; white
    sta COLUPF      

    lda #40
    sta Player0XPos
    lda #60
    sta Player0YPos

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
    ; xpos
    lda Player0XPos

    sec
    sta WSYNC
    sta HMCLR           ;-----------

divide:
    sbc #15
    bcs divide

    eor #7
    asl
    asl
    asl
    asl
    sta HMP0
    sta RESP0           ;; 69 TIA Cycles
    sta WSYNC
    sta HMOVE

    REPEAT 35
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
    sbc Player0YPos ; 192 - 185 = 7
    cmp #P0Height   ; 7 < 9
    bcc ldbmp        ; yes branch (only works on unsigned)
    lda #0

ldbmp:
    tay             ; 7 to a
    lda PlayerBmp,y
    sta GRP0

    lda PlayerClr,y
    sta COLUP0

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

    ; move apple   
    lda Player0XPos
    clc
    adc #1
    cmp #81
    bmi store
    lda #40
store:
    sta Player0XPos

    jmp frame        ; repeat frame
;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
    org ORG_END - (180+9+9)
PlayerBmp:
    .byte #%00000000
    .byte #%00101000
    .byte #%01110100
    .byte #%11111010
    .byte #%11111010
    .byte #%11111010
    .byte #%11111010
    .byte #%01111100
    .byte #%00110000

PlayerClr:
    .byte #$00
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$42
    .byte #$42
    .byte #$44
    .byte #$d2

    org ORG_END
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
