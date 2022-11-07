.include "\SrcALL\V1_Header.asm"

	adr r0,ThumbTest
	add r0,r0,#1		;Bit 0=1 THUMB ON!
	bx r0

	.thumb				;Thumb mode
ThumbTest:
	ldr r1,SPAddress	;Init Stack Pointer	
	mov sp,r1
	
	bl ScreenInit		;Init Screen
	
	
		
	mov r1,#1
	add r0,r1,r1		;Add 1 to 1 - Clears carry
	
	;b FlagsTest		;Test the S option and flags
	;b TestCarry			;Carry test
	;b TestEquals		;Test = != <>
	;b TestCompareNegative
	;b TestGreaterLessUnsigned	;Test >= <= > <
	;b TestGreaterLessSigned	;Test >= <= > <
	;b TestSign			;SignTest
	b TestOverflow		;Overflow Test
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Unlike the regular ARM, THUMB cannot specify which commands do and don't set flags
;That said, not all commands affect all flags. 

FlagsTest:	
	mov r1,#1
	add r0,r1,r1		;Add 1 to 1 - Clears carry
	
	ldr r0,NoCarryVal	;No Carry
	bl MonitorFlags
	
	add r0,r0,r1		;Add 1 to FFFFFFFF - Carry Flag Set
	bl MonitorFlags
	
	ldr r0,NoCarryVal	;LDR does not set flags - Carry still set
	bl MonitorFlags
	
	mov r0,r0			;MOV sets flags	 - Carry is cleared
	bl MonitorFlags
	
	b infloop
	
	.align 4
NoCarryVal:
	.long 0xFFFFFFFF
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestCarry:	
	mov r1,#1
	ldr r0,CarryVal		;Cause Carry
	;ldr r0,NoCarryValb	;No Carry
	
	bl MonitorFlags		;Starting Values
	
	add r0,r0,r1
	bl MonitorFlags		;Add the two - will it cause a carry?
	
	bcs jmpCarry 		;Branch if R0>=R1 / Carry Set	(Unsigned)
	
	bcc jmpNoCarry 		;Branch if R0<R1 / Carry Clear	(Unsigned)
	
	b nojmp
.align 4
CarryVal:
	.long 0xFFFFFFFF
NoCarryValb:
	.long 0xFFFFFFFE
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestEquals:		; Zero Flag and CMP
	mov r0,#10
	
	;mov r1,#11			;Not Equal Test
	mov r1,#10			;Equal Test
	
	bl MonitorFlags
	
	cmp r0,r1			;Compare - Effective Subtract
	
	bl MonitorFlags
	
	beq jmpEquals		;Branch if R0=R1
	
	bne jmpNotEquals 	;Branch if R0<>R1
	
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestCompareNegative: ;CMN
	mov r0,#10
	mov r1,#10		
	
	neg r1,r1			;CMN test
	bl MonitorFlags
	
	cmn r0,r1			;Compare negative- Effective Add
	
	bl MonitorFlags
	
	beq jmpEquals		;Branch if R0=R1		
	bne jmpNotEquals 	;Branch if R0<>R1		
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
TestGreaterLessUnsigned:	
	mov r0,#10		
	mov r1,#0	
	
	mov r1,#5		;Greater than test
	;mov r1,#20		;Less than than test
	
	;Negative numbers will not work correctly with this function
	;sub r1,#20			;(4294967286 unsigned)
	
	cmp r0,r1
	bl MonitorFlags	;Unsigned test

	;bcs jmpgreat 	;Branch if R0>=R1 / Carry Set	(Unsigned)
	
	;bcc jmpless 	;Branch if R0<R1 / Carry Clear	(Unsigned)
	
	bhi jmpgreat 	;Branch if R0>R1				(Unsigned)
	
	bls jmpless 	;Branch if R0<=R1				(Unsigned)

	b nojmp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestGreaterLessSigned:	
	mov r0,#10
	mov r1,#0
	
	;mov r1,#10		;Equals Test
	mov r1,#20		;Less Than Test
	;sub r1,#20		;Greater Test (-20)
	
	cmp r0,r1		;Compare R0 to R1 and Set flags
	bl MonitorFlags		
		
	bgt jmpgreat 	;Branch if R0>R1		(Signed)
	
	blt jmpless 	;Branch if R0<R1		(Signed)
		
	;bge jmpgreat	;Branch if R0>=R1		(Signed)
	
	;ble jmpless	;Branch if R0<=R1		(Signed)
	
	b nojmp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestSign:	
	mov r1,#100	
	mov r0,#0
	
	;sub r0,r0,r1	;N flag test Negative	
	mov r0,#100	;N flag test Positive
	
	bl MonitorFlags
	
	bpl JmpPlus 	;Branch if Positive
	
	bmi JmpMinus	;Branch if Negative

	b nojmp
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Overflow occurs when the limit of a signed number is breached and a positive number incorrectly flips to a negative (or vice versa)
;A signed number cannot contain >+32767 or <-32768... when it tries to the top bit will flip, and the value will become invalid...

TestOverflow:	
	ldr r0,OverflowVal ;Cause Overflow - 0x7FFFFFFF
	;ldr r0,NoOverflowVal	;Doesn't Cause Overflow - 0x7FFFFFFE
	
	mov r1,#1
	add r1,r0,r1
	bl MonitorFlags
	
	bvs jmpOverflow 	;Branch if overflow
	
	bvc jmpNoOverflow 	;Branch if no overflow
	
	b nojmp
	
	.align 4
OverflowVal:
	.long 0x7FFFFFFF
NoOverflowVal:
	.long 0x7FFFFFFE
	
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