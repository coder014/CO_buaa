.data
	calc_keystate: .space 4
	timer_notify: .space 4
	output_buf: .space 4

.text
#=====clear peripheral=====
addiu $t0, $0, -1
ori $t2, $0, 0x7F70 # LED
sw $t0, 0($t2)
ori $t2, $0, 0x7F50 # tube
sw $0, 0($t2)
sb $0, 4($t2)
ori $t0, $0, 0x7F00 # timer
lui $t1, 0x2FA
ori $t1, $t1, 0xF080
sw $t1, 4($t0) # count = 1s/20ns=5x10^7=0x02FAF080
#=====set UART baud-rate=====
ori $t2, $0, 0x7F30 # UART
ori $t1, $0, 2604 # DIVR=DIVT=1s/19200b/20ns
sw $t1, 8($t2)
sw $t1, 12($t2)
#======clear memory=====
sw $0, calc_keystate
sw $0, timer_notify
sw $0, output_buf

#=====entry point=====
ori $t1, $0, 0x2401 # accept timer & uart irq
mtc0 $t1, $12

#=========calculator mode=========
loop_calc:
ori $t0, $0, 0x7F68 # 8-buttons
lw $t1, 0($t0)
addiu $t0, $0, -1 # 01 turn-over
subu $t1, $t0, $t1
andi $t1, $t1, 0xF0
lw $t2, calc_keystate
bne $t1, $t2, calc_reset
nop
lw $t2, timer_notify
beq $t2, $0, loop_calc
nop
#=====timer triggered=====
sw $0, timer_notify
beq $a1, $0, loop_calc
nop
	andi $t2, $t1, 0x80 # addu
	bne $t2, $0, caseout
	addu $a0, $a1, $a2
	andi $t2, $t1, 0x40 # subu
	bne $t2, $0, caseout
	subu $a0, $a1, $a2
	andi $t2, $t1, 0x20 # mult
	bne $t2, $0, casenext
	mult $a1, $a2
	# div
	beq $a2, $0, div_by_zero
	nop
	div $a1, $a2
	casenext:
	mflo $a0
	beq $0, $0, caseout
	nop
	div_by_zero:
	ori $a0, $0, 0
caseout:
ori $a1, $a0, 0
jal func_output
nop
beq $0, $0, loop_calc
nop
calc_reset:
	sw $t1, calc_keystate
	beq $t1, $0, reset_0
	ori $t0, $0, 0x7F00 # timer
	#reset_non_0:
		sw $0, 0($t0) # stop timer
		ori $t1, $0, 0x7F60 # keygroup
		addiu $t2, $0, -1 # 01 turn-over
		lw $a1, 4($t1) # 1-op
		lw $a2, 0($t1) # 2-op
		subu $a1, $t2, $a1
		subu $a2, $t2, $a2
		ori $t2, $0, 0x9 # set timer mode 0
		sw $t2, 0($t0) # start timer
		beq $0, $0, loop_calc
		nop
	reset_0:
		sw $0, 0($t0) # stop timer
		nop
		sw $0, timer_notify
		beq $0, $0, loop_calc
		nop

func_output: # a0=num
	andi $t1, $a0, 1
	bne $t1, $0, digital_out
	nop
	#uart_out:
		ori $t0, $0, 0x7F50 # tubes
		addiu $t1, $0, -1
		sw $0, 0($t0) # tube-num
		sw $t1, 32($t0) # LED
		sw $a0, output_buf
		ori $t0, $0, 0x7F30 # uart
		ori $t3, $0, 4
		loop_sending:
			loop_uart_pending:
			lw $t1, 4($t0)
			andi $t1, $t1, 0x20 # tx available?
			beq $t1, $0, loop_uart_pending
			nop
			addiu $t3, $t3, -1
			lb $t1, output_buf($t3)
			sw $t1, 0($t0)
			bne $t3, $0, loop_sending
			nop
		jr $ra
		nop
	digital_out:
		ori $t0, $0, 0x7F50
		addiu $t1, $0, -1
		subu $t2, $t1, $a0
		sw $t2, 32($t0) # LED
		sw $a0, 0($t0) # tube-num
		jr $ra
		nop

.ktext 0x4180
mfc0 $k0, $13
andi $k0, $k0, 0x7C # exccode==0?
bne $k0, $0, handle_exec
nop

#=====set timer notify=====
mfc0 $s0, $13
andi $s0, $s0, 0x400 # timer irq?
beq $s0, $0, kecho_uart
nop
ori $s0, $0, 1
sw $s0, timer_notify
ori $s0, $0, 0x7F00 # timer
lw $s1, 0($s0)
ori $s1, $s1, 1
sw $s1, 0($s0) # restart timer

kecho_uart:
#=====check uart input=====
ori $s0, $0, 0x7F30
lw $s1, 4($s0)
andi $s1, $s1, 0x1 # rx ready?
beq $s1, $0, kexit
nop
lw $s2, 0($s0)
ori $s0, $0, 0x43 # == 67 == 'C'
bne $s0, $s2, kexit
nop
lui $s2, 0x2137
ori $s2, $s2, 0x3132
ori $s0, $0, 0x7F50
sw $0, 32($s0) # LED
sw $s2, 0($s0) # tube-num
kloop_quitlock:
beq $0, $0, kloop_quitlock
nop
kexit:
eret

handle_exec:
#=====exception lockdown====
mfc0 $k0, $14
ori $k1, $0, 0x7F50 #tube
sw $k0, 0($k1)
ori $k0, $0, 1
sb $k0, 4($k1)
klock:
beq $0, $0, klock
nop
