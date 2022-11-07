
	.include "\SrcALL\V1_Header.asm"
	bl ScreenInit
	
	b starttest


starttest:	
	adr	r0,somedata		;Address
	mov r1,#2			;Lines
	bl MemDump

	bl newline
	
	;b TestImmediate	;1. Immediate - direct numberic values 
	;b TestRegister		;2. Register - Data from other registers
	;b TestRegisterIndirect 	;3 . Register indirect
	;b TestRegIndirWithOffset 	;4 .Register indirect with constant offset - Address in Register + fixed value
	;b TestRegIndirWithRegOffset ;5. Register indirect with register offset - Address in sum of two registers
	;b TestRegisterIndirectWithPreInc ;6. Register indirect with Preincrement - Increase register and Get from address in register 
	;b TestRegIndirectWithPostInc 	;7. Register indirect with Postincrement - Get from address in register and increase register
	;b TestPCRelative 	;8. PC Relative - label relative to current code
	;b TestRegShifted 	;9. Register Shifted - Value of a register bit shifted 
	b TestRegIndirWithScaledRegOff ;10. Register indirect with scaled Register offset - Address Register + Reg*val 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mathematic commands can typically only work with registers or immediate values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestImmediate: ;Immediate - direct numberic values 
	


	mov r0,#0x12340000	;Load a hex into a register
	mov r1,#0b10101010	;Load a binary into a register (0xAA)
	mov r2,#65			;Ascii A - Decimal value (0x41)
	
	bl MonitorR0R1;Show the regs (also shows R2 on Risc OS)

	
	b infloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestRegister:	;Register - Data from other registers
	mov r2,#0x8000
	bl MonitorR0R1		
	
	mov r1,r2			;Set r1 to the value in r2
	bl MonitorR0R1		
	
	add r0,r1,r2		;set r0 to r1+r2
	bl MonitorR0R1		
	
	bl newline
	
	b infloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;LoadStore commands can work with more complex commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestRegisterIndirect: ;Register indirect
	
	adr r2,somedata
	ldr r0,[r2]			;Set r1 to the value at address in r2
	
	bl MonitorR0R1		;Show the regs (also shows R2 on Risc OS)
	
	mov r1,#0x00002301
	sub r0,r0,r1		;Keep the top two bytes 
	
	bl MonitorR0R1		;Show the regs (also shows R2 on Risc OS)
	
	str r0,[r2]			;store r0 back into address in r2
	
	bl newline
	adr	r0,somedata		;Address
	mov r1,#2			;Lines
	bl MemDump			;Show Ram onscreen
	
	b infloop
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestRegIndirWithOffset: ;Register indirect with constant offset
	
	adr r2,somedata			;Base address for our test
	
	bl MonitorR0R1			;Show the regs (also shows R2 on Risc OS)

	ldr r0,[r2,#4]			;Load R0 from address in R2 +4
	
.equ Var2,8					;We can define a symbol with the offset
	ldr r1,[r2,#Var2]		;Load R0 from address in R2 +8

	ldr r2,[r2,#-4]			;Load R0 from address in R2 -4
;(loading 32 bit values should be from addresses that are multiples of 4)
	
	bl MonitorR0R1			;Show the regs (also shows R2 on Risc OS)
	
	bl newline
	adr	r0,somedata		;Address
	mov r1,#2			;Lines
	bl MemDump			;Show Ram onscreen
	
	b infloop
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestRegIndirWithRegOffset: ;Register indirect with register offset - same as last time with a register
	
	adr r2,somedata			;Base address for our test
	
	mov r1,#4
	ldr r0,[r2,r1]			;Load R0 from address in R2 +R3 (4)
	bl MonitorR0R1			
	 
	add r1,r1,#4
	ldr r0,[r2,r1]			;Load R0 from address in R2 +R3 (8)
	bl MonitorR0R1			
	 
	sub r1,r1,#12
	ldr r0,[r2,r1]			;Load R0 from address in R2 +R3 (-4)
	bl MonitorR0R1			

	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestRegIndirWithScaledRegOff: ;Register indirect with scaled Register offset 
	
	adr r2,somedata
	mov r1,#1

	;Note: LSL #2 will shift 2 bits to the left - effectively multiplying R3 x4
	
	ldr r0,[r2,r1,lsl #2]	;Load R0 from address in R2 +R1<<2 (1*4)
	bl MonitorR0R1	
	
	add r1,r1,#1				
	ldr r0,[r2,r1,lsl #2]	;Load R0 from address in R2 +R1<<2 (2*4)
	bl MonitorR0R1
	
	sub r1,r1,#2
	ldr r0,[r2,r1,lsl #2]	;Load R0 from address in R2 +R3<<1 (-1*4)
	bl MonitorR0R1
	;(loading 32 bit values should be from addresses that are multiples of 4)
	
	
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestRegisterIndirectWithPreInc: ;Register indirect with Preincrement
	adr r1,somedata
	ldr r0,[r1]		;Load from 4 + the address in R1 (R1 unchanged)
	bl MonitorR0R1
	
	ldr r0,[r1,#4]!	;add 4 to the address in R1, Load from addr in R1 (R1 changed)
	bl MonitorR0R1
	
	ldr r0,[r1,#4]!	;add 4 to the address in R1, Load from addr in R1 (R1 changed)
	bl MonitorR0R1
	
	ldr r0,[r1,#4]!	;add 4 to the address in R1, Load from addr in R1 (R1 changed)
	bl MonitorR0R1
	
	b infloop
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestRegIndirectWithPostInc: ;Register indirect with Postincrement
	adr r1,somedata
	
	ldr r0,[r1]		;Load from the address in R1
	bl MonitorR0R1		
	
	ldr r0,[r1],#4	;Load from the address in R1, then add 4 to R1 (R1 changed)
	bl MonitorR0R1		
	
	ldr r0,[r1],#4	;Load from the address in R1, then add 4 to R1 (R1 changed)
	bl MonitorR0R1		

	ldr r0,[r1],#4	;Load from the address in R1, then add 4 to R1 (R1 changed)
	bl MonitorR0R1		
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
somedata:
	.byte 0x01,0x23,0x45,0x67,0x89,0xAB,0xCD,0xEF
	.byte 0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0
.align 4

TestPCRelative: ;PC Relative
	ldr r0,somedata			;Load from the somedata label
	ldr r1,somedata+4		;Load from the somedata label+4
	ldr r2,somedata+8		;Load from the somedata label+8
	bl MonitorR0R1			;Show the regs (also shows R2 on Risc OS)
	
	b infloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestRegShifted: ;Register Shifted - Value of a register bit shifted 

	mov r0,#0x80001002	;Set a test value
	
	mov r1,r0,lsl #8	;Logically shift R0 left 8 bits, store in R1 
	mov r2,r0,lsr #8	;Logically shift R0 right 8 bits, store in R1
							; (pushed off bits disappear)
								
	bl MonitorR0R1		
	bl newline
	
	mov r0,#0x80001002	;Set a test value
	
	;mov r1,r0,asl #8	;ASL does not exist 
	mov r2,r0,asr #8	;Arithmatic shift right 
						;(all bits shift right, but bit 31 stays the same)
	bl MonitorR0R1		
	bl newline
	
	
	mov r0,#0x80001002	;Set a test value
	
	;mov r1,r0,rol #8	;ROL does not exist
	mov r2,r0,ror #8	;Rotate bits right around the byte 
						;(anything pushed off the right comes back to the left)
	bl MonitorR0R1		
	bl newline
	
	mov r0,#0x80001002	;Set a test value
	mov r3,#4			;Rotate commands can also use registers (8 bit only)
	
	mov r1,r0,ror r3	;Rotate bits right around the byte 
	mov r2,r0,asr r3	;Arithmatic shift right

	bl MonitorR0R1		
	bl newline

	
	
;RRX - Rotate Right with eXtend
	
	mov r0,#0				
	movs r1,r0,rrx 			;Set Carry to zero
	;Rotate Right with bit 31 coming from Carry - the S after Mov sets carry to bit 0
	mov r0,#0x80002001		;Set a test value	
	movS r1,r0,rrx 	
	;Bits rotated right: 8 (%1000) becomes 4 (%0100) 1 into Carry
	
	movS r2,r0,rrx 	
	;Bits rotated right: 8 becomes 4 - Carry shifted in: 4 becomes C (%1100)
	
	bl MonitorR0R1			;Show the regs (also shows R2 on Risc OS)
	
	
	b infloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
infloop:
	b infloop

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

	