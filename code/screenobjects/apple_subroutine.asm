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

PlayerBmpPtr .word
Player0YPos .byte
Player0XPos .byte

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

    lda #1
    sta Player0XPos

    ldx #50
    stx Player0YPos    

    lda #<PlayerBmp
    sta PlayerBmpPtr
    lda #>PlayerBmp
    sta PlayerBmpPtr+1

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
    sta HMCLR

    ldy #0
    jsr SetObjXPos
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
    lda (PlayerBmpPtr),y
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
    adc #2
    and #$7f
    sta Player0XPos
    jmp frame        ; repeat frame

;====================================================================
; Set Object X Position
;--------------------------------------------------------------------
; A = X-coordinate
; Y = Player0 (0), Player1 (1), Missile0 (2), Missile1 (3), Ball (4)
;====================================================================
SetObjXPos:
    sta WSYNC
    sec
.divide
    sbc #15
    bcs .divide
    eor #7
    asl
    asl
    asl
    asl
    sta HMP0,Y          ; 0,1,2,3,4 - offset to HMP0, HMP1, etc
    sta RESP0,Y
    rts

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
