# a0 first factor address
# a1 second factor address
# t0 first factor value
# t3 second factor value
# a3 size of array
# t1 final value 
# t2 final value

# Array 1 values 
.data 0x10010020
.word 5
.data 0x10010024
.word 3
.data 0x10010028
.word 25
.data 0x1001002c
.word 35

# Array 2 values
.data 0x10010040
.word 5
.data 0x10010044
.word 3
.data 0x10010048
.word 25
.data 0x1001004c
.word 35

# Array size
.data 0x10010060
.word 4

.text

# Initialize registers
add $a0, $zero, $zero 	
add $a1, $zero, $zero

# Load Adresses
lui $a0, 0x1001 			# a0 - first array
ori $a0, $a0, 0x0020

lui $a1, 0x1001				# a1 - second array
ori $a1, $a1, 0x0040

lui $a3, 0x1001 			# a3- size of array
ori $a3, $a3, 0x0060
lw $a3, 0($a3)

lui $t1, 0x1001				# sum - address

add $t2, $zero, $zero			# temporary sum for products


summation:
	beq $a3, $zero, end
	lw $t0, 0($a0)
	lw $t3, 0($a1)
	add $v0, $zero, $zero	# temporary product

	# If zero input, then zero output
	beq $t0, $zero, end_temp
	beq $t3, $zero, end_temp

	jal mult_lab2
	end_temp:
		add $t2, $t2, $v0
		addi $a3, $a3, -1       # size counter
		addi $a0, $a0, 4	# array 1 offset
		addi $a1, $a1, 4	# array 2 offset
		j summation
	
	
	mult_lab2:
		add $v0, $v0, $t3
		addi $t0, $t0, -1
		blez $t0, go_back
		j mult_lab2
	go_back: 
		jr $ra
	

	
end:
	sw $t2, 0($t1)

