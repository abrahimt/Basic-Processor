.data
arr: .word 29, 14, 57, 36, 91, 18, 42, 68, 5, 77, 53  # Array of 11 integers
space: .asciiz " "  # Space character
.text
.globl main  # Main function

main:
  lui $s0, 0x1001  # Load array address to register $s0
  li $t0, 0        # Initialize loop counter i
  li $t1, 0        # Initialize loop counter j
  li $s1, 11       # Array size
  li $s2, 11       # Used for inner loop
  add $t2, $zero, $s0  # Copy array address for i
  add $t3, $zero, $s0  # Copy array address for j

  addi $s1, $s1, -1  # Adjust array size for 0-based index

outer:
  li  $t1, 0  # Reset j for each outer iteration
  addi $s2, $s2, -1  # Decrease inner loop size
  add $t3, $zero, $s0  # Reset j iterator to start of array

inner:
    lw $s3, 0($t3)  # Load arr[j] into $s3
    addi $t3, $t3, 4  # Move to next element in array for j
    lw $s4, 0($t3)  # Load arr[j+1] into $s4
    addi $t1, $t1, 1  # Increment j

    slt $t4, $s3, $s4  # Check if arr[j] < arr[j+1]
    bne $t4, $zero, cond  # Sort condition
    sort:
      sw $s3, 0($t3)  # Swap arr[j] and arr[j+1]
      sw $s4, -4($t3)
      lw $s4, 0($t3)

    cond:
      bne $t1, $s2, inner  # Continue inner loop if j != n-i

    addi $t0, $t0, 1  # Increment i
  bne $t0, $s1, outer  # Continue outer loop if i != n

  li $t0, 0  # Reset i
  addi $s1, $s1, 1  # Adjust array size

exit:
  li $v0, 10  # Exit syscall code
  syscall
  halt  # Halt execution

