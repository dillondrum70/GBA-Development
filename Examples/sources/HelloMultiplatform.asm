	.include "\SrcALL\V1_Header.asm"

;.equ Bmp256, 1	;256 color mode - GBA only	
	
	bl ScreenInit
	
	
	bl monitor
	
	
	mov r1,#20	;x
	mov r2,#100	;y
	bl GetScreenPos			;Get Screen address
	ldr r1,SpriteAddress
	mov r6,#48				;Height
Sprite_NextLine:	
.ifdef BuildROS
	mov r5,#48/2			;Width
.else
	.ifdef Bmp256
		mov r5,#48/2		;Width in WORDS  (Pixels/2)
	.else
		mov r5,#48			;Width
	.endif
.endif
	STMFD sp!,{r10}
Sprite_NextByte:
		.ifdef BuildROS
			ldrB r0,[r1],#1		;Copy a byte to the screen
			strB r0,[r10],#1
		.else
			ldrH r0,[r1],#2		;Must write 16/32bit on GBA
			strH r0,[r10],#2
		.endif
		subs r5,r5,#1
		bne Sprite_NextByte
	LDMFD sp!,{r10}		
	bl GetNextLine				;Move down a line
	subs r6,r6,#1
	bne Sprite_NextLine

	

	
	;b infloop
	ldr r1,HelloWorldAddress
	bl PrintString


	ldr r10,PaletteAddress
	mov r0,#0
PaletteAgain:
	ldr r1,[r10],#2
	bl SetPalette
	add r0,r0,#1
	cmp r0,#16
	bne PaletteAgain
	
	
	adr	r0,infloop		;Address
	mov r1,#2			;Lines
	bl MemDump
	
	
	
infloop:
	b infloop
	
PrintString:
	STMFD sp!,{r0-r12, lr}
PrintStringAgain:
		ldrB r0,[r1],#1
		cmps r0,#255
		beq PrintStringDone
		bl printchar 
		b PrintStringAgain
PrintStringDone:
	LDMFD sp!,{r0-r12, pc}
	
	
HelloWorldAddress:
	.long HelloWorld
	
HelloWorld:
	.byte "Hello World",255
	.align 4
SpriteAddress:
	.long SpriteTest
PaletteAddress:
	.long Palette
	
	

	
	.include "/srcALL/V1_Monitor.asm"
	.include "/srcALL/V1_BitmapMemory.asm"

BitmapFont:
	.incbin "\ResALL\Font96.FNT"
	
SpriteTest:

		
		
	.ifdef BuildGBA
		.ifdef Bmp256
			.incbin "\ResALL\SpriteGBA.RAW"	;256 Color sprite
		.else
			.incbin "\ResALL\SpriteNDS.RAW"	;ARGB 16bpp sprite
		.endif			
	.endif

	
	.ifdef BuildROS
		.incbin "\ResALL\SpriteROS.RAW"	;16 color sprite
		;.incbin "\ResALL\SpriteGBA.RAW"	; 256 Color sprite
	.endif
	
	
	.ifdef BuildNDS
		.incbin "\ResALL\SpriteNDS.RAW" ; ARGB 16bpp sprite
		;.incbin "\ResALL\SpriteGBA.RAW"	; 256 Color sprite
	.endif
	
	
Palette:
	.word 0x0250;0  -GRB
	.word 0x0000;1  -GRB
	.word 0x0555;2  -GRB
	.word 0x0AAA;3  -GRB
	.word 0x0FFF;4  -GRB
	.word 0x0826;5  -GRB
	.word 0x0D33;6  -GRB
	.word 0x03E3;7  -GRB
	.word 0x07E6;8  -GRB
	.word 0x0AE5;9  -GRB
	.word 0x0FF4;10  -GRB
	.word 0x02AA;11  -GRB
	.word 0x00FF;12  -GRB
	.word 0x030D;13  -GRB
	.word 0x063B;14  -GRB
	.word 0x0D0F;15  -GRB
	
	
	
.include "\SrcALL\V1_Footer.asm"