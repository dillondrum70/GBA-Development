	.ifdef BuildROS
		.include "\SrcROS\V1_BitmapMemory.asm"
	.endif
	.ifdef BuildGBA
		.ifdef Bmp256
			.include "\SrcGBA\V1_BitmapMemory_256Color.asm"
		
		.else
			.include "\SrcGBA\V1_BitmapMemory.asm"
		.endif
	.endif
	.ifdef BuildNDS
		.include "\SrcNDS\V1_BitmapMemory.asm"
	.endif