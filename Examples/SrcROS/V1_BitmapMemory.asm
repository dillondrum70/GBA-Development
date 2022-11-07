
SetPalette:		;R0= Palette Number R1= 0x-----GRB

	STMFD sp!,{r0-r12, lr}	
		mov r11,r0
		
		mov r0,#19	;VDU 19	-Set palette
;VDU 19,logical colour,mode,red,green,blue

		swi 0x00	;print char R0
		
		mov r0,r11	;palette number
		swi 0x00	;print char R0
		
		mov r0,#16	;NoFlash
		swi 0x00	;print char R0
		
		mov r2,r1			;Red
		and r2,r2,#0xF0 	;Nibble Mask
		mov r0,r2			;R (top 4 bit 00-F0)
		swi 0x00			;print char R0
		
		mov r2,r1,ROR #4	;Green
		and r2,r2,#0xF0 	;Nibble Mask
		mov r0,r2			;G (top 4 bit 00-F0)
		swi 0x00			;print char R0
		
		mov r2,r1,LSL #4	;Blue
		and r2,r2,#0xF0 	;Nibble Mask
		mov r0,r2			;B (top 4 bit 00-F0)
		swi 0x00			;print char R0
	LDMFD sp!,{r0-r12, pc}	
	

GetVars:
	.long 148	;ScreenStart
	.long 149	;DisplayStart
	.long 150	;TotalScreenSize
	.long -1	;List End

ReturnVars:
ScreenBase:	.long 0		;ScreenStart
			.long 0		;DisplayStart
			.long 0		;TotalScreenSize
Cls:
	mov r3,#RamArea
	mov r1,#0
	strB r1,[r3,#CursorX]	;X
	strB r1,[r3,#CursorY]	;Y 
	mov pc,lr
	
ScreenInit:
	STMFD sp!,{r0-r12, lr}  
		mov r0,#22			;VDU 22 - Selects screen mode 
		swi 0x00			;print char R0
		
		mov r0,#9			;Screen mode 9 = 320 × 256 @ 16 colors
							;Screen mode 13 = 320 × 256 @ 256 colors
		swi 0x00			;print char R0
	  	  
		SWI 0x36 			;Remove Cursor
	  
		adrl r0,GetVars		;Vars We want
		adrl r1,ReturnVars	;Area to store returned data
		swi 0x31			;OS_ReadVduVariables
			
		adr r10,InitPalette	;Source Palette
		mov r0,#0
InitPaletteAgain:
		ldr r1,[r10],#2
		bl SetPalette		;Palette Conversion
		add r0,r0,#1
		cmp r0,#16
		bne InitPaletteAgain
	LDMFD sp!,{r0-r12, pc}	
	
	
InitPalette:
		  ;-GRB
	.word 0x008;0  
	.word 0xFF0;1
	.word 0xF0F;2  
	.word 0x00F;3  
	.word 0xFF0;4  
	.word 0xFF0;5  
	.word 0xFF0;6
	.word 0xFF0;7  
	.word 0xFF0;8  
	.word 0xFF0;9  
	.word 0xFF0;A  
	.word 0xFF0;B  
	.word 0xFF0;C  
	.word 0xFF0;D  
	.word 0xFF0;E  
	.word 0xFF0;F  
	

	
	;ScreenAddr = ScreenBase + (Ypos*160) + Xpos
GetScreenPos: ;R1,R2 = X,Y ... result in R10
	STMFD sp!,{r2}
		STMFD sp!,{r1}
			adrl r1,ScreenBase	;ScreenAddr
			ldr r10,[r1]		
			mov r1,#160			;Ypos *160
			mul r2,r1,r2
		LDMFD sp!,{r1}	
		add r10,r10,r1			;Xpos
		add r10,r10,r2
	LDMFD sp!,{r2}
	MOV pc,lr	;Return 
	
GetNextLine:
	add r10,r10,#160	;Add 160 to register R10
	MOV pc,lr	;Return 	
	

PrintChar:
	STMFD sp!,{r0-r12, lr}
		mov r3,#RamArea
		mov r4,#0
		mov r5,#0
		ldrB r4,[r3,#CursorX]	;X
		ldrB r5,[r3,#CursorY]	;Y
				
		adrl r1,ScreenBase
		ldr r3,[r1]			;Get Screen Base
		
		mov r6,#4			;Xpos (4 bytes per Char)
		mul r2,r4,r6
		add r3,r3,r2
		
		mov r4,#160*8		;Ypos (160 bytes per line - 8 lines per char)
		mul r2,r5,r4
		add r3,r3,r2
		
		adrl r4,BitmapFont 	;Address of our font
		sub r0,r0,#32		;No chars <32 (first Char = space)
		add r4,r4,r0,asl #3 ;Char * 8 - offset to 
		
		mov r1,#8 ; 48 bytes per row = 12 words
NextFontLine:

		mov r9,#0b00000001
		ldrb r8,[r4]	;Load line of 1bpp font
		add r4,r4,#1
		
		mov r2,#0
		;We're going to move a bit into each nibble of R2
		
		and r10,r9,r8			;-------X
		orr r2,r2,r10
		
		and r10,r9,r8,ror #1	;------X-
		orr r2,r2,r10,ror #4*1
		
		and r10,r9,r8,ror #2	;-----X--
		orr r2,r2,r10,ror #4*2
		
		and r10,r9,r8,ror #3	;----X---
		orr r2,r2,r10,ror #4*3
		
		and r10,r9,r8,ror #4	;---X----
		orr r2,r2,r10,ror #4*4
		
		and r10,r9,r8,ror #5	;--X-----
		orr r2,r2,r10,ror #4*5
		
		and r10,r9,r8,ror #6	;-X------
		orr r2,r2,r10,ror #4*6
		
		and r10,r9,r8,ror #7	;X-------
		orr r2,r2,r10,ror #4*7
		
		mov r5,r2
		orr r5,r5,r2,asl #1		;Duplicate bit into all 4 bits of nibble
		orr r5,r5,r2,asl #2			;Color 1 -> Color 15
		orr r5,r5,r2,asl #3
		
		str r5,[r3]				;Store the complete font (in color 15)
		
		add r3,r3,#160;-8
		
		subs r1,r1,#1
		bne NextFontLine		;Repeat for next line
		
		mov r3,#ramarea
		ldrB r0,[r3,#CursorX]	;Inc X-pos
		add r0,r0,#1
		strB r0,[r3,#CursorX]	
	LDMFD sp!,{r0-r12, pc}		

NewLine:
	STMFD sp!,{r0-r12, lr}
		mov r3,#RamArea			;Pointer to Ram area
		
		mov r0,#0
		strB r0,[r3,#CursorX]	;Zero XPos
		
		ldrB r0,[r3,#CursorY]	;Inc Ypos
		add r0,r0,#1
		strB r0,[r3,#CursorY]	
	LDMFD sp!,{r0-r12, pc}		