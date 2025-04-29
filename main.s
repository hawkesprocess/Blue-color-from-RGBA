    .section .rodata
    .align 32
shuffle_mask:
    .byte 2,6,10,14,0x80,0x80,0x80,0x80
    .byte 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80
    .byte 2,6,10,14,0x80,0x80,0x80,0x80
    .byte 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80

    .section .text
    .globl _start
    .type _start,@function
_start:
    mov    $9,    %rax
    xor    %rdi, %rdi
    mov    $500000000, %rsi
    mov    $1,    %rdx
    mov    $0x8002, %r10
    xor    %r8,  %r8
    xor    %r9,  %r9
    syscall
    mov    %rax, %r12

    mov    $28,   %rax
    mov    %r12, %rdi
    mov    $500000000, %rsi
    mov    $2,    %rdx
    syscall

    mov    $77,   %rax
    mov    $1,    %rdi
    mov    $125000000, %rsi
    syscall

    mov    $9,    %rax
    xor    %rdi, %rdi
    mov    $125000000, %rsi
    mov    $2,    %rdx
    mov    $0x8001, %r10
    mov    $1,    %r8
    xor    %r9,  %r9
    syscall
    mov    %rax, %r13

    vmovdqu shuffle_mask(%rip), %ymm15

    mov    $125000000, %r14
    shr    $6, %r14

.Loop:
    prefetcht0 16384(%r12)
    .rept 8
      vmovdqa    (%r12), %ymm0
      vpshufb    %ymm15, %ymm0, %ymm0
      vextracti128 $1, %ymm0, %xmm1
      vmovd      %xmm0, %eax
      vmovd      %xmm1, %ecx
      shl        $32, %rcx
      or         %rcx, %rax
      movnti     %rax, (%r13)
      add        $32, %r12
      add        $8,  %r13
    .endr
    dec  %r14
    jne  .Loop

    vzeroupper

    mov    $60,   %rax
    xor    %rdi, %rdi
    syscall
