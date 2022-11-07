
;See if we have a command
		mov r1,#ChibiSoundb
		ldrb r0,[r1,#1]		;2nd byte= NZ=process!
		cmp r0,#0
		beq ChibiSoundDriverDone
	
;See if we need to mute
		ldrb r0,[r1,#0]		;1st Byte= Chibisound Command
		cmp r0,#0
		bne ChibiSoundDriverMakeSound

;ChibiSoundDriverMute
		mov r1,#0x4000000 ;4000500h - NDS7 - SOUNDCNT - Sound Control Register (R/W)
		add r1,r1,#0x500
				;M-31RRLL-vvvvvvv
		mov r2,#0b000000000000000
		str r2,[r1]
		b ChibiSoundDriverDone
		
ChibiSoundDriverMakeSound:
		
;Turn on Sound		
		mov r1,#0x4000000 ;4000304h - POWCNT2 - Sound/Wifi Power Control Register (R/W)
		add r1,r1,#0x304
		mov r2,#1
		str r2,[r1]
		
;Source Sample 
		mov r1,#0x4000000 ;40004x4h - SOUNDxSAD - Sound Channel X Data Source Register (W) - aligned to a 32 bit boundary (4 byte)
		add r1,r1,#0x404
		adrl r2,WavTone					;Tone Sample
		tst r0,#0b10000000		;Noise Bit
		beq ChibiSoundDriverTone
		adrl r2,WavNoise				;Noise Sample
ChibiSoundDriverTone:
		str r2,[r1]

;Sample Loop Start
		mov r1,#0x4000000 ;40004xAh - SOUNDxPNT - Sound Channel X Loopstart Register (W)
		add r1,r1,#0x40A
		mov r2,#0				;Loop From First byte
		str r2,[r1]
;Sample Length
		mov r1,#0x4000000 ;40004xCh - SOUNDxLEN - Sound Channel X Length Register (W)
		add r1,r1,#0x40C
		mov r2,#32 				;Sound Samples in bytes /4 
		str r2,[r1]
		
;Frequency
		mov r1,#0x4000000 ;40004x8h - SOUNDxTMR - Sound Channel X Timer Register (W)
		add r1,r1,#0x408
		and r2,r0,#0b00111111
		eor r2,r2,#0b00111111
		add r2,r2,#0b01000000
		mov r2,r2,asl #8
		mov r2,r2,asl #1
		str r2,[r1]
		
;Volume	
		mov r1,#0x4000000 ;4000500h - SOUNDCNT - Sound Control Register (R/W)
		add r1,r1,#0x500
				;M-31RRLL-VVVVVVV
		mov r2,#0b000000001111111
					;M-31RRLL-VVVVVVV
		add r2,r2,#0b1011000000000000
		str r2,[r1]
		
;Start the Sound	
		mov r1,#0x4000000 ;40004x0h - SOUNDxCNT - Sound Channel X Control Register (R/W)
		add r1,r1,#0x400
		and r2,r0,#0b01000000
				   ;SFFRRWWW-PPPPPPPH-----DD-vvvvvvv FF=format (0=8bit signed) v=volume
		orr r2,r2,#0b0000000000000000000000000111111
					;SFFRRWWW-PPPPPPPH-----DD-vvvvvvv S=Start R=Repeat (Loop inf) P=Panning (64=center)
		add r2,r2,#0b10001000010000000000000000000000
		str r2,[r1]

		b ChibiSoundDriverDone
		


	.balign 4
WavTone:	;8 bit 32x4 samples (signed)
	.byte 000,128,000,128,000,128,000,128	
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128	;32
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128	;64
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128	;96
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128
	.byte 000,128,000,128,000,128,000,128	;128
	
WavNoise:	;8 bit 32x4 samples
	.byte 135,217,250,193, 80,152,194,  2
	.byte 228, 51,171,121, 73,117,107,210
	.byte 195,184, 71, 82,141,186, 62,131
	.byte 135,217,250,193, 80,152,194,  2	;32
	.byte 135,217,250,193, 80,152,194,  2
	.byte 228, 51,171,121, 73,117,107,210
	.byte 106,228,241,131,229,150,118, 81	
	.byte 195,184, 71, 82,141,186, 62,131	;64
	.byte 135,217,250,193, 80,152,194,  2
	.byte 106,228,241,131,229,150,118, 81
	.byte 195,184, 71, 82,141,186, 62,131
	.byte 228, 51,171,121, 73,117,107,210	;96
	.byte 228, 51,171,121, 73,117,107,210
	.byte 106,228,241,131,229,150,118, 81
	.byte 195,184, 71, 82,141,186, 62,131
	.byte 106,228,241,131,229,150,118, 81	;128
Sound_End:	

ChibiSoundDriverDone:

