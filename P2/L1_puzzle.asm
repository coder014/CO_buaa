.macro push (%reg)
	sw %reg, ($sp)
	subiu $sp, $sp, 4
.end_macro
.macro pop (%reg)
	addiu $sp, $sp, 4
	lw %reg, ($sp)
.end_macro
.macro readInt
	li $v0, 5
	syscall
.end_macro
.macro loadMat (%mat, %reg, %i, %j)
	lw %reg, m
	mul %reg, %i, %reg
	addu %reg, %reg, %j
	sll %reg, %reg, 2
	lw %reg, %mat(%reg)
.end_macro
.macro storeMat (%mat, %reg, %i, %j)
	lw $s0, m
	mul $s0, %i, $s0
	addu $s0, $s0, %j
	sll $s0, $s0, 2
	sw %reg, %mat($s0)
.end_macro

.data
	visit: .space 256
	n: .space 4
	m: .space 4
	ans: .space 4

.text
	readInt
	sw $v0, n
	move $a0, $v0 #$a0=n
	readInt
	sw $v0, m
	move $a1, $v0 #$a1=m
	move $t1, $0 #$t1=i
for1_begin:
	beq $t1, $a0, for1_end
	move $t2, $0 #$t2=j
for2_begin:
	beq $t2, $a1, for2_end
	readInt
	storeMat(visit, $v0, $t1, $t2)
	addiu $t2, $t2, 1
	j for2_begin
for2_end:
	addiu $t1, $t1, 1
	j for1_begin
for1_end:
	readInt
	move $a0, $v0
	readInt
	move $a1, $v0
	readInt
	move $a2, $v0
	readInt
	move $a3, $v0
	subiu $a0, $a0, 1
	subiu $a1, $a1, 1
	subiu $a2, $a2, 1
	subiu $a3, $a3, 1
	li $t0, 2
	storeMat(visit, $t0, $a2, $a3)
	jal dfs
	lw $a0, ans
	li $v0, 1
	syscall
	li $v0, 10
	syscall

dfs:
	push($ra)
	bltz $a0, dfsout
	bltz $a1, dfsout
	lw $t0, n
	bge $a0, $t0, dfsout
	lw $t0, m
	bge $a1, $t0, dfsout
	loadMat(visit, $t0, $a0, $a1)
	bne $t0, 2, ifout
	lw $t0, ans
	addiu $t0, $t0, 1
	sw $t0, ans
	j dfsout
ifout:
	beq $t0, 1, dfsout
	li $t0, 1
	storeMat(visit, $t0, $a0, $a1)
	push($a0)
	push($a1)
	addiu $a0, $a0, 1
	jal dfs
	pop($a1)
	pop($a0)
	push($a0)
	push($a1)
	subiu $a0, $a0, 1
	jal dfs
	pop($a1)
	pop($a0)
	push($a0)
	push($a1)
	addiu $a1, $a1, 1
	jal dfs
	pop($a1)
	pop($a0)
	push($a0)
	push($a1)
	subiu $a1, $a1, 1
	jal dfs
	pop($a1)
	pop($a0)
	storeMat(visit, $0, $a0, $a1)
dfsout:
	pop($ra)
	jr $ra