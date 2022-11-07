
	.org 0x02000000-0x8000
HeaderStart:
;  000h    12    Game Title  (Uppercase ASCII, padded with 00h)
		;  123456789012
	.ascii "LEARNASM.NET"
;  00Ch    4     Gamecode    (Uppercase ASCII, NTR-<code>)        (0=homebrew)
	.ascii "0000"
;  010h    2     Makercode   (Uppercase ASCII, eg. "01"=Nintendo) (0=homebrew)
	.ascii "00"
;  012h    1     Unitcode    (00h=NDS, 02h=NDS+DSi, 03h=DSi) (bit1=DSi)
	.byte 0x00
;  013h    1     Encryption Seed Select (00..07h, usually 00h)
	.byte 0x00
;  014h    1     Devicecapacity         (Chipsize = 128KB SHL nn) (eg. 7 = 16MB)
	.byte 0x00
;  015h    7     Reserved    (zero filled)
	.byte 0,0,0,0,0,0,0
;  01Ch    1     Reserved    (zero)                      (except, used on DSi)
	.byte 0x00
;  01Dh    1     NDS Region  (00h=Normal, 80h=China, 40h=Korea) (other on DSi)
	.byte 0x00
;  01Eh    1     ROM Version (usually 00h)
	.byte 0x00
;  01Fh    1     Autostart (Bit2: Skip "Press Button" after Health and Safety)
	.byte 0x04     ;  1
;                (Also skips bootmenu, even in Manual mode & even Start pressed)


;  020h    4     ARM9 rom_offset    (4000h and up, align 1000h)
	.long Arm9_Start-HeaderStart
;  024h    4     ARM9 entry_address (2000000h..23BFE00h)
	.long Arm9_Start
;  028h    4     ARM9 ram_address   (2000000h..23BFE00h)
	.long Arm9_Start
;  02Ch    4     ARM9 size          (max 3BFE00h) (3839.5KB)
	.long Arm9_End-Arm9_Start
	
;  030h    4     ARM7 rom_offset    (8000h and up)
	.long Arm7_Start-HeaderStart
;  034h    4     ARM7 entry_address (2000000h..23BFE00h, or 37F8000h..3807E00h)
	;.long Arm7_Start
	.long 0x03800000
;  038h    4     ARM7 ram_address   (2000000h..23BFE00h, or 37F8000h..3807E00h)
	;.long Arm7_Start
	.long 0x03800000
;  03Ch    4     ARM7 size          (max 3BFE00h, or FE00h) (3839.5KB, 63.5KB)
	.long Arm7_End-Arm7_Start
	
	
;  040h    4     File Name Table (FNT) offset
	.long 0
;  044h    4     File Name Table (FNT) size
	.long 0
;  048h    4     File Allocation Table (FAT) offset
	.long 0
;  04Ch    4     File Allocation Table (FAT) size
	.long 0
;  050h    4     File ARM9 overlay_offset
	.long 0
;  054h    4     File ARM9 overlay_size
	.long 0
;  058h    4     File ARM7 overlay_offset
	.long 0
;  05Ch    4     File ARM7 overlay_size
	.long 0
;  060h    4     Port 40001A4h setting for normal commands (usually 00586000h)
	.long 0x00586000
;  064h    4     Port 40001A4h setting for KEY1 commands   (usually 001808F8h)
	.long 0x001808F8
;  068h    4     Icon/Title offset (0=None) (8000h and up)
	.long 0
;  06Ch    2     Secure Area Checksum, CRC-16 of [[020h]..00007FFFh]
	.byte 0,0
;  06Eh    2     Secure Area Delay (in 131kHz units) (051Eh=10ms or 0D7Eh=26ms)
	.byte 0,0
;  070h    4     ARM9 Auto Load List Hook RAM Address (?) ;\endaddr of auto-load
	.long 0
;  074h    4     ARM7 Auto Load List Hook RAM Address (?) ;/functions
	.long 0
;  078h    8     Secure Area Disable (by encrypted "NmMdOnly") (usually zero)
	.byte 0,0,0,0,0,0,0,0
;  080h    4     Total Used ROM size (remaining/unused bytes usually FFh-padded)
	.long 0
	
        
;  084h    4     ROM Header Size (4000h)
	.long 0x4000
	
;  088h    28h   Reserved (zero filled; except, [88h..93h] used on DSi)
	.byte 0x04,0x13,0x80,0xE5,0x00,0x20,0x80,0xE5     ;  8
	.byte 0x40,0x32,0x80,0xE5,0x1A,0x05,0xA0,0xE3,0x1F,0x10,0xA0,0xE3,0x03,0x29,0xA0,0xE3     ;  9
    .byte 0xB2,0x10,0xC0,0xE0,0x01,0x20,0x52,0xE2,0xFC,0xFF,0xFF,0x1A,0x50,0x41,0x53,0x53     ; A
;  0B0h    10h   Reserved (zero filled; or "DoNotZeroFillMem"=unlaunch fastboot)
	.byte 0xFE,0xFF,0xFF,0xEA,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ; B
;  0C0h    9Ch   Nintendo Logo (compressed bitmap, same as in GBA Headers)
	.byte 0xC8,0x60,0x4F,0xE2,0x01,0x70,0x8F,0xE2,0x17,0xFF,0x2F,0xE1,0x12,0x4F,0x11,0x48     ; C
	.byte 0x12,0x4C,0x20,0x60,0x64,0x60,0x7C,0x62,0x30,0x1C,0x39,0x1C,0x10,0x4A,0x00,0xF0     ; D
    .byte 0x14,0xF8,0x30,0x6A,0x80,0x19,0xB1,0x6A,0xF2,0x6A,0x00,0xF0,0x0B,0xF8,0x30,0x6B     ; E
    .byte 0x80,0x19,0xB1,0x6B,0xF2,0x6B,0x00,0xF0,0x08,0xF8,0x70,0x6A,0x77,0x6B,0x07,0x4C     ; F
    .byte 0x60,0x60,0x38,0x47,0x07,0x4B,0xD2,0x18,0x9A,0x43,0x07,0x4B,0x92,0x08,0xD2,0x18     ; 10
    .byte 0x0C,0xDF,0xF7,0x46,0x04,0xF0,0x1F,0xE5,0x00,0xFE,0x7F,0x02,0xF0,0xFF,0x7F,0x02     ; 11
    .byte 0xF0,0x01,0x00,0x00,0xFF,0x01,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00     ; 12
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ; 13
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ; 14
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
;  15Ch    2     Nintendo Logo Checksum, CRC-16 of [0C0h-15Bh], fixed CF56h
	.byte 0x1A,0x9E
;  15Eh    2     Header Checksum, CRC-16 of [000h-15Dh]
	.byte 0x7B,0xEB     ; 15
;  160h    4     Debug rom_offset   (0=none) (8000h and up)       ;only if debug
	.long 0
;  164h    4     Debug size         (0=none) (max 3BFE00h)        ;version with
	.long 0
;  168h    4     Debug ram_address  (0=none) (2400000h..27BFE00h) ;SIO and 8MB
	.long 0
;  16Ch    4     Reserved (zero filled) (transferred, and stored, but not used)
	.long 0
;  170h    90h   Reserved (zero filled) (transferred, but not stored in RAM)

	.space 0x90
	;Pad to 0x2000000
	.space 0x7E00
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Arm 9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Arm9_Start:
	mov sp,#0x03000000
	
	
.equ userram,0x02F10000	
.equ RamArea,0x02F00000
.equ MonitorWidth, 8