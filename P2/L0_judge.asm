.data
	tmps: .space 4
	str: .space 32
.text
	li $v0, 5
	syscall #read n
	move $t0, $v0 #$t0=n
	move $t1, $0
for1_begin: # $t1=i
	beq $t1, $t0, for1_end
	li $v0, 8
	li $a1, 4
	la $a0, tmps
	syscall #read char
	lb $a0, tmps
	sb $a0, str($t1) #str[i]=c
	addiu $t1, $t1, 1
	j for1_begin
for1_end:
	move $t1, $0
	srl $t2, $t0, 1 #$t2=n>>1
	subiu $t3, $t0, 1
	li $a0, 1 #$a0=result=1
for2_begin: # $t1=i
	beq $t1, $t2, for2_end
	lb $t4, str($t1) #$t4=str[i]
	lb $t5, str($t3) #$t5=str[n-i-1]
	beq $t4, $t5, if_end
	move $a0, $0 #$result=0
	j for2_end #break
if_end:
	addiu $t1, $t1, 1
	subiu $t3, $t3, 1 #$t3=n-i-1
	j for2_begin
for2_end:
	li $v0, 1
	syscall #print result
	li $v0, 10
	syscall