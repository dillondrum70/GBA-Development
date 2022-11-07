.include "\SrcALL\V1_Header.asm"

	adr r0,ThumbTest
	add r0,r0,#1		;Bit 0=1 THUMB ON!
	bx r0

	.thumb				;Thumb mode
ThumbTest:
	ldr r1,SPAddress	;Init Stack Pointer	
	mov sp,r1
	
	bl ScreenInit		;Init Screen
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	bl Monitor			;Show the registers to the screen
	
	ldr	r0,SPAddress	;Address
	mov r1,#2			;Lines
	
	bl MemDump			;Show memory onscreen
		
infloop:

	b infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.align 4
SPAddress:
	.long 0x03000000
BitmapFont:
	.incbin "\ResALL\Font96.FNT"
	
	.include "/srcALL/V1_Thumb_BitmapMemory.asm"
	.include "/srcALL/V1_Thumb_Monitor.asm"	
	.include "/srcALL/V1_Thumb_Footer.asm"
	
	
	