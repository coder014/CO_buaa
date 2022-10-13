.macro push (%reg)
	sw %reg, ($sp)
	subiu $sp, $sp, 4
.end_macro
.macro pop (%reg)
	addiu $sp, $sp, 4
	lw %reg, ($sp)
.end_macro

.data
	n: .space 4
	symbol: .space 32
	array: .space 32
.text
	li $v0, 5
	syscall
	sw $v0, n
	move $a0, $0
	jal FullArray
	li $v0, 10
	syscall

FullArray:
	push($ra)
	lw $t0, n #$t0=n
	blt $a0, $t0, if1_out
	move $t1, $0 #$t1=i
for1_begin:
	beq $t1, $t0, for1_end
	sll $t2, $t1, 2
	lw $a0, array($t2)
	li $v0, 1
	syscall
	li $v0, 11
	li $a0, 32
	syscall
	addiu $t1, $t1, 1
	j for1_begin
for1_end:
	li $v0, 11
	li $a0, 10
	syscall
	pop($ra)
	jr $ra
if1_out:
	move $t1, $0 #$t1=i
for2_begin:
	beq $t1, $t0, for2_end
	sll $t3, $t1, 2
	lw $t2, symbol($t3)
	bgtz $t2, if2_out
	addiu $t2, $t1, 1
	sll $t3, $a0, 2
	sw $t2, array($t3)
	li $t2, 1
	sll $t3, $t1, 2
	sw $t2, symbol($t3)
	push($a0)
	push($t0)
	push($t1)
	addiu $a0, $a0, 1
	jal FullArray
	pop($t1)
	pop($t0)
	pop($a0)
	move $t2, $0
	sll $t3, $t1, 2
	sw $t2, symbol($t3)
if2_out:
	addiu $t1, $t1, 1
	j for2_begin
for2_end:
	pop($ra)
	jr $ra