.section .rodata
filename: .asciz "input.txt"
yes: .asciz "Yes\n"
no: .asciz "No\n"

.section .text
.globl main

main:
    addi sp, sp, -64
    sd   ra, 56(sp)
    sd   s0, 48(sp)

    la   a0, filename
    li   a1, 0
    call open@plt
    mv   s1, a0

    bltz s1, exit_err

    mv   a0, s1
    li   a1, 0
    li   a2, 2
    call lseek@plt
    mv   s2, a0

    beqz s2, print_yes

    li   s3, 0
    addi s4, s2, -1

loop:
    bge  s3, s4, print_yes

    mv   a0, s1
    mv   a1, s3
    li   a2, 0
    call lseek@plt

    mv   a0, s1
    addi a1, sp, 16
    li   a2, 1
    call read@plt
    lbu  s5, 16(sp)

    mv   a0, s1
    mv   a1, s4
    li   a2, 0
    call lseek@plt

    mv   a0, s1
    addi a1, sp, 16
    li   a2, 1
    call read@plt
    lbu  s6, 16(sp)

    bne  s5, s6, print_no

    addi s3, s3, 1
    addi s4, s4, -1 
    j    loop


print_yes:
    la   a0, yes
    call printf@plt
    j    end

print_no:
    la   a0, no
    call printf@plt

end:
    mv   a0, s1
    call close@plt

exit_err:
    li   a0, 0
    ld   ra, 56(sp)
    ld   s0, 48(sp)
    addi sp, sp, 64
    ret