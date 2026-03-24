.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    li t0, 5
    bne a0, t0, argument_error

    addi sp, sp, -64
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    sw s5, 48(sp)
    sw s6, 52(sp)

    mv s0, a1           # s0: store the argv pointer
    mv s1, a2           # s1: store the print argument

    # Read pretrained m0
    li a0, 4
    jal malloc
    beq a0, zero, malloc_error
    mv s6, a0

    li a0, 4
    jal malloc
    beq a0, zero, malloc_error

    mv a1, s6           # a1: allocated pointer
    mv a2, a0           # a2: allcated pointer

    sw a1, 24(sp)       # 24(sp): pointer to m0's rows
    sw a2, 28(sp)       # 28(sp): pointer to m0's cols
    
    lw a0, 4(s0)        # a0: pointer to m0's filename

    jal read_matrix
    mv s2, a0           # s2: pointer to m0

    # Read pretrained m1
    li a0, 4
    jal malloc
    beq a0, zero, malloc_error
    mv s6, a0

    li a0, 4
    jal malloc
    beq a0, zero, malloc_error

    mv a1, s6           # a1: allcated pointer
    mv a2, a0           # a2: allcated pointer
    sw a1, 32(sp)       # 32(sp): pointer to m1's rows
    sw a2, 36(sp)       # 36(sp): pointer to m1's cols

    lw a0, 8(s0)        # a0: pointer to m1's filename

    jal read_matrix
    mv s3, a0           # s3: pointer to m1

    # Read input matrix
    li a0, 4
    jal malloc
    beq a0, zero, malloc_error
    mv s6, a0

    li a0, 4
    jal malloc
    beq a0, zero, malloc_error

    mv a1, s6           # a1: allcated pointer
    mv a2, a0           # a2: allcated pointer
    sw a1, 40(sp)       # 40(sp): pointer to input's rows
    sw a2, 44(sp)       # 44(sp): pointer to input's cols

    lw a0, 12(s0)       # a0: pointer to input's filename

    jal read_matrix
    mv s4, a0           # s4: pointer to input

    # Compute h = matmul(m0, input)
    lw t0, 24(sp)   
    lw t2, 0(t0)        # t2: rows of m0
    lw t1, 44(sp)   
    lw t3, 0(t1)        # t1: cols of input
    mul a0, t2, t3
    mv s6, a0           # s6: elements number
    slli a0, a0, 2      # a0: bytes to be allocated
    jal malloc

    beq a0, zero, malloc_error
    mv s5, a0           # s5: store the pointer to h

    mv a0, s2           # a0: pointer to m0
    lw t0, 24(sp)   
    lw a1, 0(t0)        # a1: rows of m0
    lw t0, 28(sp)
    lw a2, 0(t0)        # a2: cols of m0

    mv a3, s4           # a3: pointer to input
    lw t0, 40(sp)   
    lw a4, 0(t0)        # a4: rows of input
    lw t0, 44(sp)   
    lw a5, 0(t0)        # a5: cols of input
    mv a6, s5           # a6: pointer to h

    jal matmul  

    # Compute h = relu(h)
    mv a0, s5           # a0: pointer to h
    mv a1, s6           # a1: elements number of h
    jal relu

    # Compute o = matmul(m1, h)
    lw t0, 32(sp)
    lw t1, 0(t0)        # t1: rows of o(rows of m1)
    lw t2, 44(sp)   
    lw t3, 0(t2)        # t3: cols of o(cols of input)
    mul a0, t1, t3
    slli a0, a0, 2      # a0: bytes to be allocated
    jal malloc

    beq a0, zero, malloc_error
    mv s6, a0           # s6: store the pointer to o

    mv a0, s3           # a0: pointer to m1
    lw t0, 32(sp)
    lw a1, 0(t0)        # a1: rows of m1
    lw t0, 36(sp)
    lw a2, 0(t0)        # a2: cols of m1

    mv a3, s5           # a3: pointer to h
    lw t0, 24(sp)
    lw a4, 0(t0)        # a4: rows of h(rows of m1)
    lw t0, 44(sp)
    lw a5, 0(t0)        # a5: cols of h(cols of input)
    mv a6, s6           # a6: pointer to o

    jal matmul     

    # Write output matrix o

    lw a0, 16(s0)       # a0: pointer to output's filename
    mv a1, s6           # a1: pointer to o
    lw t0, 32(sp)
    lw a2, 0(t0)        # a2: rows of o(rows of m1)
    lw t1, 44(sp)
    lw a3, 0(t1)        # a3: cols of o(cols of input)

    jal write_matrix


    # Compute and return argmax(o)
    mv a0, s6           # a0: pointer to of o
    lw t0, 32(sp)
    lw t2, 0(t0)        # t2: rows of o(rows of m1)
    lw t1, 44(sp)
    lw t3, 0(t1)        # t3: cols of o(cols of input)
    mul a1, t2, t3      # a1: elements number of o
    jal argmax
    mv s6, a0           # save the return value of argmax


    # If enabled, print argmax(o) and newline
    bne s1, zero, end   # s1: print argument
    jal print_int       # a0: return value of argmax

    li a0, '\n'
    jal print_char      # print newline

end:
    lw a0, 24(sp)       # free pointer to m0's rows
    jal free    

    lw a0, 28(sp)       # free pointer to m0's cols
    jal free

    lw a0, 32(sp)       # free pointer to m1's rows
    jal free

    lw a0, 36(sp)       # free pointer to m1's cols
    jal free

    lw a0, 40(sp)       # free pointer to input's rows
    jal free            

    lw a0, 44(sp)       # free pointer to input's cols
    jal free

    mv a0, s5           # free pointer to h
    jal free

    mv a0, s6           # free pointer to o
    jal free    

    mv a0, s6           # return the argmax result

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 48(sp)
    lw s6, 52(sp)
    addi sp, sp, 64
    jr ra

argument_error:
    li a0, 31
    j exit

malloc_error:
    li a0, 26
    j exit