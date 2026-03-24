.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    addi sp, sp, -12
    sw s1, 0(sp)
    sw s2, 4(sp)
    sw s3, 8(sp)

    li t0, 1
    blt a2, t0, exception1
    blt a3, t0, exception2
    blt a4, t0, exception2

    mv t0, zero         # element index
    mv t1, zero         # result
    mv t2, zero         # arr0 index
    mv t3, zero         # arr1 index

loop_start:
    beq t0, a2, loop_end
    
    slli t4, t2, 2    
    add t4, t4, a0
    lw s1, 0(t4)

    slli t5, t3, 2
    add t5, t5, a1
    lw s2, 0(t5)

    mul s3, s1, s2
    add t1, t1, s3
    addi t0, t0, 1
    add t2, t2, a3
    add t3, t3, a4

    j loop_start

loop_end:


    # Epilogue
    lw s1, 0(sp)
    lw s2, 4(sp)
    lw s3, 8(sp)
    addi sp, sp, 12

    mv a0, t1
    jr ra

exception1:
    li a0 36
    j exit

exception2:
    li a0 37
    j exit