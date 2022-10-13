.macro loadMat (%mat, %reg, %i, %j, %column)
	lw $at, %column
	mul %reg, %i, $at
	addu %reg, %reg, %j
	sll %reg, %reg, 2
	lw %reg, %mat(%reg)
.end_macro

.macro storeMat (%reg, %i, %j, %column)
	mul $s0, %i, %column
	addu $s0, $s0, %j
	sll $s0, $s0, 2
	sw %reg, matC($s0)
.end_macro

.data
	m1: .space 4
	n1: .space 4
	m2: .space 4
	n2: .space 4
	matA: .space 1600
	matB: .space 400
	matC: .space 400

.text
	li $v0, 5 #read integer
	syscall
	sw $v0, m1
	li $v0, 5 #read integer
	syscall
	sw $v0, n1
	li $v0, 5 #read integer
	syscall
	sw $v0, m2
	li $v0, 5 #read integer
	syscall
	sw $v0, n2
	lw $t0, m1
	lw $t1, n1
	mul $a0, $t0, $t1 #$a0=m1*n1
	move $t1, $0
for1_begin: #$t1=i
	beq $t1, $a0, for1_end
	li $v0, 5 #read integer
	syscall
	sll $t0, $t1, 2
	sw $v0, matA($t0)
	addiu $t1, $t1, 1
	j for1_begin
for1_end:
	lw $t0, m2
	lw $t1, n2
	mul $a0, $t0, $t1 #$a0=m2*n2
	move $t1, $0
for2_begin: #$t1=i
	beq $t1, $a0, for2_end
	li $v0, 5 #read integer
	syscall
	sll $t0, $t1, 2
	sw $v0, matB($t0)
	addiu $t1, $t1, 1
	j for2_begin
for2_end:
	lw $a0, m1
	lw $a1, n1
	lw $a2, m2
	lw $a3, n2
	subu $a0, $a0, $a2
	subu $a1, $a1, $a3
	addiu $a0, $a0, 1
	addiu $a1, $a1, 1
	move $t1, $0
for31_begin: #$t1=i,$t2=j
	beq $t1, $a0, for31_end
	move $t2, $0
	for32_begin:
		beq $t2, $a1, for32_end
		move $t3, $0 #$t3=k
		move $t0, $0 #$t0=sum=0
		for33_begin:
			beq $t3, $a2, for33_end
			move $t4, $0 #$t4=l
			for34_begin:
				beq $t4, $a3, for34_end
				addu $s1, $t1, $t3
				addu $s2, $t2, $t4
				loadMat(matA, $t5, $s1, $s2, n1) #$t5=a[i+k][j+l]
				loadMat(matB, $t6, $t3, $t4, n2) #$t6=b[k][l]
				mul $t5, $t6, $t5 #$t5=a*b
				addu $t0, $t0, $t5
				addiu $t4, $t4, 1
				j for34_begin
			for34_end:
			addiu $t3, $t3, 1
			j for33_begin
		for33_end:
		storeMat($t0, $t1, $t2, $a1) #c[i][j]=$t0
		addiu $t2, $t2, 1
		j for32_begin
	for32_end:
	addiu $t1, $t1, 1
	j for31_begin
for31_end:
	move $t3, $a0
	move $t4, $a1
	move $t1, $0
for41_begin: #$t1=i,$t2=j
	beq $t1, $t3, for41_end
	move $t2, $0
	for42_begin:
		beq $t2, $t4, for42_end
		li $v0, 1
		mul $a0, $t1, $t4
		addu $a0, $a0, $t2
		sll $a0, $a0, 2
		lw $a0, matC($a0)
		syscall #print c[i][j]
		li $v0, 11
		li $a0, 32
		syscall #print space
		addiu $t2, $t2, 1
		j for42_begin
	for42_end:
	li $v0, 11
	li $a0, 10
	syscall #print newline
	addiu $t1, $t1, 1
	j for41_begin
for41_end:
	li $v0, 10
	syscall
