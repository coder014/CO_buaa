.data
	matrix: .space 10000

.text
	li $v0, 5 #read integer
	syscall
	move $t0, $v0 #$t0=n
	li $v0, 5 #read integer
	syscall
	move $t1, $v0 #$t1=m
	mul $t2, $t0, $t1 #$t2=n*m

	move $a3, $0
loop1_begin: #a3=i
	li $v0, 5 #read integer
	syscall
	sll $a0, $a3, 2
	sw $v0, matrix($a0)
	addiu $a3, $a3, 1
	beq $t2, $a3, loop1_end
	j loop1_begin
loop1_end:
loop2_begin: #a3=i
	subiu $a3, $a3, 1
	sll $a0, $a3, 2
	lw $a2, matrix($a0)
	beqz $a2, loop2_continue
	divu $a0, $a3, $t1 #a0=(i-1)/m
	mfhi $a1
	addiu $a1, $a1, 1 #a1=column
	addiu $a0, $a0, 1 #a0=row
	jal func_print
loop2_continue:
	beqz $a3, loop2_end
	j loop2_begin
loop2_end:
	li $v0, 10 #exit
	syscall

func_print:
	li $v0, 1 #print row
	syscall
	li $v0, 11
	li $a0, 32 #print space
	syscall
	li $v0, 1 #print column
	move $a0, $a1
	syscall
	li $v0, 11
	li $a0, 32 #print space
	syscall
	li $v0, 1 #print value
	move $a0, $a2
	syscall
	li $v0, 11
	li $a0, 10 #print newline
	syscall
	jr $ra #end_of_func_print