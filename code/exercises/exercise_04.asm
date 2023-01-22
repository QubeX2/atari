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

    lda #100
    
    clc         ; always clear carry before addition
    adc #5

    sec         ; always set the carry before subtraction
    sbc #10

    jmp start
;====================================================================
; Fill the ROM size to exactly 4kb
;====================================================================    
    org $fffc
    .word start     ; Reset vector at $fffc (where the programs start)
    .word start     ; Interrupt vector $fffe (unused in the VCS)
