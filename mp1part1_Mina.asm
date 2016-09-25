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
  	
end:	  	
	
		  	     	 	         	        	  	     	 	         	        
