.global _start

result: .space 16

// pre  A1: x
//      A2: n
// post A1: x^n
exp:
	tst a2, #1
	mov a3, a1
	moveq a1, #1 // a1 is 1 if n even, x if odd
	cmp a2, #1
	lsr a2, a2, #1
	bxle lr // return a1 for base cases (0 is even, a1 = 1; 1 odd, a1 = x)
	push {a1, lr}
	mul a1, a3, a3
	bl exp
	pop {a3}
	mul a1, a1, a3 // otherwise, a1 * exp(x * x, n >> 1); parity with n remains the same
	pop {pc}

_start:
	ldr v1, =result
	
	mov a1, #2
	mov a2, #10
	bl exp
	str a1, [v1] // 1024 0x400
	
	mov a1, #-5
	mov a2, #5
	bl exp
	str a1,[v1,#4] // -3125 -(0xc35) 0x..ff3cb
	
	mov a1, #9
	mov a2, #0
	bl exp
	str a1,[v1,#8] // 1 0x1
	
	mov a1, #9
	mov a2, #1
	bl exp
	str a1,[v1,#12] // 9 0x9
		
end:
	b end