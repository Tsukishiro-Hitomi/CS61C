.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -4
    sw s0, 0(sp)

    addi t0, zero, 1    # t0 = 1
    blt a1, t0, exception

    mv t1, zero    # t1 = zero
loop_start:
    beq t1, a1, end
    
    slli t2, t1, 2    # t2 = offset
    add t2, a0, t2

    lw t3, 0(t2)
    bge t3, zero, f
    mv t3, zero

f:
    sw t3, 0(t2)
    addi t1, t1, 1
    j loop_start

end:
    lw s0, 0(sp)
    addi sp, sp, 4
    jr ra

exception:
    li a0 36
    j exit








loop_continue:



loop_end:


    # Epilogue


    jr ra
