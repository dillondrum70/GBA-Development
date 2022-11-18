.include "GBA_Core.asm"

.EQU CursorX, Ram+32	;32 bits past ram start
.EQU CursorY, Ram+33	;1 bit past CursorX

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