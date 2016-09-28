
# Inputs are in float single precision format
.text
lui $a0, 0x423c # (47)
lui $a1, 0x4150 # (13)

op_div: 
	# 32-bit by 24-bit division in a 32-bit register
	# a0 - dividend (input)
	# a1 - divisor (input)
	# t0 - a0 placeholder
	# t1 - a1 placeholder
	# t2 - exponent 
	
	add $v0, $zero, $zero
	beq $a0, $zero, jr_ra
	lui $s7, 0x8000
	beq $a0, $s7, jr_ra
	
	addi $v0, $v0, 1 
	
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
	sub $t2, $t0, $t1	# Absolute Exponent (difference)
					
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
	# considering the target 32 bit by 24 bit division
	# This can still be improved using 2 registers to store
	# quotient(48 bit) and 1 register for Q (24 bit)	 
	sll $t0, $t0, 8		# From previous operation
	# Make divisor as small as possible  without
	# losing its mantissa's integrity
	# shift right until there's (1) in LSB

	addi $t8, $zero, 1
	divisor_chop:
		andi $t9, $t1, 1
	  	beq $t9, $t8, done_with_chopping
	  		srl $t1, $t1, 1
	  		j divisor_chop 
	  	done_with_chopping:
	
	addi $t9, $zero, 32
	add $t7, $zero, $zero
	# t7 - A	
	integer_div_proper:
	beq $t9, $zero, end_int_div

	srl $t6, $t7, 23		# Determine MSB if 0 or 1
	beq $t6, $zero, subtract	# if 0, subtract
		srl $s1, $t0, 31		# Get MSB of 32 bit Q 
		sll $t0, $t0, 1			# Shift 1 left Q
 		sll $t7, $t7, 1			# Shift 1 left A
		sll $t7, $t7, 8			# Remove MSB in 24 bit A
		srl $t7, $t7, 8			# Return 
		beq $s1, $zero, do_nothing_to_a
			addi $t7, $t7, 1	
		do_nothing_to_a:
		add $t7, $t7, $t1		# Add
		sll $t7, $t7, 8			# Remove arithmetic-overflow
		srl $t7, $t7, 8			# Return
		j wag_na_magsubtract_wew  		
	 subtract:
	 	srl $s1, $t0, 31		# Get  MSB of 32 bit Q
	 	sll $t0, $t0, 1			# Shift 1 left Q
	 	sll $t7, $t7, 1			# Shift 1 left A
	 	sll $t7, $t7, 8			# Remove MSB in 24 bit A
	 	srl $t7, $t7, 8			# Return 
	 	beq $s1, $zero, do_nothing_to_a_sub_version
	 		addi $t7, $t7, 1
	 	do_nothing_to_a_sub_version:
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
	
	# REMOVE HIDDEN BIT 
	addi $t8, $zero, 31
	addi $s2, $zero, 1 
	mantissa_encode:
	beq $t8, $zero, remove_hidden_bit
	srl $t6, $t0, 31
	beq $t6, $s2, remove_hidden_bit
		sll $t0, $t0, 1
		addi, $t8, $t8, -1
		j mantissa_encode
	remove_hidden_bit:
		sll $t0, $t0, 1
		srl $t0, $t0, 9	 	 	     
	
	or $v0, $v0, $t0
        
        jr_ra:  #end   
	#jr $ra
	
	lui $k0, 0x1001	
	sw $v0, 0($k0)
	lwc1 $f1, 0($k0)
	         
	#end_int_div: 
		
