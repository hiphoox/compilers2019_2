.p2align        4, 0x90
    .globl  main         ## -- Begin function main
main:                    ## @main
    mov     $10, %rax
    push    %rax
    mov     $7, %rax
    pop     %rcx
    sub     %rax, %rcx
    mov     %rcx, %rax
    ret     

