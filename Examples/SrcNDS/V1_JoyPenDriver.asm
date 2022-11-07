
	.ifdef JoyData
	
		mov r3,#0x4000130		;4000136h - NDS7 - EXTKEYIN - Key X/Y Input (R)
		add r3,r3,#0x6
		ldrh r1,[r3]			;--------HP--D-YX

		mov r3,#JoyData
		strh r1,[r3]
		
	.endif		
		
	.ifdef PenData
		mov r4,#0x4000000 		;40001C0h - NDS7 - SPICNT - SPI Bus Control/Status Register
		add r4,r4,#0x01C0 
		mov r3,#0x4000000		;40001C2h - NDS7 - SPIDATA - SPI Bus Data/Strobe Register (R/W)
		add r3,r3,#0x01C2 
		
		;         SCCCcrpp
		mov r1,#0b10010100		;Get Ypos
		bl GetOnePen
		mov r5,#PenData+4		;Store Ypos
		strh r6,[r5]
		
		;         SCCCcrpp
		mov r1,#0b11010100		;Get Xpos
		bl GetOnePen
		mov r5,#PenData			;Store Xpos
		strh r6,[r5]
	.endif		
	b Arm7_InfLoop

	;Get an AXIS - R1=SCCCcrpp (Ypos=0b10010100 Xpos=SCCCcrpp)
GetOnePen:				
	STMFD sp!,{lr}		
	;Select Touchscreen device
				 ;ei--ctddb-----bb
		mov r0,#0b1000101000000001	;Get 1st byte
		strh r0,[r4]	;40001C0h - NDS7 - SPICNT - SPI Bus Control/Status Register

	;Select Channel from R1 (Ypos / Xpos)		
	;         SCCCcrpp
		strh r1,[r3]	;40001C2h - NDS7 - SPIDATA - SPI Bus Data/Strobe Register (R/W)
		bl spiwait
		bl spiwait0		
		
	;Get 1st Byte
		ldrb r6,[r3]	;40001C2h - NDS7 - SPIDATA - SPI Bus Data/Strobe Register (R/W)
		mov r6,r6,lsl #3
		
	;Toggle to 2nd byte
				 ;ei--ctddb-----bb
		mov r0,#0b1000001000000001	;Get 2nd Byte
		strh r0,[r4]	;40001C0h - NDS7 - SPICNT - SPI Bus Control/Status Register
		bl spiwait0	
		
	;Get 2nd byte
		ldrh r1,[r3]	;40001C2h - NDS7 - SPIDATA - SPI Bus Data/Strobe Register (R/W)
		orr r6,r6,r1,lsr #4	
	LDMFD sp!,{pc}		

spiwait0:	
		mov r0,#0	
		strh r0,[r3]			;40001C2h - NDS7 - SPIDATA - SPI Bus Data/Strobe Register (R/W)
spiwait:
SpiBusy:		
		ldr r0,[r4]				;40001C0h - NDS7 - SPICNT - SPI Bus Control/Status Register
					 ;ei--ctddb-----bb
		ands r0,r0,#0b0000000010000000
		bne SpiBusy
	MOV pc,lr
