.data 0x10010020 # a0
.word 50
.data 0x10010024 # a1
.word 0
.data 0x10010000 # a2
.word 0x10010000

.text

# Initialize registers
add $a0, $zero, $zero 	
add $a1, $zero, $zero
add $a2, $zero, $zero

# Load Adresses
lui $a0, 0x1001 			# a0
ori $a0, $a0, 0x0020

lui $a1, 0x1001				# a1 
ori $a1, $a1, 0x0024

lui $a2, 0x1001

# Store to temporary variable
lw $t0, 0($a0)
lw $t1, 0($a1)
add $t2, $zero, $zero

# If zero input, then zero output
beq $t0, $zero, end
beq $t1, $zero, end

loop:
	add $t2, $t2, $t1
	addi $t0, $t0, -1
	blez $t0, end
	j loop

end:
	sw $t2, 0($a2)
