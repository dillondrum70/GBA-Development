;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Source: https://www.chibialiens.com/arm/helloworld.php#LessonH2
.EQU Ram, 0x02000000	;RAM on the GBA starts at 0x02000000, builds upwards, can store whatever we want whereever we want, just make sure it doesn't collide with other data in RAM or with Stack which builds down from 0x03000000

.EQU CursorX, Ram+32	;32 bits past ram start
.EQU CursorY, Ram+33	;1 bit past CursorX
.EQU PlayerX, Ram+34	;Player's x position
.EQU PlayerY, Ram+35	;Player's y position

.EQU PlayerWidth, 16
.EQU PlayerHeight, 16

.EQU ScreenXBound, 240
.EQU ScreenYBound, 160

.EQU VramBase, 0x06000000	;Base of VRAM, where address of data that is written to the screen starts

.ORG 0x08000000	;GBA ROM (the cartridge) Address starts at 0x08000000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.EQU InputLocation, 0x04000130	;Location in memory where input is stored

;OR these masks with data at input location to get input, returns 0 if pressed
.EQU Key_A, 			0b0000000000000001				
.EQU Key_B, 			0b0000000000000010
.EQU Key_Select, 		0b0000000000000100
.EQU Key_Start, 		0b0000000000001000
.EQU Key_Right, 		0b0000000000010000
.EQU Key_Left, 			0b0000000000100000
.EQU Key_Up, 			0b0000000001000000
.EQU Key_Down, 			0b0000000010000000
.EQU Key_RightBump, 	0b0000000100000000
.EQU Key_LeftBump, 		0b0000001000000000

.EQU MaskKey, 			0b1111110000000000	;Mask out other bits

.EQU BackgroundColor, 0b1100001000010000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

B Main	;Branch to start of program

;Source: https://www.chibialiens.com/arm/helloworld.php#LessonH2
;GBA Header
;004h    156   Nintendo Logo    (compressed bitmap, required!)
	.BYTE 0xC8,0x60,0x4F,0xE2,0x01,0x70,0x8F,0xE2,0x17,0xFF,0x2F,0xE1,0x12,0x4F,0x11,0x48     ; C
	.BYTE 0x12,0x4C,0x20,0x60,0x64,0x60,0x7C,0x62,0x30,0x1C,0x39,0x1C,0x10,0x4A,0x00,0xF0     ; D
    .BYTE 0x14,0xF8,0x30,0x6A,0x80,0x19,0xB1,0x6A,0xF2,0x6A,0x00,0xF0,0x0B,0xF8,0x30,0x6B     ; E
    .BYTE 0x80,0x19,0xB1,0x6B,0xF2,0x6B,0x00,0xF0,0x08,0xF8,0x70,0x6A,0x77,0x6B,0x07,0x4C     ; F
    .BYTE 0x60,0x60,0x38,0x47,0x07,0x4B,0xD2,0x18,0x9A,0x43,0x07,0x4B,0x92,0x08,0xD2,0x18     ; 10
    .BYTE 0x0C,0xDF,0xF7,0x46,0x04,0xF0,0x1F,0xE5,0x00,0xFE,0x7F,0x02,0xF0,0xFF,0x7F,0x02     ; 11
    .BYTE 0xF0,0x01,0x00,0x00,0xFF,0x01,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00     ; 12
    .BYTE 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ; 13
    .BYTE 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ; 14
	.BYTE 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1A,0x9E,0x7B,0xEB     ; 15
	
    ;		123456789012
    .ASCII "DRUMMOND.NET";0A0h    12    Game Title       (uppercase ascii, max 12 characters)	
    .ASCII "0000"	;0ACh    4     Game Code        (uppercase ascii, 4 characters)
    .ASCII "00"		;0B0h    2     Maker Code       (uppercase ascii, 2 characters)
	.BYTE 0x96		;0B2h    1     Fixed value      (must be 96h, required!)
	.BYTE 0			;0B3h    1     Main unit code   (00h for current GBA models)
	.BYTE 0			;0B4h    1     Device type      (usually 00h) (bit7=DACS/debug related)
	.SPACE 7		;0B5h    7     Reserved Area    (should be zero filled)
	.BYTE 0			;0BCh    1     Software version (usually 00h)
	.BYTE 0			;0BDh    1     Complement check (header checksum, required!)
	.WORD 0			;0BEh    2     Reserved Area    (should be zero filled)
	.LONG 0			;0C0h    4     RAM Entry Point  (32bit ARM branch opcode, eg. "B ram_start")
	.BYTE 0			;0C4h    1     Boot mode        (init as 00h - BIOS overwrites this value!)
	.BYTE 0			;0C5h    1     Slave ID Number  (init as 00h - BIOS overwrites this value!)
	.SPACE 26		;0C6h    26    Not used         (seems to be unused)
	.LONG 0			;0E0h    4     JOYBUS Entry Pt. (32bit ARM branch opcode, eg. "B joy_start")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
	MOV sp, #0x03000000		;Initialize Stack Pointer, starts at memory address 3000000 on GBA
	
	;Initialize player start position
	MOV r0, #PlayerX
	MOV r6, #50
	STRB r6, [r0]
	
	MOV r0, #PlayerY
	MOV r7, #50
	STRB r7, [r0]
	;MOV r11, #50
	;MOV r12, #50
	
	BL ScreenInit
	
	;"Spawn" player, when using EOR draw method, a copy of the player bitmap will be at the position it starts otherwise
	LDR r5, SpriteTestAddress
	MOV r4, #PlayerHeight
	MOV r3, #PlayerWidth
	MOV r2, r7
	MOV r1, r6
	BL DrawSprite
	
	;LDR r1, AsciiTestAddress1	;Load test address into r1, parameter 1	
	;BL WriteText
	;BL NewLine
	
	;LDR r1, AsciiTestAddress2	;Load test address into r1, parameter 1	
	;BL WriteText
	;BL NewLine
	
	;LDR r1, AsciiTestAddress3	;Load test address into r1, parameter 1	
	;BL WriteText
	;BL NewLine
	
	;LDR r1, AsciiTestAddress4	;Load test address into r1, parameter 1	
	;BL WriteText
	;BL NewLine
	
GameLoop:
		;MOV r1, #Key_Up					;Pass up key mask to input function
		;BL ReadInput					;Call function, value returned in r0
	
		;CMPS r0, #0						;Set flag register to check input
		;MOVE r1, #0b1111110000000000	;Turn blue if up key pressed
		;MOVNE r1, #BackgroundColor		;Stay background gray otherwise
	
		;BL ClearToColor					;Update color
		
		;Load in current player position
		MOV r6, #PlayerX
		LDRB r8, [r6]
		MOV r7, #PlayerY
		LDRB r9, [r7]
		
		LDR r5, SpriteTestAddress
		MOV r4, #PlayerHeight
		MOV r3, #PlayerWidth
		MOV r2, r9
		MOV r1, r8
		BL DrawSprite
	
		MOV r1, #Key_Up
		BL ReadInput
		CMPS r0, #0
		ADDNE r9, r9, #1
	
		MOV r1, #Key_Down
		BL ReadInput
		CMPS r0, #0
		SUBNE r9, r9, #1
		
		;Check greater than lower bound
		MOV r2, #0			;Take 0
		CMPS r9, r2			;Check if right side of player is out of bounds
		MOVLT r9, r2		;If so, move 0 into y position
		
		;Check less than upper bound
		ADD r1, r4, r9		;Sum next position and height
		MOV r2, #ScreenYBound	;Take Screen bound
		CMPS r1, r2				;Check if right side of player is out of bounds
		SUBGT r2, r2, r4		;If so, Subtract height from screen Y bound...
		MOVGT r9, r2			;And move that into y position
	
		MOV r1, #Key_Right
		BL ReadInput
		CMPS r0, #0
		SUBNE r8, r8, #1;;;;;;;;;;;;;;;;;;;********For some reason, when key_right is pressed, adding moves it left so I switched the sub and add for left and right, The problem isn't with input because I checked multiple sourdces and they all say the fifth bit is right and the sixth is left
	
		MOV r1, #Key_Left
		BL ReadInput
		CMPS r0, #0
		ADDNE r8, r8, #1;;;;;;;;;;;;;;;;;;;;***********
		
		;Check greater than lower bound
		MOV r2, #0			;Take 0
		CMPS r8, r2			;Check if right side of player is out of bounds
		MOVLT r8, r2		;If so, move 0 into x position
		
		;Check less than upper bound
		ADD r1, r3, r8		;Sum next position and width
		MOV r2, #ScreenXBound	;Take Screen bound
		CMPS r1, r2				;Check if right side of player is out of bounds
		SUBGT r2, r2, r3		;If so, Subtract width from screen x bound...
		MOVGT r8, r2			;And move that into x position
	
		;Update memory with new position
		STRB r8, [r6]
		STRB r9, [r7]
	
		LDR r5, SpriteTestAddress
		MOV r4, #PlayerHeight
		MOV r3, #PlayerWidth
		MOV r2, r9
		MOV r1, r8
	
		BL DrawSprite
		
		;Slow down frame rate (otherwise it looks very glitchy and everything moves too fast)
		MOV r0, #0x1FFF
		Delay:
			SUBS r0, r0, #1
			BNE Delay
	
	B GameLoop
	
AsciiTestAddress1:
	.LONG AsciiTest1	;Address of Ascii string
AsciiTest1:
	.BYTE " !\"#$%&'()*+,-./0123456789:;<=",255	;All characters in font, 255 terminated
	;.BYTE "Test f",255
	.ALIGN 4	;Align to 4 bytes
	
AsciiTestAddress2:
	.LONG AsciiTest2
AsciiTest2:
	.BYTE ">?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[",255
	.ALIGN 4
	
AsciiTestAddress3:
	.LONG AsciiTest3
AsciiTest3:
	.BYTE "\\]^_`abcdefghijklmnopqrstuvwxy",255
	.ALIGN 4
	
AsciiTestAddress4:
	.LONG AsciiTest4
AsciiTest4:
	.BYTE "z{|}~",255
	.ALIGN 4
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Bitmap includes

SpriteTestAddress:
	.LONG SpriteTest
SpriteTest:
	.incbin "\Bitmaps\StickPlayer.RAW"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ScreenInit:
	STMFD sp!, {r0-r3, lr}
		;Actual screen initialization, tells console which mode we're in
		MOV r3, #0x04000000		;DISPCNT - LCD Control
		MOV r2, #0x403			;4 = Layer 2 on, 3 = ScreenMode 3 
		STR r2, [r3]			;Store layer and screen mode in LCD Control address
		
		;MOV r0, #BackgroundColor		;Color to fill
		;BL ClearToColor
	LDMFD sp!, {r0-r3, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r1 = color halfword
ClearToColor:
	STMFD sp!, {r1-r3, lr}
		MOV r3, #VramBase	;Start with vram base
		MOV r2, #240*160	;Take number of pixels in screen
		
FillScreen:
		STRH r1, [r3], #2	;Store halfword (color) into position in vram and increment it by 2 bytes (to next pixel)
		SUBS r2, r2, #1		;Decrement and set signs of loop counter
		BNE FillScreen		;Loop to fill screen
		
	LDMFD sp!, {r1-r3, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r1 = X, r2 = Y
;Return VRAM position of (x,Y)
;Based on https://www.chibialiens.com/arm/platform.php#LessonP2
GetScreenPos:
	STMFD sp!, {r1-r4, lr}
		MOV r0, #VramBase	;Vram
		MOV r3, #240*2		;bytes in a line (should be 240 * 2, but y position keeps getting shifted down by an extra factor of 2)
		MUL r2, r3, r2		;Multiply Y by line byte count
		ADD r0, r0, r2		;Add number of bytes for y position
		MOV r4, #2			;Move 2 into r4
		MUL r1, r4, r1		;Multiply x by 2, 2 bytes per pixel
		ADD r0, r0, r1		;Add number of bytes for x position
	LDMFD sp!, {r1-r4, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r1 = current VRAM position
;Return VRAM position shifted down one line
;https://www.chibialiens.com/arm/platform.php#LessonP2
GetNextLine:
	ADD r0, r1, #240*2		;Simple add
	MOV pc, lr				;Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r1 = x position
;r2 = y position
;r3 = width
;r4	= height
;r5 = SpriteAddress
;Based on https://www.chibialiens.com/arm/platform.php#LessonP2
;Redesigned slightly, GetNextLine was extracted into it's own function
DrawSprite:
	STMFD sp!, {r1-r8, lr}
		;x and y position already in r1 and r2
		BL GetScreenPos
		
		MOV r7, r0
		
		SpriteNextLine:
			STMFD sp!, {r3, r7}		;Store width and current leftmost position in line of the bitmap, width (r3) acts as a counter and needs to be reset, VRAM location (r7) must be at farthest left position when we call GetNextLine since it only really moves the VRAM down one pixel, not back to the beginning of the line
			SpriteNextPixel:
				LDRH r8, [r5], #2	;Load value of pixel from RAW file then increment to next pixel in file
				LDRH r6, [r7]		;Load value currently in VRAM
				EOR r8, r8, r6		;XOR current value in VRAM with value in file (erases bitmap if it has already been drawn, faster than redrawing screen)
				STRH r8, [r7], #2	;Store value previously taken from RAW file into VRAM and increment to next VRAM pixel
			
				SUBS r3, r3, #1		;Decrement width as loop counter
			BNE SpriteNextPixel		;Exit loop once at end of width
			LDMFD sp!, {r3, r7}
			
			;GetNextLine doesn't save any registers, we just need the one line to change the value in r1 so we manage memory outside of the function
			STMFD sp!, {r1}		;Save r1 so it can be used as a parameter again
				MOV r1, r7			;Move y position into r1 and pass into GetNextLine
				BL GetNextLine
				MOV r7, r0			;Move returned value back into r7
			LDMFD sp!, {r1}		;Load r1 back so we don't lose the parameter passed to DrawSprite
			
			SUBS r4, r4, #1		;Decrement height
		BNE SpriteNextLine		;Exit once at end of height
	LDMFD sp!, {r1-r8, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Use E conditional to check if pressed
;r1 = key mask
;Returns keymask in r0
ReadInput:
	STMFD sp!, {r1-r2, lr}
		EOR r0, r0, r0
		MOV r2, #InputLocation	;Input memory location
		LDRH r0, [r2]			;Get value of input, (1 = not pressed)
		MOV r2, #MaskKey		;Mask out superfluous bits
		BIC r0, r0, r2			;Inverse AND the register to only keep input bits (last 10 bits)
		AND r0, r0, r1			;AND return register with input bits with the passed key mask
	LDMFD sp!, {r1-r2, pc}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Source: https://www.chibialiens.com/arm/helloworld.php#LessonH2
;Comments added by me, Dillon Drummond
NewLine:
	STMFD sp!, {r0-r1, lr}	;Store stack pointer, registers 0-12, and link register on stack so we don't lose info from the last function
		MOV r0, #CursorX	;Get address of cursor x
		EOR r1, r1, r1		;Clear r1
		STRB r1, [r0]		;Store 0 from r1 in CursorX, move cursor back to left side of screen
		
		MOV r0, #CursorY	;Get Y address
		LDRB r1, [r0]		;Store CursorY valye in r1
		ADD r1, r1, #1		;Add 1 to CursorY
		STRB r1, [r0]		;Store the incremented CursorY vlaue in CursorY, moves cursor down
	LDMFD sp!, {r0-r1, pc}	;Load registers from stack, put link register in program counter to return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Source: https://www.chibialiens.com/arm/helloworld.php#LessonH2
;Comments added by me, Dillon Drummond
;Some changes made
;Paramters: r1 = string address
WriteText:
	STMFD sp!, {r0-r2, lr}
		MOV r2, r1			;Store parameter in temp variable so new parameter can be passed to WriteChar
		
RepeatWriteText:
		LDRB r1, [r2], #1 	;Load byte then shift by 1
		CMPS r1, #255		;Check if char is null terminator
		BEQ WriteTextDone	;If null terminator, exit
		BL WriteChar		;Otherwise, write character
		B RepeatWriteText	;Go back to begining of this block and check if there is another character or if at null terminator
	
WriteTextDone:
	LDMFD sp!, {r0-r2, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Source: https://www.chibialiens.com/arm/helloworld.php#LessonH2
;Comments added by me, Dillon Drummond
;r1 = character to write
WriteChar:
	STMFD sp!, {r0-r12, lr}	;Store registers and link register
		;Clear r4 and r5
		EOR r4, r4, r4
		EOR r5, r5, r5
		
		;Loading address of cursor x and y then loading values into r4 and r5
		MOV r3, #CursorX
		LDRB r4, [r3]
		MOV r3, #CursorY
		LDRB r5, [r3]
		
		;r4 = cursor x position, r5 = cursor y position
		
		MOV r3, #VramBase	;Load VRAM base address in, addresses after this point will modify screen, 2 bytes, half word, 16 bits for color aBBBBBGGGGGRRRRR
		
		;Each char is 8 x 8 pixels
		;Each pixel is 2 bytes
		;8 lines of 16 bytes
		MOV r6, #16		;Bytes in a line of character
		MUL r2, r4, r6	;Multiply cursor x position by 16
		ADD r3, r3, r2	;Add that position to r2 so we are at that x position in VRAM
		
		MOV r4, #240*8*2	;240 pixels per row, 8 lines per char, 2 bytes per pixel, (no longer need cursor x position, can write over r4)
		MUL r2, r5, r4		;cursor y position * bytes per char row (8 screen lines, 240 pixels per line, 2 bytes per pixel)
		ADD r3, r3, r2		;Add number of bytes to move over in x direction (r3) and number of bytes to move down in the y direction (r2) to get final vram position
		
		;I added this, could potentially cause problems
		;Within each 8x8 space for chars, they are offset to the right by one pixel for some reason.  Since r3 is the location in VRAM for each pixel, I know the issue was there, but I do not know WHY it is offset by a byte, just that this shifts it back
		;;;;;;;;;;;;;;;;;;;;;;;
		SUB r3, r3, #2	;Subtract 1 byte from position, solves 1 byte right offset within each char space, may have something to do with indexing at 1 instead of 0
		;;;;;;;;;;;;;;;;;;;;;;;
		
		ADR r4,BitmapFont 	;Load address of font into r4
		
		SUB r1,r1,#32			;Subtract 32 from value in first paramter 
		ADD r4,r4,r1,asl #3		;Add the value to the bitmap font and shift left 3 to multiply by 8 and get address of the passed character (little endian)
		
		MOV r10,#8			;Loop counter for lines
WriteLine:
		MOV r7,#8 			;Loop counter for pixels
		LDRB r8,[r4],#1				;Load bitmap font value into r8
		MOV r9,#0b100000000			;Bitmask gets shifted over 1 through each loop
				
		MOV r2, #0b1111111101000000; Color: ABBBBBGGGGGRRRRR	A=Alpha
DrawPixel:
		TST r8,r9			;Test r8 and r9, CMP but with AND function, uses bitmask on bitmap font to check if current pixel in r3 should be turned on
		STRNEH r2,[r3]		;SToRe if Not Equal Halfword, stores halfword if test is not equal, sets pixel at r3 to the color in r2 by storing value in r2 in the memory at r3
		ADD r3,r3,#2		;Increment r3 by 1 byte
		MOV r9,r9,ror #1	;Rotate bitmask (0b10000000 checks leftmost pixel, 0b01000000 checks the next one, etc.)
		SUBS r7,r7,#1		;Decrement loop counter for pixels, set signs to check if after 8 pixels
		BNE DrawPixel		;Loop for 8 pixels, until zero flag is set
		
		ADD r3,r3,#480-16	;240 pixels * 2 bytes per pixel - 16 
		SUBS r10,r10,#1		;Decrement loop counter for lines, set signs to see if after 8 lines	
		BNE WriteLine		;If zeor flag set, exit.  Otherwise, repeat, go to next line
LineDone:	
		MOV r3,#CursorX		;Get CursorX address
		LDRB r1,[r3]		;Get CursorX value
		ADD r1,r1,#1		;Increment cursor by 1 position
		STRB r1,[r3]		;Store incremented value back in address
		
	LDMFD sp!, {r0-r12, pc}	;Return
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Starts at ASCII number 32, simplifying by starting at 0
;I translated the Presst Start 2P Google Font into 8 element arrays of byte sized hex codes
;This effectively defines an 8x8 bitmap of a character
;Method learned from https://www.chibialiens.com/arm/helloworld.php#LessonH2
BitmapFont:
	.BYTE 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	;0 - Space
	.BYTE 0x70,0x70,0x70,0x60,0x60,0x00,0x60,0x00	;1 - !
	.BYTE 0x00,0x66,0x66,0x66,0x00,0x00,0x00,0x00	;2 - "
	.BYTE 0x00,0x6C,0xFE,0x6C,0x6C,0x6C,0xFE,0x6C	;3 - #
	.BYTE 0x00,0x10,0x7C,0xD0,0x7C,0x16,0xFC,0x10	;4 - $
	.BYTE 0x00,0x62,0xA4,0xC8,0x10,0x26,0x4A,0x8C	;5 - %
	.BYTE 0x00,0x70,0xD8,0xD8,0x70,0xDA,0xCC,0x7E	;6 - &
	.BYTE 0x00,0x30,0x30,0x60,0x00,0x00,0x00,0x00	;7 - '
	.BYTE 0x00,0x0C,0x18,0x30,0x30,0x30,0x18,0x0C	;8 - (
	.BYTE 0x00,0x30,0x18,0x0C,0x0C,0x0C,0x18,0x30	;9 - )
	.BYTE 0x00,0x6C,0x38,0xFE,0x38,0x6C,0x00,0x00	;10 - *
	.BYTE 0x00,0x18,0x18,0x7E,0x7E,0x18,0x18,0x00	;11 - +
	.BYTE 0x00,0x00,0x00,0x00,0x00,0x30,0x30,0x60	;12 - ,
	.BYTE 0x00,0x00,0x00,0x3C,0x00,0x00,0x00,0x00	;12 - -
	.BYTE 0x00,0x00,0x00,0x00,0x00,0x00,0x30,0x30	;13 - .
	.BYTE 0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80	;14 - /
	.BYTE 0x38,0x4C,0xC6,0xC6,0xC6,0xC6,0x64,0x38	;15 - 0
	.BYTE 0x00,0x18,0x38,0x18,0x18,0x18,0x18,0x7E	;16 - 1
	.BYTE 0x00,0x7C,0xC6,0x0E,0x3C,0x78,0xE0,0xFE	;17 - 2
	.BYTE 0x00,0x7E,0x0C,0x18,0x3C,0x06,0xC6,0x7C	;18 - 3
	.BYTE 0x00,0x1C,0x3C,0x6C,0xCC,0xFE,0x0C,0x0C	;19 - 4
	.BYTE 0x00,0xFC,0xC0,0xFC,0x06,0x06,0xC6,0x7C	;20 - 5
	.BYTE 0x00,0x3C,0x60,0xC0,0xFC,0xC6,0xC6,0x7C	;21 - 6
	.BYTE 0x00,0xFE,0xC6,0x0C,0x18,0x30,0x30,0x30	;22 - 7
	.BYTE 0x00,0x78,0xC4,0xE4,0x78,0x9E,0x86,0x7C	;23 - 8
	.BYTE 0x00,0x7C,0xC6,0xC6,0x7E,0x06,0x0C,0x78	;24 - 9
	.BYTE 0x00,0x30,0x30,0x00,0x00,0x30,0x30,0x00	;25 - :
	.BYTE 0x00,0x30,0x30,0x00,0x30,0x30,0x60,0x00	;26 - ;
	.BYTE 0x00,0x0C,0x18,0x30,0x18,0x0C,0x00,0x00	;27 - <
	.BYTE 0x00,0x00,0x7E,0x00,0x7E,0x00,0x00,0x00	;28 - =
	.BYTE 0x00,0x30,0x18,0x0C,0x18,0x30,0x00,0x00	;29 - >
	.BYTE 0x00,0x7C,0xFE,0xC6,0x0C,0x38,0x00,0x38	;30 - ?
	.BYTE 0x00,0x7C,0x82,0xBA,0xAA,0xBE,0x80,0x7C	;31 - @
	.BYTE 0x00,0x38,0x6C,0xC6,0xC6,0xFE,0xC6,0xC6	;32 - A
	.BYTE 0x00,0xFC,0xC6,0xC6,0xFC,0xC6,0xC6,0xFC	;33 - B
	.BYTE 0x00,0x3C,0x66,0xC0,0xC0,0xC0,0x66,0x3C	;34 - C
	.BYTE 0x00,0xF8,0xCC,0xC6,0xC6,0xC6,0xCC,0xF8	;35 - D
	.BYTE 0x00,0xFE,0xC0,0xC0,0xFC,0xC0,0xC0,0xFE	;36 - E
	.BYTE 0x00,0xFE,0xC0,0xC0,0xFC,0xC0,0xC0,0xC0	;37 - F
	.BYTE 0x00,0x3E,0x60,0xC0,0xCE,0xC6,0x66,0x3E	;38 - G
	.BYTE 0x00,0xC6,0xC6,0xC6,0xC6,0xFE,0xC6,0xC6	;39 - H
	.BYTE 0x00,0x7E,0x18,0x18,0x18,0x18,0x18,0x7E	;40 - I
	.BYTE 0x00,0x06,0x06,0x06,0x06,0x06,0xC6,0x7C	;41 - J
	.BYTE 0x00,0xC6,0xCC,0xD8,0xF0,0xF8,0xDC,0xCE	;42 - K
	.BYTE 0x00,0x60,0x60,0x60,0x60,0x60,0x60,0x7E	;43 - L
	.BYTE 0x00,0xC6,0xEE,0xFE,0xD6,0xD6,0xC6,0xC6	;44 - M
	.BYTE 0x00,0xC6,0xE6,0xF6,0xDE,0xDE,0xC6,0xC6	;45 - N
	.BYTE 0x00,0x7C,0xC6,0xC6,0xC6,0xC6,0xC6,0x7C	;46 - O
	.BYTE 0x00,0xFC,0xC6,0xC6,0xC6,0xFC,0xC0,0xC0	;47 - P
	.BYTE 0x00,0x7C,0xC6,0xC6,0xC6,0xDE,0xCC,0x7A	;48 - Q
	.BYTE 0x00,0xFC,0xC6,0xC6,0xCE,0xF8,0xDC,0xCE	;49 - R
	.BYTE 0x00,0x7C,0xC6,0xC0,0x7C,0x06,0xC6,0x7C	;50 - S
	.BYTE 0x00,0x7E,0x18,0x18,0x18,0x18,0x18,0x18	;51 - T
	.BYTE 0x00,0xC6,0xC6,0xC6,0xC6,0xC6,0xC6,0x7C	;52 - U
	.BYTE 0x00,0xC6,0xC6,0xC6,0xEE,0x7C,0x38,0x10	;53 - V
	.BYTE 0x00,0xD6,0xD6,0xD6,0xD6,0xFE,0xEE,0x44	;54 - W
	.BYTE 0x00,0xC6,0xC6,0x6C,0x38,0x6C,0xC6,0xC6	;55 - X
	.BYTE 0x00,0x66,0x66,0x66,0x3C,0x18,0x18,0x18	;56 - Y
	.BYTE 0x00,0xFE,0x0E,0x1C,0x38,0x70,0xE0,0xFE	;57 - Z
	.BYTE 0x00,0x3C,0x30,0x30,0x30,0x30,0x30,0x3C	;58 - [
	.BYTE 0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01	;59 - \ 
	.BYTE 0x00,0x3C,0x0C,0x0C,0x0C,0x0C,0x0C,0x3C	;60 - ]
	.BYTE 0x00,0x38,0x6C,0x00,0x00,0x00,0x00,0x00	;61 - ^
	.BYTE 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFE	;62 - _
	.BYTE 0x00,0x10,0x08,0x00,0x00,0x00,0x00,0x00 	;63 - `
	.BYTE 0x00,0x00,0x00,0x7C,0x06,0x7E,0xC6,0x7E	;64 - a
	.BYTE 0x00,0xC0,0xC0,0xFC,0xC6,0xC6,0xC6,0x7C	;65 - b
	.BYTE 0x00,0x00,0x00,0x7E,0xC0,0xC0,0xC0,0x7E	;66 - c
	.BYTE 0x00,0x06,0x06,0x7E,0xC6,0xC6,0xC6,0x7E	;67 - d
	.BYTE 0x00,0x00,0x00,0x7C,0xC6,0xFE,0xC0,0x7C	;68 - e
	.BYTE 0x00,0x0E,0x18,0x7E,0x18,0x18,0x18,0x18	;69 - f
	.BYTE 0x00,0x00,0x7E,0xC6,0xC6,0x7E,0x06,0x7C	;70 - g
	.BYTE 0x00,0xC0,0xC0,0xFC,0xC6,0xC6,0xC6,0xC6	;71 - h
	.BYTE 0x00,0x18,0x00,0x38,0x18,0x18,0x18,0x7E	;72 - i
	.BYTE 0x00,0x0C,0x00,0x1C,0x0C,0x0C,0x0C,0x78	;73 - j
	.BYTE 0x00,0xC0,0xC0,0xC6,0xCC,0xF8,0xCC,0xC6	;74 - k
	.BYTE 0x00,0x38,0x18,0x18,0x18,0x18,0x18,0x7E	;75 - l
	.BYTE 0x00,0x00,0x00,0xFC,0xB6,0xB6,0xB6,0xB6	;76 - m
	.BYTE 0x00,0x00,0x00,0xFC,0xC6,0xC6,0xC6,0xC6	;77 - n
	.BYTE 0x00,0x00,0x00,0x7C,0xC6,0xC6,0xC6,0x7C	;78 - o
	.BYTE 0x00,0x00,0xFC,0xC6,0xC6,0xFC,0xC0,0xC0	;79 - p
	.BYTE 0x00,0x00,0x7E,0xC6,0xC6,0x7E,0x06,0x06	;80 - q
	.BYTE 0x00,0x00,0x00,0x6E,0x70,0x60,0x60,0x60	;81 - r
	.BYTE 0x00,0x00,0x00,0x7C,0xC0,0x7C,0x06,0xFC	;82 - s
	.BYTE 0x00,0x18,0x18,0x7E,0x18,0x18,0x18,0x18	;83 - t
	.BYTE 0x00,0x00,0x00,0xC6,0xC6,0xC6,0xC6,0x7E	;84 - u
	.BYTE 0x00,0x00,0x00,0x66,0x66,0x66,0x3C,0x18	;85 - v
	.BYTE 0x00,0x00,0x00,0xD6,0xD6,0xD6,0xD6,0x6C	;86 - w
	.BYTE 0x00,0x00,0x00,0xC6,0x6C,0x38,0x6C,0xC6	;87 - x
	.BYTE 0x00,0x00,0xC6,0xC6,0xC6,0x7E,0x06,0x7C	;88 - y
	.BYTE 0x00,0x00,0x00,0xFE,0x1C,0x38,0x70,0xFE	;89 - z
	.BYTE 0x00,0x0C,0x18,0x18,0x30,0x18,0x18,0x0C	;90 - {
	.BYTE 0x00,0x18,0x18,0x18,0x18,0x18,0x18,0x18	;91 - |
	.BYTE 0x00,0x30,0x18,0x18,0x0C,0x18,0x18,0x30	;92 - }
	.BYTE 0x00,0x00,0x70,0xBA,0x1C,0x00,0x00,0x00	;93 - ~
	;.BYTE 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF