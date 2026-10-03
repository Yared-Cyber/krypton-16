bits 16

section .data

    packet_buffer:
        db 'K', 'P'                  
        db 0x04                      
        db 0x38                     
        db 0xDE, 0xAD, 0xBE, 0xEF     

    MAGIC_WORD equ 0x504B            
    MAX_PAYLOAD_LEN equ 32

section .bss
    decrypted_buffer: resb 64        
section .text
    global _start

_start:
    
    mov ax, cs
    mov ds, ax
    mov es, ax

    mov si, packet_buffer
    call validate_header
    cmp ax, 0
    je .drop_packet

    mov si, packet_buffer
    call verify_checksum
    cmp ax, 0
    je .drop_packet

    mov dx, 0x0001
    jmp .continue_pipeline


.drop_packet:
    mov dx, 0xFFFF
    cli                              
    hlt     

.continue_pipeline:
    cli
    hlt     

 validate_header:
    mov ax, word [si]
    cmp ax, MAGIC_WORD
    jne .invalid_hdr

    mov cl, byte [si + 2]
    cmp cl, 0
    je .invalid_hdr
    cmp cl, MAX_PAYLOAD_LEN
    ja .invalid_hdr

    mov ax, 1
    ret

.invalid_hdr:
    mov ax, 0
    ret     

verify_checksum:
    push bx

    mov cl, byte [si + 2]              
    mov ch, 0
    mov dl, byte [si + 3]

    add si, 4
    xor bl, bl

.checksum_loop:
    lodsb
    add bl, al
    loop .checksum_loop

    cmp bl, dl
    jne .chksum_mismatch

    mov ax, 1
    pop bx
    ret 

.chksum_mismatch:
    mov ax, 0
    pop bx
    ret 