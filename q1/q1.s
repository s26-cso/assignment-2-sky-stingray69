.globl make_node
.globl insert
.globl get

make_node: 
    addi sp, sp, -16
    sd   ra, 8(sp)        # Save return address
    sw   a0, 4(sp)        # Save 'val'

    li   a0, 24           # malloc(sizeOf(struct Node)); sizeOf(struct Node) = 24; data - 4byte, padding - 4bytes, Node* left - 8bytes, Node* right - 8bytes
    call malloc

    lw   t0, 4(sp)        # Load 'val'
    sw   t0, 0(a0)        # new_node->val = val
    sd   x0, 8(a0)        # new_node->left = 0 (NULL) 
    sd   x0, 16(a0)       # new_node->right = 0 (NULL)
                          # Note: the new_node address is @ a0, hence automatically returned.
    ld   ra, 8(sp)
    addi sp, sp, 16
    ret
.globl getAtMost

insert:
    bnez a0, insert_traverse # if root != 0, insert_traverse()

    mv   a0, a1
    tail make_node           # tail call, as it is anyways end of the insert function. https://cass-kul.github.io/exercises/3-functions-stack/#excursion-tail-recursion

insert_traverse:
    addi sp, sp, -32
    sd   ra, 24(sp)
    sd   s0, 16(sp)
    sd   s1,  8(sp)
    sd   s2,  4(sp)

    mv   s0, a0            # s0 = root
    mv   s1, a0            # s1 = curr (root)
    mv   s2, a1            # s2 = val

insert_loop:
    lw   t0, 0(s1)         # t0 = curr->val
    bge  s2, t0, insert_right

insert_left:
    ld   t1, 8(s1)         # t1 = curr->left
    bnez t1, update_curr   # if curr->left != 0, then curr = t1

    mv   a0, s2            # else, a0 = val
    call make_node         # make_node(val); a0 <- new_node
    sd   a0, 8(s1)         # curr->left = a0
    j    insert_done          # insert_done (return root)

insert_right:
    ld   t1, 16(s1)        # t1 = curr->right
    bnez t1, update_curr   # if curr->right != 0, then curr = t1

    mv   a0, s2            # else, a0 = val
    call make_node         # make_node(val); a0 <- new_node
    sd   a0, 16(s1)        # curr->right = a0
    j    insert_done       # insert_done (return root)

update_curr:
    mv   s1, t1
    j    insert_loop

insert_done:
    mv   a0,  s0            # return root        
    lw   s2,  4(sp)
    ld   s1,  8(sp)
    ld   s0, 16(sp)
    ld   ra, 24(sp)
    addi sp, sp, 32
    ret

get:

get_loop:
    beqz a0, get_end       # root == 0, then get_end()

    lw   t0, 0(a0)         # t0 = curr->val
    beq  a1, t0, get_end   # if val == curr->val, then get_end

    blt  a1, t0, get_left  # if (val < curr->val), then get_left

    ld a0, 16(a0)          # curr = curr->right
    j get_loop             # jump to get_loop
               

get_left:
    ld a0, 8(a0)           # curr = curr-left
    j get_loop             # jump to get_loop
               

get_end:
    ret

getAtMost:
    li t1, -1

getAtMost_loop:
    beqz a1, getAtMost_end
    lw   t0, 0(a1) 
    bgt  t0, a0, getAtMost_left # if curr->val > val, then getAtMost_left()

    mv   t1, t0
    ld   a1, 16(a1)
    j    getAtMost_loop

getAtMost_left:
    ld   a1, 8(a1)              # curr = curr->left
    j    getAtMost_loop

getAtMost_end:
    mv a0, t1
    ret