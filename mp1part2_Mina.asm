.data 0x10010030
.word 1
.data 0x10010034
.word 7
.data 0x10010038
.word -18
# Ax^2 + bx + c

.text
# Load Addresses
add $t9, $zero, $zero
add $s0, $zero, $zero
lui $t9, 0x1001		
ori $t9, $t9, 0x0030
lui $s0, 0x1001

lw $t7, 0($t9)		# A 	
lw $t8, 4($t9)		# B
lw $t9, 8($t9)		# C 
  
# Task 1 :  b^2
add $a0, $zero, $t8
add $a1, $zero, $t8
jal op_mult
sw $v0, 0($s0)

# Task 2 : -4ac
addi $a0, $zero, -4
add $a1, $zero, $t7
jal op_mult
add $a0, $zero, $v0
add $a1, $zero, $t9
jal op_mult  
sw $v0, 4($s0)

# Task 3 : b^2 - 4ac
lw $a0, 0($s0)
lw $a1, 4($s0)
jal op_add
sw $v0, 8($s0) 

# Task 4 : sqrt(b^2 - 4ac)
lw $a0, 8($s0)
jal op_sqrt
sw $v0, 12($s0)


# Task 5 : -b + sqrt(b^2 - 4ac)
lw $a0, 12($s0)
add $a1, $zero, $t8
jal op_sub
sw $v0, 16($s0)

# Task 6 : -b - sqrt(b^2 - 4ac)
add $a0, $zero, $zero
lw $a1, 12($s0)
jal op_sub
add $a0, $zero, $v0
add $a1, $zero, $t8
jal op_sub
sw $v0, 20($s0) 

# Task 7 : float
lw $a0, 16($s0)
jal floating_point_converter
sw $v0, 24($s0)
lwc1 $f1, 24($s0)

# Task 8: float
lw $a0, 20($s0)
jal floating_point_converter
sw $v0, 28($s0)
lwc1 $f2, 28($s0)

# Task 9: float
add $a0, $zero, $t7
addi $a1, $zero, 2
jal op_mult
add $a0, $zero, $v0
jal floating_point_converter  

  
j end

op_add:
	add $v0, $a0, $a1
	jr $ra
	
op_sub:
	sub $v0, $a0, $a1
	jr $ra
	
op_mult:
	add $v0, $zero, $zero
	beq $a0, $zero, end_op_mult
	beq $a1, $zero, end_op_mult	
	# a0 - bigger factor
	# a1 - smaller factor
	add $t0, $zero, $zero
	bgez $a0, ok1
		addi $t0, $t0, 1
		sub $a0, $zero, $a0
	ok1: # factor 1 already positive	
	bgez $a1, ok2
		addi $t0, $t0, 1
		sub $a1, $zero, $a1
	ok2: # factor 2 already positive
	sub $t1, $a0, $a1
	bgez $t1, ok3
		add $t1, $zero, $a0
		add $a0, $zero, $a1
		add $a1, $zero, $t1
	ok3: # a0 > a1 already
	repeated_addition:
		beq $a1, $zero, end_repeated_addition
		add $v0, $v0, $a0
		addi $a1, $a1, -1
		j repeated_addition
	end_repeated_addition:
		addi $t1, $zero, 1
		bne $t0, $t1, end_op_mult 
		sub $v0, $zero, $v0  
	end_op_mult:	
		jr $ra	
	  	  	
op_sqrt:
	# t0 - odd numbers
	 
	add $v0, $zero, $zero
	beq $a0, $zero, end_op_sqrt   	
	addi $t0, $zero, 1

	add_odd:
		addi $v0, $v0, 1
		sub $a0, $a0, $t0
		addi $t0, $t0, 2  
		bgez $a0, add_odd
	end_op_sqrt:
		addi $v0, $v0, -1
		jr $ra
		
floating_point_converter:
	# Uses explicit chopping for rounding mantissa
	# v0 - float representation
	# t1 - raw exponent (not excess 127 format)
	# t2 - placeholder for shift_right_end algorithm
	# t3 - result of AND op of LSB bit
	# t4 - exponent (excess 127 format)
	# t5 - variable for mantissa shifting (left)  
	# t6 - placeholder for mantissa
	  
	add $v0, $zero, $zero
	beq $a0, $zero, end_float_conversion
	
	# Determine if positive or negative
	bgtz $a0, positive_float
		addi $v0, $v0, 1
		sub $a0, $zero, $a0
		
	positive_float:
	sll $v0, $v0, 8
	
	# Determine the exponent
	addi $t1, $zero, 30
	exponent_finder:
		srlv $t2, $a0, $t1
		add $t3, $zero, $zero
		andi $t3, $t2, 1
		beq $t3, $zero, not_one
			j exponent_found
		not_one:
			addi $t1, $t1, -1
			j exponent_finder		
				   
		exponent_found:
		addi $t4, $t1, 127
		or $v0, $v0, $t4
		sll $v0, $v0, 23
	
	# Determine the mantissa
	addi $t5, $t1, -32
	sub $t5, $zero, $t5	
	sllv $t6, $a0, $t5
	srl $t6, $t6, 9
	
	or $v0, $v0, $t6  	  	 
			 
	end_float_conversion:
		jr $ra			 	 			 	 	
  	
end:	  	
	
		  	     	 	         	        	  	     	 	         	        
