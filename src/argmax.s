.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t1, 0(a0)

    li t0, 0
    li t2, 0
loop_start:
    # TODO: Add your own implementation
    beq t0,a1,return  # when i == a1 exit  
    slli t3,t0,2    # t3 = sizeof(int)*i
    add t3,a0,t3    # t3 = address of value
    lw t4,0(t3)     # t4 = load the value from address
    sub t5,t1,t4    # max - next value
    srai t5,t5,31   # t5 = use sign bit to fill 32 bits if max > next value => 000... 
    xori t6,t5,-1   # t6 = not t5
    and t1,t1,t6    # if max > next value t1 = original value otherwise equal 0
    and t4,t4,t5    # if max < next value t4 = original value otherwise equal 0
    add t1,t1,t4    # decide max value
    and t5,t5,t0    # if max < next value t5 = next value index 
    and t2,t2,t6
    add t2,t2,t5    # decide max value index
    addi t0,t0,1    # i+1
    j loop_start 

handle_error:
    li a0, 36
    j exit
return:
    mv a0,t2
    ret
