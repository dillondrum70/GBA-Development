	
	.org  0x08000 			;Program Start
    
	b RiscOS_Start			;Jump to the start of our program
	
	.space 128				;Space for the stack
Stack:

RiscOS_Start:
	adrl sp,stack			;Load the stack pointer 
	
	ldr r1,HelloWorldAddress	;Address of Hello World Message
	bl PrintString				;Show Message
	
	bl NewLine
	
	bl monitor				;Show Regs
	
	bl NewLine
		
	adr	r0,HelloWorld		;Address
	mov r1,#2				;Lines
	bl MemDump				;Dump to screen
	
    MOV R0,#0            	;0=No  Error
    SWI 0x11				;OS_Exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintChar:
		SWI 0x00			;OS_WriteC - Write Character R0 to Screen
	MOV pc,lr
	
NewLine:
		SWI 0x03			;OS_NewLine - Start a new line (no params) 
	MOV pc,lr
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
PrintString:				;Print 255 terminated string 
	STMFD sp!,{r0-r12, lr}
PrintStringAgain:
		ldrB r0,[r1],#1
		cmps r0,#255
		beq PrintStringDone	;Repeat until 255
		bl printchar 		;Print Char
		b PrintStringAgain
		
PrintStringDone:
	LDMFD sp!,{r0-r12, pc}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
HelloWorldAddress:
	.long HelloWorld		;Pointer to Hello message
	
HelloWorld:
	.byte "Hello World",255
	.align 4	 
	 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.equ MonitorWidth,8
	.include "/srcALL/V1_Monitor.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

