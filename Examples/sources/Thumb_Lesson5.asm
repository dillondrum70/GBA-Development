.include "\SrcALL\V1_Header.asm"

	adr r0,ThumbTest
	add r0,r0,#1		;Bit 0=1 THUMB ON!
	bx r0

	.thumb				;Thumb mode
ThumbTest:
	ldr r1,SPAddress	;Init Stack Pointer	
	mov sp,r1
	
	bl ScreenInit		;Init Screen
	
	;nop ; Does nothing - Broken on VASM :(

	;b TestLogicalOps
	;b TestTest
	;b TestCarry
	b TestMultiply
	
	
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestLogicalOps:
	ldr r0,TestValue
	ldr r1,TestMask
	bl MonitorR0R1

	ldr r0,TestValue
	
	and r0,r1			;R0 = R0 AND R1
	bl MonitorR0R1
	
	ldr r0,TestValue
	
	orr r0,r1			;R0 = R0 OR R1
	bl MonitorR0R1
	
	ldr r0,TestValue
	
	eor r0,r1			;R0 = R0 XOR R1
	bl MonitorR0R1
	
	ldr r0,TestValue
	
	bic r0,r1			;R0 = R0 CLEAR BITS R1
	bl MonitorR0R1
	b infloop

	.align 4
TestValue:
	.long 0x12345678
TestMask:
	.long 0x0000FFFF
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
TestTest:
	mov r0,#0x0F
	mov r1,#0xF0		;AND results in Zero
	mov r1,#0x0F		;AND results in NotZero
	
	bl MonitorFlags
	
	tst r0,r1 			;AND test (Flags = RO AND R1)
	
	bl MonitorFlags
	
	beq jmpEquals
	bne jmpNotEquals
	
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestCarry:
	mov r0,#0			;High part of 64 bit pair
	ldr r1,LowPart		;Low part of 64 bit pair
	
	mov r4,#0			;Used for ADC
	mov r2,#1			;Value to add
	
	mov r3,#8			;Loop Count
CarryLoop1:
	bl MonitorR0R1
	add r1,r1,r2		;Add value to Low 
	adc r0,r4			;Add carry to High
	
	sub r3,r3,#1		;Decrease loop count
	bne CarryLoop1
	
	bl newline	
			
	mov r3,#8			;Loop Count
CarryLoop2:
	bl MonitorR0R1
	sub r1,r1,r2		;Subtract value from Low 
	sbc  r0,r4			;Subtract carry from High
	
	sub r3,r3,#1		;Decrease loop count
	bne CarryLoop2
	
	b infloop
	
	.align 4
LowPart:
	.long 0xFFFFFFFC
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Arm has multiply commands but no divide!!	

TestMultiply:
	bl newline
	mov r0,#2
	mov r1,#3
	bl MonitorR0R1
	
	mul r0,r1			;R0=R0*R1
	
	bl MonitorR0R1
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

infloop:	
	b infloop


jmpEquals:	
	mov r0,#61 ;'='
	bl printchar
	b infloop
	

jmpNotEquals:	
	mov r0,#33 ;'!'	
	bl printchar
	mov r0,#61 ;'='
	bl printchar
	b infloop
	
	
MonitorR0R1:	
	push {r0-r7, lr}			;Push Regs
		mov r6,#0
		mov r7,r0
		bl ShowReg ;ShowReg R6=R7
		
		mov r6,#1
		mov r7,r1
		bl ShowReg ;ShowReg R6=R7
				
		bl newline	
	pop {r0-r7, pc}				;Pop Regs and return


MonitorFlags:
	push {r0-r7, lr}
	bl GetFlagsT
		push {r7}
			bl ShowFlags
		
			mov r6,#0
			mov r7,r0
			bl ShowReg ;ShowReg R6=R7
			
			mov r6,#1
			mov r7,r1
			bl ShowReg ;ShowReg R6=R7
			bl newline
		pop {r7}
		bl SetFlagsT
	pop {r0-r7, pc}

ShowFlags:	
	push {r0-r7, lr}
		mov r0,#78 ;'N'
		bl MonitorFlag
		mov r0,#90 ;'Z'
		bl MonitorFlag
		mov r0,#67 ;'C'
		bl MonitorFlag
		mov r0,#86 ;'V'
		bl MonitorFlag
		mov r0,#32 ;' '
		bl PrintChar
	pop {r0-r7, pc}
	
MonitorFlag:	
	push {r0-r6, lr}
		lsl r7,r7,#1
		bcs MonitorFlagB
		mov r0,#45 ;-
MonitorFlagB:		
		bl PrintChar
	pop {r0-r6, pc}

GetFlagsT:
	adr r6,GetFlags
	bx r6
GetFlagsDone:
	mov pc,lr  
SetFlagsT:
	adr r6,SetFlags
	bx r6
SetFlagsDone:
	mov pc,lr  
		
	 .align 4
	.arm
GetFlags:
	mrs r7,CPSR	;Get Flags (Arm3+)
	
	adr r6,GetFlagsDone
	add r6,r6,#1		;Bit 0=1 THUMB ON!
	bx r6
SetFlags:
	msr CPSR,r7	;Get Flags (Arm3+)
	
	adr r6,SetFlagsDone
	add r6,r6,#1		;Bit 0=1 THUMB ON!
	bx r6
	
	
	.thumb

	
	.align 4
SPAddress:
	.long 0x03000000
	.align 4
BitmapFont:
	.incbin "\ResALL\Font96.FNT"
	
	.include "/srcALL/V1_Thumb_BitmapMemory.asm"
	.include "/srcALL/V1_Thumb_Monitor.asm"
	
	.include "/srcALL/V1_Thumb_Footer.asm"