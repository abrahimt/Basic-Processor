
# data section
.data

# code/instruction section
.text
addi  $1,  $0,  1 		# Place “1” in $1
addi  $2,  $0,  2		# Place “2” in $2
addi  $3,  $0,  3		# Place “3” in $3
addiu $4, $0 , 4		#Place "4" in $4
add	 $11, $1,  $2		# $11 = $1 + $2 #fetch add, wb addi 2
sub 	 $12, $11, $3 		# $12 = $11 - $3	#wb add, fetch sub
subu	$13, $11, $3 		#$13 = $11 - $3		
j shift


testlogic: 
	slt $3, $4, $2 	#fetch slt
	slti $3, $1, 4 	#fetch slti
	and $3, $4, $2	#fetch and, wb slti
	andi $1, $4, 9	
	nor $2, $3, $1	#fetch nor
	xor $10, $4, $1	#dec nor
	xori $14, $3, 2	#exec nor
	or $11, $2, $4	#wb nor, fetch or
	ori $12, $1, 2
	j more

shift: 
	sll $5, $1, 1
	srl $6, $1, 1
	sra $7, $1, 1
	j testlogic
more: 
	lui $15, 4097
	jal testjal	#fetch jal
	j exit



testjal: 
	addi $8, $0, 8	#exec jal
	addi $9, $0, 9	#memjal
	jr $31

exit: 

	halt
	
	





