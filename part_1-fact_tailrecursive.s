.global _start

result: .space 12

// pre  A1 n
// post A1 n! (result)
fac:
	mov a2, a1
	mov a1, #1
facr:
	cmp a2, #2
	bxlt lr
	mul a1, a1, a2
	sub a2, a2, #1
	b facr

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
	