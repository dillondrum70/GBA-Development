.EQU Ram, 0x02000000	;RAM on the GBA starts at 0x02000000, builds upwards, can store whatever we want whereever we want, just make sure it doesn't collide with other data in RAM or with Stack which builds down from 0x03000000

.EQU Stack, 0x03000000

.EQU VramBase, 0x06000000	;Base of VRAM, where address of data that is written to the screen starts

.EQU LCDControl, 0x04000000
.EQU ScanlineCounter, 0x04000006	;Stores how many lines have been written