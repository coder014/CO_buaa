.data
	calc_keystate: .space 4
	timer_keystate: .space 4
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
sw $0, timer_keystate
sw $0, timer_notify
sw $0, output_buf

#=====entry point=====
ori $t1, $0, 0x2401 # accept timer & uart irq
mtc0 $t1, $12

ori $t0, $0, 0x7F68 # 8-buttons
lw $t1, 0($t0)
addiu $t0, $0, -1 # 01 turn-over
subu $t1, $t0, $t1
andi $t1, $t1, 1
beq $t1, $0, loop_calc
nop

#=========timer mode=========
loop_timer:
ori $t0, $0, 0x7F60 # key group 3~0
lw $t1, 0($t0)
addiu $t0, $0, -1 # 01 turn-over
subu $t1, $t0, $t1
lw $t2, timer_keystate
bne $t1, $t2, timer_reset
nop
lw $t1, timer_notify
beq $t1, $0, loop_timer
nop
#=====timer triggered=====
sw $0, timer_notify
beq $a1, $a2, loop_timer
nop
addu $a1, $a1, $a3
ori $a0, $a1, 0
jal func_output
nop
beq $0, $0, loop_timer
nop
timer_reset:
	sw $t1, timer_keystate
	beq $t1, $0, reset_0
	ori $t0, $0, 0x7F00 # timer
	#reset_non_0:
		sw $0, 0($t0) # stop timer
		ori $a1, $0, 0 # initial value
		ori $a2, $t1, 0 # final value
		ori $a3, $0, 1 # loop step
		ori $t2, $0, 0x9 # set timer mode 0
		sw $t2, 0($t0) # start timer
		ori $t0, $0, 0x7F68 # 8-buttons
		lw $t1, 0($t0)
		addiu $t0, $0, -1 # 01 turn-over
		subu $t1, $t0, $t1
		andi $t1, $t1, 0x4
		beq $t1, $0, trst_ifout
		nop
		#=====counter-wise=====
			ori $a1, $a2, 0
			ori $a2, $0, 0
			addiu $a3, $0, -1
		#=====clock-wise=====
		trst_ifout:
		ori $a0, $a1, 0
		jal func_output
		nop
		beq $0, $0, loop_timer
		nop
	reset_0:
		sw $0, 0($t0) # stop timer
		nop
		sw $0, timer_notify
		ori $a0, $0, 0
		jal func_output
		nop
		beq $0, $0, loop_timer
		nop

#=========calculator mode=========
loop_calc:
ori $t0, $0, 0x7F68 # 8-buttons
lw $t1, 0($t0)
addiu $t0, $0, -1 # 01 turn-over
subu $t1, $t0, $t1
andi $t1, $t1, 0xFC
lw $t2, calc_keystate
beq $t1, $t2, loop_calc
nop
sw $t1, calc_keystate
beq $t1, $0, loop_calc
nop
ori $t0, $0, 0x7F68
lw $t3, -4($t0) # key group 7~4
addiu $t2, $0, -1 # 01 turn-over
subu $t3, $t2, $t3
lw $t4, -8($t0) # key group 3~0
subu $t4, $t2, $t4
	andi $t2, $t1, 0x80 # addu
	bne $t2, $0, caseout
	addu $a0, $t3, $t4
	andi $t2, $t1, 0x40 # subu
	bne $t2, $0, caseout
	subu $a0, $t3, $t4
	andi $t2, $t1, 0x08 # and
	bne $t2, $0, caseout
	and $a0, $t3, $t4
	andi $t2, $t1, 0x04 # or
	bne $t2, $0, caseout
	or $a0, $t3, $t4
	andi $t2, $t1, 0x20 # mult
	bne $t2, $0, casenext
	mult $t3, $t4
	div $t3, $t4 # div
	casenext:
	mflo $a0
caseout:
jal func_output
nop
beq $0, $0, loop_calc
nop

func_output: # a0=num
	ori $t0, $0, 0x7F68 # 8-buttons
	lw $t1, 0($t0)
	addiu $t0, $0, -1 # 01 turn-over
	subu $t1, $t0, $t1
	andi $t1, $t1, 0x2
	beq $t1, $0, digital_out
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
#=====echo uart input out=====
ori $s0, $0, 0x7F30
lw $s1, 4($s0)
andi $s1, $s1, 0x1 # rx ready?
beq $s1, $0, kexit
nop
lw $s2, 0($s0)
kloop_uart_pending:
lw $s1, 4($s0)
andi $s1, $s1, 0x20 # tx available?
beq $s1, $0, kloop_uart_pending
nop
sw $s2, 0($s0)
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
