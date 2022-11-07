
ChibiSound:		;TVPPPPPP T=tone (Tone/Noise) V=Volume (Low/High) P=Pitch
;Turn on Sound
		mov r1,#0x4000000	;4000084h - SOUNDCNT_X (NR52) - Sound on/off (R/W)
		add r1,r1,#0x84
				; M---4321
		mov r2,#0b10000000
		strh r2,[r1]
		
;Branch based on sound type
		tst r0,#0b11111111
		beq ChibiSound_Silent
		
		tst r0,#0b10000000
		bne ChibiSound_Noise
		
;Volume		
		mov r1,#0x4000000	;4000062h - SOUND1CNT_H (NR11, NR12) - Channel 1 Duty/Len/Envelope (R/W)
		add r1,r1,#0x62
		
		and r2,r0,#0b01000000
		mov r2,r2,asl #8
		mov r2,r2,asl #1
				    ;VVVVDSSSWWLLLLLL - L=length W=wave pattern duty S=envelope Step D= env direction V=Volume
		orr r2,r2,#0b0111000000000000	
		strh r2,[r1]
		
;Frequency (Pitch)
		mov r1,#0x4000000	;4000064h - SOUND1CNT_X (NR13, NR14) - Channel 1 Frequency/Control (R/W)
		add r1,r1,#0x64
		
		and r2,r0,#0b00111111
		eor r2,r2,#0b00111111		;Flip pitch
		mov r2,r2,asl #4
				    ;IL---FFFFFFFFFFF
		orr r2,r2,#0b1000000000000000	;I=Init sound F=Frequency
		strh r2,[r1]
		
;Master Volume	Channel 1 on	
		mov r1,#0x4000000	;4000080h - SOUNDCNT_L (NR50, NR51) - Channel L/R Volume/Enable (R/W)
		add r1,r1,#0x80
				 ;LLLLRRRR-lll-rrr  - LR=Channel 4331 on (1=on) ... lr=master volume (7=max)
		mov r2,#0b0001000101110111	;Master 2 on
		strh r2,[r1]
	MOV pc,lr
	
ChibiSound_Silent:
		mov r1,#0x4000000	;4000080h - SOUNDCNT_L (NR50, NR51) - Channel L/R Volume/Enable (R/W)
		add r1,r1,#0x80
				 ;LLLLRRRR-lll-rrr  - LR=Channel 4331 on (1=on) ... lr=master volume (7=max)
		mov r2,#0b0000000000000000
		strh r2,[r1]
	MOV pc,lr

ChibiSound_Noise:

;Volume
		mov r1,#0x4000000	;4000078h - SOUND4CNT_L (NR41, NR42) - Channel 4 Length/Envelope (R/W)
		add r1,r1,#0x78
		
		and r2,r0,#0b01000000
		mov r2,r2,asl #8
		mov r2,r2,asl #1
				    ;VVVVDSSSWWLLLLLL
		orr r2,r2,#0b0111000000000000
		strh r2,[r1]
		
;Frequency (Pitch)
		mov r1,#0x4000000	;400007Ch - SOUND4CNT_H (NR43, NR44) - Channel 4 Frequency/Control (R/W)
		add r1,r1,#0x7C
		
		and r2,r0,#0b00111100
		mov r2,r2,asl #2
				    ;IL------FFFFCDDD
		orr r2,r2,#0b1000000000000000
		strh r2,[r1]
		
;Master Volume	Channel 4 on	
		mov r1,#0x4000000	;4000080h - SOUNDCNT_L (NR50, NR51) - Channel L/R Volume/Enable (R/W)
		add r1,r1,#0x80
				 ;LLLLRRRR-lll-rrr  - LR=Channel 4331 on (1=on) ... lr=master volume (7=max)
		mov r2,#0b1000100001110111	;Master 2 on
		strh r2,[r1]
	MOV pc,lr
	
	
	
	