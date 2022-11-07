	.equ JoyData,RamArea+4	;4 bytes
	
	
	.equ PenData,RamArea+8	;8 Bytes X,Y
	
	.include "\SrcALL\V1_Header.asm"
	
;.equ Bmp256, 1	;256 color mode - GBA only	
	
	bl ScreenInit
Again:	
	bl cls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Risc OS	

	.ifdef BuildROS
	
		mov r0,#129		;Read a key
		mov r1,#16		;Wait Length L Byte (00-FF)
		mov r2,#0		;Wait Length H Byte (Max 7F)
		SWI 0x6			;OSByte
		
		mov r0,r1		;R1=Ascii key press
		bl MonitorR0

;Up Test
		mov r0,#129		;Test a key
		mov r1,#255^57	;Key 57=UP (255 xor key)
		mov r2,#255		;255=No Wait
		SWI 0x6			;OSByte
		
		cmp r1,#255		;255=Pressed 0=Unpressed
		mov r0,#32
		moveq r0,#85	;U
		bl PrintChar
		
;Down Test
		mov r0,#129		;Test a key
		mov r1,#255^41	;Key 41=DOWN (255 xor key)
		mov r2,#255		;255=No Wait
		SWI 0x6			;OSByte

		cmp r1,#255		;255=Pressed 0=Unpressed
		mov r0,#32		;D
		moveq r0,#68	;Move if Equal
		bl PrintChar
		
;Left Test
		mov r0,#129		;Test a key
		mov r1,#255^25	;Key 41=DOWN (255 xor key)
		mov r2,#255		;255=No Wait
		SWI 0x6			;OSByte

		cmp r1,#255		;255=Pressed 0=Unpressed
		mov r0,#32		;L
		moveq r0,#76	;Move if Equal
		bl PrintChar

;Right Test
		mov r0,#129		;Test a key
		mov r1,#255^121	;Key 41=DOWN (255 xor key)
		mov r2,#255		;255=No Wait
		SWI 0x6			;OSByte
		
		cmp r1,#255		;255=Pressed 0=Unpressed
		mov r0,#32		;R
		moveq r0,#82	;Move if Equal
		bl PrintChar	
		
	.endif
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GBA
	
	.ifdef BuildGBA
	
		mov r3,#0x4000130	;GBA Keys 
		ldrh r0,[r3]		;------LRDULRSsBA
		bl MonitorR0		

		mov r1,#5
Delay:
		mov r0,#0x4000004
		ldrh r0,[r0]
		ands r0,r0,#1
		beq Delay			;Wait for Vblank End
Delay2:
		mov r0,#0x4000004
		ldrh r0,[r0]
		ands r0,r0,#1
		bne Delay2			;Wait for Vblank Start
		subs r1,r1,#1
		bne delay
	.endif

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	NDS
		
	.ifdef BuildNDS
		mov r3,#0x4000130	;GBA Keys 
		ldrh r0,[r3]		;------LRDULRSsBA
		bl MonitorR0		
	
		mov r3,#joyData	;Extra NDS buttons only accessible via ARM7 (done by arm7 program)
		ldrh r0,[r3]	;--------HP--D-YX
		bl MonitorR0
		
		bl newline
		
		mov r3,#PenData		;NDS Pen X
		ldr r0,[r3]
		bl MonitorR0
		
		mov r3,#PenData+4	;NDS Pen Y
		ldr r0,[r3]
		bl MonitorR0
 
		mov r1,#5
Delay:
		mov r0,#0x4000004
		ldrh r0,[r0]
		ands r0,r0,#1
		beq Delay			;Wait for Vblank End
Delay2:
		mov r0,#0x4000004
		ldrh r0,[r0]
		ands r0,r0,#1
		bne Delay2			;Wait for Vblank Start
		subs r1,r1,#1
		bne delay
	.endif
	
	b Again
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



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