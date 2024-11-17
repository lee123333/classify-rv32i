# Assignment 2
>contributed by < [李皓翔]() >
## Part A: Mathematical Functions

### Task 1: ReLU
The full name of ReLU is Rectified Linear Unit .It is a type of activation function used in neural networks. The purpose of an activation function is to introduce non-linear characteristics into the neural network.

In the early days, before deep networks were developed, one commonly used algorithm for data prediction was linear regression. As its name implies, linear regression can only be used to predict data that exhibits a linear distribution, making it difficult to describe non-linear relationships with such a function. However, in real life, most phenomena are non-linear. For example, the relationship between income and age in the United States forms a curved distribution. Thus, predicting the income of a person of a given age would clearly be challenging using linear regression.

To address more complex problems, methods with non-linear characteristics, such as logistic regression, were developed. Logistic regression allowed solving simple binary classification problems and paved the way for more advanced models.
![image](https://github.com/user-attachments/assets/7c3b9db0-94ab-4f17-985d-6d2df3283113)



#### relu.s
In `relu.s`, I implemented two approaches:
1. **Using `bgez`:** 
This approach checks if the values in the array are greater than or equal to 0. If the value is greater than or equal to 0, it jumps to the label `loop_continue`. Otherwise, the value is set to zero.
3. **Using branchless logic:** 
In this method, I used the srai instruction to replace the 32 bits of the original value with its sign bits. Then, I performed a bitwise `not` operation on the transformed value. Finally, I performed a bitwise `and` operation between the original value and the transformed value to get the result. This branchless approach avoids the use of conditional branching.
```s
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
    # TODO: Add your own implementation
    beq t0 , a1, loop_end            
    slli t1, t0, 2                    
    add t2, a0, t1 
    lw t3, 0(t2)
    bgez t3, loop_continue
    add t3 ,x0, x0
    sw t3, 0(t2)
    
loop_continue:
    addi t0, t0, 1
    j loop_start

loop_end:

    # Epilogue

	ret
error:
    li a0, 36          
    j exit 
```
#### relu.s (branchless)
```s
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

    beq t0,a1,loop_end   # when t0 == a1 stop
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
loop_end:
    ret
```


### Task 2: argmax
Argmax is a mathematical and computational operation that returns the argument (input) that maximizes a given function. In simpler terms, it tells which input produces the highest output for a given function. 
In argmax.s, implement the argmax function, which returns the index of the largest element in a given vector. If multiple elements share the largest value, return the smallest index. This function operates on 1D vectors.
#### argmax.s
In `argmax.s`.First, load the first element of the array into t0. Since RISC-V memory operates in 4-byte units (one word), I incremented the pointer by 4 before reading each subsequent element and I implemented two methods to find the max value and its index.
1. **Using `ble`:** 
In this approach, I used the `ble` instruction to compare the size of each element. If the newly read value was greater than the previous maximum, it replaced the current maximum, and I updated the index. Otherwise, it jumped to the loop_continue label to proceed with the loop.
2. **Using branchless logic :**
In this method, I first subtracted the two values to be compared. I then applied `srai` to extend the sign bit of the result to 32 bits (t5). Next, I performed a `not` operation on the extended value (t6). Using these result (t5 & t6), I applied a bitwise `and` to the two values being compared. As a result, the smaller value became zero, while the larger value retained its original value. Adding these two values yielded the maximum value, effectively replacing the need for conditional branching.

```s
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
    lw t0, 0(a0)
    li t1, 0 #counter to end
    
loop_start:
    beq t1, a1, loop_end
    slli t4, t1, 2
    add t4, t4, a0
    lw t5, 0(t4)
    ble t5, t0, loop_continue
    mv t0, t5                       # update the maximum value
    mv t2, t1                       # update the maximum index
    
loop_continue:
    addi t1, t1, 1
    j loop_start

loop_end:
    mv a0, t2                       # return the maximum index
    
    ret
    
handle_error:
    li a0, 36
    j exit
```
#### argmax.s (branchless)
```s
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

```
### Task 3.1: Dot Product

The dot product  is an operation between two vectors that results in a scalar (a single number).In `dot.s`, implement the dot product function, defined as:
![公式](https://latex.codecogs.com/svg.latex?dot(a,b)=\sum_{i=0}^{n-1}(a_i\cdot&space;b_i))


![image](https://github.com/user-attachments/assets/380819d6-c03f-46ea-aa59-6992647190b9)


#### dot.s

In `dot.s`,  I set `t0` to store the multiplication result and `t1` as a counter to record the number of iterations . Since RISC-V memory operates in 4-byte units, the values in `a3` and `a4` are left-shifted by 2 (equivalent to multiplying by 4) to calculate the correct memory offsets.

For the dot product computation, I implemented a custom `multiply` routine instead of using the `mul` instruction. To ensure that the registers used in the loop are not affected by the `multiply` function call, I saved the values of frequently used registers onto the stack before calling `multiply`. This approach preserves the state of the registers and avoids unintended side effects during the computation
```s
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
    sw a3,4(sp)
    sw a2,8(sp)
 


loop_start:
    bge t1, a2, loop_end    # when t1 = a2 end loop (end for loop)

    addi sp, sp, -4
    sw a0, 0(sp)
    lw a2,0(a0)
    lw a3,0(a1)
    
    jal multiply
    
    add t0,t0,a0
    lw a0, 0(sp)
    addi sp, sp, 4
    lw a3, 4(sp)
    lw a2, 8(sp)
    addi t1,t1,1
    add a0,a0,a3
    add a1,a1,a4
    j loop_start

loop_end:

    mv a0, t0
    lw ra,0(sp)
    addi sp,sp,12
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit



```
### multiply function
In the `multiply` function, I implemented a simple binary multiplication algorithm. For example, to compute 101×11 (i.e., 5×3 in decimal):
This can be represented as:
![image](https://github.com/user-attachments/assets/a5358acb-08f8-4fc9-a071-4c82da4a6d69)

Hence, We can perform the multiplication simply by following these steps:
1. Left-shift the multiplicand (e.g., 101) for each bit in the multiplier, effectively multiplying it by powers of 2.
2. Right-shift the multiplier (e.g., 11), examining one bit at a time.
3. Add the appropriately shifted multiplicand to the result only when the corresponding bit in the multiplier is 1.

```s
# =======================================================
#multiply function
#Input 
#        a1: multiplicand
#        a2: multiplier
#Output 
#        a0: multiplication result
# =======================================================
multiply: 

    li a0, 0 

multiply_loop:
    andi a5, a2, 1     
    beqz a5, skip_add  
    add a0, a0, a3     

skip_add:
    slli a3, a3, 1      
    srli a2, a2, 1      
    bnez a2, multiply_loop 
    ret
```

### Task 3.2: Matrix Multiplication
In `matmul.s`, implement matrix multiplication, where:
$$
C[i][j] = \text{dot}(A[i], B[:,j]) 
$$
Given matrices $A(size, n\times m)$ and $B(size, m\times k)$, the output matrix $C$ will have dimensions $n\times k$. 
* Rows of matrix $A$ will have **stride = 1**.
* Columns of matrix $B$ will require calculating the correct starting index and stride.
#### matmul.s
In matmul.s, the matrix is stored in row-major order, meaning elements are laid out in memory row by row. For example, given the matrix: ![image](https://github.com/user-attachments/assets/2b72916d-db14-47b8-99b1-4da6a6f05083)
Its memory layout would be:
![image](https://github.com/user-attachments/assets/2338792f-8cae-4c0a-82cf-65184feb0b55)

In this function, it is divided into an outer loop and an inner loop:
* **Outer Loop:**
This loop iterates over the rows of the first matrix. The stride for this matrix is 1, as its rows are laid out contiguously in memory.
* **Inner Loop:**
The inner loop performs the multiplication between a row of the first matrix and a column of the second matrix. To achieve this, the stride for the second matrix is set to its row length (the number of columns in the second matrix),becaues of the row-major order .

Each element of the resulting matrix is computed as the dot product of a row from the first matrix and a column from the second matrix.After computing the dot product for each combination of rows and columns, the result is stored back into the appropriate memory address. 

```s
.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication Implementation
#
# Performs operation: D = M0 × M1
# Where:
#   - M0 is a (rows0 × cols0) matrix
#   - M1 is a (rows1 × cols1) matrix
#   - D is a (rows0 × cols1) result matrix
#
# Arguments:
#   First Matrix (M0):
#     a0: Memory address of first element
#     a1: Row count
#     a2: Column count
#
#   Second Matrix (M1):
#     a3: Memory address of first element
#     a4: Row count
#     a5: Column count
#
#   Output Matrix (D):
#     a6: Memory address for result storage
#
# Validation (in sequence):
#   1. Validates M0: Ensures positive dimensions
#   2. Validates M1: Ensures positive dimensions
#   3. Validates multiplication compatibility: M0_cols = M1_rows
#   All failures trigger program exit with code 38
#
# Output:
#   None explicit - Result matrix D populated in-place
# =======================================================
matmul:
    # Error checks
    li t0 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    
    li s0, 0 # outer loop counter 
    li s1, 0 # inner loop counter
    mv s2, a6 
    mv s3, a0 
    mv s4, a3 
    
outer_loop_start:
    #s0 is going to be the loop counter for the rows in A
    li s1, 0
    mv s4, a3
    blt s0, a1, inner_loop_start

    j outer_loop_end
    
inner_loop_start:
# HELPER FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use = number of columns of A, or number of rows of B
#   a3 (int)  is the stride of arr0 = for A, stride = 1
#   a4 (int)  is the stride of arr1 = for B, stride = len(rows) - 1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
    beq s1, a5, inner_loop_end

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    
    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B
    
    jal dot
    
    mv t0, a0 # storing result of the dot product into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24
    
    sw t0, 0(s2)   
    addi s2, s2, 4 
    
    li t1, 4
    add s4, s4, t1 # incrememtning the column on Matrix B
    
    addi s1, s1, 1
    j inner_loop_start
    
inner_loop_end:
    # TODO: Add your own implementation
    slli s5,a2,2
    add s3,s3,s5
    addi s0,s0,1
    j outer_loop_start
outer_loop_end:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    
    ret
error:
    li a0, 38
    j exit
```
### Task 4 : Absolute Value
For any real number ${\displaystyle x}$, the absolute value or modulus of ${\displaystyle x}$ is denoted by ${\displaystyle |x|}$, with a vertical bar on each side of the quantity, and is defined as
![image](https://github.com/user-attachments/assets/6c4c63f3-8ca6-4dd5-bf8c-79dcb737f57e)


#### abs.s
In `abs.s`, I implemented a method to compute the absolute value of a number using bitwise operations:

1. **Extend the sign bit:**
Use the `srai` instruction to perform an arithmetic right shift, extending the sign bit across all 32 bits. This produces a mask:
    * If the number is negative, the mask becomes all 1s (0xFFFFFFFF).
    * If the number is non-negative, the mask becomes all 0s (0x00000000).

2. **Flip bits for negative numbers:**
Perform a bitwise XOR between the original value and the sign-extended mask. This effectively:
    * Leaves positive numbers unchanged (XOR with 0).
    * Flips all bits of negative numbers (XOR with 0xFFFFFFFF).

3. **Adjust for two's complement:**
Add 1 to the result if the number was negative, completing the two's complement operation and converting the negative value to its positive equivalent.

```ｓ
.globl abs

.text
# =================================================================
# FUNCTION: Absolute Value Converter
#
# Transforms any integer into its absolute (non-negative) value by
# modifying the original value through pointer dereferencing.
# For example: -5 becomes 5, while 3 remains 3.
#
# Args:
#   a0 (int *): Memory address of the integer to be converted
#
# Returns:
#   None - The operation modifies the value at the pointer address
# =================================================================
abs:
    # Prologue
    ebreak
    # Load number from memory
    lw t0 0(a0)
    bge t0, zero, done

    # TODO: Add your own implementation
    srai t1, t0, 31
    xor t0, t0, t1 
    addi t0,t0,1
    sw t0,0(a0)
done:
    # Epilogue
    jr ra
```
## Part B: File Operations and Main
### Task 1: Read Matrix
In `read_matrix.s`, implement the function to read a binary matrix from a file and load it into memory. If any file operation fails, exit with the following codes:

* 48: Malloc error
* 50: fopen error
* 51: fread error
* 52: fclose error

#### read_matrix.s
To replace the original mul instruction with the custom multiply function in this part of the code:
**1. Replace `mul` with `multiply`:**
The custom `multiply` function, which simulates multiplication using bitwise operations, is called instead of using the mul instruction.
**2. Save affected registers:**
Identify the registers that are used in the loop or are critical to the computation and may be altered by the `multiply` function. These registers are pushed onto the stack using the sw instruction before the function call.
**3. Restore saved registers:**
After the `multiply` function completes, the saved registers are restored from the stack using the lw instruction. This ensures that the function's temporary changes do not disrupt the main computation flow.

```s
.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Binary Matrix File Reader
#
# Loads matrix data from a binary file into dynamically allocated memory.
# Matrix dimensions are read from file header and stored at provided addresses.
#
# Binary File Format:
#   Header (8 bytes):
#     - Bytes 0-3: Number of rows (int32)
#     - Bytes 4-7: Number of columns (int32)
#   Data:
#     - Subsequent 4-byte blocks: Matrix elements
#     - Stored in row-major order: [row0|row1|row2|...]
#
# Arguments:
#   Input:
#     a0: Pointer to filename string
#     a1: Address to write row count
#     a2: Address to write column count
#
#   Output:
#     a0: Base address of loaded matrix
#
# Error Handling:
#   Program terminates with:
#   - Code 26: Dynamic memory allocation failed
#   - Code 27: File access error (open/EOF)
#   - Code 28: File closure error
#   - Code 29: Data read error
#
# Memory Note:
#   Caller is responsible for freeing returned matrix pointer
# ==============================================================================
read_matrix:
    
    # Prologue
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    mv s3, a1         # save and copy rows
    mv s4, a2         # save and copy cols

    li a1, 0

    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # fopen didn't work

    mv s0, a0        # file

    # read rows n columns
    mv a0, s0
    addi a1, sp, 28  # a1 is a buffer

    li a2, 8         # look at 2 numbers

    jal fread

    li t0, 8
    bne a0, t0, fread_error

    lw t1, 28(sp)    # opening to save num rows
    lw t2, 32(sp)    # opening to save num cols

    sw t1, 0(s3)     # saves num rows
    sw t2, 0(s4)     # saves num cols

    # mul s1, t1, t2   # s1 is number of elements
    addi sp,sp,-16
    sw a0,0(sp)
    sw a2,4(sp)
    sw a3,8(sp)
    sw a5,12(sp)
    mv a2,t1
    mv a3,t2
    jal multiply
    mv s1,a0
    
    lw a0,0(sp)
    lw a2,4(sp)
    lw a3,8(sp)
    lw a5,12(sp)
    addi sp,sp,16
    slli t3, s1, 2
    sw t3, 24(sp)    # size in bytes

    lw a0, 24(sp)    # a0 = size in bytes

    jal malloc

    beq a0, x0, malloc_error

    # set up file, buffer and bytes to read
    mv s2, a0        # matrix
    mv a0, s0
    mv a1, s2
    lw a2, 24(sp)

    jal fread

    lw t3, 24(sp)
    bne a0, t3, fread_error

    mv a0, s0

    jal fclose

    li t0, -1

    beq a0, t0, fclose_error

    mv a0, s2

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 40

    jr ra

malloc_error:
    li a0, 26
    j error_exit

fopen_error:
    li a0, 27
    j error_exit

fread_error:
    li a0, 29
    j error_exit

fclose_error:
    li a0, 28
    j error_exit

error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 40
    j exit

multiply: 

    li a0, 0 
multiply_loop:
    andi a5, a2, 1     
    beqz a5, skip_add  
    add a0, a0, a3   

skip_add:
    slli a3, a3, 1      
    srli a2, a2, 1    
    bnez a2, multiply_loop 
    ret
```
### Task 2: Write Matrix
In `write_matrix.s`, implement the function to write a matrix to a binary file. Use the following exit codes for errors:

* 53: fopen error
* 54: fwrite error
* 55: fclose error

#### write_matrix.s
To replace the original mul instruction with the custom multiply function in this part of the code:
**1. Replace `mul` with `multiply`:**
The custom `multiply` function, which simulates multiplication using bitwise operations, is called instead of using the mul instruction.
**2. Save affected registers:**
Identify the registers that are used in the loop or are critical to the computation and may be altered by the `multiply` function. These registers are pushed onto the stack using the sw instruction before the function call.
**3. Restore saved registers:**
After the `multiply` function completes, the saved registers are restored from the stack using the lw instruction. This ensures that the function's temporary changes do not disrupt the main computation flow.
```s
.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Write a matrix of integers to a binary file
# FILE FORMAT:
#   - The first 8 bytes store two 4-byte integers representing the number of 
#     rows and columns, respectively.
#   - Each subsequent 4-byte segment represents a matrix element, stored in 
#     row-major order.
#
# Arguments:
#   a0 (char *) - Pointer to a string representing the filename.
#   a1 (int *)  - Pointer to the matrix's starting location in memory.
#   a2 (int)    - Number of rows in the matrix.
#   a3 (int)    - Number of columns in the matrix.
#
# Returns:
#   None
#
# Exceptions:
#   - Terminates with error code 27 on `fopen` error or end-of-file (EOF).
#   - Terminates with error code 28 on `fclose` error or EOF.
#   - Terminates with error code 30 on `fwrite` error or EOF.
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    # save arguments
    mv s1, a1        # s1 = matrix pointer
    mv s2, a2        # s2 = number of rows
    mv s3, a3        # s3 = number of columns

    li a1, 1

    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # fopen didn't work

    mv s0, a0        # file descriptor

    # Write number of rows and columns to file
    sw s2, 24(sp)    # number of rows
    sw s3, 28(sp)    # number of columns

    mv a0, s0
    addi a1, sp, 24  # buffer with rows and columns
    li a2, 2         # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    li t0, 2
    bne a0, t0, fwrite_error

    # mul s4, s2, s3   # s4 = total elements
    addi sp,sp,-16
    sw a0,0(sp)
    sw a2,4(sp)
    sw a3,8(sp)
    sw a5,12(sp)
    mv a2,s2
    mv a3,s3
    jal multiply
    mv s4,a0
    
    lw a0,0(sp)
    lw a2,4(sp)
    lw a3,8(sp)
    lw a5,12(sp)
    addi sp,sp,16
    # write matrix data to file
    mv a0, s0
    mv a1, s1        # matrix data pointer
    mv a2, s4        # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    bne a0, s4, fwrite_error

    mv a0, s0

    jal fclose

    li t0, -1
    beq a0, t0, fclose_error

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44

    jr ra

fopen_error:
    li a0, 27
    j error_exit

fwrite_error:
    li a0, 30
    j error_exit

fclose_error:
    li a0, 28
    j error_exit

error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44
    j exit
multiply: 

    li a0, 0 
multiply_loop:
    andi a5, a2, 1     
    beqz a5, skip_add  
    add a0, a0, a3    

skip_add:
    slli a3, a3, 1      
    srli a2, a2, 1     
    bnez a2, multiply_loop
    ret

```


    

### Task 3: Classification
In `classify.s`, bring everything together to classify an input using two weight matrices and the ReLU and ArgMax functions. Use the following sequence:
1. Matrix Multiplication:
$\text{hidden_layer} = \text{matmul}(m0, \text{input})$
2. ReLU Activation:
$\text{relu(hidden_layer)}$
3. Second Matrix Multiplication:
$\text{scores} = \text{matmul}(m1, \text{hidden_layer})$
4. Classification:
Call `argmax` to find the index of the highest score.
#### classify.s
To replace the original mul instruction with the custom multiply function in this part of the code:
**1. Replace `mul` with `multiply`:**
The custom `multiply` function, which simulates multiplication using bitwise operations, is called instead of using the mul instruction.
**2. Save affected registers:**
Identify the registers that are used in the loop or are critical to the computation and may be altered by the `multiply` function. These registers are pushed onto the stack using the sw instruction before the function call.
**3. Restore saved registers:**
After the `multiply` function completes, the saved registers are restored from the stack using the lw instruction. This ensures that the function's temporary changes do not disrupt the main computation flow.
```s
.globl classify

.text
# =====================================
# NEURAL NETWORK CLASSIFIER
# =====================================
# Description:
#   Command line program for matrix-based classification
#
# Command Line Arguments:
#   1. M0_PATH      - First matrix file location
#   2. M1_PATH      - Second matrix file location
#   3. INPUT_PATH   - Input matrix file location
#   4. OUTPUT_PATH  - Output file destination
#
# Register Usage:
#   a0 (int)        - Input: Argument count
#                   - Output: Classification result
#   a1 (char **)    - Input: Argument vector
#   a2 (int)        - Input: Silent mode flag
#                     (0 = verbose, 1 = silent)
#
# Error Codes:
#   31 - Invalid argument count
#   26 - Memory allocation failure
#
# Usage Example:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
# =====================================
classify:
    # Error handling
    li t0, 5
    blt a0, t0, error_args
    
    # Prolouge
    addi sp, sp, -48
    
    sw ra, 0(sp)
    
    sw s0, 4(sp) # m0 matrix
    sw s1, 8(sp) # m1 matrix
    sw s2, 12(sp) # input matrix
    
    sw s3, 16(sp) # m0 matrix rows
    sw s4, 20(sp) # m0 matrix cols
    
    sw s5, 24(sp) # m1 matrix rows
    sw s6, 28(sp) # m1 matrix cols
     
    sw s7, 32(sp) # input matrix rows
    sw s8, 36(sp) # input matrix cols
    sw s9, 40(sp) # h
    sw s10, 44(sp) # o
    
    # Read pretrained m0
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s3, a0 # save m0 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s4, a0 # save m0 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 4(a1) # set argument 1 for the read_matrix function  
    mv a1, s3 # set argument 2 for the read_matrix function
    mv a2, s4 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s0, a0 # setting s0 to the m0, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12
    # Read pretrained m1
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s5, a0 # save m1 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s6, a0 # save m1 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 8(a1) # set argument 1 for the read_matrix function  
    mv a1, s5 # set argument 2 for the read_matrix function
    mv a2, s6 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s1, a0 # setting s1 to the m1, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12

    # Read input matrix
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s7, a0 # save input rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s8, a0 # save input cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 12(a1) # set argument 1 for the read_matrix function  
    mv a1, s7 # set argument 2 for the read_matrix function
    mv a2, s8 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s2, a0 # setting s2 to the input matrix, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12

    # Compute h = matmul(m0, input)
    addi sp, sp, -28
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw t0, 0(s3)
    lw t1, 0(s8)
    # mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation
    mv a2,t0
    mv a3,t1
    jal multiply
    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s9, a0 # move h to s9
    
    mv a6, a0 # h 
    
    mv a0, s0 # move m0 array to first arg
    lw a1, 0(s3) # move m0 rows to second arg
    lw a2, 0(s4) # move m0 cols to third arg
    
    mv a3, s2 # move input array to fourth arg
    lw a4, 0(s7) # move input rows to fifth arg
    lw a5, 0(s8) # move input cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 28
    
    # Compute h = relu(h)
    addi sp, sp, -8
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    
    mv a0, s9 # move h to the first argument
    lw t0, 0(s3)
    lw t1, 0(s8)
    # mul a1, t0, t1 # length of h array and set it as second argument
    # FIXME: Replace 'mul' with your own implementation
    addi sp,sp -8
    sw a0, 0(sp)
    sw a2, 4(sp)

    mv a2,t0
    mv a3,t1
    jal multiply
    mv a1,a0
    lw a0, 0(sp)
    lw a2, 4(sp)

    addi sp,sp,8
    
    jal relu
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    
    addi sp, sp, 8
    
    # Compute o = matmul(m1, h)
    addi sp, sp, -28
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw t0, 0(s3)
    lw t1, 0(s6)
    mv a2,t0
    mv a3,t1
    # mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation
    jal multiply
    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s10, a0 # move o to s10
    
    mv a6, a0 # o
    
    mv a0, s1 # move m1 array to first arg
    lw a1, 0(s5) # move m1 rows to second arg
    lw a2, 0(s6) # move m1 cols to third arg
    
    mv a3, s9 # move h array to fourth arg
    lw a4, 0(s3) # move h rows to fifth arg
    lw a5, 0(s8) # move h cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 28
    
    # Write output matrix o
    addi sp, sp, -16
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    
    lw a0, 16(a1) # load filename string into first arg
    mv a1, s10 # load array into second arg
    lw a2, 0(s5) # load number of rows into fourth arg
    lw a3, 0(s8) # load number of cols into third arg
    
    jal write_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    
    addi sp, sp, 16
    
    # Compute and return argmax(o)
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv a0, s10 # load o array into first arg
    lw t0, 0(s3)
    lw t1, 0(s6)
    #mul a1, t0, t1 
    # FIXME: Replace 'mul' with your own implementation
    addi sp,sp,-4
    sw a0,0(sp)
    mv a2,t0
    mv a3,t1
    jal multiply
    mv a1,a0
    lw a0,0(sp)
    addi sp,sp,4
    jal argmax
    mv t0, a0 # move return value of argmax into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp 12
    
    mv a0, t0

    # If enabled, print argmax(o) and newline
    bne a2, x0, epilouge
    
    addi sp, sp, -4
    sw a0, 0(sp)
    
    jal print_int
    li a0, '\n'
    jal print_char
    
    lw a0, 0(sp)
    addi sp, sp, 4
    
    # Epilouge
epilouge:
    addi sp, sp, -4
    sw a0, 0(sp)
    
    mv a0, s0
    jal free
    
    mv a0, s1
    jal free
    
    mv a0, s2
    jal free
    
    mv a0, s3
    jal free
    
    mv a0, s4
    jal free
    
    mv a0, s5
    jal free
    
    mv a0, s6
    jal free
    
    mv a0, s7
    jal free
    
    mv a0, s8
    jal free
    
    mv a0, s9
    jal free
    
    mv a0, s10
    jal free
    
    lw a0, 0(sp)
    addi sp, sp, 4

    lw ra, 0(sp)
    
    lw s0, 4(sp) # m0 matrix
    lw s1, 8(sp) # m1 matrix
    lw s2, 12(sp) # input matrix
    
    lw s3, 16(sp) 
    lw s4, 20(sp)
    
    lw s5, 24(sp)
    lw s6, 28(sp)
    
    lw s7, 32(sp)
    lw s8, 36(sp)
    
    lw s9, 40(sp) # h
    lw s10, 44(sp) # o
    
    addi sp, sp, 48
    
    jr ra

error_args:
    li a0, 31
    j exit

error_malloc:
    li a0, 26
    j exit
multiply: 

    li a0, 0 
multiply_loop:
    andi a5, a2, 1     
    beqz a5, skip_add 
    add a0, a0, a3   

skip_add:
    slli a3, a3, 1     
    srli a2, a2, 1     
    bnez a2, multiply_loop
    ret

    
```
## Test Result
### .test.sh all
![image](https://hackmd.io/_uploads/ry2vubLMyg.png)
