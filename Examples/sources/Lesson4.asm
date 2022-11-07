.macro ShowstackPlusR1
	mov r8,lr			;back up LR/R14
	bl MonitorR0SPR1		;Show SP+RO+LR
	bl showstack		;Show the stack
.endm

.macro ShowLR
	mov r8,lr			;back up LR/R14
	STMFD sp!,{r0-r12,lr}	;Push Regs
		bl MonitorR0SPLR		;Show SP+RO+LR
	LDMFD sp!,{r0-r12,lr}	;Pop Regs and return	
.endm

.macro ShowstackPlusLR
	mov r8,lr			;back up LR/R14
	bl MonitorR0SPLR		;Show SP+RO+LR
	bl showstack		;Show the stack
.endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.include "\SrcALL\V1_Header.asm"
	bl ScreenInit
	
	mov r9,sp
	
	;b TestPushAnItem
	;b TestPushAnItemNested
	;b TestPushItems
	b TestBranchLink
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestPushAnItem:	
	mov r0,#0xFFEE0000	;Test Value
	add r0,r0,#0xDDCC
	
	ShowstackPlusR1		;Show the stack
	
	str r0, [sp, #-4]!	;Push onto stack 
	
		mov r0,#0
		ShowstackPlusR1		;Show the stack
	
	ldr r0, [sp], #4	;Pop off the stack
	
	ShowstackPlusR1		;Show the stack
	b infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestPushAnItemNested:		
	mov r0,#0xFFEE0000	;Test Value
	add r0,r0,#0xDDCC
	ShowstackPlusR1		;Show the stack

	str r0, [sp, #-4]!	;Push onto stack 
		mov r0,#0x11220000	;Test Value
		add r0,r0,#0x3344
		ShowstackPlusR1		;Show the stack
		
		str r0, [sp, #-4]!	;Push onto stack 
			mov r0,#0
			ShowstackPlusR1		;Show the stack
		
		ldr r0, [sp], #4	;Pop off the stack
		ShowstackPlusR1		;Show the stack
	
	ldr r0, [sp], #4	;Pop off the stack
	ShowstackPlusR1		;Show the stack
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;We can push multiple items with STMFD and LDMFD, We use a comma list eg (r1,r2,r4) and/or a range (r1-r4,r6)
;The order we put the registers in the list doesn't affect the order they are pushed onto the stack.
;But of course if we pop them of into different registers, things could go wrong!
TestPushItems:	
	mov r0,#0xFFEE0000	;Test Value
	add r0,r0,#0xDDCC
	
	mov r1,#0x44330000	;Test Value
	add r1,r1,#0x2211
	
	ShowstackPlusR1		;Show the stack
	
	STMFD sp!,{r0-r1}	;Push Regs 
	
		mov r0,#0
		mov r1,#1
		ShowstackPlusR1		;Show the stack
		
	LDMFD sp!,{r0,r1}	;Pop Regs and return	
	
	;LDMFD sp!,{r1,r0}	;Order doesn't matter	
	;LDMFD sp!,{r1,r2}	;different registers used!
	
	ShowstackPlusR1		;Show the stack
	
	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;We need to back up LR somehow, either into another register (R12?)	or push it onto the stack (Saferst)

TestBranchLink:
	mov r0,#0	
	bl BranchLinkTest
	bl BranchLinkTest
	;bl NestedBLTestBAD	;This will not work
	bl NestedBLTestGOOD
	
	ShowLR			;Show Results
	b infloop
	
BranchLinkTest:	
	add r0,r0,#1	;INC R0
	ShowLR			;Show Results
	mov pc,lr		;Return statement (RET)

NestedBLTestGOOD:		
	str lr, [sp, #-4]!	;Push LR/R14 onto stack (nested CALL)
	
		bl BranchLinkTest
		bl BranchLinkTest
		add r0,r0,#0xFF000000 ;This will happen fine
		
	ldr pc, [sp], #4	;Pop PC/R15 off the stack (RET)
		
;This will not work... the nested BL will corrupt LR causing a crash when the return happens
NestedBLTestBAD:	
	add r0,r0,#0x10	;INC R0
	
	bl BranchLinkTest	;Calling this trashes LR
	
	bl BranchLinkTest	;This will never happen 
	add r0,r0,#0xFF000000 ;This will never happen
	mov pc,lr			;This will never happen


	
	
infloop:
	b infloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showstack:
	STMFD sp!,{r0-r12, lr}	;Push Regs
		sub r9,r9,#16
		mov r1,#2			;Lines
		mov r0,r9
		bl MemDump		
		bl NewLine
	LDMFD sp!,{r0-r12, pc}	;Pop Regs and return	
	;MOV pc,lr
	;mov r15,r14
	
	
MonitorFlags:
	STMFD sp!,{r0-r12, lr}	;Push Regs
	STMFD sp!,{r0,r1}		;Push Regs
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

MonitorR0SPR1:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		bl MonitorR0
		bl MonitorR1
		bl MonitorSP
		bl newline	
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return

MonitorR0SPLR:
	STMFD sp!,{r0-r12, lr}			;Push Regs
		bl MonitorR0
		bl MonitorSP
		bl MonitorLR
		bl newline	
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
	
MonitorSP:	;put SP into r10
	mov r10,sp
	STMFD sp!,{r0-r12, lr}			;Push Regs
		mov r0,#83					;Letter S
		bl PrintChar
		mov r0,#80 					;Letter P
		bl PrintChar
		mov r0,#58 					;Ascii :
		bl PrintChar
		
		mov r0,r10
		bl ShowHex32	
		mov r0,#32 					;Ascii Space
		bl PrintChar
	LDMFD sp!,{r0-r12, pc}			;Pop Regs and return
		
MonitorLR:	;put LR into r8
	
	STMFD sp!,{r0-r12, lr}			;Push Regs
		
		mov r0,#76					;Letter L
		bl PrintChar
		mov r0,#82					;Letter R
		bl PrintChar
		mov r0,#58 					;Ascii :
		bl PrintChar
		
		mov r0,r8
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

	