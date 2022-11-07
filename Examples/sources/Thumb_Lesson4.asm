
.macro ShowstackPlusR0
	mov r8,lr			;back up LR/R14
	bl MonitorR0SP		;Show SP+RO+LR
	bl showstack		;Show the stack
.endm
.macro ShowstackPlusR0R1LR
	mov r8,lr			;back up LR/R14
	bl MonitorR0R1SPLR		;Show SP+RO+LR
	bl showstack		;Show the stack
.endm
.macro ShowLR
	mov r8,lr			;back up LR/R14
	push {r0-r7}	;Push Regs
		bl MonitorR0R1SPLR		;Show SP+RO+LR
		bl newline
	pop {r0-r7}	;Pop Regs and return	
	mov lr,r8
.endm

.macro ShowstackPlusLR
	mov r8,lr			;back up LR/R14
	bl MonitorR0R1SPLR		;Show SP+RO+LR
	bl showstack		;Show the stack
.endm


.include "\SrcALL\V1_Header.asm"

	adr r0,ThumbTest
	add r0,r0,#1		;Bit 0=1 THUMB ON!
	bx r0

	.thumb				;Thumb mode
ThumbTest:
	ldr r1,SPAddress	;Init Stack Pointer	
	mov sp,r1
	
	bl ScreenInit		;Init Screen

	
	

	mov r9,sp
	
	;b TestPushAnItem
	;b TestPushAnItemNested
	;b TestPushItems
	;b TestMultiItems
	b TestBranchLink
	;b TestSWI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestPushAnItem:	
	ldr r0,TestValue	;Test Value 0xFFEEDDCC
		
	ShowstackPlusR0		;Show the stack
	
	push {r0}			;Push onto stack 
	
		mov r0,#0
		ShowstackPlusR0	;Show the stack
	
	pop {r0}			;Pop off the stack
	
	ShowstackPlusR0		;Show the stack
	
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestPushAnItemNested:		
	ldr r0,TestValue	;Test Value 0xFFEEDDCC
	
	ShowstackPlusR0		;Show the stack

	push {r0}			;Push onto stack 
	
		ldr r0,TestValue2	;Test Value 0x44332211
		
		ShowstackPlusR0		;Show the stack
		
		push {r0}			;Push onto stack 
			mov r0,#0
			ShowstackPlusR0		;Show the stack
		
		pop {r0}			;Pop off the stack
		ShowstackPlusR0		;Show the stack
	
	pop {r0}			;Pop off the stack
	ShowstackPlusR0		;Show the stack
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;We can push multiple items like STMFD and LDMFD, We use a comma list eg (r1,r2,r4) and/or a range (r1-r4,r6)
;The order we put the registers in the list doesn't affect the order they are pushed onto the stack.
;But of course if we pop them of into different registers, things could go wrong!

TestPushItems:	

	ldr r0,TestValue	;Test Value 0xFFEEDDCC
	
	ldr r1,TestValue2	;Test Value 0x44332211
	
	ShowstackPlusR0R1LR		;Show the stack
	
	push {r0-r1}		;Push Regs 
	
		mov r0,#0
		mov r1,#1
		ShowstackPlusR0R1LR		;Show the stack
		
	pop {r0,r1}			;Pop Regs and return	
	
	;POP {r1,r0}	;Order doesn't matter	
	;POP {r1,r2}	;different registers used!
	
	ShowstackPlusR0R1LR		;Show the stack
	
	b infloop


TestMultiItems:	

	ldr r0,TestValue	;Test Value 0xFFEEDDCC
	
	ldr r1,TestValue2	;Test Value 0x44332211
	
	ldr r7,MultTest
	bl ShowMultiTest	
	
	stmia r7!,{r0-r1}		;Store Regs 
	
		mov r0,#0
		mov r1,#1
		bl ShowMultiTest	
				
	ldr r7,MultTest	
	bl ShowMultiTest	
	
	ldmia r7!,{r0,r1}		;Load Regs
	
	;LDMIA r7!,{r1,r0}	;Order doesn't matter	
	;LDMIA r7!,{r1,r2}	;different registers used!
	
	bl ShowMultiTest	
	
	b infloop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;We need to back up LR somehow, either into another register (R12?)	or push it onto the stack (Saferst)

TestBranchLink:
	mov r0,#0	
	bl BranchLinkTest
	bl BranchLinkTest
	bl newline
	;bl NestedBLTestBAD	;This will not work
	bl NestedBLTestGOOD
	
	ShowLR				;Show Results
	b infloop
	
BranchLinkTest:	
	add r0,r0,#1		;INC R0
	ShowLR				;Show Results
	mov pc,lr			;Return statement (RET)

NestedBLTestGOOD:		
	push {lr}			;Push LR/R14 onto stack (nested CALL)
	
		bl BranchLinkTest
		bl BranchLinkTest
		mvn r0,r0		;This will happen fine
		
	pop {pc}			;Pop PC/R15 off the stack (RET)
		
;This will not work... the nested BL will corrupt 
		;LR causing a crash when the return happens
		
NestedBLTestBAD:	
	add r0,#0x10		;increase R0
	
	bl BranchLinkTest	;Calling this trashes LR
	bl BranchLinkTest	
	
	mvn r0,r0		 	;This will never happen
	mov pc,lr			;This will never happen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestSWI:
	SWI 10
	
	bl Monitor
	b infloop
	
	
infloop:
	b infloop
	
	.align 4
TestValue:
	.long 0xFFEEDDCC	
TestValue2:
	.long 0x44332211
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ShowMultiTest:
	push {r0-r7, lr}	;Push Regs
		push {r7}
			mov r6,#0
			mov r7,r0
			bl ShowReg ;ShowReg R6=R7
			
			mov r6,#1
			mov r7,r1
			bl ShowReg ;ShowReg R6=R7
			
			bl newLine
			
			mov r6,#7
		pop {r7}
		bl ShowReg ;ShowReg R6=R7
		
		mov r6,#13
		mov r7,sp
		bl ShowReg ;ShowReg R6=R7
			
		bl newLine
		
		ldr r7,MultTest
		mov r1,#2		;Lines
		mov r0,r7
		bl MemDump		
		bl NewLine
	pop {r0-r7, pc}		;Pop Regs and return	

showstack:
	push {r0-r7, lr}	;Push Regs
		mov r7,r9
		sub r7,#12
		mov r1,#2		;Lines
		mov r0,r7
		bl MemDump		
		bl NewLine
	pop {r0-r7, pc}		;Pop Regs and return	
	;MOV pc,lr
	;mov r15,r14

MonitorR0SP:	
	push {r0-r7, lr}			;Push Regs
		mov r6,#0
		mov r7,r0
		bl ShowReg ;ShowReg R6=R7
		
		mov r6,#13
		mov r7,sp
		bl ShowReg ;ShowReg R6=R7
				
		bl newline	
	pop {r0-r7, pc}				;Pop Regs and return
	
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

	
MonitorR0R1SPLR:
	push {r0-r7, lr}			;Push Regs
		mov r6,#0
		mov r7,r0
		bl ShowReg ;ShowReg R6=R7
		mov r6,#1
		mov r7,r1
		bl ShowReg ;ShowReg R6=R7		
		
		bl newline	
		
		mov r6,#13
		mov r7,sp
		bl ShowReg ;ShowReg R6=R7
		
		mov r6,#14
		mov r7,r8	;LR backed up in R8
		bl ShowReg ;ShowReg R6=R7
		
		bl newline	
	pop {r0-r7, pc}				;Pop Regs and return

	
	.align 4
SPAddress:
	.long 0x03000000
MultTest:
	.long 0x02F01000
	
	.align 4

BitmapFont:
	.incbin "\ResALL\Font96.FNT"
	
	.include "/srcALL/V1_Thumb_BitmapMemory.asm"
	.include "/srcALL/V1_Thumb_Monitor.asm"
	
	.include "/srcALL/V1_Thumb_Footer.asm"