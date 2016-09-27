
# Inputs are in float single precision format
.text
lui $a0, 0x41c8
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
	srl $t0, $t0, 8		# From previous operation
						#	24 bit mantissa chopped into 16 bit
	# Make divisor as small as possible  without
	# losing its mantissa's integrity
	# shift right until there's (1) in LSB
	srl $t1, $t1, 8
	addi $t8, $zero, 1
	divisor_chop:
		andi $t9, $t1, 1
	  	beq $t9, $t8, done_with_chopping
	  		srl $t1, $t1, 1
	  		j divisor_chop 
	  	done_with_chopping:
	
#	addi $t9, $zero, 16 		# quotient bit counter
	addi $t9, $zero, 16
	integer_div_proper:
	beq $t9, $zero, end_int_div
	#sll $t0, $t0, 1			# Shift left
	srl $t6, $t0, 31		# Determine MSB if 0 or 1
	beq $t6, $zero, subtract	# if 0, subtract
		sll $t0, $t0, 1   
		srl $t7, $t0, 16		# extract upper 16 bit (A)
		add $t8, $t7, $t1		# Add
		sll $t8, $t8, 16		# Remove arithmetic-overflow
		sll $t0, $t0, 16		# Zero-out upper 16 bit (A)
		srl $t0, $t0, 16		# --
		or $t0, $t0, $t8
		j wag_na_magsubtract_wew  		
	 subtract:
	 	sll $t0, $t0, 1
	 	srl $t7, $t0, 16		# Extract upper 16 bit (A)
	 	sub $t8, $t7, $t1   	# subtract
	 	sll $t8, $t8, 16		# Remove arithmetic overflow / Formats to upper bit
	 	sll $t0, $t0, 16		# Zero-out upper 16 bit (A)
	 	srl $t0, $t0, 16		# --
	 	or $t0, $t0, $t8
	
	wag_na_magsubtract_wew: 	 	
	srl $t6, $t0, 31	# Determine MSB if 0 or 1
	addi $t6, $t6, -1 
	beq $t6 , $zero, do_nothing
		add_one:
		addi $t0, $t0, 1
	do_nothing:	  	
	addi $t9, $t9, -1 
	j integer_div_proper
	
	end_int_div:
	
	sll $t9, $t0, 16		# Extract lowest 16 bit 
	srl $t9, $t9, 16
	
	# Make lowest 16 bit and 23 bit mantissa w/o the hidden bit
	addi $t8, $zero, 15
	addi $t7, $zero, 1 
	mantissa_encode:
	beq $t8, $zero, remove_hidden_bit
	srl $t6, $t9, 15
	beq $t6, $t7, remove_hidden_bit
		sll $t9, $t9, 1
		addi, $t8, $t8, -1
		j mantissa_encode
	remove_hidden_bit:
		sll $t9, $t9, 17
		srl $t9, $t9, 9	 	 	     
	
	or $v0, $v0, $t9
	
	lui $k0, 0x1001	
	sw $v0, 0($k0)
	lwc1 $f1, 0($k0)
	         
	#end_int_div: 
		
