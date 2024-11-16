.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    li t0, 1             
    blt a1, t0, error     
    li t0, 0             

loop_start:

    beq t0,a1,end   # when t0 == a1 stop
    slli t1,t0,2    # t1 = t0 * sizeof(int)
    add t2,a0,t1    # t2 : address of the element
    lw t3 ,0(t2)    # load the element value
    srai t4,t3,31   # right shift the value,fill the entire 32 bits with the sign bit  
    xori t4,t4,-1   # bitwise NOT operation
    and t3,t3,t4    # if value > 0 keep it if not set it to 0
    sw t3,0(t2)     # store the value to array
    addi t0,t0,1    # count plus 1
    j loop_start    # back to loop


error:
    li a0, 36          
    j exit          
end:
    ret