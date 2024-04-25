
# data section
.data

# code/instruction section
.text

	addi  $1,  $0,  1 		# Place “1” in $1
	addi  $2,  $0,  2		# Place “2” in $2
	j next
	addi $4, $0, 4
	addi $5, $0, 5

next: 
	addi $3, $0, 3

exit: 
	
	halt
	
	





