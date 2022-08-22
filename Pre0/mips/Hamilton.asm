.macro finish
	li $v0, 10
	syscall
.end_macro
.macro getInt
	li $v0, 5
	syscall
.end_macro
.macro printInt(%in)
	move $a0, %in
	li $v0, 1
	syscall
.end_macro
.macro push(%in)
	sw %in, ($sp)
	subiu $sp, $sp, 4
.end_macro
.macro pop(%out)
	addiu $sp, $sp, 4
	lw %out, ($sp) 
.end_macro

.data
	graph: .space 256
	book: .space 32
	v_n: .space 4

.text
	getInt
	sw $v0, v_n
	getInt
	move $a0, $v0 #a0=m
	move $t0, $0 #int i=0, t0=i
loop_begin:
	beq $t0, $a0, loop_end
	getInt
	move $t1, $v0 #t1=x-1
	subiu $t1, $t1, 1
	getInt #v0=y-1
	subiu $v0, $v0, 1
	sll $t2, $t1, 3
	addu $t2, $t2, $v0 #t2=[x-1][y-1]
	sll $t2, $t2, 2
	ori $t3, $0, 1
	sw $t3, graph($t2)
	sll $t2, $v0, 3
	addu $t2, $t2, $t1 #t2=[y-1][x-1]
	sll $t2, $t2, 2
	sw $t3, graph($t2)
	addiu $t0, $t0, 1
	j loop_begin
loop_end:
	move $a0, $0
	move $v0, $0
	jal dfs #call dfs(0)
	printInt($v0)
	finish

dfs: #a0=x
	push($ra)
	ori $t0, $0, 1 #t0=1
	sll $t1, $a0, 2 #t1=[x]
	sw $t0, book($t1)
	ori $a1, $0, 1 #a1=flag=1

	move $t1, $0 #int i=0, t1=i
	lw $t3, v_n #t3=n
loop1_begin:
	beq $t1, $t3, loop1_end
	sll $t2, $t1, 2 #t2=[i]
	lw $t4, book($t2)
	and $a1, $a1, $t4
	addiu $t1, $t1, 1
	j loop1_begin
loop1_end:

	beqz $a1, if1_end
	sll $t1, $a0, 5 #t1=[x][0]
	lw $t2, graph($t1)
	beqz $t2, if1_end
	ori $v0, $0, 1 #return v0=1
	j dfs_return
if1_end:

	move $t1, $0 #int i=0, t1=i, t3=n
loop2_begin:
	beq $t1, $t3, loop2_end
	sll $t0, $t1, 2 #t0=[i]
	lw $t2, book($t0)
	bnez $t2, if2_end
	sll $t0, $a0, 3
	addu $t0, $t0, $t1
	sll $t0, $t0, 2 #t0=[x][i]
	lw $t2, graph($t0)
	beqz $t2, if2_end
	push($a0)
	push($t1)
	push($t3)
	move $a0, $t1
	jal dfs
	pop($t3)
	pop($t1)
	pop($a0)
if2_end:
	addiu $t1, $t1, 1
	j loop2_begin
loop2_end:

	sll $t0, $a0, 2 #t0=[x]
	sw $0, book($t0)

dfs_return:
	pop($ra)
	jr $ra