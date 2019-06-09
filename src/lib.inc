native "drop", drop
    add rsp, 8
    jmp next

native "swap", swap
    pop rax
    pop rdx
    push rax
    push rdx
    jmp next

native "dup", dup
    push qword [rsp]
    jmp next

native "+", add
    pop rax
    pop rdx
    add rax, rdx
    push rax
    jmp next

native "*", mul
    pop rax
    pop rdx
    imul rdx
    push rax
    jmp next

native "/", div
    pop rcx
    pop rax
    cqo
    idiv rcx
    push rax
    jmp next

native "%", mod
    pop rcx
    pop rax
    cqo
    idiv rcx
    push rdx
    jmp next

native "-", sub
    pop rax
    pop rdx
    sub rdx, rax
    push rdx
    jmp next      

native "=", equals
    pop rax
    pop rdx
    cmp rax, rdx
    jne .not
    push 1
    jmp next
  .not:
    push 0
    jmp next

native "<", less
    pop rax
    pop rdx
    cmp rdx, rax
    jnl .not
    push 1
    jmp next
  .not:
    push 0
    jmp next

native "not", not
    pop rax
    test rax, rax
    setz al
    movzx rax, al
    push rax
    jmp next

native "and", and
    pop rax,
    pop rdx,
    and rax, rdx,
    push rax
    jmp next

native "or", or
    pop rax,
    pop rdx,
    or rax, rdx,
    push rax
    jmp next

native "land", land
    pop rax
    pop rdx
    test rax, rax
    jz .not
    push rdx
    jmp next
.not:
    push rax
    jmp next

native "lor", lor
    pop rax
    pop rdx
    test rax, rax
    jnz .yes
    push rdx
    jmp next
.yes:
    push rax
    jmp next

native ">r", push_r
    pop rax
    rpush rax
    jmp next

native "r>", pop_r
    rpop rax
    push rax
    jmp next

native "r@", fetch_r
    push qword [rstack]
    jmp next

native "@", fetch
    pop rax
    push qword[rax]
    jmp next

native "!", write
    pop rax
    pop rdx
    mov [rax], rdx
    jmp next

native "c!", write_byte
    pop rax
    pop rdx
    mov [rax], dl
    jmp next

native "c@", fetch_byte
    pop rax
    xor rdx, rdx
    mov dl, byte [rax]
    push rdx
    jmp next

native "execute", execute
    pop rax
    mov w, rax
    jmp [rax]

const "forth-dp", dp

native "docol", docol
    rpush pc
    add w, 8
    mov pc, w
    jmp next

native "branch", branch
    mov pc, [pc]
    jmp next

native "0branch", branch0
    pop rax
    test rax, rax
    jnz .skip
    mov pc, [pc]
    jmp next
    .skip:
    add pc, 8
    jmp next

native "exit", exit
    rpop pc
    jmp next

native "lit", lit
    push qword [pc]
    add pc, 8
    jmp next

native "sp", sp
    push rsp
    jmp next

native "syscall", syscall
    pop r9
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi
    pop rax
    syscall
    push rax
    push rdx
    jmp next


native "'", forth_tick, 1
    mov rdi, word_buffer
    call read_word
    call find_word

    test rax, rax
    jz .no_word

    mov rdi, rax
    call cfa
   
    cmp qword[state], 1
    jne .interpret

    mov rdi, [here]			
    mov qword [rdi], xt_lit             	
    add qword [here], 8

    mov rdi, [here]
    mov [rdi], rax              	
    add qword [here], 8
    jmp next
.no_word:
    call print_no_word
    jmp next 
.interpret:
    push rax
    jmp next

native "last_word", last_word
    push qword last_word
    jmp next


native "here", here
    push qword here
    jmp next

native "here_adv", here_adv
    push qword [here]
    jmp next

native "forth-is-compiling", state
    push qword state
    jmp next

native "forth-input-fd", fd
    push qword fd
    jmp next

native "forth-stack-start", stack_start
    push qword stack_start
    jmp next

native "cfa", cfa
    pop rsi
    add rsi, 9
    .loop:
    mov al, [rsi]
    test al, al
    jz .end
    inc rsi
    jmp .loop

    .end:
    add rsi, 2
    push rsi
    jmp next

native ",", comma
    mov rax, [here]
    pop qword [rax]
    add qword [here], 8
    jmp next
