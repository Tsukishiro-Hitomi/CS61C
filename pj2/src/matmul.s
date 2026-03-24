.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    bge zero, a1, exception
    bge zero, a2, exception
    bge zero, a4, exception
    bge zero, a5, exception

    bne a2, a4, exception

    # Prologue
    addi sp, sp, -48
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)
    sw a4, 20(sp)
    sw a5, 24(sp)
    sw a6, 28(sp)
    sw s0, 32(sp)
    sw s1, 36(sp)
    sw s2, 40(sp)


    li s0, 0            # row index
    li s1, 0            # col index
    li s2, 0            # offset

outer_loop_start:
    lw a1, 8(sp)
    bge s0, a1, outer_loop_end



inner_loop_start:
    lw a5, 24(sp)
    bge s1, a5, inner_loop_end

    lw a0, 4(sp)        # address of m0
    lw a1, 16(sp)       # address of m1

    lw a2, 12(sp)       # columns of m0, also numbers to be mutiplied
    mul t0, s0, a2
    slli t0, t0, 2
    add a0, a0, t0      # begin of arr0

    slli t0, s1, 2
    add a1, a1, t0      # begin of arr1

    li a3, 1            # stride of arr0

    lw a4, 24(sp)       # columns of m1, also stride of arr1

    jal dot    
    lw a6, 28(sp)
    slli t0, s2, 2
    add t0, a6, t0      # compute the save address
    sw a0, 0(t0)        # save the result


    addi s1, s1, 1
    addi s2, s2, 1
    j inner_loop_start




inner_loop_end:
    addi s0, s0, 1
    mv s1, zero
    j outer_loop_start



outer_loop_end:


    # Epilogue
    lw ra, 0(sp)
    lw s0, 32(sp)
    lw s1, 36(sp)
    lw s2, 40(sp)
    addi sp, sp, 48

    jr ra

exception:
    li a0, 38
    j exit