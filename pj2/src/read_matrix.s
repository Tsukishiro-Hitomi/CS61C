.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw a1, 16(sp)
    sw a2, 20(sp)

    li a1, 0                # a1 = 0: read-only
    jal fopen

    li t0, -1
    beq a0, t0, fopen_error
    mv s0, a0               # s0: store the file descriptor

    addi sp, sp, -8
    mv a1, sp               # a1: read buffer
    li a2, 8                # a2: bytes to be read
    jal fread

    li a2, 8
    bne a2, a0, fread_error

    lw t0, 0(sp)            # rows of matrix
    lw t1, 4(sp)            # cols of matrix

    addi sp, sp, 8

    lw a1, 16(sp)
    lw a2, 20(sp)

    sw t0, 0(a1)            # store the rows
    sw t1, 0(a2)            # store the cols

    mul a0, t0, t1
    mv s2, a0               # s2: store the number of elements
    slli a0, a0, 2          # a0: bytes to be allocated
    jal malloc

    beq a0, zero, malloc_error
    mv s1, a0               # s1: store the pointer of allocated memory

    mv a0, s0               # a0: file descriptor
    mv a1, s1               # s1: pointer to memory
    slli a2, s2, 2          # a2: bytes to be read
    jal fread
    slli a2, s2, 2
    bne a0, a2, fread_error

    mv a0, s0               # a0: file descriptor
    jal fclose
    
    bne a0, zero, fclose_error
    mv a0, s1

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 32

    jr ra

fopen_error:
    li a0, 27
    j exit

malloc_error:
    li a0, 26
    j exit

fread_error:
    li a0, 29
    j exit

fclose_error:
    li a0, 28
    j exit