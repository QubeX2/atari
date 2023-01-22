    processor 6502

    seg code
    org $f000       ; define the code origin at $f000

start:
    sei             ; disable interupts
    cld             ; disable the BCD math mode
    ldx #$ff        ; 
    txs             ; transfer x register to (S)tack pointer

;====================================================================
; Code
;====================================================================
    clc
    lda #$ff
    adc #1

    sec
    lda #$00
    sbc #1

    clc
    lda #$7f        ; overflow v
    adc #$01        ; addition goes outside range of -128 to 127

    jmp start

;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
    org $fffc
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
