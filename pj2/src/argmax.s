.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue

loop_start:
    addi t0, zero, 1
    blt a1, t0, exception

    addi t1, zero, 1    # t1: cur_index
    mv t2, zero    # t2: max_index

    lw t3, 0(a0)   # t3: max_value


loop_continue:
    beq t1, a1, loop_end

    slli t4, t1, 2
    add t4, t4, a0
    lw t5, 0(t4)    # t5: cur_value
    bge t3, t5, foo
    mv t3, t5
    mv t2, t1

foo:
    addi t1, t1, 1
    j loop_continue

loop_end:
    # Epilogue
    mv a0, t2
    jr ra

exception:
    li a0, 36
    j exit