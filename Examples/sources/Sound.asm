	.equ JoyData,RamArea+4	;4 bytes
	
	
	.equ PenData,RamArea+8	;8 Bytes X,Y
	.equ ChibiSoundb,RamArea+16	;2 Bytes

	
	.include "\SrcALL\V1_Header.asm"
	
;.equ Bmp256, 1	;256 color mode - GBA only	
	
	bl ScreenInit
			; NVPPPPPP
	mov r0,#0b00000000
	
Again:	
	
	add r0,r0,#1
	bl ChibiSound
	
	STMFD sp!,{r0}			;Push Regs
		bl MonitorR0
		

		mov r1,#5
Delay:
		mov r2,#0x4000004
		ldrh r2,[r2]
		ands r2,r2,#1
		beq Delay			;Wait for Vblank End
		
		
Delay2:
		mov r2,#0x4000004
		ldrh r2,[r2]
		ands r2,r2,#1
		bne Delay2			;Wait for Vblank Start

		subs r1,r1,#1
		bne delay
		
		bl cls
		
	LDMFD sp!,{r0}	
	
	b Again
;SoundAddress:
	;.long Sound
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.include "\SrcALL\V1_ChibiSound.asm"


MonitorR0:	
	STMFD sp!,{lr}			;Push Regs
		bl ShowHex32	
		mov r0,#32 					;Ascii Space
		bl PrintChar
	LDMFD sp!,{pc}			;Pop Regs and return	

	
	.include "/srcALL/V1_Monitor.asm"
	.include "/srcALL/V1_BitmapMemory.asm"

BitmapFont:
	.incbin "\ResALL\Font96.FNT"
	
SpriteTest:

		
	
.include "\SrcALL\V1_Footer.asm"


