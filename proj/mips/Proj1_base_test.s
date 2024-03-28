# Initialize registers with values
addi $1, $0, 10   # $1 = 10
addi $2, $0, 5    # $2 = 5
addi $3, $0, 3    # $3 = 3
addi $4, $0, 8    # $4 = 8
addi $5, $0, 16   # $5 = 16
addi $6, $0, 4    # $6 = 4
addi $7, $0, 20   # $7 = 20
addi $8, $0, 15   # $8 = 15
addi $9, $0, 2    # $9 = 2

# Perform arithmetic operations
add $10, $1, $2   # $10 = $1 + $2
sub $11, $10, $3  # $11 = $10 - $3

# Perform logical operations
and $14, $8, $9   # $14 = $8 & $9
or $15, $8, $9    # $15 = $8 | $9
xor $16, $8, $9   # $16 = $8 ^ $9
nor $17, $8, $9   # $17 = ~($8 | $9)

# Compare values
slt $18, $10, $11  # Set $18 to 1 if $10 < $11, else 0

# Halt execution
halt

