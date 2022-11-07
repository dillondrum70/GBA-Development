	.ifdef BuildROS
		.include "\SrcROS\V1_Header.asm"
	.endif
	.ifdef BuildGBA
		.include "\SrcGBA\V1_Header.asm"
	.endif
	.ifdef BuildNDS
		.include "\SrcNDS\V1_Header.asm"
	.endif