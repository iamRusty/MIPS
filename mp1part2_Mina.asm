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
sw $v0, 32($s0)
lwc1 $f3, 32($s0)   

# Task 10 
lw $a0, 24($s0)
lw $a1, 32($s0)
jal op_div
sw $v0, 36($s0)
lwc1 $f4, 36($s0)

# Task 11
lw $a0, 28($s0)
lw $a1, 32($s0)
jal op_div
sw $v0, 40($s0)
lwc1 $f5, 40($s0)  

  
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
		
lui $a0, 0x4000
lui $a1, 0x4040

op_div: 
	# 16-bit by 16-bit division in a 32-bit register
	# a0 - dividend (input)
	# a1 - divisor (input)
	# t0 - a0 placeholder
	# t1 - a1 placeholder
	# t2 - exponent 
	
	
	addi $v0, $zero, 1
	
	# Determine if negative or positive
	srl $t0, $a0, 31
	srl $t1, $a1, 31
	add $t2, $t0, $t1
	addi $t2, $t2, -1
	beq $t2, $zero, negative_sign_div
		add $v0, $zero, $zero
	negative_sign_div:
	sll $v0, $v0, 8	
	
	# Determine the difference of exponent
	sll $t0, $a0, 1
	srl $t0, $t0, 24
	sll $t1, $a1, 1
	srl $t1, $t1, 24
	sub $t2, $t0, $t1	# Abosulute Exponent (difference)
					
	# Determine if which has bigger mantissa
	# if a0 => a1 then go on
	# otherwise subtract 1 to exponent
	sll $t0, $a0, 9		# Extracting first Mantissa
	srl $t0, $t0, 1
	lui $t9, 0x8000
	add $t0, $t0, $t9
	srl $t0, $t0, 8
	
	sll $t1, $a1, 9		#Extracting second Mantissa
	srl $t1, $t1, 1
	add $t1, $t1, $t9
	srl $t1, $t1, 8
	
	sub $t9, $t0, $t1 
	bgez $t9, go_to_mantissa_division
		addi $t2, $t2, -1
	go_to_mantissa_division:
	addi $t2, $t2, 127 
	or $v0, $v0, $t2
	sll $v0, $v0, 23 
	
	
	# -----------------------------
	# 		Mantissa Division
	#------------------------------
	# Make dividend mantissa as big as possible
	# considering the target 16 bit br 16 bit division
	# This can still be improved using 2 registers to store
	# remainder and quotient adjacently	 
#	srl $t0, $t0, 8		# From previous operation
						#	24 bit mantissa chopped into 16 bit
	# Make divisor as small as possible  without
	# losing its mantissa's integrity
	# shift right until there's (1) in LSB
#	srl $t1, $t1, 8
	addi $t8, $zero, 1
	divisor_chop:
		andi $t9, $t1, 1
	  	beq $t9, $t8, done_with_chopping
	  		srl $t1, $t1, 1
	  		j divisor_chop 
	  	done_with_chopping:
	
	addi $t9, $zero, 24
	add $t7, $zero, $zero
	# t7 - A	
	integer_div_proper:
	beq $t9, $zero, end_int_div

	srl $t6, $t7, 23		# Determine MSB if 0 or 1
	beq $t6, $zero, subtract	# if 0, subtract
		sll $t0, $t0, 1			# Shift 1 left Q
 		sll $t7, $t7, 1			# Shift 1 left A
		sll $t7, $t7, 8			# Remove MSB in 24 bit A
		srl $t7, $t7, 8			# Return 
		srl $s1, $t0, 24		# Get MSB of 24 bit Q 
		beq $s1, $zero, do_nothing_to_a
			addi $t7, $t7, 1	
		do_nothing_to_a:
		sll $t0, $t0, 8			# Remove MSB in 24 bit Q
		srl $t0, $t0, 8  	   	# Return
		add $t7, $t7, $t1		# Add
		sll $t7, $t7, 8			# Remove arithmetic-overflow
		srl $t7, $t7, 8			# Return
		j wag_na_magsubtract_wew  		
	 subtract:
	 	sll $t0, $t0, 1			# Shift 1 left Q
	 	sll $t7, $t7, 1			# Shift 1 left A
	 	sll $t7, $t7, 8			# Remove MSB in 24 bit A
	 	srl $t7, $t7, 8			# Return 
	 	srl $s1, $t0, 24		# Get  MSB of 24 bit Q
	 	beq $s1, $zero, do_nothing_to_a_sub_version
	 		addi $t7, $t7, 1
	 	do_nothing_to_a_sub_version:
	 	sll $t0, $t0, 8			# Remove MSB in 24 bit Q
	 	srl $t0, $t0, 8  	   	# Return
	 	sub $t7, $t7, $t1   	# Subtract
	 	sll $t7, $t7, 8			# Remove arithmetic overflow (most likely, it won't overflow but who knows) .. no it really won't
	 	srl $t7, $t7, 8			# Return
	
	wag_na_magsubtract_wew: 	 	
	srl $t6, $t7, 23	# Determine MSB if 0 or 1
	addi $t6, $t6, -1 
	beq $t6 , $zero, do_nothing
		add_one:
		addi $t0, $t0, 1
	do_nothing:	  	
	addi $t9, $t9, -1 
	j integer_div_proper
	
	end_int_div:
	
	#sll $t9, $t0, 16		# Extract lowest 16 bit 
	#srl $t9, $t9, 16
	
	# REMOVE HIDDEN BIT 
	addi $t8, $zero, 23
	addi $s2, $zero, 1 
	mantissa_encode:
	beq $t8, $zero, remove_hidden_bit
	srl $t6, $t0, 23
	beq $t6, $s2, remove_hidden_bit
		sll $t0, $t0, 1
		addi, $t8, $t8, -1
		j mantissa_encode
	remove_hidden_bit:
		sll $t0, $t0, 9
		srl $t0, $t0, 9	 	 	     
	
	or $v0, $v0, $t0
          
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
	
		  	     	 	         	        	  	     	 	         	        
