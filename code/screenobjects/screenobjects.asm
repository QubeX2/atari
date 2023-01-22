;====================================================================
; Atari 2600 Startup
;====================================================================
    processor 6502

ORG_END = $fffc

    include "../_inc/vcs.h"
    include "../_inc/macro.h"

    seg code
    org $f000       ; define the code origin at $f000

start:
    CLEAN_START     ; macro to safely clear the memory

    ldx #$80        ; blue color
    stx COLUBK
    lda #$0f        ; white
    sta COLUPF      

    lda #$48
    sta COLUP0
    lda #$c6
    sta COLUP1

    ldy #%00000010
    sty CTRLPF

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
    REPEAT 10
        sta WSYNC
    REPEND

;; playfield score
    ldy #0
score:
    lda numberBmp,y
    sta PF1
    sta WSYNC
    iny
    cpy #10
    bne score

    lda #0
    sta PF1

    ;; draw 50 empty scanlines
    REPEAT 50 
        sta WSYNC
    REPEND

;; player 0
    ldy #0
ply0:
    lda playerBmp,y
    sta GRP0
    sta WSYNC
    iny
    cpy #10
    bne ply0   
    lda #0
    sta GRP0        ; disable player 0 graphics

;; player 1
    ldy #0
ply1:
    lda playerBmp,y
    sta GRP1
    sta WSYNC
    iny
    cpy #10
    bne ply1
    lda #0
    sta GRP1

    ; 102 scanlines

    REPEAT 102
        sta WSYNC
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
    org ORG_END - 20
playerBmp:
    .byte #%01111110
    .byte #%11111111
    .byte #%10011001
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%10111101
    .byte #%11000011
    .byte #%11111111
    .byte #%01111110

    org ORG_END - 10
numberBmp:
    .byte #%00001110
    .byte #%00001110
    .byte #%00000010
    .byte #%00000010
    .byte #%00001110
    .byte #%00001110
    .byte #%00001000
    .byte #%00001000
    .byte #%00001110
    .byte #%00001110

    org ORG_END
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
