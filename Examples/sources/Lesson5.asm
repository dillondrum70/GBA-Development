
	.include "\SrcALL\V1_Header.asm"
	bl ScreenInit
	
	b starttest


starttest:	

	nop ; Does nothing

	;b TestLogicalOps
	;b TestMultiply
	;b TestTest
	;b TestCarry
	;b TestNegative
	b Arm4Test			;These will only work on GBA or later RISCs
	b infloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestLogicalOps:
	mov r1,#0x12340000
	add r1,r1,#0x00005678
	mov r2,#0x0000FFFF

	and r0,r1,r2		;R0 = R1 AND R2
	bl MonitorR0R1
	orr r0,r1,r2		;R0 = R1 OR R2
	bl MonitorR0R1
	eor r0,r1,r2		;R0 = R1 XOR R2
	bl MonitorR0R1
	bic r0,r1,r2		;R0 = R1 CLEAR BITS R2
	bl MonitorR0R1
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Arm has multiply commands but no divide!!	

TestMultiply:
	bl newline
	mov r1,#2
	mov r2,#3
	mov r3,#1
	mul r0,r1,r2			;R0=R1*R2
	bl MonitorR0R1R2R3
	mla r0,r1,r2,r3			;R0=(R1*R2)+R3
	bl MonitorR0R1R2R3
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;LDRH/STRH are only available on the 'T' architectures like Arm4T+	
;it only works with addresses in registers, not directly specified ones.

Arm4Test:
.ifndef CpuArm2			;only works on GBA
	
	mov r0,#0xFEFD0000	;Reset R0
	add r0,r0,#0xFCFA	;Reset R0
	mov	r2,#userram		;Load the address of TestVal into r2
	str r0,[r2]
	
	mov r0,#0xFFFF0000	;Reset R0
	add r0,r0,#0xFFFF	;Reset R0
	bl ShowRegAndRam	;Show the regs (also shows R2 on Risc OS)
	
	ldrH r0,[r2]		;Load HalfBYTE r0 from address TestVal
	bl MonitorR0R1		
	rsb r0,r0,#0		;Negate It
	strH r0,[r2]		;Store HALFYTE R0 into the address in R2

	bl ShowRegAndRam
	bl NewLine
	bl ShowRegAndRam
	
	mov r1,#0x11220000
	add r1,r1,#0x3344
	mov r0,#0x88770000
	add r0,r0,#0x6655
	bl MonitorR0R1		;Show the regs (also shows R2 on Risc OS)
	
	bl NewLine
	
	swp r0,r1,[r2]		;Load r0 from [base],store r1 in [base]
	;swp r0,r0,[r2]		;This works too!
	
	bl ShowRegAndRam
.endif								

	b infloop
	
	
	
	;SWP r1, r2, [r0]       ; Swap R2 with location [R0], [R0] value placed in R1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestCarry:
	mov r0,#0x00000000	;High part of 64 bit pair
	mov r1,#0xFFFF0000	;Low part of 64 bit pair
	add r1,r1,#0x0000FFFC
	
	mov r2,#0x00000001	;Value to add
	
	mov r3,#0x00000008	;Loop Count
CarryLoop1:
	bl MonitorR0R1
	adds r1,r1,r2		;Add value to Low 
	adc  r0,r0,#0		;Add carry to High
	
	subs r3,r3,#1		;Decrease loop count
	bne CarryLoop1
	
	bl newline	
			
	mov r3,#0x00000008	;Loop Count
CarryLoop2:
	bl MonitorR0R1
	subs r1,r1,r2		;Subtract value from Low 
	sbc  r0,r0,#0		;Subtract carry from High
	
	subs r3,r3,#1		;Decrease loop count
	bne CarryLoop2
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
TestNegative:
	mov r0,#0
	sub r0,r0,#1
	mov r1,r0
;Reversed subtract - Parameters are flipped
	bl newline	
	mov r4,#0
	mov r1,#4
	mov r3,#0x00000008	;Loop Count
CarryLoop3:
	bl MonitorR0R1
	rsbs r1,r2,r1		;RevSub value from Low 
	rsc  r0,r4,r0		;RevSub carry from High
	
	subs r3,r3,#1		;Decrease loop count
	bne CarryLoop3
	
	bl NewLine
	
	mov r0,#0x1234
	mvn r1,r0			;Move negative of R0 into R1
	mov r2,#5000
	
	bl MonitorR0R1
	cmn r1,r2		;Compare -$1234 to -5000
	;cmp r1,r2		;Compare -$1234 to 5000
	
	blt jmpless
	bgt jmpgreat
	
	b infloop
	
	
jmpless:	
	mov r0,#60 ;'<'
	bl printchar
	b infloop
jmpgreat:	
	mov r0,#62 ;'>'
	bl printchar
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
TestTest:
	mov r0,#0x0000FF0F
	;mov r1,#0x000000F0	;EQ test (result = zero)
	;mov r1,#0x0000000F	;NE test (result != zero)
	mov r1,#0x0000FF0F 	;TEQ test 
	
	.ifdef CpuArm2
		bl MonitorR0R1
	.endif
	
	;tst r0,r1 			;AND test (Flags = RO AND R1)
	teq r0,r1 			;XOR test (Flags = R0=R1)
	
	.ifndef CpuArm2
		mrs r2,CPSR		;Back up flags
		bl MonitorR0R1	;Show Monitor (changes flags)
		msr CPSR,r2		;Restore flags
	.endif
	beq jmpEquals
	bne jmpNotEquals
	
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
infloop:
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

jmpNotEquals:	
	mov r0,#33 ;'!'	
	bl printchar
jmpEquals:	
	mov r0,#61 ;'='
	bl printchar
	b infloop

ShowRegAndRam:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		bl MonitorR0R1		;Show the regs (also shows R2 on Risc OS)
		mov	r0,#userram		;Address
		mov r1,#1			;Lines
		bl MemDump
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
MonitorR0R1:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		bl MonitorR0
		bl MonitorR1
		.ifdef BuildROS
			bl MonitorR2
			
		.endif


		
		bl newline	
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
MonitorR0R1R2R3:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		bl MonitorR0
		bl newline	
		bl MonitorR1
		bl MonitorR2
		.ifndef BuildROS
			bl newline	
		.endif
		bl MonitorR3
		bl newline	
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
MonitorR0R1R2R3b:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		bl MonitorR0
		bl MonitorR1
		bl newline	
		bl MonitorR2
		bl MonitorR3
		bl newline	
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
				
MonitorR3:	
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r2,r3
		mov r1,#48+3				;Number 3
		b MonitorRn
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
		
MonitorR2:	
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r1,#48+2				;Number 2
		b MonitorRn
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
	
MonitorR1:	
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r2,r1
		mov r1,#48+1				;Number 1
		b MonitorRn
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
	
MonitorR0:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r2,r0
		mov r1,#48+0				;Number 0
MonitorRn:	
		mov r0,#82					;Letter R
		bl PrintChar
		mov r0,r1 					;reg number
		bl PrintChar
		mov r0,#58 					;Ascii :
		bl PrintChar
		
		mov r0,r2
		bl ShowHex32	
		mov r0,#32 					;Ascii Space
		bl PrintChar
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
	
	.include "/srcALL/V1_Monitor.asm"
	.include "/srcALL/V1_BitmapMemory.asm"

BitmapFont:
	.incbin "\ResALL\Font96.FNT"
SpriteTest:
	.ifdef BuildROS
		.incbin "\ResALL\SpriteROS.RAW"
	.endif
	.ifdef BuildGBA
		.incbin "\ResALL\SpriteGBA.RAW"
	.endif

	