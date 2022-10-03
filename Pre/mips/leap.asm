.data
	true: .asciiz "1"
	false: .asciiz "0"

.text
	li $v0, 5 #read integer
	syscall
	
	ori $t0, $0, 400
	divu $v0, $t0
	mfhi $t0
	beqz $t0, print_1 #(n%400==0)?
	ori $t0, $0, 4
	divu $v0, $t0
	mfhi $t0
	bgtz $t0, print_0 #(n%4==0)?
	ori $t0, $0, 100
	divu $v0, $t0
	mfhi $t0
	bgtz $t0, print_1 #(n%100!=0)?

print_0:
	li $v0, 4 #print
	la $a0, false
	syscall
	j exit
print_1:
	li $v0, 4 #print
	la $a0, true
	syscall
exit:
	li $v0, 10 #exit
	syscall