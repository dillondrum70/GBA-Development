;r1 = dividend
;r2 = divisor
;Don't bother saving r2, not changed
MOD:
STMFD sp!, {r1, lr}
	ADD r1, r1, r2	;Gives the result of flipping bits from r2 in r1
	AND r0, r1, r2	;Thus, AND will give us the bits that represent the remainder
LDMFD sp!, {r1, pc}

;http://www.tofla.iconbar.com/tofla/arm/arm02/index.htm
;r1 = dividend
;r2 = divisor
DIV:
STMFD sp!, {r1-r4, lr}
	;divide by 0 check
	CMP r2, #0
	BEQ DIV_End
	
	EOR r0, r0, r0
	MOV r3, #1	;set bit 0, will be shifted left and right
	
	;Bitshift both left until divisor is almost greater than dividend
	DIV_Start:
		CMP r2, r1
		MOVLS r2, r2, LSL#1	;r2 will set the corresponding bit in r3 for every time subtraction succeeds
		MOVLS r3, r3, LSL#1	;Bitshift r3 left to see the limit of the flag, how far r2 must go
	BLS DIV_Start
	
	DIV_Next:
		CMP r1, r2	;Check if another subtraction can be made, carry flag set if (r1 > r2)
		SUBCS r1, r1, r2	;Subtract if carry flag is set in result
		ADDCS r0, r0, r3	;Add current bit in r3 to accumulator, r0
		
		MOVS r3, r3, LSR#1	;Shift r3 into carry flag
		MOVCC r2, r2, LSR#1	;if bit 0 of r3 is o, shift r2 right (carry clear)
	
		BCC DIV_Next	;Loop while carry is clear, carry is not clear when r1 < r2 and subtraction yields our result
		
	DIV_End:
LDMFD sp!, {r1-r4, pc}