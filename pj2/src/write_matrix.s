.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue

    addi sp, sp, -32
    sw ra, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw s0, 16(sp)
    sw s1, 20(sp)

    li a1, 1                # a1 = 1: write-only
    jal fopen
    li t0, -1
    beq a0, t0, fopen_error

    mv s0, a0               # s0: store the file descriptor

    lw t0, 8(sp)
    lw t1, 12(sp)
    mul s1, t0, t1          # s1: store the number of elements  

    addi sp, sp, -8
    sw t0, 0(sp)
    sw t1, 4(sp)            # store rows and cols into the buffer
    mv a1, sp               # a1: pointer to buffer
    addi sp, sp, 8

    li a2, 2                # a2: elements number
    li a3, 4                # a3: size of each element

    jal fwrite
    li a2, 2
    bne a2, a0, fwrite_error

    mv a0, s0               # a0: file descriptor
    lw a1, 4(sp)            # a1: pointer to buffer(the matrix in memory)
    mv a2, s1               # a2: number of elements
    li a3, 4                # a3: size of each element
    jal fwrite
    bne a0, s1, fwrite_error

    mv a0, s0               # a0: file descriptor
    jal fclose
    bne a0, zero, fclose_error


    # Epilogue
    lw ra, 0(sp)
    lw s0, 16(sp)
    lw s1, 20(sp)
    addi sp, sp, 32
    jr ra

fopen_error:
    li a0, 27
    j exit

fwrite_error:
    li a0, 30
    j exit

fclose_error:
    li a0, 28
    j exit