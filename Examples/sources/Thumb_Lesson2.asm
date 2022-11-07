.include "\SrcALL\V1_Header.asm"

	adr r0,ThumbTest
	add r0,r0,#1		;Bit 0=1 THUMB ON!
	bx r0

	.thumb				;Thumb mode
ThumbTest:
	ldr r1,SPAddress	;Init Stack Pointer	
	mov sp,r1
	
	bl ScreenInit		;Init Screen
	mov r0,#0
	mov r1,#0
	mov r2,#0
	mov r3,#0

	
	;b TestImmediate	;1. Immediate - direct numberic values 
	;b TestRegister		;2. Register - Data from other registers
	;b TestRegisterIndirect 	;3 . Register indirect
	;b TestRegIndirWithOffset 	;4 .Register indirect with constant offset - Address in Register + fixed value
	;b TestRegIndirWithRegOffset ;5. Register indirect with register offset - Address in sum of two registers
	;b TestPCRelative 	;6. PC register Relative - label relative to current code
	;b TestShifts 	;9. Register Shifted - Value of a register bit shifted 
	b TestMultiple	;Ranges of values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mathematic commands can typically only work with registers or immediate values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestImmediate: ;Immediate - direct numberic values 

	mov r0,#0x12		;Load a hex into a register
	mov r1,#0b10101010	;Load a binary into a register (0xAA)
	mov r2,#65			;Ascii A - Decimal value (0x41)
	
	bl MonitorR0R1R2R3;Show the regs (also shows R2 on Risc OS)
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestRegister:	;Register - Data from other registers
	
	mov r2,#0x80
	bl MonitorR0R1R2R3		
	
	mov r1,r2			;Set r1 to the value in r2
	bl MonitorR0R1R2R3		
	
	add r0,r1,r2		;set r0 to r1+r2
	bl MonitorR0R1R2R3		
		
	b infloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;LoadStore commands can work with more complex commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestRegisterIndirect: ;Register indirect
							;Vasm requires us to specify #0
	bl ShowSomedata
	
	adr r2,somedata
	ldr r0,[r2,#0]			;Set r1 to the value at address in r2
	
	bl MonitorR0R1R2R3		;Show the regs 
	
	lsr r0,r0,#16			;Alter R0
	
	bl MonitorR0R1R2R3		;Show the regs 
	
	str r0,[r2,#0]			;store r0 back into address in r2
	
	bl ShowSomedata
	
	b infloop
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestRegIndirWithOffset: ;Register indirect with Immediate offset
	
	bl ShowSomedata
		
	adr r3,somedata			;Base address for our test
	
	bl MonitorR0R1R2R3

	ldr r0,[r3,#4]			;Load R0 from address in R2 +4
	
.equ Var2,8					;We can define a symbol with the offset
	ldr r1,[r3,#Var2]		;Load R0 from address in R2 +8
	
	;ldr r2,[r3,#1]		;Won't work - must be word aligned
	;ldr r2,[r3,#-4]		;Won't work - must be positive
	
	ldrh r2,[r3,#2]			;Offset must be positive multiple of 4/2/1
								; (depending on load size)
								
;(loading 32 bit values should be from addresses that are multiples of 4)
	
	bl MonitorR0R1R2R3
	
	b infloop
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestRegIndirWithRegOffset: ;Register offset 
	
	;No Predec/Postinc in Thumb
	
	bl ShowSomedata
	
	adr r2,somedata			;Base address for our test
	
	mov r1,#4
	ldr r0,[r2,r1]			;Load R0 from address in R2 +R3 (4)
	bl MonitorR0R1R2R3
	 
	add r1,#4
	ldr r0,[r2,r1]			;Load R0 from address in R2 +R3 (8)
	bl MonitorR0R1R2R3
	 
	sub r1,#8
	ldr r0,[r2,r1]			;Load R0 from address in R2 +R3 (0)
	bl MonitorR0R1R2R3	

	b infloop
		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;somedata - can't be here - must be BEFORE PC

TestPCRelative: ;PC Relative - Must be AFTER Current line!

	bl ShowSomedata

	ldr r0,somedata			;Load from the somedata label
	
	ldr r1,somedata+4		;Load from the somedata label+4
	
	ldr r2,somedata+8		;Load from the somedata label+8
	
	bl MonitorR0R1R2R3		;Show the regs (also shows R2 on Risc OS)
	
	b infloop
	
	.align 4
somedata:
	.byte 0x01,0x23,0x45,0x67,0x89,0xAB,0xCD,0xEF
	.byte 0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0
	.align 4
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestShifts: ;Register Shifted - Value of a register bit shifted 

	ldr r0,TestValue	;Set a test value #0x80001002
	ldr r1,TestValue	;Set a test value #0x80001002
	mov r2,#8	
	bl MonitorR0R1		
	
	lsl r0,r1,#4		;R0=R1 Left shifted 4 bits
	lsr r1,r1,#4		;R0=R1 Right shifted 4 bits
	
	bl MonitorR0R1		
	lsl r0,r2			;Shift Left R2 bits
	lsr r1,r2			;Shift Right R2 bits
								
	bl MonitorR0R1		
	bl newline
	
	ldr r0,TestValue	;Set a test value #0x80001002
	ldr r1,TestValue	;Set a test value #0x80001002
	bl MonitorR0R1		
		
	asr r0,r1,#4
	asr r1,r2
	;asl r1,r2			;ASL doesn't exist, use LSL
	
	bl MonitorR0R1		
	bl newline
	
	ldr r0,TestValue	;Set a test value #0x80001002
	ldr r1,TestValue	;Set a test value #0x80001002
	bl MonitorR0R1		
		
	mov r2,#4
	mov r3,#32-4		;Effective ROL 4
	
	ror r0,r2
	ror r1,r3
	;rol r0,r1			;ROL does not exist
	;ror r1,#8			;ROR wit immediate Doesn't exist
	
	bl MonitorR0R1		
	bl newline
	
	b infloop
	

TestMultiple:		;Load/Store Multiple
; - specifies a range   , eg R0-R4
; , specifies individual, eg R0,R2,R4

	bl ShowSomedata
	ldr r2,somedataaddr
	bl MonitorR0R1R2R3
	
	LDMIA R2!,{R0-R1,R3}	;Load multiple 
	
	bl MonitorR0R1R2R3	
	
	mvn r0,r0
	mvn r1,r1			;Flip bits of registers
	mvn r3,r3
	
	ldr r2,somedataaddr
	bl MonitorR0R1R2R3	
	
	STMIA R2!,{R0-R1,R3} 	;Store multiple 
	
	bl ShowSomedata
	
	;push and pop work with the stack - command format the same!
	;We'll cover the stack next lesson!
	
	bl MonitorR0R1		
	
	Push {R0-R1,R3}	;Push R0,R1 and R3 onto the stack
		mov r0,#0x11
		mov r1,#0x22
		bl MonitorR0R1		
	pop {R0-R1,R3}	;Pop R0,R1 and R3 onto the stack
	
	bl MonitorR0R1		
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	.align 4
TestValue:
	.long 0x80001002
infloop:
	b infloop

MonitorR0R1:
	push {r0-r7, lr}
		mov r6,#0
		mov r7,r0
		bl ShowReg ;ShowReg R6=R7
		mov r6,#1
		mov r7,r1
		bl ShowReg ;ShowReg R6=R7
		bl newline
	pop {r0-r7, pc}
	
MonitorR0R1R2R3:
	push {r0-r7, lr}
		mov r6,#0
		mov r7,r0
		bl ShowReg ;ShowReg R6=R7
		mov r6,#1
		mov r7,r1
		bl ShowReg ;ShowReg R6=R7
		bl newline
		
		mov r6,#2
		mov r7,r2
		bl ShowReg ;ShowReg R6=R7
		mov r6,#3
		mov r7,r3
		bl ShowReg ;ShowReg R6=R7
		bl newline
		
		bl newline
	pop {r0-r7, pc}
	
ShowSomedata:
	push {r0-r7, lr}
		ldr	r0,somedataaddr	;Address
		mov r1,#2			;Lines
		bl MemDump			;Show Ram onscreen	
		
		bl newline
	pop {r0-r7, pc}

	.align 4
somedataaddr:
	.long somedata
SPAddress:
	.long 0x03000000

	.align 4

BitmapFont:
	.incbin "\ResALL\Font96.FNT"
	
	.include "/srcALL/V1_Thumb_BitmapMemory.asm"
	.include "/srcALL/V1_Thumb_Monitor.asm"
	
	.include "/srcALL/V1_Thumb_Footer.asm"