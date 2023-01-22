    processor 6502

    seg code
    org $f000       ; define the code origin at $f000

start:
    sei             ; disable interupts
    cld             ; disable the BCD math mode
    ldx #$ff        ; 
    txs             ; transfer x register to (S)tack pointer

;====================================================================
; Clear the Page Zero Region ($00 - $ff)
; Clear RAM and TIA registers
;====================================================================

    lda #0
    ldx #$ff

loop:
    sta $0,x        ; store the value of A inside memadr $0 + x
    dex
    bne loop        ; loop until x is equal to zero (z-flag i set)

;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================
    org $fffc
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)




