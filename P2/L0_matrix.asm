.macro loadMat (%mat, %reg, %i, %j)
	mul %reg, %i, $t0
	addu %reg, %reg, %j
	sll %reg, %reg, 2
	lw %reg, %mat(%reg)
.end_macro

.macro storeMat (%reg, %i, %j)
	mul $s0, %i, $t0
	addu $s0, $s0, %j
	sll $s0, $s0, 2
	sw %reg, matC($s0)
.end_macro

.data
	matA: .space 256
	matB: .space 256
	matC: .space 256

.text
	li $v0, 5 #read integer
	syscall
	move $t0, $v0 #$t0=n
	mul $a0, $t0, $t0 #$a0=n*n
	move $t1, $0
for1_begin: #$t1=i
	beq $t1, $a0, for1_end
	li $v0, 5 #read integer
	syscall
	sll $s0, $t1, 2
	sw $v0, matA($s0)
	addiu $t1, $t1, 1
	j for1_begin
for1_end:
	move $t1, $0
for2_begin: #$t1=i
	beq $t1, $a0, for2_end
	li $v0, 5 #read integer
	syscall
	sll $s0, $t1, 2
	sw $v0, matB($s0)
	addiu $t1, $t1, 1
	j for2_begin
for2_end:
	move $t1, $0
for31_begin: #$t1=i,$t2=j
	beq $t1, $t0, for31_end
	move $t2, $0
	for32_begin:
		beq $t2, $t0, for32_end
		move $t3, $0 #$t3=k
		move $t6, $0 #$t6=sum=0
		for33_begin:
			beq $t3, $t0, for33_end
			loadMat(matA, $t4, $t1, $t3) #$t4=a[i][k]
			loadMat(matB, $t5, $t3, $t2) #$t5=b[k][j]
			mul $t5, $t4, $t5 #$t5=a[i][k]*b[k][j]
			addu $t6, $t6, $t5
			addiu $t3, $t3, 1
			j for33_begin
		for33_end:
		storeMat($t6, $t1, $t2) #c[i][j]=$t6
		addiu $t2, $t2, 1
		j for32_begin
	for32_end:
	addiu $t1, $t1, 1
	j for31_begin
for31_end:
	move $t1, $0
for41_begin: #$t1=i,$t2=j
	beq $t1, $t0, for41_end
	move $t2, $0
	for42_begin: #$t1=i,$t2=j
		beq $t2, $t0, for42_end
		li $v0, 1
		loadMat(matC, $a0, $t1, $t2)
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