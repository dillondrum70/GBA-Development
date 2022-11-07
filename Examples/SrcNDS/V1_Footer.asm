Arm9_End:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Arm 7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;.balign 0x1000
;*=0x03800000
Arm7_Start:
Arm7_InfLoop:
	.ifdef ChibiSoundb
		.include "\SrcNDS\V1_ChibiSoundDriver.asm"
	.endif

	.include "\SrcNDS\V1_JoyPenDriver.asm"
	b Arm7_InfLoop		
Arm7_End:	
	