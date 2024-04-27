 .data
arr: .word 1, 66, 44, 73, 24, 31, 96, 101, 0, 83, 52
  space: .asciiz " "
  .text
  .globl main

#nops are absolutely necessary after CF instructions (j, jal, jr, beq, bne) to avoid fetching (and subsequently executing) a 'real' instruction.

main:
  lui $s0, 0x1001                   #arr[0]
  li $t0, 0                         #i = 0
  li $t1, 0                         #j = 0
  li $s1, 11                        #n = 11
  li $s2, 11                        #n-i for inner loop
  add $t2, $zero, $s0               #for iterating addr by i
  add $t3, $zero, $s0               #for iterating addr by j
  addi $s1, $s1, -1

outer:
  li  $t1, 0                        #j = 0
  addi $s2, $s2, -1                 #decreasing size for inner_loop
  add $t3, $zero, $s0               #resetting addr itr j

  inner:
    addi $t1, $t1, 1                #j++
    lw $s3, 0($t3)                  #arr[j]
    addi $t3, $t3, 4                #addr itr j += 4
    lw $s4, 0($t3)                  #arr[j+1]
    slt $t4, $s3, $s4               #set $t4 = 1 if $s3 < $s4
    bne $t4, $zero, cond
 
    sort:
      sw $s3, 0($t3)
      sw $s4, -4($t3)
      lw $s4, 0($t3)

    cond:
      bne $t1, $s2, inner      #j != n-i
      addi $t0, $t0, 1                  #i++
      bne $t0, $s1, outer           #i != n
      li $t0, 0
      addi $s1, $s1, 1

exit:
  li $v0, 10
  syscall
  halt
