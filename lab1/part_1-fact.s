.global _start

result: .space 12

// pre  A1 n
// post A1 n! (result)
// better to do this iteratively / tail recursively
fac:
	cmp a1, #2
	movlt a1, #1
	bxlt lr
	push {a1, lr}
	sub a1, a1, #1
	bl fac
	pop {a2}
	mul a1, a1, a2
	pop {pc}

_start:
	ldr v1, =result

	mov a1, #5
	bl fac
	str a1, [v1] //120 0x78
	
	mov a1, #10
	bl fac
	str a1, [v1, #4] //3628800 0x375f00
	
	mov a1, #0
	bl fac
	str a1, [v1, #8] //1 0x1
	
end:
	b end
	