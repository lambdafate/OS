;   file: /boot/boot.asm 
;   boot.asm, it is a little boot sector. it's size is 512byte
;   BIOS will load this file to 0x0000:0x7c00(cs:ip), and run in real mode
;   the main function of this file:
;        1. load the setup.asm to memory(0x7e00)
;        2. jmp to the setup.asm(cs=0x07e0, ip=0x0000)
;    
;   author: lambdafate
;   time  : 2020/03/10 
;

    ; declare some constant
    JmpTargetCS     equ     0x07e0          ; setup's cp
    JmpTargetIP     equ     0x0000          ; setup's ip
    LoadTargetSize  equ     0x02            ; setup's size (512byte*LoadTargetSize)

    ; let's begin the fucking boot sector!
    ; set stack register
    mov ax, 0x7c00
    mov ss, ax
    mov sp, 0x200

    ; clear the screen 
    mov ax, 0xb800
    mov es, ax
    mov bp, 0x0000
    mov cx, 25*80
clearscreen:
    mov word [es:bp], 0x0000
    add bp, 2
    loop clearscreen

    ; read the setup.asm
    mov ax, JmpTargetCS
    mov es, ax
    mov bx, JmpTargetIP             
    mov ah, 0x02
    mov al, LoadTargetSize
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, 0x00
    int 0x13                                ; read 'setup.asm' in boot disk

    ; set lightpoint position
    mov bh, 0
    mov dx, 0
    mov ah, 2
    int 0x10
    ; display stepinfo
    mov ax, 0x07c0
    mov es, ax
    mov bp, stepinfo
    mov cx, 25
    mov bl, 7
    call print

    ; check if reading is successful (cf=0 if success)
    jnc loadsuccess              
    ; loading setup.asm failed
    call readpoint
    mov bp, errorinfo
    mov cx, 28                            ; error message's size
    mov bl, 4                             ; message color
    call print                            ; display error message if failed, then stop runing
    jmp $

loadsuccess:
    ; load setup.asm success
    call readpoint
    mov bp, successinfo
    mov cx, 32
    mov bl, 7
    call print

    ; next, i will jmp to setup.
    ; jmp $
    jmp JmpTargetCS:JmpTargetIP


; es:bp -> string
; cx    -> string size
; bl    -> color
print:
    ; read lightpoint position, then display message
    mov bh, 0x00
    mov al, 0x01
    mov ah, 0x13
    int 0x10
    ret

readpoint:
    mov bh, 0x00
    mov ah, 0x03
    int 0x10
    ret



stepinfo:
    db  "[/boot/boot           ]: "                                 ; length 25
successinfo:
    db "bootsector reading successful!", 13, 10                     ; length 32
errorinfo:
    ; give some messages if reading error
    db "bootsector reading error!", 13, 10                          ; length 28

    times 510-($-$$) db 0
    db 0x55, 0xaa














