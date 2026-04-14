.section .rodata
filename: .asciz "input.txt"
yes: .asciz "Yes\n"
no: .asciz "No\n"

.section .text
.globl main

main:
    addi sp, sp, -64 # Did extra for buffer, the article said its good practice when handling with files.
    sd   ra, 56(sp)  # storing return address
    sd   s0, 48(sp)  # Storing frame pointer

    la   a0, filename # loading filename in a0
    li   a1, 0        # second argument is 0, which is read only.
    call open@plt     # Call open function
    mv   s1, a0       # store the file_pointer in s1

    bltz s1, exit_err # if file_pointer <= 0, then exit.

    mv   a0, s1       # a0 = file_pointer
    li   a1, 0        # a1 = 0, offset
    li   a2, 2        # a2 = 2, at end set it
    call lseek@plt    # call function
    mv   s2, a0       # store offset value in s2

    beqz s2, print_yes # if offset is 0, print yes (file is empty)

    li   s3, 0        # s3 = 0
    addi s4, s2, -1   # s4 = offset - 1 (end character before EOF)

loop:
    bge  s3, s4, print_yes # if left_pointer > right_pointer then print yes

    mv   a0, s1            # a0 = file_pointer
    mv   a1, s3            # a1 = left_pointer
    li   a2, 0             # a2 = 0 (begin)
    call lseek@plt         # call lseek

    mv   a0, s1            # a0 = file_pointer
    addi a1, sp, 16        # a1 = assign buffer
    li   a2, 1             # a2 = 1 (read)
    call read@plt          # call read
    lbu  s5, 16(sp)        # Load the byte unsigned into s5

    mv   a0, s1            # same as above but for right_pointer
    mv   a1, s4
    li   a2, 0
    call lseek@plt

    mv   a0, s1
    addi a1, sp, 16
    li   a2, 1
    call read@plt
    lbu  s6, 16(sp)

    bne  s5, s6, print_no # if left != right then not palindrome

    addi s3, s3, 1       # left++
    addi s4, s4, -1      # right --
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