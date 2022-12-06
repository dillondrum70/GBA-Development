.EQU Ram, 0x02000000	;RAM on the GBA starts at 0x02000000, builds upwards, can store whatever we want whereever we want, just make sure it doesn't collide with other data in RAM or with Stack which builds down from 0x03000000

.EQU Stack, 0x03000000

;Used in a different screen mode

.EQU LCDControl, 0x04000000			;Controls which layers are on, what sceenmode we're in
.EQU ScanlineCounter, 0x04000006	;Stores how many lines have been written

.EQU BackgroundPaletteMemory, 0x05000000		;Location of GBA background palettes in memory
.EQU SpritePaletteMemory, 0x05000200	;Location of GBA hardware sprite palettes in memory memory

.EQU VramBase, 0x06000000	;Base of VRAM, where address of data that is written to the screen starts
.EQU VramTilemapPixels, 0x06004000	;Location of tile pixels patterns (images) in memory
.EQU VramBackground, 0x06000800	;Memory location in VRAM of background layer
.EQU VramSpritePixels, 0x06010000	;Location of GBA sprite pixels patterns (images) in memory

.EQU SpriteOAMSettings, 0x07000000	;Memory address for attributes for sprites that determine how they're drawn