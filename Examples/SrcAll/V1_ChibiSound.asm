	.ifdef BuildGBA
		.include "\SrcGBA\V1_ChibiSound.asm"
	.endif
	.ifdef BuildNDS
		.include "\SrcNDS\V1_ChibiSound.asm"
	.endif