.globl f # this allows other files to find the function f

# f takes in two arguments:
# a0 is the value we want to evaluate f at
# a1 is the address of the "output" array (read the lab spec for more information).
# The return value should be stored in a0
f:
    # Your code here
    addi t3, a0, 3 # get the correct array index
    slli t4, t3, 2 # compute the offset, note the size of int is 4
    add t4, a1, t4 # compute the address, store it in t4
    lw t5, 0(t4) # get the value, store it in t5
    mv a0, t5
    # This is how you return from a function. You'll learn more about this later.
    # This should be the last line in your program.
    jr ra
