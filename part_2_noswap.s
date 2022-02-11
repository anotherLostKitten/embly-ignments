.global _start

len: .word 10
list: .word 68,-22,-31,75,-10,-61,39,92,94,-55

// A1: address of start of array
// A2: low index
// A3: high index
// sorts array in place
quicksort:
	cmp a2, a3
	bxge lr
	push {a3, v1, v2, v3, lr}
	mov a4, a2 // a4 = pivot location
	ldr v2, [a1, a2,lsl#2] // v2 = pivot value
qsiloop: // find leftmost number greater than pivot, save index to a2
	ldr v3, [a1, a2,lsl#2] // v1 = possible out of order value
	cmp v3, v2
	bgt qsjloop
	add a2, a2, #1
	cmp a2, a3 // comparing to the end of the list vs comparing to j is the same
	blt qsiloop
qsjloop: // find rightmost number less than pivot at, save index to a3
	ldr v1, [a1, a3,lsl#2]
	cmp v1, v2
	subgt a3, a3, #1
	bgt qsjloop
	cmp a2, a3
	// swap if out of order
	bge qsloopout
	str v3, [a1, a3,lsl#2]
	str v1, [a1, a2,lsl#2]
	b qsiloop // repeat if maybe more out of order elements
qsloopout:
	mov a2, a4
	// swap pivot with last number smaller than it
	str v2, [a1, a3,lsl#2]
	str v1, [a1, a2,lsl#2]
	sub a3, a3, #1
	bl quicksort
	add a2, a3, #2
	pop {a3, v1, v2, v3, lr}	
	b quicksort
	
	
_start:
	ldr a1, =list
	ldr a3, len
	mov a2, #0
	sub a3, a3, #1
	bl quicksort
	
end:
	b end
	
	
