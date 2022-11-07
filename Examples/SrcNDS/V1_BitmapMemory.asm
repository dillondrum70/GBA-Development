
 ;4000304h - NDS9 - POWCNT1 - Graphics Power Control Register (R/W)
  ;0     Enable Flag for both LCDs (0=Disable) (Prohibited, see notes)
  ;1     2D Graphics Engine A      (0=Disable) (Ports 008h-05Fh, Pal 5000000h)
  ;2     3D Rendering Engine       (0=Disable) (Ports 320h-3FFh)
  ;3     3D Geometry Engine        (0=Disable) (Ports 400h-6FFh)
  ;4-8   Not used
  ;9     2D Graphics Engine B      (0=Disable) (Ports 1008h-105Fh, Pal 5000400h)
  ;10-14 Not used
  ;15    Display Swap (0=Send Display A to Lower Screen, 1=To Upper Screen)
  ;16-31 Not used
  
;4000000h - DISPCNT - LCD Control (Read/Write)
;  Bit   Expl.
;  0-2   A+B   BG Mode
  ;3     A     BG0 2D/3D Selection (instead CGB Mode) (0=2D, 1=3D)
  ;4     A+B   Tile OBJ Mapping        (0=2D; max 32KB, 1=1D; max 32KB..256KB)
  ;5     A+B   Bitmap OBJ 2D-Dimension (0=128x512 dots, 1=256x256 dots)
;  6     A+B   Bitmap OBJ Mapping      (0=2D; max 128KB, 1=1D; max 128KB..256KB)
;  7     Forced Blank           (1=Allow FAST access to VRAM,Palette,OAM)
;  8     Screen Display BG0  (0=Off, 1=On)
;  9     Screen Display BG1  (0=Off, 1=On)
;  10    Screen Display BG2  (0=Off, 1=On)
;  11    Screen Display BG3  (0=Off, 1=On)
;  12    Screen Display OBJ  (0=Off, 1=On)
;  13    Window 0 Display Flag   (0=Off, 1=On)
;  14    Window 1 Display Flag   (0=Off, 1=On)
;  15    OBJ Window Display Flag (0=Off, 1=On)
;  16-17 A+B   Display Mode (Engine A: 0..3, Engine B: 0..1, GBA: Green Swap)
;  18-19 A     VRAM block (0..3=VRAM A..D) (For Capture & above Display Mode=2)
;  20-21 A+B   Tile OBJ 1D-Boundary   (see Bit4)
;  22    A     Bitmap OBJ 1D-Boundary (see Bit5-6)
;  23    A+B   OBJ Processing during H-Blank (was located in Bit5 on GBA)
;  24-26 A     Character Base (in 64K steps) (merged with 16K step in BGxCNT)
;  27-29 A     Screen Base (in 64K steps) (merged with 2K step in BGxCNT)
;  30    A+B   BG Extended Palettes   (0=Disable, 1=Enable)
;  31    A+B   OBJ Extended Palettes  (0=Disable, 1=Enable)

;400000Ch - BG2CNT - BG2 Control (R/W) (BG Modes 0,1,2 only)
  ;Bit   Expl.
  ;0-1   BG Priority           (0-3, 0=Highest)
  ;2-3   Character Base Block  (0-3, in units of 16 KBytes) (=BG Tile Data)
  ;4-5   Not used (must be zero) (except in NDS mode: MSBs of char base)
  ;6     Mosaic                (0=Disable, 1=Enable)
  ;7     Colors/Palettes       (0=16/16, 1=256/1)
  ;8-12  Screen Base Block     (0-31, in units of 2 KBytes) (=BG Map Data)
  ;13    BG0/BG1: Not used (except in NDS mode: Ext Palette Slot for BG0/BG1)
  ;13    BG2/BG3: Display Area Overflow (0=Transparent, 1=Wraparound)
  ;14-15 Screen Size (0-3)
	 
	 
;  BGxCNT.Bit7 BGxCNT.Bit2 Extended Affine Mode Selection
;  0           CharBaseLsb rot/scal with 16bit bgmap entries (Text+Affine mixup)
;  1           0           rot/scal 256 color bitmap
;  1           1           rot/scal direct color bitmap

 
	 ;4000020h - BG2PA - BG2 Rot/Scl Param A (dx)
	 ;4000022h - BG2PB - BG2 Rot/Scl Param B (dmx)
	 ;4000024h - BG2PC - BG2 Rot/Scl Param C (dy) 
	 ;4000026h - BG2PD - BG2 Rot/Scl Param D (dmy
  
;These registers are replacing the BG scrolling registers which are used for Text mode, ie. the X/Y coordinates specify the source position from inside of the BG Map/Bitmap of the pixel to be displayed at upper left of the GBA display. The normal BG scrolling registers are ignored in Rotation/Scaling and Bitmap modes.
;  Bit   Expl.
;  0-7   Fractional portion (8 bits)
;  8-26  Integer portion    (19 bits)
;  27    Sign               (1 bit)
;  28-31 Not used	
  
  
ScreenInit:
	STMFD sp!,{r0-r12, lr}
	
;Enable Hardware
		mov r0, #0x4000000
		add r0, r0, #0x304	;4000304h - POWCNT1 Graphics Power Control

		mov r1, #0x8203	;Bit0:Enable + Bit1:2D.A + Bit9:2D.B Bit15:Swap 
		str r1, [r0]

		
;Turn on top screen via Engine A
		mov r0, #0x04000000	;4000000h - DISPCNT.A- LCD Control (Read/Write)
		mov r1, #0x00020000 ;Bit16.17: Display Mode (Engine A):VRAM Display 
		str r1, [r0]
	
;Turn on RAM for top screen		
		mov r0, #0x04000000
		add r0, r0, #0x240
		mov r1, #0x80	;Enable top screen ram
		strb r1, [r0]	;4000240h - VRAMCNT_A - VRAM-A (128K) Bank Control 
	
	
 ;Turn on bottom screen via Engine B
	mov r0, #0x04001000	;4001000h - DISPCNT.B - LCD Control (Read/Write)
	mov r1, #0x00010400 ;Bit10: BG2 ON - Bit16.17: Display Mode.B: Tile+Sprite Bit 
	add r1,r1,#5		;Bit0-2: EngineB: BG Mode 5 (Bg2=Affine)
	str r1, [r0]

 
	mov r0,#0x04001000	
	add r0,r0,#0xC		;400000Ch - BG2CNT - BG2 Control (R/W) (BG Modes 0,1,2 only)
	
			 ;FEDCBA9876543210
	mov r1,#0b0100000010000100	;Bit2+7: RotScale 32k color. Bit14.15: Scrn Sz 256x256
	strh r1, [r0] 

	 
	mov r2,#0x0100		;Setting params for Affine
	mov r1,#0
	
;Set Layer Pos
	mov r0,#0x4001000
	add r0,r0,#0x28		;4000028h+ Affine Layer start pos
	 
	strh r1,[r0],#2	;0...4000028h - BG2X_L - BG2 RefPt X L
	strh r1,[r0],#2	;0...400002Ah - BG2X_H - BG2 RefPt X H
	strh r1,[r0],#2	;0...400002Ch - BG2Y_L - BG2 RefPt Y L
	strh r1,[r0],#2	;0...400002Eh - BG2Y_H - BG2 RefPt Y H

;Set Layer Rot/Scale	
	mov r0,#0x4001000	
	add r0,r0,#0x20		;4000020h+ Affine Rotate/Scale Params
	 
	strh r2,[r0],#2	;100.4000020h - BG2PA - BG2 Rot/Scl Param A (dx)
	strh r1,[r0],#2	;0...4000022h - BG2PB - BG2 Rot/Scl Param B (dmx)
	strh r1,[r0],#2	;0...4000024h - BG2PC - BG2 Rot/Scl Param C (dy) 
	strh r2,[r0],#2	;100.4000026h - BG2PD - BG2 Rot/Scl Param D (dmy)
	 
;Turn on RAM for bottom screen
		mov r0, #0x04000000
		add r0, r0, #0x242
		mov r1, #0x84	;Enable bottom screen ram
		strb r1, [r0]	;4000242h - VRAMCNT_C - VRAM-C (128K) Bank Control

		bl cls
		
;Reset Cursor Pos
		mov r0,#0x00
		mov r3,#CursorX		;Reset Cursor pos
		strh r0,[r3]
	LDMFD sp!,{r0-r12, pc}

NewLine:
	STMFD sp!,{r0-r12, lr}
		mov r3,#CursorX
		mov r0,#0
		strB r0,[r3]	;X
		
		mov r3,#CursorY
		ldrB r0,[r3]	;Y
		add r0,r0,#1
		strB r0,[r3]	;Y
	LDMFD sp!,{r0-r12, pc}
	
PrintChar:
	STMFD sp!,{r0-r12, lr}
		mov r4,#0
		mov r5,#0
		
		mov r3,#CursorX
		ldrB r4,[r3]	;X
		mov r3,#CursorY
		ldrB r5,[r3]	;Y
		
		mov r3,#0x06800000 ; VRAM
		
		cmp r5,#24
		movcs r3,#0x06200000 ; VRAM
		subcs r5,r5,#24
		
		mov r6,#16			;Xpos 
		mul r2,r4,r6
		add r3,r3,r2
		
		mov r4,#256*8*2		;Ypos 
		mul r2,r5,r4
		add r3,r3,r2
		
		adr r4,BitmapFont 	;Font source
		sub r0,r0,#32		;First Char is 32 (Space)
		add r4,r4,r0,asl #3	;8 bytes per char
		
		mov r1,#8			;8 lines 
DrawLine:
		mov r7,#8 			;8 pixels per line
		ldrb r8,[r4],#1		;Load Letter
		mov r9,#0b100000000	;Mask

				;  ABBBBBGGGGGRRRRR	A=Alpha
		mov r2, #0b1111111101000000
		
DrawPixel:
		tst r8,r9			;Is bit 1?
		strneh r2,[r3]		;Yes? then fill pixel
		add r3,r3,#2
		mov r9,r9,ror #1	;Bitshift Mask
		subs r7,r7,#1
		bne DrawPixel		;Next Hpixel
		
		add r3,r3,#512-16	;Move Down a line
		subs r1,r1,#1
		bne DrawLine		;Next Vline
		
		mov r3,#CursorX
		ldrB r0,[r3]	
		add r0,r0,#1		;Move across screen
		strB r0,[r3]	
	LDMFD sp!,{r0-r12, pc}

	
GetScreenPos: ;R1,R2 = X,Y
	STMFD sp!,{r2}
		STMFD sp!,{r1}
			mov r10,#0x06800000   ;Upper Screen VRAM
			
			cmp r2,#192			  ;Line 192+ on lower screen
			movcs r10,#0x06200000 ;Lower Screen VRAM
			subcs r2,r2,#192
			
			mov r1,#512		;Ypos * 256*2 
			mul r2,r1,r2
		LDMFD sp!,{r1}	
		add r10,r10,r2 
		add r10,r10,r1		;Xpos * 2 (2 bytes per pixel)
		add r10,r10,r1
	LDMFD sp!,{r2}
	MOV pc,lr
	
GetNextLine:
	add r10,r10,#512		;256 pixels per line 
	MOV pc,lr
	
	
SetPalette:		;Not needed in 16bpp mode
	STMFD SP!,{R0-R12, LR}
		mov r11,#0x05000400  ; palette register address for Engine B
		add r11,r11,r0,asl #1

		;bl monitor
		mov r2,r1,asl #11				;B
				 ;----GGGGRRRRBBBB
		mov r3,#0b0111100000000000
		and r2,r2,r3
		mov r5,r2
		;bl monitor
		
		mov r2,r1,lsr #3			;R
				 ;----GGGGRRRRBBBB
		mov r3,#0b0000000000011110
		and r2,r2,r3
		orr r5,r5,r2
		;bl monitor
		
		mov r2,r1,lsr #2			;G
				 ;----GGGGRRRRBBBB
		mov r3,#0b0000001111000000
				  
		and r2,r2,r3
		orr r5,r5,r2
		
		strH r5,[r11]	;-BBBBBGGGGGRRRRR
		;b infloop
	LDMFD sp!,{r0-r12, pc}	
	
cls:
		mov r3,#CursorX
		mov r0,#0
		strB r0,[r3]	;X
		mov r3,#CursorY
		strB r0,[r3]	;Y
		
;Clear Screen
		mov r0, #0x06800000	;Top Screen
		mov r3, #0x06200000 ;Bottom screen
		mov r2, #256*192/2	;Pixels to fill
		
				;  ABBBBBGGGGGRRRRR	A=Alpha
		mov r1, #0b1000000010001010	;Color
		add r1,r1,#0x808A0000
CLS_loop:
		str r1, [r0],#4	;Clear Top Screen
		str r1, [r3],#4	;Clear Bottom Screen
		subs r2, r2, #1
		bne CLS_loop
	MOV PC,LR

.equ CursorX,RamArea+0
.equ CursorY,RamArea+1