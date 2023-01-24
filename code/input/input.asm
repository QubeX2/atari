;====================================================================
; Atari 2600 Startup
;====================================================================
    processor 6502

    include "../_inc/vcs.h"
    include "../_inc/macro.h"

;====================================================================
; Variables
;====================================================================
ORG_END EQU $fffc
P0Height EQU 12
    seg.u vars
    org $80

P0XPos  .byte
P0YPos  .byte

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
    lda #$D0        ; white
    sta COLUPF      

    lda #10
    sta P0XPos

    lda #100
    sta P0YPos

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
    lda P0XPos
    and #$7f
    sta WSYNC
    sta HMCLR

    sec
divide:
    sbc #15
    bcs divide

    eor #7
    asl
    asl
    asl
    asl
    sta HMP0
    sta RESP0
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
    sbc P0YPos
    cmp #P0Height
    bcc player
    lda #0

player:
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

;====================================================================
; JOYSTICK INPUT
;====================================================================
joyu:
    lda #%00010000
    bit SWCHA
    bne joyd
    inc P0YPos

joyd:
    lda #%00100000
    bit SWCHA
    bne joyl
    dec P0YPos

joyl:
    lda #%01000000
    bit SWCHA
    bne joyr
    dec P0XPos
joyr:
    lda #%10000000
    bit SWCHA
    bne joyx
    inc P0XPos

joyx:

    jmp frame        ; repeat frame
;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
   org ORG_END - 24
PlayerBmp:
    .byte #%00000000
    .byte #%00111000
    .byte #%00111000
    .byte #%00010000
    .byte #%11111110
    .byte #%10111010
    .byte #%10111010
    .byte #%00101000
    .byte #%00101000
    .byte #%00101000
    .byte #%01101100
    .byte #%00000000

PlayerClr:
    .byte #$80
    .byte #$22
    .byte #$22
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$42
    .byte #$82
    .byte #$84
    .byte #$84
    .byte #$82
    .byte #$80
    
    org ORG_END
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
