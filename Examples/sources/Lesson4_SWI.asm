	
	.org  0x08000     
	SWI 0x01				;OS_WriteS
	.ascii "Hello World!"
	.byte 0					;End of string
	.align 4
	
    MOV R0,#0            	;0=No Error
    SWI 0x11				;OS_Exit
	 
	 
	 