
# data section
.data

# code/instruction section
.text

	addi  $1,  $0,  1 		# Place “1” in $1
	addi  $2,  $0,  2		# Place “2” in $2

	beq $2, $1, next
	addi $4, $0, 4
	addi $5, $0, 5

next: 
	addi $3, $0, 3		# expect 3
	addi $4, $3, 4		# expect 7
	addi $5, $4, 5		# expect 13
	add  $6, $4, $5		# expect 20

exit: 
	
	halt
	
	





