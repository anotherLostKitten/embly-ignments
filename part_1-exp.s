.global _start

result: .space 16

// pre  A1: x
//      A2: n
// post A1: x^n
exp:
	mov a3, a1
	mov a1, #1
expl:
	subs a2, a2, #1
	bxmi lr
	mul a1, a1, a3
	b expl


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