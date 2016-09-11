.data 0x10010020 # a0
.word -50
.data 0x10010024 # a1
.word 50
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

add $t3, $zero, $zero

#lw $a0, 0($a0)
#lw $a1, 0($a1)

loop:
	add $t2, $t2, $t1
	bltz $t0, add_loop
	bgtz $t0, minus_loop
	add_loop:
		addi $t0, $t0, 1
		j rest_loop
	minus_loop:
		addi $t0, $t0, -1
		j rest_loop
	rest_loop:
	beq $t0, $zero, before_end
	j loop


before_end:
	lw $a0, 0($a0)
	bltz $a0, subtract_from_zero
	bgtz $a0, end
	
	subtract_from_zero:
		sub $t2, $zero, $t2
		j end
		

end:
	sw $t2, 0($a2)
