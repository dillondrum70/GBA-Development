

ScreenInit:
;Turn on the screen - ScreenMode 3 - 240x160 16 bit color
	push {r0-r6, lr}
		ldr r4,screenaddr  	;DISPCNT -LCD Control
		ldr r2,screensetting    		;4= Layer 2 on / 3= ScreenMode 3
		str	r2,[r4,#0]         	

		;Fill the screen	
		ldr r0,screenram	;Screen Ram
			
		ldr r1,screencolor
		mov r2, #192
		lsl r2,r2,#8 	;*256

FillScreenLoop:
		strh r1,[r0,#0]		;Store+inc 2 bytes
		add r0,#2
		sub r2, #1		
		bne FillScreenLoop	
		
	pop {r0-r6, pc}

	.align 4
screencolor:
	.long 0b1000000010001010	;  ABBBBBGGGGGRRRRR	A=Alpha
screenaddr:
	.long 0x04000000
screensetting:
	.long 0x403

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	

	  
NewLine:
	push {r0-r6, lr}
		ldr r3,adrCursorX
		mov r0,#0
		strB r0,[r3,#0]	;X
		
		ldr r3,adrCursorY
		ldrB r0,[r3,#0]	;Y
		add r0,r0,#1
		strB r0,[r3,#0]	;Y
	pop {r0-r6, pc}
	
	.equ MonitorWidth,6
;	.include "/srcALL/V1_Monitor.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintString:					;Print 255 terminated string 
	push {r0-r6, lr}
PrintStringAgain:
		ldrB r0,[r1,#0]
		add r1,#1
		cmp r0,#255
		beq PrintStringDone		;Repeat until 255
		bl printchar 			;Print Char
		b PrintStringAgain
PrintStringDone:
	pop {r0-r6, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
PrintChar:
	push {r0-r7, lr}
		mov r4,#0
		mov r5,#0
		
		ldr r3,adrCursorX		;LDR Rd, [pc, #immed_8x4]
		ldrB r4,[r3,#0]	;X
		
		ldr r3,adrCursorY
		ldrB r5,[r3,#0]	;Y
		
		ldr r3,screenram ;#0x06000000 ; VRAM
		
		mov r6,#16			;Xpos 
		mul r6,r4
		add r3,r3,r6
		
		ldr r6,LineSize		;Ypos 
		mul r6,r5
		add r3,r3,r6
		
		ldr r4,BitmapFontAddress 	;Font source
		sub r0,#32		;First Char is 32 (Space)
		lsl r0,r0,#3
		add r4,r4,r0 ;r4,r0,asl #3	;8 bytes per char
		
		
		ldr r2, FontColor
		
		
		
		mov r6,#8			;8 lines 
DrawLine:
		mov r7,#8 			;8 pixels per line
		ldrb r1,[r4,#0]		;Load Letter
		add r4,#1
		ldr r5,BitMask	;Mask

				;  ABBBBBGGGGGRRRRR	A=Alpha
		
DrawPixel:
		tst r1,r5			;Is bit 1?
		beq DrawPixelSkip 
		strh r2,[r3,#0]		;Yes? then fill pixel
DrawPixelSkip:		
		add r3,r3,#2
		lsr r5,r5,#1	;Bitshift Mask
		sub r7,r7,#1
		bne DrawPixel		;Next Hpixel
		ldr r0,LineSize2
		add r3,r3,r0	;Move Down a line
		sub r6,r6,#1
		bne DrawLine		;Next Vline
		
		ldr r3,adrCursorX
		ldrB r0,[r3,#0]	
		add r0,r0,#1		;Move across screen
		strB r0,[r3,#0]	
	pop {r0-r7, pc}

	.align 4
adrCursorX:
	.long CursorX
adrCursorY:
	.long CursorY
screenram:
	.long 0x06000000
LineSize:
	.long 240*8*2
LineSize2:
	.long 480-16
FontColor:
	.long 0b1111111101000000
BitMask:
	.long 0b100000000
BitmapFontAddress:
	.long BitmapFont
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	