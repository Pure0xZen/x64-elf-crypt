section .data
    msg1        db  "Welcome to crypt!", 10, 10, 0
    len1        equ $-msg1
    msg2        db  "1) Encrypt", 10, 0
    len2        equ $-msg2
    msg3        db  "2) Decrypt",10, 0
    len3        equ $-msg3
    msg4        db  "Choose one option (1/2): ", 0
    len4        equ $-msg4
    number      dq  0x0
    msg5        db  10, "Enter message: ", 0
    len5        equ $-msg5
    seed        dq  0xDEADBEEFDEADBEEF
    error1      db  10, "Error... Please check what you typed and try again...", 10, 10, 0
    lnerror     equ $-error1
    result      db  "Result: ", 10, 0
    len_res     equ $-result
    error2      db  10, "Error... Please enter a message to continue...", 10, 10, 0
    lnerror1    equ $-error2
    seed_key    dq  0x0F4D87B1536457AF
section .bss
    dkey        resb    1
    buffer      resb    500000
    body_enc    resb    500000
    input_len   resq    1
    hex_len     resq    1
    buffer_out  resb    500000
    hex_buffer  resb    10000000
    nonce       resq    1
    final_key   resq    1
    key         resb    8
    key1        resb    8
    octet1      resb    1
    octet2      resb    1
    octet3      resb    1
    octet4      resb    1
    octet5      resb    1
    octet6      resb    1
    octet7      resb    1
    octet8      resb    1
    nonbuffer   resb    8
    out_len     resq    1

section .text
                global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, len1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, len2
    syscall                 ;display messages
    mov rax, 1
    mov rdi, 1
    mov rsi, msg3
    mov rdx, len3
    syscall
huh:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg4
    mov rdx, len4
    syscall
huh1:
    mov rax, 0
    mov rdi, 0
    mov rsi, number
    mov rdx, 2     ;known issue
    syscall
    jmp check
enter_msg:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg5
    mov rdx, len5
    syscall
    ret
read_input:
    mov rsi, buffer
    mov rbx, 499990
    xor r12, r12
    jmp .next_char
.next_char:
    cmp r12, rbx
    je .done
    jmp .read
.read:

    mov rax, 0
    mov rdi, 0
    lea rsi, [buffer+r12]
    mov rdx, 1
    syscall
    mov al, [buffer+r12]
    cmp al, 0x0A
    je decide
    inc r12
    jmp .next_char
.done:
    cmp r12, 0
    je .next_char

    ret
check:
    mov al, [rel number]
    cmp al, '1'
    je encrypt
    cmp al, '2'
    je decrypt
    jmp error
encrypt:
    call enter_msg
    call read_input
    cpuid
    call retry
    mov rdx, rax
    mov [rel nonce], rdx
    mov rax, [rel seed]
    xor rax, rdx
    rol rax, 15
    mov [rel final_key], rax
    ror rax, 3
    mov rdx, [rel final_key]
    xor rax, rdx
    rol rax, 12
    mov [rel final_key], rax
    mov r13, rax
    mov [rel key], r13b
    shr r13, 8
    mov [rel key+1], r13b
    shr r13, 8
    mov [rel key+2], r13b
    shr r13, 8
    mov [rel key+3], r13b
    shr r13, 8
    mov [rel key+4], r13b
    shr r13, 8
    mov [rel key+5], r13b
    shr r13, 8
    mov [rel key+6], r13b
    shr r13, 8
    mov [rel key+7], r13b
    shr r13, 8
    call .encrypt_decryptor
    mov r14, [rel final_key]
    mov al, r14b
    xor al, 0
    rol al, 2
    add al, 3
    mov [rel buffer_out], al
    shr r14, 8
    mov al, r14b
    xor al, 1
    rol al, 2
    add al, 4
    mov [rel buffer_out+1], al
    shr r14, 8
    mov al, r14b
    xor al, 2
    rol al, 2
    add al, 2
    mov [rel buffer_out+2], al
    shr r14, 8
    mov al, r14b
    xor al, 3
    rol al, 2
    add al, 1
    mov [rel buffer_out+3], al
    shr r14, 8
    mov al, r14b
    xor al, 4
    rol al, 2
    add al, 5
    mov [rel buffer_out+4], al
    call buffer_writer
    jmp exit
.encrypt_decryptor:
    xor rcx, rcx
    mov rax, [rel seed]
    mov rbx, [rel seed_key]
    xor rax, rbx
    add rax, 0xE9F17
    ror rax, 17
    mov r14, rax
    mov [rel key1], r14b
    shr r14, 8
    mov [rel key1+1], r14b
    shr r14, 8
    mov [rel key1+2], r14b
    shr r14, 8
    mov [rel key1+3], r14b
    shr r14, 8
    mov [rel key1+4], r14b
    shr r14, 8
    mov [rel key1+5], r14b
    shr r14, 8
    mov [rel key1+6], r14b
    shr r14, 8
    mov [rel key1+7], r14b
    shr r14, 8
    xor rcx, rcx
    call .finaly_key_for_message
    ret
.finaly_key_for_message:
    mov al, [key+rcx]
    mov bl, [key1+rcx]
    xor al, bl
    sub al, 0x00000012
    xor al, 0x00000017
    mov dl, cl
    add dl, 0x00000043
    rol dl, 1
    xor al, dl
    mov [key+rcx], al
    inc rcx
    cmp rcx, 8
    jne .finaly_key_for_message
    ret
buffer_writer:
    mov rsi, buffer_out
    add rsi, 5
    mov rdi, buffer
    mov rbx, [rel input_len]
    mov rax, [rel nonce]
    mov r15, rax
    mov [rel nonbuffer], r15b
    shr r15, 8
    mov [rel nonbuffer+1], r15b
    shr r15, 8
    mov [rel nonbuffer+2], r15b
    shr r15, 8
    mov [rel nonbuffer+3], r15b
    shr r15, 8
    mov [rel nonbuffer+4], r15b
    shr r15, 8
    mov [rel nonbuffer+5], r15b
    shr r15, 8
    mov [rel nonbuffer+6], r15b
    shr r15, 8
    mov [rel nonbuffer+7], r15b
    shr r15, 8
    mov al, [rel key]
    mov [rel octet1], al
    mov al, [rel key+1]
    mov [rel octet2], al
    mov al, [rel key+2]
    mov [rel octet3], al
    mov al, [rel key+3]
    mov [rel octet4], al
    mov al, [rel key+4]
    mov [rel octet5], al
    mov al, [rel key+5]
    mov [rel octet6], al
    mov al, [rel key+6]
    mov [rel octet7], al
    mov al, [rel key+7]
    mov [rel octet8], al
    call retry
    and al, 0x07
    inc al
    xor rbx, rbx
    mov bl, al
    xor rdx, rdx
    mov dl, bl
    xor dl, 5
    shl dl, 2
    add dl, 3
    rol dl, 1
    mov [rel buffer_out+5], dl
    movzx rbx, bl
    mov [rel dkey], bl
    xor r10, r10
    mov r10, 6
    xor r9, r9
    mov [rel out_len], 6
    call octet1_encrypt
    movzx rbx, byte [rel dkey]
    mov rsi, buffer_out
    add rsi, 6
    mov rdi, body_enc
    mov rcx, [rel input_len]
    rep movsb
    mov r8, [rel input_len]
    imul r8, rbx
    xor r9, r9
.fill_trash:
    cmp r9, r8
    jge .fill_done
    call retry
    mov [buffer_out + 6+ r9], al
    inc r9
    jmp .fill_trash
.fill_done:
    xor r9, r9
.scatter:
    cmp r9, [rel input_len]
    jge .scatter_done
    mov rax, r9
    imul rax, rbx
    mov dl, [body_enc+r9]
    mov [buffer_out + 6 + rax], dl
    inc r9
    jmp .scatter
.scatter_done:
    mov r9, [rel input_len]
    imul r9, rbx
    add r9, 6
    mov r14, [rel final_key]
    shr r14, 40
    mov al, r14b
    xor al, 3
    rol al, 2
    add al, 5
    mov [buffer_out+r9], al
    shr r14, 8
    mov al, r14b
    xor al, 2
    rol al, 1
    add al, 4
    mov [buffer_out+r9+1], al
    shr r14, 8
    mov al, r14b
    xor al, 4
    rol al, 3
    add al, 3
    mov [buffer_out+r9+2], al
    add r9, 3
    mov [rel out_len], r9
    mov r8, [rel out_len]
    call print_as_hex
    ret
octet1_encrypt:
    cmp r9, [rel input_len]
    jae return
    xor rcx, rcx
    call help
    xor rbx, rbx
    mov bl, [buffer+r9]
    xor r8, r8
    mov r8, r9
    inc r8
    mov dl, [rel octet1]
    xor dl, r8b
    rol dl, 1
    xor dl, bl
    ror dl, 2
    mov [buffer_out+r10], dl
    mov rdx, [rel out_len]
    inc rdx
    mov [rel out_len], rdx
    inc r9
    inc r10
    jmp octet2_encrypt
octet2_encrypt:
    cmp r9, [rel input_len]
    jge return
    xor rcx, rcx
    call help
    xor rbx, rbx
    mov bl, [buffer+r9]
    xor r8, r8
    mov r8, r9
    inc r8
    mov dl, [rel octet2]
    xor dl, r8b
    rol dl, 1
    xor dl, bl
    ror dl, 2
    mov [buffer_out+r10], dl
    mov rdx, [rel out_len]
    inc rdx
    mov [rel out_len], rdx
    inc r9
    inc r10
    jmp octet3_encrypt
octet3_encrypt:
    cmp r9, [rel input_len]
    jge return
    xor rcx, rcx
    call help
    xor rbx, rbx
    mov bl, [buffer+r9]
    xor r8, r8
    mov r8, r9
    inc r8
    mov dl, [rel octet3]
    xor dl, r8b
    rol dl, 1
    xor dl, bl
    ror dl, 2
    mov [buffer_out+r10], dl
    mov rdx, [rel out_len]
    inc rdx
    mov [rel out_len], rdx
    inc r9
    inc r10
    jmp octet4_encrypt
octet4_encrypt:
    cmp r9, [rel input_len]
    jge return
    xor rcx, rcx
    call help
    xor rbx, rbx
    mov bl, [buffer+r9]
    xor r8, r8
    mov r8, r9
    inc r8
    mov dl, [rel octet4]
    xor dl, r8b
    rol dl, 1
    xor dl, bl
    ror dl, 2
    mov [buffer_out+r10], dl
    mov rdx, [rel out_len]
    inc rdx
    mov [rel out_len], rdx
    inc r9
    inc r10
    jmp octet5_encrypt
octet5_encrypt:
    cmp r9, [rel input_len]
    jge return
    xor rcx, rcx
    call help
    xor rbx, rbx
    mov bl, [buffer+r9]
    xor r8, r8
    mov r8, r9
    inc r8
    mov dl, [rel octet5]
    xor dl, r8b
    rol dl, 1
    xor dl, bl
    ror dl, 2
    mov [buffer_out+r10], dl
    mov rdx, [rel out_len]
    inc rdx
    mov [rel out_len], rdx
    inc r9
    inc r10
    jmp octet6_encrypt
octet6_encrypt:
    cmp r9, [rel input_len]
    jge return
    xor rcx, rcx
    call help
    xor rbx, rbx
    mov bl, [buffer+r9]
    xor r8, r8
    mov r8, r9
    inc r8
    mov dl, [rel octet6]
    xor dl, r8b
    rol dl, 1
    xor dl, bl
    ror dl, 2
    mov [buffer_out+r10], dl
    mov rdx, [rel out_len]
    inc rdx
    mov [rel out_len], rdx
    inc r9
    inc r10
    jmp octet7_encrypt
octet7_encrypt:
    cmp r9, [rel input_len]
    jge return
    xor rcx, rcx
    call help
    xor rbx, rbx
    mov bl, [buffer+r9]
    xor r8, r8
    mov r8, r9
    inc r8
    mov dl, [rel octet7]
    xor dl, r8b
    rol dl, 1
    xor dl, bl
    ror dl, 2
    mov [buffer_out+r10], dl
    mov rdx, [rel out_len]
    inc rdx
    mov [rel out_len], rdx
    inc r9
    inc r10
    jmp octet8_encrypt
octet8_encrypt:
    cmp r9, [rel input_len]
    jge return
    xor rcx, rcx
    call help
    xor rbx, rbx
    mov bl, [buffer+r9]
    xor r8, r8
    mov r8, r9
    inc r8
    mov dl, [rel octet8]
    xor dl, r8b
    rol dl, 1
    xor dl, bl
    ror dl, 2
    mov [buffer_out+r10], dl
    mov rdx, [rel out_len]
    inc rdx
    mov [rel out_len], rdx
    inc r9
    inc r10
    jmp octet1_encrypt
help:
    mov cl, [buffer_out+r10]
    cmp cl, 0x0
    je return
    inc r10
    jmp help
print_as_hex:
    xor rsi, rsi
    xor rdi, rdi
.convert_loop:
    cmp rsi, r8
    jge .done_hex
    mov al, [buffer_out+rsi]

    mov bl, al
    shr bl, 4
    call .to_ascii
    mov [hex_buffer+rdi], bl
    inc rdi
    mov bl, al
    and bl, 0x0F
    call .to_ascii
    mov [hex_buffer+rdi], bl
    inc rdi
    mov byte [hex_buffer+rdi], ' '
    inc rdi
    inc rsi
    jmp .convert_loop
.to_ascii:
    cmp bl, 10
    jl .is_digit
    add bl, 7
.is_digit:
    add bl, '0'
    ret
.done_hex:
    mov byte [hex_buffer+rdi], 10
    inc rdi
    mov [rel hex_len], rdi
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel hex_buffer]
    mov rdx, [rel hex_len]
    syscall
    ret
return:
    ret
decrypt:
    call enter_msg
    call read_input
    call hex_decode
    mov dl, [rel buffer+5]
    ror dl, 1
    sub dl, 3
    shr dl, 2
    xor dl, 5
    mov [rel dkey], dl
    mov r8, [rel input_len]
    call remake_key
    movzx rbx, byte [rel dkey]
    mov rax, [rel input_len]
    sub rax, 9
    xor rdx, rdx
    div rbx
    mov r8, rax
    test r8, r8
    jle print_buffer
    xor r9, r9

.extract:
    cmp r9, r8
    jge .extract.done
    mov rax, r9
    imul rax, rbx
    mov dl, [buffer+6+rax]
    mov [buffer + r9], dl
    inc r9
    jmp .extract

.extract.done:
    xor r9, r9
    xor r11, r11
    call octet1_decrypt
    call print_buffer
    jmp exit
remake_key:
    mov al, [rel buffer]
    sub al, 3
    ror al, 2
    xor al, 0
    mov [rel key], al
    mov al, [rel buffer+1]
    sub al, 4
    ror al, 2
    xor al, 1
    mov [rel key+1], al
    mov al, [rel buffer+2]
    sub al, 2
    ror al, 2
    xor al, 2
    mov [rel key+2], al
    mov al, [rel buffer+3]
    sub al, 1
    ror al, 2
    xor al, 3
    mov [rel key+3], al
    mov al, [rel buffer+4]
    sub al, 5
    ror al, 2
    xor al, 4
    mov [rel key+4], al
    xor rcx, rcx
    mov rcx, r8
    sub rcx, 3
    mov al, [buffer+rcx]
    sub al, 5
    ror al, 2
    xor al, 3
    mov [rel key+5], al
    xor rcx, rcx
    mov rcx, r8
    sub rcx, 2
    mov al, [buffer+rcx]
    sub al, 4
    ror al, 1
    xor al, 2
    mov [rel key+6], al
    xor rcx, rcx
    mov rcx, r8
    sub rcx, 1
    mov al, [buffer+rcx]
    sub al, 3
    ror al, 3
    xor al, 4
    mov [rel key+7], al
    call remake_key1
    mov al, [rel key]
    mov [rel octet1], al
    mov al, [rel key+1]
    mov [rel octet2], al
    mov al, [rel key+2]
    mov [rel octet3], al
    mov al, [rel key+3]
    mov [rel octet4], al
    mov al, [rel key+4]
    mov [rel octet5], al
    mov al, [rel key+5]
    mov [rel octet6], al
    mov al, [rel key+6]
    mov [rel octet7], al
    mov al, [rel key+7]
    mov [rel octet8], al
    ret
remake_key1:
    xor rcx, rcx
    mov rax, [rel seed]
    mov rbx, [rel seed_key]
    xor rax, rbx
    add rax, 0xE9F17
    ror rax, 17
    mov r14, rax
    mov [rel key1], r14b
    shr r14, 8
    mov [rel key1+1], r14b
    shr r14, 8
    mov [rel key1+2], r14b
    shr r14, 8
    mov [rel key1+3], r14b
    shr r14, 8
    mov [rel key1+4], r14b
    shr r14, 8
    mov [rel key1+5], r14b
    shr r14, 8
    mov [rel key1+6], r14b
    shr r14, 8
    mov [rel key1+7], r14b
    shr r14, 8
    xor rcx, rcx
    call remake_key2
    ret
remake_key2:
    mov al, [key+rcx]
    mov bl, [key1+rcx]
    xor al, bl
    sub al, 0x00000012
    xor al, 0x00000017
    mov dl, cl
    add dl, 0x00000043
    rol dl, 1
    xor al, dl
    mov [key+rcx], al
    inc rcx
    cmp rcx, 8
    jne remake_key2
    ret
final_clear:
    cmp rbx, r8
    jge return
    mov al, [buffer+rbx]
    mov [buffer+rbx-6], al
    inc rbx
    jmp final_clear
octet1_decrypt:
    cmp r9, r8
    jae return
    mov bl, [buffer+r9]
    rol bl, 2
    xor r11, r11
    mov r11, r9
    inc r11
    mov cl, [rel octet1]
    xor cl, r11b
    rol cl, 1
    xor cl, bl
    mov [buffer+r9], cl
    inc r9
    jmp octet2_decrypt
octet2_decrypt:
    cmp r9, r8
    jae return
    mov bl, [buffer+r9]
    rol bl, 2
    xor r11, r11
    mov r11, r9
    inc r11
    mov cl, [rel octet2]
    xor cl, r11b
    rol cl, 1
    xor cl, bl
    mov [buffer+r9], cl
    inc r9
    jmp octet3_decrypt
octet3_decrypt:
    cmp r9, r8
    jae return
    mov bl, [buffer+r9]
    rol bl, 2
    xor r11, r11
    mov r11, r9
    inc r11
    mov cl, [rel octet3]
    xor cl, r11b
    rol cl, 1
    xor cl, bl
    mov [buffer+r9], cl
    inc r9
    jmp octet4_decrypt
octet4_decrypt:
    cmp r9, r8
    jae return
    mov bl, [buffer+r9]
    rol bl, 2
    xor r11, r11
    mov r11, r9
    inc r11
    mov cl, [rel octet4]
    xor cl, r11b
    rol cl, 1
    xor cl, bl
    mov [buffer+r9], cl
    inc r9
    jmp octet5_decrypt
octet5_decrypt:
    cmp r9, r8
    jae return
    mov bl, [buffer+r9]
    rol bl, 2
    xor r11, r11
    mov r11, r9
    inc r11
    mov cl, [rel octet5]
    xor cl, r11b
    rol cl, 1
    xor cl, bl
    mov [buffer+r9], cl
    inc r9
    jmp octet6_decrypt
octet6_decrypt:
    cmp r9, r8
    jae return
    mov bl, [buffer+r9]
    rol bl, 2
    xor r11, r11
    mov r11, r9
    inc r11
    mov cl, [rel octet6]
    xor cl, r11b
    rol cl, 1
    xor cl, bl
    mov [buffer+r9], cl
    inc r9
    jmp octet7_decrypt
octet7_decrypt:
    cmp r9, r8
    jae return
    mov bl, [buffer+r9]
    rol bl, 2
    xor r11, r11
    mov r11, r9
    inc r11
    mov cl, [rel octet7]
    xor cl, r11b
    rol cl, 1
    xor cl, bl
    mov [buffer+r9], cl
    inc r9
    jmp octet8_decrypt
octet8_decrypt:
    cmp r9, r8
    jae return
    mov bl, [buffer+r9]
    rol bl, 2
    xor r11, r11
    mov r11, r9
    inc r11
    mov cl, [rel octet8]
    xor cl, r11b
    rol cl, 1
    xor cl, bl
    mov [buffer+r9], cl
    inc r9
    jmp octet1_decrypt
error:
    mov rax, 1
    mov rdi, 1
    mov rsi, error1
    mov rdx, lnerror
    syscall
    jmp exit
decide:
    cmp r12, 0
    je errormsg
    mov byte [buffer+r12], 0
    mov [rel input_len], r12
    ret
retry:
    rdseed rax
    jnc retry
    ret
errormsg:
    mov rax, 1
    mov rdi, 1
    mov rsi, error2
    mov rdx, lnerror1
    syscall
    jmp exit
print_buffer:
    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, len_res
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, r8
    syscall
    push 10
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rax
    ret
hex_decode:
    xor rsi, rsi
    xor rdi, rdi
next_byte:
    mov al, [buffer+rsi]
    cmp al, 0
    je done_decode
    cmp al, 0x0A
    je done_decode
    cmp al, ' '
    je skip_ws
    cmp al, 9
    je skip_ws
    call char_to_val
    shl al, 4
    mov bl, al
    inc rsi
    mov al, [buffer+rsi]
    call char_to_val
    or bl, al
    inc rsi
    mov [buffer+rdi], bl
    inc rdi
    jmp next_byte
skip_ws:
    inc rsi
    jmp next_byte
done_decode:
    mov [rel input_len], rdi
    ret
char_to_val:
    cmp al, '0'
    jl invalid
    cmp al, '9'
    jle is_digit1
    cmp al, 'A'
    jl check_lower
    cmp al, 'F'
    jle is_upper
check_lower:
    cmp al, 'a'
    jl invalid
    cmp al, 'z'
    jg invalid
    sub al, 'a'-10
    ret
is_digit1:
    sub al, '0'
    ret
is_upper:
    sub al, 'A'-10
    ret
invalid:
    xor al, al
    ret
exit:
    xor rax, rax
    mov rax, 60
    xor rdi, rdi
    syscall
