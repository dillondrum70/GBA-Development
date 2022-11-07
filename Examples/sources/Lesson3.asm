
	.include "\SrcALL\V1_Header.asm"
	bl ScreenInit
	
	mov r1,#1
	adds r0,r1,r1		;Add 1 to 1 - Clears carry
	
	;b FlagsTest		;Test the S option and flags
	;b TestCarry			;Carry test
	;b TestEquals		;Test = != <>
	;b TestGreaterLessUnsigned	;Test >= <= > <
	;b TestGreaterLessSigned	;Test >= <= > <
	;b TestSign			;SignTest
	;b TestOverflow
	;b TestAlways		;Constant / Never Jumps
	
	
	
	b ConditionsOnNonBranches

.align 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlagsTest:	
	mov r1,#1
	adds r0,r1,r1		;Add 1 to 1 - Clears carry
	
	mov r0,#0xFFFFFFFF	;No Carry					
	bl MonitorFlags
	
	add r0,r0,r1		;Add 1 to FFFFFFFF - Not updating flags
	bl MonitorFlags
	bl NewLine
	
	mov r0,#0xFFFFFFFF	;No Carry
	bl MonitorFlags
	
	;we're using addS - the S makes the flags update
	adds r0,r0,r1		;Add 1 to FFFFFFFF -  this causes a carry
	bl MonitorFlags
	
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestGreaterLessSigned:	
	mov r0,#10
	
	;mov r1,#10		;Equals Test
	mov r1,#20		;Less Than Test
	;mov r1,#-20	;Greater Test
	
	cmps r0,r1		;Compare R0 to R1 and Set flags
	bl MonitorFlags		
	
	
	bgt jmpgreat 	;Branch if R0>R1		(Signed)
	blt jmpless 	;Branch if R0<R1		(Signed)
	
	
	;bge jmpgreat	;Branch if R0>=R1		(Signed)
	;ble jmpless	;Branch if R0<=R1		(Signed)
	
	b nojmp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestEquals:		; Zero Flag
	mov r0,#10
	
	;mov r1,#11		;Not Equal Test
	mov r1,#10		;Equal Test
	bl MonitorFlags
	
	cmps r0,r1		
	bl MonitorFlags
	
	beq jmpEquals	;Branch if R0=R1		
	bne jmpNotEquals ;Branch if R0<>R1		
	
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestAlways:	

	bnv nojmp 		;Branch Never
	bal dojmp 		;Branch Always
	
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestGreaterLessUnsigned:	
	mov r0,#10		
	
	mov r1,#5		;Greater than test
	;mov r1,#20		;Less than than test
	
	;Negative numbers will not work correctly with this function
	;mov r1,#-20		;(4294967286 unsigned)
	
	cmps r0,r1
	bl MonitorFlags	;Unsigned test

	;bcs jmpgreat 	;Branch if R0>=R1 / Carry Set	(Unsigned)
	;bcc jmpless 	;Branch if R0<R1 / Carry Clear	(Unsigned)
	
	bhi jmpgreat 	;Branch if R0>R1				(Unsigned)
	bls jmpless 	;Branch if R0<=R1				(Unsigned)

	b nojmp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestCarry:	
	mov r1,#1
	mov r0,#0xFFFFFFFF	;Cause Carry
	;mov r0,#0xFFFFFFFE	;No Carry
	bl MonitorFlags		;Add the two - will it cause a carry?
	
	adds r0,r0,r1
	bl MonitorFlags		;Add the two - will it cause a carry?
	
	bcs jmpCarry 		;Branch if R0>=R1 / Carry Set	(Unsigned)
	bcc jmpNoCarry 		;Branch if R0<R1 / Carry Clear	(Unsigned)
	
	b nojmp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestSign:	
	movs r0,#-100	;N flag test Negative	
	;movs r0,#100	;N flag test Positive
	
	bl MonitorFlags
	
	bpl JmpPlus 	;Branch if Positive
	bni JmpMinus	;Branch if Negative

	b nojmp
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Overflow occurs when the limit of a signed number is breached and a positive number incorrectly flips to a negative (or vice versa)
;A signed number cannot contain >+32767 or <-32768... when it tries to the top bit will flip, and the value will become invalid...
TestOverflow:	
	mov r0,#0x7FFFFFFF	;Cause Overflow 
	;mov r0,#0x7FFFFFFE	;Doesn't Cause Overflow 
	
	mov r1,#1
	adds r1,r0,r1
	bl MonitorFlags
	
	bvs jmpOverflow 	;Branch if overflow
	bvc jmpNoOverflow 	;Branch if no overflow
	
	b nojmp
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ConditionsOnNonBranches:
	mov r0,#10
	
	;mov r1,#10		;Equals Test
	;mov r1,#20		;Less Than Test
	mov r1,#-20		;Greater Test
	
	cmps r0,r1		;Compare R0 to R1 and Set flags
	bl MonitorFlags		
	
	mov r0,#61 ;'='
	movlt r0,#60 ;'<'	;Will only run if R0<R1
	movgt r0,#62 ;'>'	;Will only run if R0>R1
	
	bl printchar
	b infloop
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
infloop:	
	b infloop
dojmp:	
	mov r0,#74 ;'J'
	bl printchar
	b infloop
	
nojmp:	
	mov r0,#46 ;'.'
	bl printchar
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

jmpless:	
	mov r0,#60 ;'<'
	bl printchar
	b infloop
jmpgreat:	
	mov r0,#62 ;'>'
	bl printchar
	b infloop

jmpNoCarry:	
	mov r0,#78 ;'N'
	bl printchar
jmpCarry:	
	mov r0,#67 ;'C'
	bl printchar
	b infloop

jmpPlus:	
	mov r0,#43 ;'+'
	bl printchar
	b infloop
jmpMinus:	
	mov r0,#45 ;'-'
	bl printchar
	b infloop
	
jmpNoOverflow:	
	mov r0,#78 ;'N'
	bl printchar
jmpOverflow:	
	mov r0,#86 ;'V'
	bl printchar
	b infloop
	

	

	
Mydata:
	.long 0x12345678
TestPointer: 
	.long Mydata	
	
		
	
	
	
MonitorFlags:
	STMFD sp!,{r0-r12, lr}			;Push Regs
	STMFD sp!,{r0,r1}			;Push Regs
	.ifdef CpuArm2
		mov r4,r15	;Get Flags (Arm2)
	.else
		mrs r4,CPSR	;Get Flags (Arm3+)
	.endif
	
				; NZCVIF------------------------MM
		mov r2,#0b10000000000000000000000000000000
		ands r3,r4,r2
		mov r0,#45 ;-
		beq nnjp
		mov r0,#78 ;N
nnjp:
		bl printchar
		
		
				; NZCVIF------------------------MM
		mov r2,#0b01000000000000000000000000000000
		ands r3,r4,r2
		mov r0,#45 ;-
		beq nzjp
		mov r0,#90 ;z
nzjp:		
		bl printchar

				; NZCVIF------------------------MM
		mov r2,#0b00100000000000000000000000000000
		ands r3,r4,r2
		mov r0,#45 ;-
		beq ncjp
		mov r0,#67 ;C
ncjp:	
		bl printchar
		
				; NZCVIF------------------------MM
		mov r2,#0b00010000000000000000000000000000
		ands r3,r4,r2
		mov r0,#45 ;-
		beq nvjp
		mov r0,#86 ;V
nvjp:
		bl printchar
		mov r0,#32
		bl printchar
	
	LDMFD sp!,{r0,r1}			;Pop Regs and return
	bl MonitorR0
	bl MonitorR1
	bl newline
	.ifdef CpuArm2
		  	    ;   NZCVIF------------------------MM
		;tstp R4,#0b11111100000000000000000000000011
		;tstp R4,#0xFC000003
		teqp R4,#0
	.else
		msr CPSR,r4	;Get Flags (Arm3+)
	.endif
	
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
MonitorR0R1:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		bl MonitorR0
		bl MonitorR1
		.ifdef BuildROS
			bl MonitorR2
		.endif
		bl newline	
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

	