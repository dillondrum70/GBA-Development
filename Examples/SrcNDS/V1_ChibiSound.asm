
	;Send Settings to ChibiSound Driver on Arm7
ChibiSound:
		mov r1,#ChibiSoundb
		strb r0,[r1,#0]		;1st Byte= Chibisound Command
		mov r2,#1
		strb r2,[r1,#1]		;2nd byte= NZ=process!
	MOV pc,lr
	
	