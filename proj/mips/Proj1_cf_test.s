.data

.text

li $sp, 0x10011000
#Sum all positive integers between 0 and a0 (exclusive)
li $a0, 11


slti $t0, $a0, 0
bne $0, $t0, exit

jal recursion

#v0 should be return value for recursive linear sum
j exit

recursion:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	
	#add $s0, $a0, $zero
	
	beq $a0, $0, return0
	addi $a0, $a0, -1
	add $s0, $a0, $0
	jal recursion
	add $v0, $v0, $s0


exit_recursion:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
return0:
	li $v0, 0
	j exit_recursion

exit:


halt
