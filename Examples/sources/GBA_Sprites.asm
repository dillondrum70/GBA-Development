	.include "\SrcALL\V1_Header.asm"

	mov sp,#0x03000000			;Init Stack Pointer

	
;Nintendo DDS
	
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
		;Bit  Engine Expl.
		;0-2   A+B   BG Mode
		;3     A     BG0 2D/3D Selection (instead CGB Mode) (0=2D, 1=3D)
		;4     A+B   Tile OBJ Mapping        (0=2D; max 32KB, 1=1D; max 32KB..256KB)
		;5     A+B   Bitmap OBJ 2D-Dimension (0=128x512 dots, 1=256x256 dots)
		;6     A+B   Bitmap OBJ Mapping      (0=2D; max 128KB, 1=1D; max 128KB..256KB)
		;7-15  A+B   Same as GBA
		;16-17 A+B   Display Mode (Engine A: 0..3, Engine B: 0..1, GBA: Green Swap)
		;18-19 A     VRAM block (0..3=VRAM A..D) (For Capture & above Display Mode=2)
		;20-21 A+B   Tile OBJ 1D-Boundary   (see Bit4)
		;22    A     Bitmap OBJ 1D-Boundary (see Bit5-6)
		;23    A+B   OBJ Processing during H-Blank (was located in Bit5 on GBA)
		;24-26 A     Character Base (in 64K steps) (merged with 16K step in BGxCNT)
		;27-29 A     Screen Base (in 64K steps) (merged with 2K step in BGxCNT)
		;30    A+B   BG Extended Palettes   (0=Disable, 1=Enable)
		;31    A+B   OBJ Extended Palettes  (0=Disable, 1=Enable)
	
	;4000240h - NDS9 - VRAMCNT_A - 8bit - VRAM-A (128K) Bank Control (W)
		;0-2   VRAM MST              ;Bit2 not used by VRAM-A,B,H,I
		;3-4   VRAM Offset (0-3)     ;Offset not used by VRAM-E,H,I
		;5-6   Not used
		;7     VRAM Enable (0=Disable, 1=Enable)
	
	.ifdef BuildNDS
		mov r0, #0x4000000
		add r0, r0, #0x304	;4000304h - NDS9 - POWCNT1 - Graphics Power Control Register (R/W)
		mov r1, #0x8003		;2D + Enable
		str r1, [r0]

		mov r0, #0x04000000	;4000000h - DISPCNT - LCD Control (Read/Write)
		mov r1, #0x00010100
		str r1, [r0]		;2  Engine A only: VRAM Display (Bitmap from block selected in DISPCNT.18-19)

		mov r0, #0x04000000
		add r0, r0, #0x240
		mov r1, #0x81		;Enable
		strb r1, [r0]		;4000240h - NDS9 - VRAMCNT_A - 8bit - VRAM-A (128K) Bank Control (W)
	.endif

	
;GameBoy Advance

	;4000000h - DISPCNT - LCD Control (Read/Write)
		;Bit   Expl.
		;0-2   BG Mode                (0-5=Video Mode 0-5, 6-7=Prohibited)
		;3     Reserved / CGB Mode    (0=GBA, 1=CGB; can be set only by BIOS opcodes)
		;4     Display Frame Select   (0-1=Frame 0-1) (for BG Modes 4,5 only)
		;5     H-Blank Interval Free  (1=Allow access to OAM during H-Blank)
		;6     OBJ Character VRAM Mapping (0=Two dimensional, 1=One dimensional)
		;7     Forced Blank           (1=Allow FAST access to VRAM,Palette,OAM)
		;8     Screen Display BG0  (0=Off, 1=On)
		;9     Screen Display BG1  (0=Off, 1=On)
		;10    Screen Display BG2  (0=Off, 1=On)
		;11    Screen Display BG3  (0=Off, 1=On)
		;12    Screen Display OBJ  (0=Off, 1=On)
		;13    Window 0 Display Flag   (0=Off, 1=On)
		;14    Window 1 Display Flag   (0=Off, 1=On)
		;15    OBJ Window Display Flag (0=Off, 1=On)
 



	.ifdef BuildGBA
		mov r4,#0x04000000  ;4000000h - DISPCNT - LCD Control (Read/Write)
		mov r2,#0x100    	;1= Layer 0 on / 0= ScreenMode 0
		str	r2,[r4]         			
	.endif
		
;4000008h - BG0CNT - BG0 Control (R/W) (BG Modes 0,1 only)	
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

	
	mov r4,#0x04000000 	;4000008h - BG0CNT - BG0 Control (R/W) (BG Modes 0,1 only)
	add r4,r4,#0x08
	
	mov r2,#0x4004   		;$---4 = Patten Base address=0x06004000 	
	str	r2,[r4]    				;$4--- = ScreenSize=64x32 tilemap
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
	
	adr r1,Palettes			;Define palettes
	mov r2,#0x05000000			;-BBBBBGGGGGRRRRR
	mov r3,#16*2			;2 bytes per color
	bl LDIR16

	adr r1,TilePatterns		;Define Tilepatterns
	mov r2,#0x06004000
	mov r3,#TilePatterns_End-TilePatterns
	bl LDIR16
	

;Screen uses 2x 32x32 tilemaps to make 1x 64x32 tilemap	
	
	adr r1,Tilemap			;PPPPVHTTTTTTTTTT
								;P=Palette HV=HV flip T=Tilenum
								
	mov r2,#0x06000000		;SC0 (32x32 Left Tiles)
	mov r3,#32*32*2			;2 bytes per tile
	bl LDIR16

	adr r1,Tilemap
	mov r2,#0x06000800		;SC1 (32x32 Right Tiles)
	mov r3,#32*32*2			;2 bytes per tile
	bl LDIR16
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	adr r1,Palettes
	mov r2,#0x05000200			;Sprite Palettes
	mov r3,#16*2
	bl LDIR16
	
	.ifdef BuildGBA
		mov r2,#0x06010000		;Sprite Pattern Ram
	.endif
	
	.ifdef BuildNDS
		mov r0, #0x4000000
		add r0, r0, #0x241
		mov r1, #0x82	;Turn on Sprite RAM
		strb r1, [r0]	;4000241h - NDS9 - VRAMCNT_B - 8bit - VRAM-B (128K) Bank Control (W)
	
		mov r2,#0x06400000		;Sprite Pattern Ram
	.endif
	
	adr r1,TilePatterns
	mov r3,#TilePatterns_End-TilePatterns
	bl LDIR16					;Transfer Sprite patterns to Vram
	
	.ifdef BuildGBA
		mov r4,#0x04000000  ;DISPCNT -LCD Control
		mov r2,#0x1140    	;1= Sprite on / 1= Layer 0 on / 4= 1D Tile layout 
		str	r2,[r4]         	;0= ScreenMode 0 
	.endif
	
	.ifdef BuildNDS
		mov r0, #0x04000000	;4000000h - DISPCNT - LCD Control (Read/Write)
		mov r1, #0x00011110
		str r1, [r0]		;1=Display On / 1= Sprite on / 1= Layer 0 on
	.endif							;1= 1D Tile layout / 0= ScreenMode 0 

;4000000h - GBA DISPCNT - LCD Control (Read/Write)
  ;Bit   Expl.
  ;0-2   BG Mode                (0-5=Video Mode 0-5, 6-7=Prohibited)
  ;3     Reserved / CGB Mode    (0=GBA, 1=CGB; can be set only by BIOS opcodes)
  ;4     Display Frame Select   (0-1=Frame 0-1) (for BG Modes 4,5 only)
  ;5     H-Blank Interval Free  (1=Allow access to OAM during H-Blank)
  ;6     OBJ Character VRAM Mapping (0=Two dimensional, 1=One dimensional)
  ;7     Forced Blank           (1=Allow FAST access to VRAM,Palette,OAM)
  ;8     Screen Display BG0  (0=Off, 1=On)
  ;9     Screen Display BG1  (0=Off, 1=On)
  ;10    Screen Display BG2  (0=Off, 1=On)
  ;11    Screen Display BG3  (0=Off, 1=On)
  ;12    Screen Display OBJ  (0=Off, 1=On)
  ;13    Window 0 Display Flag   (0=Off, 1=On)
  ;14    Window 1 Display Flag   (0=Off, 1=On)
  ;15    OBJ Window Display Flag (0=Off, 1=On)

 
 
;4000000h - NDS DISPCNT - LCD Control (Read/Write)
; Bit  Engine Expl.
 ; 0-2   A+B   BG Mode
 ; 3     A     BG0 2D/3D Selection (instead CGB Mode) (0=2D, 1=3D)
 ; 4     A+B   Tile OBJ Mapping        (0=2D; max 32KB, 1=1D; max 32KB..256KB)
 ; 5     A+B   Bitmap OBJ 2D-Dimension (0=128x512 dots, 1=256x256 dots)
 ; 6     A+B   Bitmap OBJ Mapping      (0=2D; max 128KB, 1=1D; max 128KB..256KB)
 ; 7-15  A+B   Same as GBA
 ; 16-17 A+B   Display Mode (Engine A: 0..3, Engine B: 0..1, GBA: Green Swap)
 ; 18-19 A     VRAM block (0..3=VRAM A..D) (For Capture & above Display Mode=2)
;  20-21 A+B   Tile OBJ 1D-Boundary   (see Bit4)
;  22    A     Bitmap OBJ 1D-Boundary (see Bit5-6)
;  23    A+B   OBJ Processing during H-Blank (was located in Bit5 on GBA)
;  24-26 A     Character Base (in 64K steps) (merged with 16K step in BGxCNT)
;  27-29 A     Screen Base (in 64K steps) (merged with 2K step in BGxCNT)
;  30    A+B   BG Extended Palettes   (0=Disable, 1=Enable)
;  31    A+B   OBJ Extended Palettes  (0=Disable, 1=Enable)



	
;16 color sprite 2x2 tile
	
	mov r0,#0x01	   		;Sprite Num
;S=Shape (Square /HRect / Vrect)  C=Colors(16/256)  M=Mosiac  
;T=Transparent  D=Disable/Doublesize  R=Rotation  Y=Ypos
			; SSCMTTDRYYYYYYYY
	mov r1,#0b0000000001100000		;Ypos
	
;S=Obj Size  VH=V/HFlip  R=Rotation parameter  X=Xpos
			; SSVHRRRXXXXXXXXX
	mov r2,#0b0100000011000000		;Xpos
	
;C=Color palette   P=Priority   T=Tile Number
			; CCCCPPTTTTTTTTTT
	mov r3,#0b0000000000000110   	;Tile
	bl SetSprite

;16 color sprite (Wide 2x1 using tile patterns)
	mov r0,#0x02	   		;Sprite Num
	mov r1,#0x4020   		;Ypos
	mov r2,#0x0040   		;Xpos
	mov r3,#0x0001   		;Tile
	bl SetSprite
	
;256 color sprite
	mov r0,#0x00	   		;Sprite Num
	mov r1,#0x2030   		;Ypos
	mov r2,#0x4060   		;Xpos	4=256 color
	mov r3,#0x000A   		;Tile 
	bl SetSprite	
;(each 256 color tile takes 2x 16 color ones)
	
	
InfLoop:
	
	
	mov r4,#0x04000000  
	add r4,r4,#0x10		;4000010h - BG0HOFS - BG0 X-Offset (W)
	strh	r2,[r4]    
	add r4,r4,#0x02		;4000012h - BG0VOFS - BG0 Y-Offset (W)
	strh	r2,[r4]    
	
	add r2,r2,#1
	
	.ifdef BuildGBA
		mov r3,#0x10000
	.endif
	.ifdef BuildNDS
		mov r3,#0x100000
	.endif
	
Delay:	
	subs r3,r3,#1
	bne Delay
	
    b InfLoop			;Halt
	
	

	
SetSprite:	;Set Sprite R0... Set Attribute words 1,2,3 to R1,R2,R3
	STMFD sp!,{r0-r12, lr}
	
		mov r4,#0x07000000  	;Sprite (OAM) settings
		add r4,r4,r0,asl #3		;8 bytes per sprite (6 used)	
		
		;S=Shape (Square /HRect / Vrect)  C=Colors(16/256)  M=Mosiac  
		;T=Transparent  D=Disable/Doublesize  R=Rotation  Y=Ypos
		strH	r1,[r4]    		;1st attrib - SSCMTTDRYYYYYYYY
			
		add r4,r4,#2
		
		;S=Obj Size  VH=V/HFlip  R=Rotation parameter  X=Xpos
		strH	r2,[r4]    		;2nd attrib - SSVHRRRXXXXXXXXX
		
		add r4,r4,#2
		
		;C=Color palette   P=Priority   T=Tile Number
		strH	r3,[r4]    		;3rd attrib - CCCCPPTTTTTTTTTT
	
	LDMFD sp!,{r0-r12, pc}	
		
		
	
	
LDIR16:			;Transfer R3 bytes from [R1] to [R2]
	STMFD sp!,{r0-r12, lr}
LDIR16B:	
		ldrH r5,[r1],#2
		strH r5,[r2],#2	
		
		subs r3, r3, #2		
		bne LDIR16B	
	LDMFD sp!,{r0-r12, pc}	

	
	
			
	
Palettes:
    .word 0b0000000000000000; ;0  %-BBBBBGGGGGRRRRR
    .word 0b0010100101001010; ;1  %-BBBBBGGGGGRRRRR
    .word 0b0101011010110101; ;2  %-BBBBBGGGGGRRRRR
    .word 0b0111111111111111; ;3  %-BBBBBGGGGGRRRRR
    .word 0b0100000000000000; ;4  %-BBBBBGGGGGRRRRR
    .word 0b0100000000010000; ;5  %-BBBBBGGGGGRRRRR
    .word 0b0100001000000000; ;6  %-BBBBBGGGGGRRRRR
    .word 0b0100111110010011; ;7  %-BBBBBGGGGGRRRRR
    .word 0b0111110000010000; ;8  %-BBBBBGGGGGRRRRR
    .word 0b0000000000011111; ;9  %-BBBBBGGGGGRRRRR
    .word 0b0000001111100000; ;10  %-BBBBBGGGGGRRRRR
    .word 0b0000001111111111; ;11  %-BBBBBGGGGGRRRRR
    .word 0b0111110000000000; ;12  %-BBBBBGGGGGRRRRR
    .word 0b0111110000011111; ;13  %-BBBBBGGGGGRRRRR
    .word 0b0111111111100000; ;14  %-BBBBBGGGGGRRRRR
	.word 0b0111111111111111; ;15  %-BBBBBGGGGGRRRRR
	
	
;Same format as MSX2 (linear data not bitplanes)
	
TilePatterns:	
	.incbin "\ResALL\TilesGBA16color.raw"
	.incbin "\ResALL\HSpriteGBA.RAW"
	.incbin "\ResALL\HSpriteGBA_256.RAW"
TilePatterns_End:	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tilemap:	;Tile numbers 32*32 - PPPPVHTTTTTTTTTT
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,2,0,0,0,0,0,0,0,0,0,2,0,0,2,0,0,2,0,0,0,0,0,0,0,2,0,0,2,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,3,0,3,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,2,0,0,2,0,0,0
	.word 0,0,3,3,3,4,3,4,3,0,0,0,0,0,0,0,0,0,0,0,3,3,0,0,0,0,0,0,0,0,0,3
	.word 0,3,4,4,4,4,4,4,4,3,0,5,0,0,0,0,0,3,3,3,4,4,3,3,0,0,0,0,0,3,3,4
	.word 3,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,4,4,4,4,4,4,4,3,3,3,3,3,4,4,4
	.word 3,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,4,4,4,4,4,4,4,3,3,3,3,3,4,4,4
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 3,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,4,4,4,4,4,4,4,3,3,3,3,3,4,4,4
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 3,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,4,4,4,4,4,4,4,3,3,3,3,3,4,4,4
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 3,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,4,4,4,4,4,4,4,3,3,3,3,3,4,4,4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		

.include "\SrcALL\V1_Footer.asm"