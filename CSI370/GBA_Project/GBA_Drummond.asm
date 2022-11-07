;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.equ ram, 0x02000000	;RAM on the GBA starts at 0x02000000
.equ CursorX, ram+32	;32 bits past ram start
.equ CursorY, ram+33	;1 bit past CursorX

.org 0x08000000	;GBA ROM (the cartridge) Address starts at 0x08000000

