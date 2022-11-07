
	.include "\SrcALL\V1_Header.asm"
	bl ScreenInit

	;b TestRegAddSub	;Test Basic Register values: MOV,ADD,SUB
	;b TestReadWriteRam	;Test Reading And Writing Ram
	b TestReadWriteRamB
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

;Lets learn how to set the values in Registers with the MOVe command.
;This command takes 2 parameters, the one on the left is the destination register... 
;the value on the right is the source
	
;All registers on the arm are 32 bit, but we can only set 16 bits in a single Operation 
;this is because of the structure of the bytecode

TestRegAddSub:	;Test Basic Register values: MOV,ADD,SUB
	
	mov r0,#0x00001234		;Load a hex into a register
	
	mov r1,#0x12340000		;Load a hex into a register
	
	bl MonitorR0R1			;Show the regs (also shows R2 on Risc OS)
	
	;We can only load 4 digits at a time, so this won't work
	;mov r0,#0x12345000	
	
	
	;MOV Rx,Val RX <- Val
	mov r0,#0x12340000		;Load a hex into a register
	
	mov r1,#0b10101010		;Load a binary into a register (0xAA)
	
	;We can't directly load Ascii into a register (grr)
	mov r2,#65				;Ascii A - Decimal 	(0x41)
			
	bl MonitorR0R1	;Show the regs (also shows R2 on Risc OS)
	
	bl NewLine
	
	mov r0,r2
	
	bl MonitorR0R1		;Show the regs (also shows R2 on Risc OS)
	bl NewLine
	
	;This only works on Arm 3+
	
;We can only directly set 16 bits of a 32 bit register - if we need to set all 32, we'll need to do a pair of commands.
;We can use ADD to add a second immediate value 
;Of course we also have SUBtract commands

	mov r0,#0x12340000		;load 12340000 into a register 
	bl MonitorR0R1	
	
	;ADD Rx,Rn,Val Rx=Rn+Val
	add r0,r0,#0x00005678	;add R0 + 0x5678... store result in R0
	bl MonitorR0R1	
	add r1,r0,#0x00000001	;add 1 to R0 and store result in R1 (R0 unchanged)
	
	bl MonitorR0R1			;Show the regs (also shows R2 on Risc OS)
	
	;SUB Rx,Rn,Val Rx=Rn-Val
	sub r0,r0,#0x10000000	;Subtract from R0
	bl MonitorR0R1	
	sub r1,r1,#0x00000001   ;Subtract 1
	
	bl MonitorR0R1			;Show the regs (also shows R2 on Risc OS)
	
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;We can load a register from a label with LDR, and store it back with STR
TestVal: 
	.long 0xFEDCBA98
	.align 4	
TestReadWriteRam:	;Test Reading And Writing Ram

	bl ShowTestRam		;show 'TestVal' ram
	bl newline
	
	bl MonitorR0R1
	
	ldr r0,TestVal		;Load r0 from address TestVal
	bl MonitorR0R1
	
	add r0,r0,#1		;add 1 to R0
	bl MonitorR0R1
	
	str r0,TestVal		;Store R0 into the address TestVal
	bl MonitorR0R1
	
	bl newline
	bl ShowTestRam		;show 'TestVal' ram
	
	bl newline
	bl newline
	
	mov r0,#0
	
	bl ShowTestRam	;show 'UserRam' ram
	bl newline
	
	adr r2,testval		;Load the address of TestVal into r2
	
	ldr r1,[r2]			;Load r1 from the address in r2
	
	bl MonitorR0R1		;Show the regs (also shows R2 on Risc OS)
	
	mov r0,#0x00122100	;Move a test value into R0
	
	mov	r2,#userram		;Move the address userram into R0... 
							;userram isn't a label (it's a symbol)
							;so we can't use ADR
	
	str r0,[r2]			;Store R0 into the address in R2
	
	bl MonitorR0R1		;Show the regs (also shows R2 on Risc OS)
	bl newline
	
	bl ShowUserRam	;show 'UserRam' ram
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestReadWriteRamB:	;Test Reading And Writing Ram
			
	bl ShowTestRam		;show 'TestVal' ram
	bl newline
	
	mov r0,#0xFFFF0000	;Reset R0
	add r0,r0,#0xFFFF	;Reset R0
	bl MonitorR0R1		;Show the regs (also shows R2 on Risc OS)
	
	ldrB r0,TestVal		;Load BYTE r0 from address TestVal
	
	bl MonitorR0R1		
	
	add r0,r0,#0xFF		;add a value 
	strB r0,TestVal		;Store BYTE R0 into the address in R2
							
	bl MonitorR0R1		;Show the regs (also shows R2 on Risc OS)

	bl newline
	bl ShowTestRam		;show 'TestVal' ram
	
	b infloop


infloop:
	b infloop

.align 4				;We need to make sure we're aligned to a 32 bit boundsry
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ShowTestRam:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		adr	r0,testval		;Address
		mov r1,#1			;Lines
		bl MemDump
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ShowUserRam:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov	r0,#userram
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

	