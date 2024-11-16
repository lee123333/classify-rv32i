.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  


    li t0, 0    # product value -> 0       
    li t1, 0    # counter -> 0         
    slli a3,a3,2
    slli a4,a4,2
    addi sp,sp,-12
    sw ra,0(sp)
    sw a1,4(sp)
    sw a2,8(sp)
    mv t3,a0
    mv t4,a1


loop_start:
    beq t1, a2, loop_end    # when t1 = a2 end loop (end for loop)


    lw a1,0(t3)
    lw a2,0(t4)
    
    jal multiply
    
    add t0,t0,a0

    lw a1, 4(sp)
    lw a2, 8(sp)
    addi t1,t1,1
    add t3,t3,a3
    add t4,t4,a4
    j loop_start

loop_end:

    mv a0, t0
    lw ra,0(sp)
    addi sp,sp,12
    ret

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit

multiply: 

    li a0, 0 
multiply_loop:
    andi a5, a2, 1     
    beqz a5, skip_add  # 如果最低位為 0，跳過加法
    add a0, a0, a1     # 如果最低位為 1，將被乘數 (t5) 加到結果 (a6) 中

skip_add:
    slli a1, a1, 1      # 將被乘數 (t5) 左移 1 位，相當於被乘數乘以 2
    srli a2, a2, 1      # 將乘數 (t6) 右移 1 位，相當於移除最低位
    bnez a2, multiply_loop # 如果 t6 不為 0，繼續迴圈
    ret                  