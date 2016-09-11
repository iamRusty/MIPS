.data 0x10010020
.word 10

.text

add $a0, $zero, $zero #initialize $a0

lui $a0, 0x1001 #set $a0 to address of input
ori $a0, $a0, 0x0020

lw $t0, 0($a0)

loop:
add $t1, $t1, $t0 #add then update input
addi $t0, $t0, -1
blez $t0, end
j loop

end:
sw $t1, 4($a0) #store result
