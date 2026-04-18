.section .rodata
fmt_int: .asciz "%d"
fmt_space: .asciz " "
fmt_newline: .asciz "\n"

.section .text
.globl main
main:
    addi sp, sp, -64
    sd   ra, 56(sp) # Return address
    sd   s0, 48(sp) # Frame stack pointer
    sd   s1, 40(sp) # argc
    sd   s2, 32(sp) # argv pointer
    sd   s3, 24(sp) # Input array
    sd   s4, 16(sp) # output array
    sd   s5,  8(sp) # stack pointer

    mv   s1, a0     # s1 = argc
    addi s1, s1, -1 # s1 = argc - 1
    mv   s2, a1     # s2 = argv (pointer)

    blez s1, end    # if number_of_elem < 0, then end

    slli a0, s1, 2  # a0 = num_of_elem * sizeof(int) 
    call malloc@plt
    mv s3, a0       # s3 = pointer to freed space for input array
    
    slli a0, s1, 2  
    call malloc@plt
    mv s4, a0       # similarly for output array

    slli a0, s1, 2
    call malloc@plt
    mv s5, a0       # and for stack

    li t0, 0 # i = 0

parse_loop:
    beq t0, s1, process
    slli t1, t0, 3
    addi t1, t1, 8
    add t1, s2, t1
    ld a0, 0(t1)

    addi sp, sp, -16
    sd t0, 0(sp)
    call atoi@plt
    ld t0, 0(sp)
    addi sp, sp, 16

    slli t1, t0, 2
    add t1, s3, t1
    sw a0, 0(t1)

    addi t0, t0, 1
    j parse_loop

process:
    li t0, 0
    
init_res:           # To initialise output array with -1
    beq t0, s1, algo
    slli t1, t0, 2
    add t1, s4, t1
    li t2, -1
    sw t2, 0(t1)
    addi t0, t0, 1
    j init_res

algo:
    li s6, 0
    li t0, 0

algo_loop:
    beq t0, s1, print

    slli t1, t0, 2
    add t1, s3, t1
    lw t2, 0(t1) # t2 = input[i]

stack_check:
    blez s6, push_curr # if top <= 0 -> stack empty, hence push curr value

    addi t3, s6, -1 # t3 = top - 1
    slli t3, t3, 2  # t3 = t3 * 4 (sizeOf(int))
    add  t3, s5, t3 # t3 = stackPointer + t3
    lw   t4, 0(t3)  # t4 = stack[top]

    slli t5, t4, 2  # t5 = t4 * 4
    add  t5, s3, t5 # t5 = output + t5
    lw   t6, 0(t5)  # input[stack[top]]

    bge  t6, t2, push_curr

    slli t5, t4, 2
    add  t5, s4, t5
    sw   t0, 0(t5)  # output[stack[top]] = i

    addi s6, s6, -1 # pop
    j    stack_check

push_curr:
    slli t1, s6, 2
    add  t1, s5, t1
    sw   t0, 0(t1)
    addi s6, s6, 1

    addi t0, t0, 1
    j    algo_loop

print:
    li s6, 0

print_loop:
    beq s6, s1, print_newline

    slli t0, s6, 2
    add t0, s4, t0
    lw a1, 0(t0)

    la a0, fmt_int
    call printf@plt

    addi t0, s6, 1
    beq t0, s1, skip_space
    la a0, fmt_space
    call printf@plt

skip_space:
    add s6, s6, 1
    j print_loop

print_newline:
    la   a0, fmt_newline
    call printf@plt

end:
   li a0, 0
   ld ra, 56(sp)
   ld s0, 48(sp)
   ld s1, 40(sp)
   ld s2, 32(sp)
   ld s3, 24(sp)
   ld s4, 16(sp)
   ld s5, 8(sp)
   addi sp, sp, 64
   ret
