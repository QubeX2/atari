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

;# FRAME #############################################################
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

;# SUBROUTINES ######################################################
;====================================================================
; SetObjXPos
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

;# DATA #############################################################
;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
    org ORG_END
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
