# a0 - CAR PRICES address
# a1 - MONTH address
# t0 - CAR PRICES value
# t3 - MONTH DATA value
# a2 - MONTH counter
# a3 - size of array counter
# t1 - INCOME PER MONTH PER CAR TYPE 
# t2 - MONTHLY INCOME
# t4 - STACK OF MONTH ADDRESSES 0x10010140
# t5 - January address - later reused for array counter
# t6 - February address
# t7 - March address
# t8 - sum of MONTHLY INCOME
# t9 - address value of CURRENT MONTH

# ----------- CAR PRICES ----------------
.data 0x10010020
.word 700000
.data 0x10010024
.word 800000
.data 0x10010028
.word 900000

# ------------- JANUARY -------------------
.data 0x10010040
.word 10
.data 0x10010044
.word 8
.data 0x10010048
.word 5

# ------------- FEBRUARY -------------------
.data 0x10010060
.word 12
.data 0x10010064
.word 7
.data 0x10010068
.word 7

# ------------- MARCH -----------------------
.data 0x10010080
.word 9
.data 0x10010084
.word 6
.data 0x10010088
.word 4

# Array size
.data 0x10010100
.word 3

.text

# Initialize registers
add $a1, $zero, $zero

# Load Adresses
lui $t5, 0x1001 			# January
ori $t5, $t5, 0x0040

lui $t6, 0x1001				# February
ori $t6, $t6, 0x0060

lui $t7, 0x1001				# March
ori $t7, $t7, 0x0080

lui $a0, 0x1001				# CAR PRICES address
ori $a0, $a0, 0x0020

lui $a3, 0x1001 			# a3- size of array
ori $a3, $a3, 0x0100

lui $t1, 0x1001				# (address) t1 - sum
ori $t1, 0x0120

add $t2, $zero, $zero			# (value) temporary sum for products

# Stacks for Months
lui $t4, 0x1001				# Intialize MONTH address stacks at 0x10010140
ori $t4, 0x0140
sw $t5, 0($t4)				# January	0x10010140
sw $t6, 4($t4)				# February	0x10010144
sw $t7, 8($t4)				# March		0x10010148

lw $t5, 0($a3)				# Copies value of size array to temporary variable (reused)

addi $a2, $zero, 3			# 3 months

add $t8, $zero, $zero			# Initialize SUM of MONTHLY INCOME to 0

jal scalar_prod
j end
	
scalar_prod:
	beq $a2, $zero, end_scalar_prod
	sw $ra, 0($sp)
	lui $a0, 0x1001			# Every month, initialize the CAR PRICES address
	ori $a0, 0x0020
	add $a3, $zero, $t5 		# Every month initialize array size counter			
	add $a1, $zero, $zero		# Copies current month's address
	lw $t9, 0($t4)
	add $a1, $zero, $t9
	add $t2, $zero, $zero		# Initialize MONTHLY INCOME to 0
	
	summation_within_month:
		beq $a3, $zero, end_summation
		lw $t3, 0($a0)			# pass value of a0(first input) to t0
		lw $t0, 0($a1)			# pass value of a1(second input) to t3
		add $v0, $zero, $zero		# (value) temporary product set to 0

		# If zero input, then zero output
		beq $t0, $zero, end_mult
		beq $t3, $zero, end_mult

		
		jal mult_lab2
		end_mult:
			add $t2, $t2, $v0
			addi $a3, $a3, -1       # size counter
			addi $a0, $a0, 4	# array 1 offset
			addi $a1, $a1, 4	# array 2 offset
			lw $ra, 0($sp)
			j summation_within_month
	
		mult_lab2:
			add $v0, $v0, $t3
			addi $t0, $t0, -1
			blez $t0, end_mult
			j mult_lab2
			jr $ra
		
	end_summation:
		add $t8, $t8, $t2
		addi $a0, $a0, 4
		addi $a2, $a2, -1
		addi $t4, $t4, 4
		j scalar_prod

	end_scalar_prod:
		jr $ra
	
end:
	sw $t8, 0($t1)
