;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;LITTLE ENDIAN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Source: https://www.chibialiens.com/arm/helloworld.php#LessonH2
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

.EQU ScreenXBound, 240
.EQU ScreenYBound, 160

;Constant
.EQU PlayerWidth, 16
.EQU PlayerHeight, 16

.EQU FacingDown, 0
.EQU FacingLeft, 1
.EQU FacingUp, 2
.EQU FacingRight, 3

;Variable
.EQU PlayerX, Ram+34	;Player's x position
.EQU PlayerY, Ram+35	;Player's y position

.EQU PlayerFace, Ram+38	;Direction player faces
.EQU PlayerCurrentAnimIndex, Ram+36	;Address between beginning and end where current animation frame is
.EQU PlayerCurrentAnimBegin, Ram+40	;Address of current animation indices
.EQU PlayerCurrentAnimEnd, Ram+44 ;Address where current animation indices end
;.EQU PlayerAnimIndex, Ram+40	;current index of frame in animation tileset, tells us sprite number for sprite attributes for draw calls

;Access animation array -> get index in array -> value from the animation is an index in the sprite tilemap -> pass index from animation array as sprite num when drawing player

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
;0B0h    2     Maker Code       (uppercase ascii, 2 characters)
    .BYTE "GB"				;Maker
;0B2h    1     Fixed value      (must be 96h, required!)
	.BYTE 0x96
;0B3h    1     Main unit code   (00h for current GBA models)
	.BYTE 0x00
;0B4h    1     Device type      (usually 00h) (bit7=DACS/debug related)
	.BYTE 0x00
;0B5h    7     Reserved Area    (should be zero filled)
	.BYTE 0x00,0x00,0x00,0x00,0x00,0x00,0x00
;0BCh    1     Software version (usually 00h)
	.BYTE 0x00
;0BDh    1     Complement check (header checksum, required!)
	.BYTE 0x00
;0BEh    2     Reserved Area    (should be zero filled)
	.BYTE 0x00,0x00
;0C0h    4     RAM Entry Point  (32bit ARM branch opcode, eg. "B ram_start")
	.BYTE 0x00,0x00,0x00,0x00
;0C4h    1     Boot mode        (init as 00h - BIOS overwrites this value!)
	.BYTE 0x00
;0C5h    1     Slave ID Number  (init as 00h - BIOS overwrites this value!)
	.BYTE 0x00
;0C6h    26    Not used         (seems to be unused)
	.BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;0E0h    4     JOYBUS Entry Pt. (32bit ARM branch opcode, eg. "B joy_start")
	.BYTE 0x00,0x00,0x00,0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Main:
	MOV sp, #Stack		;Initialize Stack Pointer, starts at memory address 3000000 on GBA
	
	BL ScreenInit
	
	;;;;Load background
	BL BackgroundAndSpriteInit
	
	
	;Initialize player variables
	MOV r0, #PlayerX
	MOV r6, #20
	STRB r6, [r0]
	
	MOV r0, #PlayerY
	MOV r7, #20
	STRB r7, [r0]
	
	MOV r0, #PlayerCurrentAnimBegin
	ADRL r6, Anim_PlayerIdle	;Start with idle animation, load player idle address
	STRW r6, [r0]
	
	MOV r0, #PlayerCurrentAnimIndex	;Current index of current animation will be frame 0 of the idle animation
	MOV r6, #10
	STRB r6, [r0]
	
	MOV r0, #PlayerCurrentAnimEnd
	ADRL r6, Anim_PlayerIdle_END	;Start with idle animation, load player idle address end position 
	STRW r6, [r0]
	
	MOV r0, #PlayerFace
	MOV r6, #FacingDown	;Start facing down (towards the screen)
	STRB r6, [r0]

;16 color sprite (Wide 2x1 using tile patterns)
	;mov r0,#0x00	   		;Sprite Num
	;mov r1,#0x4020   		;Ypos
	;mov r2,#0x0040   		;Xpos
	;mov r3,#0x0001   		;Tile
	;bl DrawSprite
	
;256 color sprite
	;mov r0,#0x00	   		;Sprite Num
	;mov r1,#0x2000   		;Ypos
	;mov r2,#0x4000   		;Xpos	4=256 color
	;mov r3,#0x000A   		;Tile 
	;bl DrawSprite
	
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
		;BL GetButton					;Call function, value returned in r0
	
		;CMPS r0, #0						;Set flag register to check input
		;MOVE r1, #0b1111110000000000	;Turn blue if up key pressed
		;MOVNE r1, #BackgroundColor		;Stay background gray otherwise
	
		;BL ClearToColor					;Update color
		
		;Load in current player position
		MOV r6, #PlayerX
		LDRB r8, [r6]
		MOV r10, r8	;Cache last player x position so we can modify current position
		MOV r7, #PlayerY
		LDRB r9, [r7]
		MOV r11, r9	;Cache last player y position so we can modify current position
		
		;Erase Sprite
		;LDR r5, SpriteTestAddress
		MOV r4, #PlayerHeight
		MOV r3, #PlayerWidth
		;MOV r2, r9
		;MOV r1, r8
		;BL DrawSprite
	
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Vertical Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		MOV r1, #Key_Up
		BL GetButton
		CMPS r0, #0
		ADDNE r9, r9, #1
	
		MOV r1, #Key_Down
		BL GetButton
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
		
	
		;;;;;;;;;;;;;;;;;;;;;;;;;;; Horizontal Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		MOV r1, #Key_Right
		BL GetButton
		CMPS r0, #0
		SUBNE r8, r8, #1;;;;;;;;;;;;;;;;;;;********For some reason, when key_right is pressed, adding moves it left so I switched the sub and add for left and right, The problem isn't with input because I checked multiple sourdces and they all say the fifth bit is right and the sixth is left
	
		MOV r1, #Key_Left
		BL GetButton
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
		
		;Do collisions independently so we can still move up and down well moving right against a wall
		;;;;;;;;;;;;;;; Vertical Collision ;;;;;;;;;;;;;;;;;;;;
		MOV r1, r10
		MOV r2, r11
		MOV r3, r9
		BL VerticalCollision
		
		;;;;;;;;;;;;;;;;;;;;;;; Horizontal Background Collision ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		MOV r1, r10
		MOV r2, r11
		MOV r3, r8
		BL HorizontalCollision
		
		;;;;;;;;;;;;;;;;;;;;;;; Animation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;MOV r0, #PlayerFace
		;LDRB r1, [r0]
		
		;MOV r0, #PlayerCurrentAnim
		;LDRB r2, [r0]
		
		;MOV r0, #PlayerAnimIndex
		;LDRB r3, [r0]
	
		
		
		;;;;;;;;;;;;;;;;;;; Render images
		;No parameters, render handles that
		BL Render
		
		;Slow down frame rate (otherwise it looks very glitchy and everything moves too fast)
		MOV r0, #0x2000
		DelayFrame:
			SUBS r0, r0, #1
			BNE DelayFrame
		DelayNextDraw:
			SUBS r0, r0, #1
			MOV r0, #ScanlineCounter
			LDR r1, [r0]
			MOV r0, #ScreenYBound
			CMPS r1, r0
			BGE DelayNextDraw
		DelayNextBlank:
			SUBS r0, r0, #1
			MOV r0, #ScanlineCounter
			LDR r1, [r0]
			MOV r0, #ScreenYBound
			CMPS r1, r0
			BLT DelayNextBlank
		
	
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
		MOV r3, #LCDControl		;DISPCNT - LCD Control
		MOV r2, #0x100;0x403			;4 = Layer 2 on, 3 = ScreenMode 3 
		STR r2, [r3]			;Store layer and screen mode in LCD Control address
		
		ADD r3, r3, #0x08;		;Get to BGOCNT - BGO Control at #0x04000008
		MOV r2, #0x4004			;first 4 = Screen size (64x32 tilemap), last 4 = pattern base address, 0x06004000
		STR r2, [r3]			;Store the values in BGO control
		
		;MOV r1, #BackgroundColor		;Color to fill
		;BL ClearToColor
	LDMFD sp!, {r0-r3, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BackgroundAndSpriteInit:
	STMFD sp!, {r0-r3, lr}
	
		;Load Background Palette Colors
		ADRL r1, ColorPalette		;Palette Address
		MOV r2, #BackgroundPaletteMemory
		MOV r3, #16*2		;Number of colors * bytes per color
		BL LoadHalfwords
		
		;Load tilemap images
		ADRL r1, TilemapFiles	;File with tilemap patterns
		MOV r2, #VramTilemapPixelPatterns
		MOV r3, #TilemapFiles_END-TilemapFiles
		BL LoadHalfwords
		
		;Load tilemap patterns directly into VRAM
		ADRL r1, Tilemap
		MOV r2, #VramBase	;Load the pattern into screen block 0 of character block 0
		MOV r3, #Tilemap_END-Tilemap	;<width> x <height> tilemap with 2 bytes per tile
		BL LoadBytes
		
		;Load tilemap into Background Layer VRAM so our 32x32 tilemap becomes 64x32 and repeats
		ADRL r1, Tilemap
		MOV r2, #VramBackground	;Load the pattern into the screen block 1 of character block 0
		MOV r3, #Tilemap_END-Tilemap	;<width> x <height> tilemap with 2 bytes per tile
		BL LoadBytes
		
		;Load Sprite Palette Colors
		ADRL r1, ColorPalette		;Palette Address
		MOV r2, #SpritePaletteMemory
		MOV r3, #16*2		;Number of colors * bytes per color
		BL LoadHalfwords
		
		;Load sprite images
		ADRL r1, SpriteFiles	;File with tilemap patterns
		MOV r2, #VramSpritePixelPatterns
		MOV r3, #SpriteFiles_END-SpriteFiles
		BL LoadHalfwords
		
		;Turn Screen On
		MOV r0, #LCDControl
		MOV r1, #0x1140	;1 = Sprite on, 1 = layer on, 4 = 1D tile layout, 0 = screen mode 0
		
		str r1, [r0]
		
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
;r1 = Color Palette Location
;r2 = GBA Palette Memory Location
;r3 = number of bytes (halfwords, we load 2 at a time)
LoadHalfwords:
	STMFD sp!, {r1-r4, lr}
	
LoadHalfwordsRep:
		LDRH r4, [r1], #2	;Load current position in color palette into r1 and increment halfword
		STRH r4, [r2], #2	;Store palette value in GBA Palette memory and increment halfword
		
		SUBS r3, r3, #2
		BNE LoadHalfwordsRep	;Repeat process until number of bytes reached
	
	LDMFD sp!, {r1-r4, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r1 = Color Palette Location
;r2 = GBA Palette Memory Location
;r3 = number of bytes
LoadBytes:
	STMFD sp!, {r1-r4, lr}
	
LoadBytesRep:
		LDRB r4, [r1], #1	;Load current position in from byte array and increment 1 byte
		STRH r4, [r2], #2	;Store palette value in halfword location and increment halfword
		
		SUBS r3, r3, #1
		BNE LoadBytesRep	;Repeat process until number of bytes reached
	
	LDMFD sp!, {r1-r4, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r1 = current VRAM position
;Return VRAM position shifted down one line
;https://www.chibialiens.com/arm/platform.php#LessonP2
GetNextLine:
	ADD r0, r1, #240*2		;Simple add
	MOV pc, lr				;Return
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r1 = current x position
;r2 = current y position
;r3 = next y position
;Checks collision with background objects
;Check player's position in relation to tiles
;Get tile at that index in the tilemap ((TilemapWidth * y) + x)
;If tile is equal or greater than the index mark (non-colliding tiles below, colliding tiles above) reset movement to 0
VerticalCollision:
	STMFD sp!, {r1-r7, lr}
		MOV r5, r3	;r5 = next y
		MOV r6, r1	;r6 = current x
		MOV r7, r2	;r7 = current y
			
		CMP r5, r7
		BEQ VerticalCollision_END
		BGT VerticalCollision_CheckDown	;Greater than means moving down since (0,0) is top left
		;Otherwise, we are less than and don't need to check
			
		VerticalCollision_CheckUp:
		;;;;;;;;;;;Top Left Collision
		;X index in tilemap is ((playerX - TileLength) / TileLength)
		MOV r1, r6	;Load player X position into first register
		;Add nothing to get rightmost x value
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r3, r0
		
		MOV r1, r5	;Load player next Y position into first register
		;Add nothing to get top X value
		MOV r2, #TileLength	;Divide Y by length of a tile
		BL DIV
		MOV r4, r0
		
		;Load tile index from tilemap
		ADRL r0, Tilemap	;Get addresses of tilemap, far away in code so use ADRL
		MOV r1, #TilemapWidth
		MLA r2, r1, r4, r3	;r2 = ((r1 * r4) + r3) -> Load the tile at specified position from tilemap (Tilemap address + ((tilemap width * y index) + x index))
		LDRB r4, [r0, r2]	;Load data in tilemap
		
		;If greater than or equal to colliding limit, then we reset position to prevent movement and "collide" with the tile
		CMP r4, #BackgroundCollideLimit
		MOVGTE r5, r7	;If colliding, reset y position
		BGE VerticalCollision_END	;End early, if we collided here, we couldn't have collided in the opposite direction and we already know we need to stop so the other side doens't matter
		
		;;;;;;;;;;;Top Right Collision
		;X index in tilemap is ((playerX - TileLength) / TileLength)
		MOV r1, r6	;Load player X position into first register
		ADD r1, r1, #PlayerWidth-1	;Add width of player to get rightmost x value, subtract 1 to get flush with wall (so we get index INSIDE the character, not outside)
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r3, r0
		
		MOV r1, r5	;Load player Y position into first register
		;Add nothing to get top X value
		MOV r2, #TileLength	;Divide Y by length of a tile
		BL DIV
		MOV r4, r0
		
		;Load tile index from tilemap
		ADRL r0, Tilemap	;Get addresses of tilemap, far away in code so use ADRL
		MOV r1, #TilemapWidth
		MLA r2, r1, r4, r3	;r2 = ((r1 * r4) + r3) -> Load the tile at specified position from tilemap (Tilemap address + ((tilemap width * y index) + x index))
		LDRB r4, [r0, r2]	;Load data in tilemap
		
		;If greater than or equal to colliding limit, then we reset position to prevent movement and "collide" with the tile
		CMP r4, #BackgroundCollideLimit
		MOVGTE r5, r7	;If colliding, reset y position
		
		B VerticalCollision_END	;Finished checking up, skip to end
		
		VerticalCollision_CheckDown:
		;;;;;;;;;;;Bottom Left Collision
		;X index in tilemap is ((playerX - TileLength) / TileLength)
		MOV r1, r6	;Load player X position into first register
		;Add nothing to get left x value
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r3, r0
		
		;Y index is found the same way
		MOV r1, r5	;Load player X position into first register
		ADD r1, r1, #PlayerHeight-1	;Add height of player to get bottom y level, subtract 1 to get flush with wall (so we get index INSIDE the character, not outside)
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r4, r0
		
		;Load tile index from tilemap
		ADRL r0, Tilemap	;Get addresses of tilemap, far away in code so use ADRL
		MOV r1, #TilemapWidth
		MLA r2, r1, r4, r3	;r2 = ((r1 * r4) + r3) -> Load the tile at specified position from tilemap (Tilemap address + ((tilemap width * y index) + x index))
		LDRB r4, [r0, r2]	;Load data in tilemap
		
		;If greater than or equal to colliding limit, then we reset position to prevent movement and "collide" with the tile
		CMP r4, #BackgroundCollideLimit
		MOVGTE r5, r7	;If colliding, reset y position
		BGE VerticalCollision_END
		
		;;;;;;;;;;;Bottom Right Collision
		;X index in tilemap is ((playerX - TileLength) / TileLength)
		MOV r1, r6	;Load player X position into first register
		ADD r1, r1, #PlayerWidth-1;Add width to get right x value, subtract 1 to get flush with wall (so we get index INSIDE the character, not outside)
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r3, r0
		
		;Y index is found the same way
		MOV r1, r5	;Load player X position into first register
		ADD r1, r1, #PlayerHeight-1	;Add height of player to get bottom y level, subtract 1 to get flush with wall (so we get index INSIDE the character, not outside)
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r4, r0
		
		;Load tile index from tilemap
		ADRL r0, Tilemap	;Get addresses of tilemap, far away in code so use ADRL
		MOV r1, #TilemapWidth
		MLA r2, r1, r4, r3	;r2 = ((r1 * r4) + r3) -> Load the tile at specified position from tilemap (Tilemap address + ((tilemap width * y index) + x index))
		LDRB r4, [r0, r2]	;Load data in tilemap
		
		;If greater than or equal to colliding limit, then we reset position to prevent movement and "collide" with the tile
		CMP r4, #BackgroundCollideLimit
		MOVGE r5, r7	;If colliding, reset y position
		
		VerticalCollision_END:
		
		;Update memory with new position
		MOV r6, #PlayerY
		STRB r5, [r6]
	LDMFD sp!, {r1-r7, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r1 = current x position
;r2 = current y position
;r3 = next x position
;Checks collision with background objects
;Check player's position in relation to tiles
;Get tile at that index in the tilemap ((TilemapWidth * y) + x)
;If tile is equal or greater than the index mark (non-colliding tiles below, colliding tiles above) reset movement to 0
HorizontalCollision:
	STMFD sp!, {r1-r7, lr}
		MOV r5, r3	;r5 = next y
		MOV r6, r1	;r6 = current x
		MOV r7, r2	;r7 = current y
		
		CMP r5, r6	;Compare new position to last position
		BEQ HorizontalCollision_END	;If equal, we haven't moved, don't need to check collision
		BGT HorizontalCollision_CheckRight	;If current is greater than last position
		
		HorizontalCollision_CheckLeft:
		;Checking just x component (in case colliding trying to move vertically also and there isn't a collision there or vice versa)
		;;;;;;;;;;;Top Left Collision
		;X index in tilemap is ((playerX - TileLength) / TileLength)
		MOV r1, r5	;Load player X position into first register
		;Add nothing to get rightmost x value
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r3, r0
		
		;Y index is found the same way
		MOV r1, r7	;Load player y position into first register
		;Add nothing to get top y value
		MOV r2, #TileLength	;Divide y by length of a tile
		BL DIV
		MOV r4, r0
		
		;Load tile index from tilemap
		ADRL r0, Tilemap	;Get addresses of tilemap, far away in code so use ADRL
		MOV r1, #TilemapWidth
		MLA r2, r1, r4, r3	;r2 = ((r1 * r4) + r3) -> Load the tile at specified position from tilemap (Tilemap address + ((tilemap width * y index) + x index))
		LDRB r4, [r0, r2]	;Load data in tilemap
		
		;If greater than or equal to colliding limit, then we reset position to prevent movement and "collide" with the tile
		CMP r4, #BackgroundCollideLimit
		MOVGTE r5, r6	;If colliding, reset x position
		BGE HorizontalCollision_END
		
		;;;;;;;;;;;Bottom Left Collision
		;X index in tilemap is ((playerX - TileLength) / TileLength)
		MOV r1, r5	;Load player X position into first register
		;Add nothing to get left x value
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r3, r0
		
		;Y index is found the same way
		MOV r1, r7	;Load player X position into first register
		ADD r1, r1, #PlayerHeight-1	;Add height of player to get bottom y level, subtract 1 to get flush with wall (so we get index INSIDE the character, not outside)
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r4, r0
		
		;Load tile index from tilemap
		ADRL r0, Tilemap	;Get addresses of tilemap, far away in code so use ADRL
		MOV r1, #TilemapWidth
		MLA r2, r1, r4, r3	;r2 = ((r1 * r4) + r3) -> Load the tile at specified position from tilemap (Tilemap address + ((tilemap width * y index) + x index))
		LDRB r4, [r0, r2]	;Load data in tilemap
		
		;If greater than or equal to colliding limit, then we reset position to prevent movement and "collide" with the tile
		CMP r4, #BackgroundCollideLimit
		MOVGTE r5, r6	;If colliding, reset x position
		BGE HorizontalCollision_END
		
		HorizontalCollision_CheckRight:
		
		;;;;;;;;;;;Top Right Collision
		;X index in tilemap is ((playerX - TileLength) / TileLength)
		MOV r1, r5	;Load player X position into first register
		ADD r1, r1, #PlayerWidth-1	;Add width of player to get rightmost x value, subtract 1 to get flush with wall (so we get index INSIDE the character, not outside)
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r3, r0
		
		;Y index is found the same way
		MOV r1, r7	;Load player X position into first register
		;Add nothing to get top y value
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r4, r0
		
		;Load tile index from tilemap
		ADRL r0, Tilemap	;Get addresses of tilemap, far away in code so use ADRL
		MOV r1, #TilemapWidth
		MLA r2, r1, r4, r3	;r2 = ((r1 * r4) + r3) -> Load the tile at specified position from tilemap (Tilemap address + ((tilemap width * y index) + x index))
		LDRB r4, [r0, r2]	;Load data in tilemap
		
		;If greater than or equal to colliding limit, then we reset position to prevent movement and "collide" with the tile
		CMP r4, #BackgroundCollideLimit
		MOVGTE r5, r6	;If colliding, reset x position
		BGE HorizontalCollision_END
		
		;;;;;;;;;;;Bottom Right Collision
		;X index in tilemap is ((playerX - TileLength) / TileLength)
		MOV r1, r5	;Load player X position into first register
		ADD r1, r1, #PlayerWidth-1;Add width to get right x value, subtract 1 to get flush with wall (so we get index INSIDE the character, not outside)
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r3, r0
		
		;Y index is found the same way
		MOV r1, r7	;Load player X position into first register
		ADD r1, r1, #PlayerHeight-1	;Add height of player to get bottom y level, subtract 1 to get flush with wall (so we get index INSIDE the character, not outside)
		MOV r2, #TileLength	;Divide X by length of a tile
		BL DIV
		MOV r4, r0
		
		;Load tile index from tilemap
		ADRL r0, Tilemap	;Get addresses of tilemap, far away in code so use ADRL
		MOV r1, #TilemapWidth
		MLA r2, r1, r4, r3	;r2 = ((r1 * r4) + r3) -> Load the tile at specified position from tilemap (Tilemap address + ((tilemap width * y index) + x index))
		LDRB r4, [r0, r2]	;Load data in tilemap
		
		;If greater than or equal to colliding limit, then we reset position to prevent movement and "collide" with the tile
		CMP r4, #BackgroundCollideLimit
		MOVGTE r5, r6	;If colliding, reset x position
		
		HorizontalCollision_END:
		
		;Update memory with new position
		MOV r6, #PlayerX
		STRB r5, [r6]
	LDMFD sp!, {r1-r7, pc}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r1 = Sprite number to draw
;r2 = First sprite attribute (See code below for format)
;r3 = Second sprite attribute (See code below for format)
;r4	= Third sprite attribute (See code below for format)
;Based on https://www.chibialiens.com/arm/platform.php#LessonP2
;Redesigned slightly, GetNextLine was extracted into it's own function
DrawSprite:
	STMFD sp!, {r1-r5, lr}
		MOV r5, #SpriteOAMSettings
		ADD r5, r5, r1, asl #3	;First 8 bytes is the sprite number, bit shift left to get 8 so we can set the first sprite attribute
		
		;S=Shape Square / HRect / VRect
		;C=Colors 15/256
		;M=Mosaic
		;T=Transparent
		;D=Disable/Doublesize
		;R=Rotation
		;Y=Ypos
		;First Attribute - SSCMTTDRYYYYYYYY
		STRH r2, [r5]
		ADD r5, r5, #2	;Move to next halfword to set the second sprite attribute
		
		;S=Obj Size
		;VH=V/HFlip
		;R=Rotation Parameter
		;X=Xpos
		;Second Attribute - SSVHRRRXXXXXXXXX
		STRH r3, [r5]
		ADD r5, r5, #2 ;Move to next halfword to set the third sprite attribute
		
		;C=Color Palette
		;P=Priority
		;T=Tile Number
		;Third Attribute - CCCCPPTTTTTTTTTT
		STRH r4, [r5]
	LDMFD sp!, {r1-r5, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Choose which frame to render and then render it
;
Render:
	STMFD sp!, {r1-r7, lr}
		;See DrawSprite for meanings of the sprite attribute bits (r2-r4)
		MOV r1, #PlayerSpriteNum
		
		MOV r2,#0b0000000000000000
		MOV r4, #PlayerY
		LDRB r5, [r4]
		ADD r2, r2, r5	;Add y pos to first sprite attribute (y pos is lowest 8 bits)
		
		MOV r3,#0b0100000000000000
		MOV r4, #PlayerX
		LDRB r5, [r4]
		ADD r3, r3, r5	;Add x pos to second sprite attribute (x pos is lowest 9 bits)
		
		MOV r4,#0b0000000000000000
		
		;;;;;;;;;;;;;;; Animation ;;;;;;;;;;;;;;;;;; - Change the start tile we choose from the sprite tileset
		MOV r0, #PlayerCurrentAnimBegin	;Get address to the current address where animation indices beginning
		LDR r5, [r0]	;Access memory and get address of the beginning of current animation
		MOV r0, #PlayerCurrentAnimIndex	;Address of index in current animation
		LDRB r6, [r0]		;Get index within current animation
		LDRB r7, [r5, r6];Get actual index from beginning address location + index offset
		ADD r4, r4, r7	;Add index in tilemap of the starting tile to draw for the player
		
		;ADRL r0, Anim_PlayerIdle	;Load idle animation address
		;MOV r5, #PlayerCurrentAnimIndex	;Address of index in current animation
		;LDRB r6, [r5]	;Load index in current animation
		;LDRB r7, [r0, r6]	;Access r6 index in r0, the animation, to get the sprite tile index in the sprite tiles' tilemap
		;ADD r4, r4, r7
		
		;Draw sprite after getting current frame, parameters loaded in r1-r4
		BL DrawSprite
		
		;ADD r6, r6, #1	;Increment address to next index (one byte)
		MOV r0, #PlayerCurrentAnimEnd	;Get address of the current address where animation indices end
		LDR r4, [r0]	;Get memory location where animation ends
		SUB r4, r4, #1	;(- 1 to get the index of the last frame, not just past the last frame)
		
		ADD r6, r6, #1	;Increment memory to see if next is equal to end of array
		ADD r7, r5, r6	;Get start memory address + offset
		
		MOV r1, #PlayerCurrentAnimIndex	;Address of index in current animation
		
		CMP r7, r4	;Test current address against end address
		;MOVGTE r0, #PlayerCurrentAnimBegin	;If greater or equal, loop back to beginning of animation
			EORGTE r6, r6, r6	;Clear index to 0
			STRBGTE r6, [r1]	;If current address is equal or greater than end, reset the current address in memory to the address at the beginning of the animation
			
			STRBLT r6, [r1]	;Otherwise, store this new animation index as our current address
		
	LDMFD sp!, {r1-r7, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Use E conditional to check if pressed
;r1 = key mask
;Returns keymask in r0
GetButton:
	STMFD sp!, {r1-r2, lr}
		EOR r0, r0, r0
		MOV r2, #InputLocation	;Input memory location
		LDRH r0, [r2]			;Get value of input, (1 = not pressed)
		MOV r2, #MaskKey		;Mask out superfluous bits
		BIC r0, r0, r2			;Inverse AND the register to only keep input bits (last 10 bits)
		AND r0, r0, r1			;AND return register with input bits with the passed key mask
	LDMFD sp!, {r1-r2, pc}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.INCLUDE "GBA_Core.asm"
.INCLUDE "GBA_Text.asm"
.INCLUDE "GBA_Math.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-BBBBBGGGGGRRRRR
ColorPalette:
	.WORD 0b0000000000000000; ;0  %-BBBBBGGGGGRRRRR
    .WORD 0b0000000000010000; ;1  %-BBBBBGGGGGRRRRR
    .WORD 0b0000001000000000; ;2  %-BBBBBGGGGGRRRRR
    .WORD 0b0000001000010000; ;3  %-BBBBBGGGGGRRRRR
    .WORD 0b0100000000000000; ;4  %-BBBBBGGGGGRRRRR
    .WORD 0b0100000000010000; ;5  %-BBBBBGGGGGRRRRR
    .WORD 0b0100001000000000; ;6  %-BBBBBGGGGGRRRRR
    .WORD 0b0110001100011000; ;7  %-BBBBBGGGGGRRRRR
    .WORD 0b0100001000010000; ;8  %-BBBBBGGGGGRRRRR
    .WORD 0b0000000000011111; ;9  %-BBBBBGGGGGRRRRR
    .WORD 0b0000001111100000; ;10  %-BBBBBGGGGGRRRRR
    .WORD 0b0000001111111111; ;11  %-BBBBBGGGGGRRRRR
    .WORD 0b0111110000000000; ;12  %-BBBBBGGGGGRRRRR
    .WORD 0b0111110000011111; ;13  %-BBBBBGGGGGRRRRR
    .WORD 0b0111111111100000; ;14  %-BBBBBGGGGGRRRRR
    .WORD 0b0111111111111111; ;15  %-BBBBBGGGGGRRRRR

	
TilemapFiles:
	.INCBIN "\Tilemaps\GameTilemap.RAW"
TilemapFiles_END:;Points to memory at end of files so we can get their size

SpriteFiles:
	.INCBIN "\Tilemaps\CharacterSpriteTilemap.RAW"
SpriteFiles_END:

.EQU PlayerSpriteNum, 1	;Player is always our first sprite
.EQU PlayerTileStart, 1 ;Index of first sprite tile

;Indexes where the 4 tiles lie in the tilemap for each frame
Anim_PlayerIdle:
	.BYTE 1, 1, 1, 1, 5, 5, 5, 5, 9, 9 ,9, 9 , 5, 5, 5, 5	;Loop through the 3 idle frames
Anim_PlayerIdle_END:
	
.EQU BackgroundCollideLimit, 18	;Colliding tiles start at this index
.EQU TileLength, 8	;Tiles are 8x8 pixels
.EQU TilemapWidth, 32
.EQU TilemapHeight, 32

;Screen is 240x160 pixels, 32x32 tiles in background, tiles are 8x8, screen shows 30x20 tiles-worth of pixels at a time
Tilemap:
	.BYTE 0 ,0 ,0 ,0 ,0 ,0 ,25,24,2 ,0 ,0 ,1 ,0 ,12,3 ,3 ,15,0 ,2 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,1 ,0 ,1 ,0 ,0 ,0
	.BYTE 0 ,2 ,0 ,1 ,2 ,0 ,25,24,1 ,2 ,0 ,0 ,0 ,12,3 ,3 ,15,1 ,0 ,0 ,0 ,2 ,0 ,1 ,0 ,0 ,2 ,0 ,0 ,0 ,1 ,0
	.BYTE 0 ,0 ,0 ,0 ,0 ,0 ,25,24,2 ,0 ,0 ,0 ,0 ,12,3 ,3 ,15,0 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,2
	.BYTE 0 ,0 ,0 ,2 ,0 ,0 ,25,24,0 ,0 ,1 ,14,14,8 ,3 ,3 ,11,14,14,14,14,0 ,0 ,2 ,0 ,0 ,2 ,1 ,0 ,1 ,0 ,0
	.BYTE 0 ,1 ,0 ,0 ,2 ,0 ,25,24,0 ,0 ,12,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,15,2 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0
	.BYTE 0 ,1 ,0 ,0 ,2 ,0 ,25,24,0 ,0 ,12,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,15,2 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0
	.BYTE 21,21,16,16,16,21,30,24,2 ,0 ,12,3 ,3 ,10,13,13,13,13,9 ,3 ,3 ,15,0 ,2 ,0 ,1 ,2 ,0 ,0 ,0 ,2 ,0
	.BYTE 32,32,16,16,16,32,32,24,0 ,0 ,12,3 ,3 ,15,0 ,2 ,0 ,1 ,12,3 ,3 ,15,0 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,1 ,0
	.BYTE 20,27,16,16,16,26,20,27,1 ,2 ,12,3 ,3 ,15,0 ,0 ,0 ,0 ,12,3 ,3 ,15,0 ,1 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,2
	.BYTE 0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,12,3 ,3 ,15,0 ,0 ,0 ,0 ,12,3 ,3 ,15,0 ,0 ,0 ,0 ,0 ,1 ,0 ,2 ,0 ,0
	.BYTE 0 ,1 ,0 ,0 ,0 ,1 ,0 ,2 ,0 ,0 ,12,3 ,3 ,15,0 ,1 ,0 ,0 ,12,3 ,3 ,15,2 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0
	.BYTE 0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,1 ,0 ,12,3 ,3 ,11,14,14,14,14,8 ,3 ,3 ,15,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,2
	.BYTE 0 ,2 ,0 ,0 ,2 ,0 ,0 ,0 ,2 ,0 ,12,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,15,0 ,2 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0
	.BYTE 0 ,1 ,0 ,0 ,2 ,0 ,0 ,1 ,0 ,0 ,12,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,15,2 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0
	.BYTE 0 ,0 ,1 ,2 ,0 ,0 ,1 ,2 ,0 ,0 ,0 ,13,13,13,13,13,13,13,13,13,13,0 ,1 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0
	.BYTE 0 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,1 ,2 ,0 ,1 ,0 ,2 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,2 ,0 ,2
	.BYTE 1 ,0 ,1 ,2 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,2 ,0 ,0 ,0 ,0
	.BYTE 0 ,0 ,2 ,0 ,0 ,2 ,1 ,2 ,0 ,0 ,2 ,0 ,1 ,0 ,0 ,2 ,0 ,0 ,1 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0
	.BYTE 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,1 ,0
	.BYTE 0 ,0 ,2 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0
	.BYTE 0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,1 ,0 ,0 ,0 ,0
	.BYTE 0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,2
	.BYTE 0 ,0 ,2 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,2 ,0 ,1 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0
	.BYTE 0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,2 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,2 ,0 ,1 ,0 ,0 ,0
	.BYTE 0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,1 ,0 ,2 ,0 ,0 ,1 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,2 ,0
	.BYTE 0 ,0 ,0 ,0 ,0 ,1 ,0 ,2 ,0 ,0 ,2 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,1 ,0 ,0
	.BYTE 0 ,1 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,2 ,0 ,0 ,0 ,1 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,2
	.BYTE 0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,1 ,2 ,0 ,0 ,0 ,0
	.BYTE 0 ,0 ,0 ,0 ,1 ,0 ,1 ,0 ,0 ,2 ,0 ,0 ,1 ,0 ,0 ,2 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,1
	.BYTE 0 ,1 ,0 ,2 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,1 ,0 ,0 ,2 ,0 ,0 ,0 ,0
	.BYTE 0 ,0 ,0 ,1 ,0 ,1 ,0 ,2 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,1 ,0 ,0 ,1 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,2
	.BYTE 0 ,0 ,2 ,0 ,0 ,0 ,2 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,2 ,0 ,0
Tilemap_END:
	
