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
    lda #1
loop:
    clc
    adc #1
    cmp #10
    bne loop


    jmp start

;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
    org $fffc
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
