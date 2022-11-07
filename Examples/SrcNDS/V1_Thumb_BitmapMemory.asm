
ScreenInit:
	push {r0-r7, lr}
		ldr r0,PowCnt1
		;add r0, r0, #0x304	; - NDS9 - POWCNT1 - Graphics Power Control Register (R/W)
  
		ldr r1, PowEna	;2D + Enable
		str r1, [r0,#0]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		ldr r0, DispCnt	;4000000h - DISPCNT - LCD Control (Read/Write)
		ldr r1, LcdOn
		str r1, [r0,#0]	;2  Engine A only: VRAM Display (Bitmap from block selected in DISPCNT.18-19)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		ldr r0, VRAMCntA
		mov r1, #0x80	;Enable
		strb r1, [r0,#0]	;4000240h - NDS9 - VRAMCNT_A - 8bit - VRAM-A (128K) Bank Control (W)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
		; loop
		ldr r0, ScreenVram
				;  -BBBBBGGGGGRRRRR
		ldr r1, fillcolor
		
		ldr r2, ScreenPixelCount
 
ClearScreen:
		strh r1, [r0,#0]	;Store+inc
		add r0,r0,#2
		sub r2, r2, #1
		bne ClearScreen
	pop {r0-r7, pc}
	
	
	
	.align 4
fillcolor:
	.long 0b1011110000000000
DispCnt:
	.long 0x04000000
VRAMcntA:
	.long 0x04000240
PowCnt1:
	.long 0x04000304
ScreenVram:
	.long 0x06800000
PowEna:
	.long 0x8003
LcdOn:
	.long 0x00020000
ScreenPixelCount:
	.long 0x18000


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

.equ RamArea,0x02F00000
.equ CursorX,RamArea+0
.equ CursorY,RamArea+1

adrCursorX:
	.long CursorX
adrCursorY:
	.long CursorY
screenram:
	.long 0x06800000
LineSize:
	.long 256*8*2
LineSize2:
	.long 512-16
FontColor:
	.long 0b0000001111111111
BitMask:
	.long 0b100000000
BitmapFontAddress:
	.long BitmapFont