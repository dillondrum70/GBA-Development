.include "\SrcALL\V1_Header.asm"

	adr r0,ThumbTest
	add r0,r0,#1		;Bit 0=1 THUMB ON!
	bx r0

	.thumb				;Thumb mode
ThumbTest:
	ldr r1,SPAddress	;Init Stack Pointer	
	mov sp,r1
	
	bl ScreenInit		;Init Screen
	
	;b TestMoves
	;b TestAdds
	b TestRamRW
	
;;;;;;;;;;;;;; Move values and Load immediate ;;;;;;;;;;;;;;
	
TestMoves:		;MOV Rx,Val Rx = Val
	
	mov r0,#0x12		;Move limited to 0-255 in thumb :-(
	mov r1,#0xFF
	
	;mov r1,#256			;This won't work :-(
	
	bl MonitorR0R1		
		
	mov r0,#0x10			;Load a hexadecimal value into a register
	mov r1,#0b00000010		;Load a binary into a register (0x02)
	
	bl MonitorR0R1
	
	mov r0,#10				;Decimal 10	
	mov r1,#65				;Ascii A - Decimal 	(0x41)

	bl MonitorR0R1
	
	bl NewLine
	
	mov r0,r1				;Transfer Reg to Reg
	
	bl MonitorR0R1
	
	;mov r8,#10				;This won't work, Can't set R8-15 directly
	;Most commansd on ARM-Thumb only support R0-R7
	
	mov r0,#10
	mov r8,r0				;This will work, set low reg r0-r7 first!
	
	bl MonitorR0R8
	
	bl NewLine
	
	ldr r0,TestVal			;Load 32 bit value from address after PC
	
	;ldr r8,TestVal			;This won't work, Reg 0-7 only
	;ldr r0,ThumbTest		;This won't work, Address must be below PC
	
	bl MonitorR0R8
	
	bl NewLine
	
	;mov r1,#-4				;This won't work, can only load 
								
	mov r0,#0
	sub r0,#4				;This will work
		
	bl MonitorR0R1
	
	mov r1,#8				;Load R1 with 8
	mvn r0,r1				;Load R0 with NOT R1
	;mvn r0,#8				;This won't work, can only use 
								;MVN with Register source
	bl MonitorR0R1
	
	neg r1,r1					;Negate R1
	
	bl MonitorR0R1
	
	b InfLoop					;Halt
	
;;;;;;;;;;;;;; Add and Subtract ;;;;;;;;;;;;;;

TestAdds:
	
	mov r0,#0
	ldr r1,TestVal			;Load 32 bit value from address after PC
	
	bl MonitorR0R1
	
	add r0,r1,#0x7			;R0=R1+7 (Short form - Values up to 7)
	sub r1,r1,#0x7			;R1=R1-7 (Short form - Values up to 7)
	
	;add r0,r1,#10			;This won't work, 0-7 only
	
	bl MonitorR0R1
	
	add r0,#0x10			;R0=R0+16 (value up to 255)
	sub r1,#0x10			;R1=R1-16 (value up to 255)
	
	bl MonitorR0R1
		
	bl NewLine
	
	ldr r1,TestVal			;Load 32 bit value from address after PC
	mov r0,#0x20
	bl MonitorR0R1
	
	add r0,r0,r1			;R0=R0+R1
	bl MonitorR0R1
	sub r0,r0,r1			;R0=R0-R1
	bl MonitorR0R1
	
	bl NewLine
	
	mov r0,#8
	ldr r1,TestVal
	mov r8,r1
	bl MonitorR0R8
	
	add r8,r0				;High Reg version of add R8=R8+r0
	;sub r8,r0				;Doesn't work - no Subtract version
	
	bl MonitorR0R8
		
	b InfLoop				;Halt
	
;;;;;;;;;;;;;; Load and Store ;;;;;;;;;;;;;;
	
TestRamRW:
	
	bl ShowTestRam
	
	ldr r0,TestVal		;Load R0 from PC relative TestVal
	ldr r1,TestRam
		
	str r0,[r1,#0]		;Store R0 to Address R0+0 (TestRam)
	str r0,[r1,#8]		;Store R0 to Address R0+8 (TestRam)
	
	ldr r2,[r1,#0]		;Load R2 from Address R0+0 (TestRam)
	ldr r3,[r1,#8]		;Load R3 from Address R0+8 (TestRam)
	
	bl MonitorR0R1R2R3
	
	bl ShowTestRam
	bl NewLine
	mov r2,#4			;Final address must be 32 bit aligned for 32 bit load
	;mov r2,#4			;This will not work! (will work for LDRH)
	str r0,[r1,r2]		;offset in register
	bl ShowTestRam
	
	bl NewLine
	
	ldr r2,TestRam		;Load R2 with our test data
	
	ldrb r0,[r2,#0]		;Load Unsigned byte
	ldrh r1,[r2,#0]		;Load Unsigned Half
	
	bl MonitorR0R1
	bl NewLine
	
	mov r0,#0
	sub r0,r0,#1		;Set R0,R1 to 0xFFFFFFFF
	mov r1,r0
	
	strb r0,[r2,#4]		;Load Unsigned byte
	strh r0,[r2,#8]		;Load Unsigned Half
	bl MonitorR0R1
	bl ShowTestRam
	
	
	mov r3,#2
	ldrb r0,[r2,r3]		;Load Unsigned byte - note top bits cleared
	ldrh r1,[r2,r3]		;Load Unsigned Half - note top bits cleared
	
	bl MonitorR0R1
	
	mov r3,#0			;Need to use 2 register addresses for these
	ldsb r0,[r2,r3]		;Load signed byte 
	ldsh r1,[r2,r3]		;Load signed Half (16 bit)
	
	;Note: No need for signed versions of STR
	bl MonitorR0R1
	
	b InfLoop					;Halt
	
InfLoop:
    b InfLoop					;Halt

	  
	.align 4
TestVal:
	.long 0x22446688
	
TestRam:
	.long 0x0200F000
	
	
	.align 4
SPAddress:
	.long 0x03000000
	
ShowTestRam:
	push {r0-r7, lr}
		ldr	r0,TestRam2		;Address
		mov r1,#2			;Lines
		bl MemDump
	pop {r0-r7, pc}
TestRam2:
	.long 0x0200F000
	
	
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
	pop {r0-r7, pc}
	
MonitorR0R8:
	push {r0-r7, lr}
		mov r6,#0
		mov r7,r0
		bl ShowReg ;ShowReg R6=R7
		mov r7,r8
		bl ShowReg ;ShowReg R6=R7
		bl newline
	pop {r0-r7, pc}
	
	
	
	
	
	
	.align 4

BitmapFont:
	.incbin "\ResALL\Font96.FNT"
	
	.include "/srcALL/V1_Thumb_BitmapMemory.asm"
	.include "/srcALL/V1_Thumb_Monitor.asm"
	
	.include "/srcALL/V1_Thumb_Footer.asm"