bits 16

section .data

    packet_buffer:
        db 'K', 'P'                  ; Offset +0: Magic Header ASCII 'K' and 'P'
        db 0x04                      ; Offset +2: Length = 4 bytes
        db 0x82                      ; Offset +3: Expected Checksum
        db 0xDE, 0xAD, 0xBE, 0xEF     ; Offset +4: 4 encrypted payload bytes

    MAGIC_WORD equ 0x504B            ; 'KP' represented in x86 Little-Endian

section .bss
    decrypted_buffer: resb 64        ; Reserve 64 bytes for decrypted payload output

section .text
    global _start

_start:
    
    mov ax, cs
    mov ds, ax
    mov es, ax

    mov ax, word [packet_buffer]
    mov cl, byte [packet_buffer + 2]
    mov dl, byte [packet_buffer + 3]
    mov si, packet_buffer + 4

    
    cli                              
    hlt                              