# Floating point converter
# Can only support mantissa for 2^-31 to (2^31-1) integers
# Uses explicit chopping for rounding mantissa

.data 0x10010030
.word 2000000000
.data 0x10010034
.word 4
.data 0x10010038
.word 1

# fp1: .float 2.5
.text
lui $t0, 0x1001
ori $t0, $t0, 0x0030
lw $t1, 0($t0)

add $t2, $zero, $zero
beq $t1, $zero, end_float_conversion 

# Determine if positive or negative
bgez $t1, positive_float
	addi $t2, $t2, 1
	sub $t1, $zero, $t1 

positive_float:
sll $t2, $t2, 8	


# Determine the exponent 

addi $t4, $zero, 30
exponent_finder:
srlv $t7, $t1, $t4
add $t5, $zero, $zero
andi $t5, $t7, 1
beq $t5, $zero, not_one
	j exponent_found
not_one:
addi $t4, $t4, -1
j exponent_finder

exponent_found:
addi $t6, $t4, 127 
or $t2, $t2, $t6
sll $t2, $t2, 23 

	  
# Determine the mantissa
addi $t8, $t4, -32
sub $t8, $zero, $t8
sllv $t1, $t1, $t8 
srl $t1, $t1, 9

or $t2, $t2, $t1


# Loading to float coproc
lui $v0, 0x1001
ori $v0, $v0, 0x0080 
sw $t2, 0($v0)

lwc1 $f1, 0($v0)
  	    	  
end_float_conversion:
