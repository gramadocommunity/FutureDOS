bits 16
cpu 8086
org 0

%define _KERNEL_SEGMENT 0x0800
%define _KERNEL_OFFSET 0x0000

%macro PRINT_DONE 0
    mov bl, 0x02
    mov si, DONE_STR
    call puts
%endmacro

%macro PRINT_FAIL 0
    mov bl, 0x04
    mov si, FAIL_STR
    call puts
%endmacro

%macro PRINT_TRACE 1
    mov bl, 0x0F
    mov si, %1
    call puts
%endmacro

kmain:

    mov ax, _KERNEL_SEGMENT
    mov ds, ax
    mov es, ax

    call init_cga

    PRINT_TRACE INITIALIZING_DRIVERS_STR
    PRINT_DONE

    PRINT_TRACE REMAPING_INTERRUPTS_STR
    call init_ivt
    PRINT_DONE

    PRINT_TRACE LOADED_SUCCESSFULLY_STR

    PRINT_TRACE PROMPT

.a:
    call keyboard_getkey
    jmp .a


init_ivt:
    push ax
    push di
    push es

    xor ax, ax
    mov es, ax

    xor di, di

    cli

    mov [es:di+0x00], word isr0
    mov [es:di+0x02], word cs

    mov [es:di+0x24], word isr9
    mov [es:di+0x26], word cs

    sti

    pop es
    pop di
    pop ax
    ret


%include "kernel/drivers/cga.asm"
%include "kernel/drivers/keyboard.asm"

%include "kernel/lib/debug.asm"
%include "kernel/lib/screen.asm"
%include "kernel/lib/string.asm"

%include "kernel/isr/isr0.asm"
%include "kernel/isr/isr9.asm"

DONE_STR: db " DONE",0x0A,0x0D,0x00
FAIL_STR: db " FAIL",0x0A,0x0D,0x00

INITIALIZING_DRIVERS_STR: db "Initializing drivers...",0x00
REMAPING_INTERRUPTS_STR: db "Remapping interrupts...",0x00
LOADED_SUCCESSFULLY_STR: db "FutureDOS started successfully.",0x00

PROMPT: db 0x0a,0x0d,0x0a,0x0d,"# ",0x00
times 1536 - ($ - $$) db 0
