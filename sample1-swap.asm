.data 0x10010020
.word 5
.data 0x10010040
.word 6

.text
add $a0, $zero, $zero #initialize registers
add $a1, $zero, $zero

lui $a0, 0x1001 #set $a0 to address of first input
ori $a0, $a0, 0x0020

lui $a1, 0x1001 #set $a1 to address of second input
ori $a1, $a1, 0x0040

lw $t0, 0($a0) #swap
lw $t1, 0($a1)
sw $t0, 0($a1)
sw $t1, 0($a0)