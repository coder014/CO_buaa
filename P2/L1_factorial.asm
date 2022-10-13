.macro push (%reg)
	sw %reg, ($sp)
	subiu $sp, $sp, 4
.end_macro
.macro pop (%reg)
	addiu $sp, $sp, 4
	lw %reg, ($sp)
.end_macro

.data
	num: .word 1
	     .space 4000
.text
	li $v0, 5
	syscall #v0=n
	li $s1, 2 #$s1=i
	li $s0, 1 #$s0=len
for1_begin:
	bgt $s1, $v0, for1_end
	move $s2, $0 #$s2=j
for2_begin:
	beq $s2, $s0, for2_end
	sll $s3, $s2, 2
	lw $s4, num($s3)
	mulu $s4, $s4, $s1
	sw $s4, num($s3)
	addiu $s2, $s2, 1
	j for2_begin
for2_end:
	divu $s3, $s1, 3
	mfhi $s3
	bgtz $s3, ifout
	jal carry
ifout:
	addiu $s1, $s1, 1
	j for1_begin
for1_end:
	jal carry
	subiu $s0, $s0, 1 #s0=i=(len-1)*4
	sll $s0, $s0, 2
for3_begin:
	bltz $s0, for3_end
	lw $a0, num($s0)
	li $v0, 1
	syscall
	subiu $s0, $s0, 4
	j for3_begin
for3_end:
	li $v0, 10
	syscall

carry:
	move $t0, $0 #$t0=i
for4_begin:
	beq $t0, $s0, for4_end
	sll $t1, $t0, 2 #$t1=i*4
	lw $t2, num($t1)
	divu $t2, $t2, 10
	addiu $t1, $t1, 4
	lw $t3, num($t1)
	addu $t3, $t2, $t3
	sw $t3, num($t1)
	subiu $t1, $t1, 4
	mfhi $t2
	sw $t2, num($t1)
	addiu $t0, $t0, 1
	j for4_begin
for4_end	:
while_begin:
	sll $t0, $s0, 2
	lw $t1, num($t0)
	beqz $t1, while_end
	divu $t1, $t1, 10
	addiu $t0, $t0, 4
	lw $t2, num($t0)
	addu $t2, $t1, $t2
	sw $t2, num($t0)
	subiu $t0, $t0, 4
	mfhi $t1
	sw $t1, num($t0)
	addiu $s0, $s0, 1
	j while_begin
while_end:
	jr $ra
