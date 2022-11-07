	.include "\SrcALL\V1_Header.asm"
	bl ScreenInit
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	bl monitor	;Branch and Link to the Monitor Subroutine (call)
	
infloop:		;Label called infloop (Note: Colon and not inset)

	b infloop	;Branch to the InfLoop label (jump)
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	.include "/srcALL/V1_Monitor.asm"
	.include "/srcALL/V1_BitmapMemory.asm"

BitmapFont:
	.incbin "\ResALL\Font96.FNT"

	