.data

.text
lui $sp, 0x1001
nop
nop
nop
addi $sp, $sp, 0x1000
nop
nop
nop
#Sum all positive integers between 0 and a0 (exclusive)
add $a0, $0, 11
nop
nop
nop

slti $t0, $a0, 0
nop
nop
nop
bne $0, $t0, exit
nop
nop
nop
jal recursion
nop
nop
nop
#v0 should be return value for recursive linear sum
j exit
nop
nop
nop
recursion:
nop
nop
nop
	addi $sp, $sp, -8
nop
nop
nop
	sw $ra, 0($sp)
nop
nop
nop
	sw $s0, 4($sp)
nop
nop
nop	
	
	#add $s0, $a0, $zero
	
	beq $a0, $0, return0
nop
nop
nop
	addi $a0, $a0, -1
nop
nop
nop
	add $s0, $a0, $0
nop
nop
nop
	jal recursion
nop
nop
nop
	add $v0, $v0, $s0


exit_recursion:
nop
nop
nop
	lw $ra, 0($sp)
nop
nop
nop
	lw $s0, 4($sp)
nop
nop
nop
	addi $sp, $sp, 8
nop
nop
nop
	jr $ra
return0:
nop
nop
nop
	li $v0, 0
nop
nop
nop
	j exit_recursion

exit:
nop
nop
nop

halt
