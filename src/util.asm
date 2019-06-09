section .data
in_fd: dq 0

section .text

exit: 
    mov rax, 60
    syscall

string_length:
    xor rax, rax
    .loop:
        cmp byte[rdi+rax], 0 ;сравниваем с концом строки
        je .exit ; если конец, выходим
        inc rax ; иначе увеличиваем счетчик длины
        jmp .loop    
    .exit:
    ret

print_string:
    push rdi ; сохраняем адрес 
    call string_length ; считаем длину строки
    mov rdx, rax ; результат вызова помещаем в rdx
    mov rax, 1 ; sys_write
    mov rdi, 1 ; stdout
    pop rsi ; source - адресс строки
    syscall
    ret


print_char:
    push rdi ; помещаем код символа на стэк
    mov rsi, rsp ; source - вершина стэка
    mov rax, 1 ; sys_write
    mov rdi, 1 ; stdout
    mov rdx, 1 ; count - 1
    syscall
    pop rdi ; возвращаем стэк в исходное положение
    ret

print_newline:
    mov rdi, 10 ; передаем в print-char код конца строки
    jmp print_char


print_uint:
    mov rax, rdi ; помещаем исходное число в аккумулятор 
    mov rdi, rsp 
    push 0 ; нуль-терминируем строку
    sub rsp, 16 ; выдеряем буффер на стэке 

    dec rdi ; dec rdi, т.к положили ноль
    mov r8, 10 ; делитель

    .loop:
        dec rdi ; смещаем указатель на буфер
        xor rdx, rdx ; обнуля rdx 
        div r8 ; делим на 10
        or dl, 0x30 ; приводим к ascii  символу
        mov [rdi], dl ; помещаем символ в буфер по адресу в rdi
        test rax, rax ; проверяем частное на равенство нуль
        jnz .loop ; если не ноль, повторяем

    call print_string    ; печатаем
    add rsp, 24 ; очищаем буфер 16 + 8(push 0)
    ret


print_int:
    test rdi, rdi ; 
    jns print_uint ; если не знаковое, просто выводим
    push rdi ; иначе сохраняем число
    mov rdi, '-' ; выводим минус
    call print_char
    pop rdi ; возвращаем число с вершины стэка
    neg rdi ; x = -x и выводим 
    jmp print_uint

string_equals:
    mov al, byte[rdi] ; текущий символ первой строки
    cmp al, byte[rsi] ; сравниваем текущии символы двух строк
    jne .false ; если не равны, возвращаем ноль
    inc rdi ; перемещаем указатель на следующие символы 
    inc rsi
    test al, al ; проверяем на конец строки
    jnz string_equals ; если не конец, продолжаем 
    mov rax, 1 ; иначе возвращаем один 
    ret
    .false:
    xor rax, rax
    ret

read_char:
    push 0 ;
    xor rax, rax ; 0 для sys_read
    xor rdi, rdi ; 0 для stdin
    mov rsi, rsp ;  читаем на вершину стэка 
    mov rdx, 1 ; 1 символ
    syscall
    pop rax ; возвращаем считанный символ
    ret 


section .text

read_word:
    xor r8, r8; счетчик длины 
    mov r9, rsi; размер буфера 
    dec r9 

    .skip:
    push rdi ; сохраняем адрес буфера
    call read_char ; читаем символ
    pop rdi

    test al, al ; проверка на конец строки
    je .end  
    
    cmp al, 0x21 ; пропускаем символы меньше 0х21
    jb .skip
    
    .read:
    mov byte [rdi + r8], al ; записываем символ в буфер 
    inc r8 ; увеличиваем счетчик длинны 

    push rdi
    call read_char 
    pop rdi

    cmp al, 0x21
    jb .end

    cmp r8, r9
    je .err

    jmp .read

    .end:
    mov byte[rdi + r8], 0 ; нуль-терминируем строку 
    mov rax, rdi

    mov rdx, r8
    ret

    .err:
    xor rax, rax
    ret
    

; rdi points to a string
; returns rax: number, rdx : length
parse_uint:
    xor rax, rax
    xor rcx, rcx 
    mov r8, 10
    xor r9, r9
    .loop:
    mov r9b, byte [rdi + rcx]
    cmp r9b, '0'
    jb .end
    cmp r9b, '9'
    ja .end

    xor rdx, rdx
    mul r8
    and r9b, 0x0f
    add rax, r9
    inc rcx
    jmp .loop
    
    .end:
    mov rdx, rcx
    ret

; rdi points to a string
; returns rax: number, rdx : length
parse_int:
    cmp byte[rdi], '-'
    je .negative
    jmp parse_uint
    
    .negative:
    inc rdi
    call parse_uint
    neg rax
    inc rdx
    ret 


string_copy:
    push rdi
    push rsi
    push rdx
    call string_length
    pop rdx
    pop rsi
    pop rdi

    cmp rax, rdx 
    jae .size_err

    push rsi
    
    .loop:
    mov al, byte[rdi]
    mov byte[rsi], al
    inc rdi
    inc rsi
    test al, al
    jnz .loop

    pop rax
    ret


    .size_err:
    xor rax, rax
    ret



print_no_word:
    mov rdi, word_buffer
    call print_string
    mov rdi, msg.no_such_word
    call print_string
    ret
    
cfa:
    add rdi, 9
    call string_length
    add rdi, rax
    add rdi, 2
    mov rax, rdi
    ret
    
find_word:
    xor eax, eax
    mov rsi, [last_word]
.loop:
    push rdi
    push rsi
    add rsi, 9
    call string_equals
    pop rsi
    pop rdi
    test rax, rax
    jnz .found
    mov rsi, [rsi]
    test rsi, rsi
    jnz .loop
    xor rax, rax
    ret
.found:
    mov rax, rsi
    ret
