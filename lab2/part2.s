.global _start

clock: .word 0
segment_encode:
.word 0b01001111010110110000011000111111 
.word 0b00000111011111010110110101100110
.word 0b01111100011101110110111101111111
.word 0b01110001011110010101111001011000

// Slider Switches Driver
// returns the state of slider switches in R0
// post- A1: slide switch state
.equ SW_ADDR, 0xFF200040
read_slider_switches_ASM:
	ldr a1, =SW_ADDR
    ldr a1, [a1]         // read slider switch state 
    bx lr

// LEDs Driver
// writes the state of LEDs (On/Off state) in A1 to the LEDs’ memory location
// pre-- A1: data to write to LED state
.equ LED_ADDR, 0xFF200000
write_LEDs_ASM:
	ldr a3, =LED_ADDR
    str a1, [a3]        // update LED state with the contents of A1
    bx lr

.equ SEG_ADDR, 0xFF200020
hex_mask:
	mov a3, a1
	mov a1, #0
	mov a2, #0
	tst a3, #1
	orrne a1, #0xFF
	tst a3, #2
	orrne a1, #0xFF00
	tst a3, #4
	orrne a1, #0xFF0000
	tst a3, #8
	orrne a1, #0xFF000000
	tst a3, #16
	orrne a2, #0xFF
	tst a3, #32
	orrne a2, #0xFF00
	bx lr
HEX_clear_ASM:
	push {lr}
	bl hex_mask
	ldr a3, =SEG_ADDR
	ldr a4, [a3]
	bic a4, a4, a1
	str a4, [a3]
	ldr a4, [a3, #16]
	bic a4, a4, a2
	str a4, [a3, #16]
	pop {pc}

HEX_flood_ASM:
	push {lr}
	bl hex_mask
	ldr a3, =SEG_ADDR
	ldr a4, [a3]
	orr a4, a4, a1
	str a4, [a3]
	ldr a4, [a3, #16]
	orr a4, a4, a2
	str a4, [a3, #16]
	pop {pc}

HEX_write_ASM:
	ldr a3, =segment_encode
	ldrb a2, [a3, a2]
	
	ldr a3, =SEG_ADDR
	ldr a4, [a3]
	
	tst a1, #1
	bfine a4, a2, #0, #8	
	tst a1, #2
	bfine a4, a2, #8, #8	
	tst a1, #4
	bfine a4, a2, #16, #8
	tst a1, #8
	bfine a4, a2, #24, #8
	
	str a4, [a3]
	ldr a4, [a3, #16]
	
	tst a1, #16
	bfine a4, a2, #0, #8
	tst a1, #32
	bfine a4, a2, #8, #8
	
	str a4, [a3, #16]
	
	bx lr
	
HEX_set_all_ASM:
	push {v1}
	ldr v1, =SEG_ADDR
	ldr a3, =segment_encode
	
	mov a4, #0
	
	ubfx a2, a1, #0, #4
	ldrb a2, [a3, a2]
	bfi a4, a2, #0, #8

	ubfx a2, a1, #4, #4
	ldrb a2, [a3, a2]
	bfi a4, a2, #8, #8

	ubfx a2, a1, #8, #4
	ldrb a2, [a3, a2]
	bfi a4, a2, #16, #8

	ubfx a2, a1, #12, #4
	ldrb a2, [a3, a2]
	bfi a4, a2, #24, #8
	
	str a4, [v1]
	mov a4, #0
	
	ubfx a2, a1, #16, #4
	ldrb a2, [a3, a2]
	bfi a4, a2, #0, #8

	ubfx a2, a1, #20, #4
	ldrb a2, [a3, a2]
	bfi a4, a2, #8, #8

	str a4, [v1, #16]
	pop {v1}
	bx lr

.equ PB_ADDR, 0xFF200050
read_PB_data_ASM:
	ldr a1, =PB_ADDR
	ldr a1, [a1]
	bx lr
PB_data_is_pressed_ASM:
	ldr a2, =PB_ADDR
	ldr a2, [a2]
	ands a1, a1, a2
	movne a1, #1
	bx lr
read_PB_edgecp_ASM:
	ldr a1, =PB_ADDR
	ldr a1, [a1, #12]
	bx lr
PB_edgecp_is_pressed_ASM:
	ldr a2, =PB_ADDR
	ldr a2, [a2, #12]
	ands a1, a1, a2
	movne a1, #1
	bx lr
PB_clear_edgecp_ASM:
	ldr a3, =PB_ADDR
	mov a4, #0xF
	str a4, [a3, #12]
	bx lr
enable_PB_INT_ASM:
	ldr a2, =PB_ADDR
	ldr a3, [a2, #8]
	orr a3, a3, a1
	str a3, [a2, #8]
	bx lr
disable_PB_INT_ASM:
	ldr a2, =PB_ADDR
	ldr a3, [a2, #8]
	bic a3, a3, a1
	str a3, [a2, #8]
	bx lr

.equ TIMER_ADDR, 0xFFFEC600
ARM_TIM_config_ASM:
	ldr a3, =TIMER_ADDR
	str a1, [a3]
	str a2, [a3, #8]
	bx lr
ARM_TIM_read_INT_ASM:
	ldr a3, =TIMER_ADDR
	ldr a1, [a3, #12]
	bx lr
ARM_TIM_clear_INT_ASM:
	ldr a3, =TIMER_ADDR
	mov a4, #1
	str a4, [a3, #12]
	bx lr

inc_clock:
	ldr a2, =clock
	ldr a1, [a2]
	
	add a1, #0x1
	tst a1, #0x8
	tstne a1, #0x2
	bicne a1, #0xF
	addne a1, #0x10
	tstne a1, #0x80
	tstne a1, #0x20
	bicne a1, #0xF0
	addne a1, #0x100
	tstne a1, #0x400
	tstne a1, #0x200
	bicne a1, #0xF00
	addne a1, #0x1000
	tstne a1, #0x8000
	tstne a1, #0x2000
	bicne a1, #0xF000
	addne a1, #0x10000
	tstne a1, #0x40000
	tstne a1, #0x20000
	bicne a1, #0xF0000
	addne a1, #0x100000
	
	str a1, [a2]

	b HEX_set_all_ASM
	
clock_reset:
	push {v1}
	ldr v1, =clock
	mov a4, #0
	str a4, [v1]
	pop {v1}
	mov a1, #0xFF
	mov a2, #0
	b HEX_write_ASM
	
clock_start:
	push {lr}
	bl ARM_TIM_clear_INT_ASM
	pop {lr}
	ldr a1, =MS
	mov a2, #0x03
	b ARM_TIM_config_ASM

clock_stop:
	push {lr}
	mov a2, #0
	bl ARM_TIM_config_ASM
	pop {lr}
	b ARM_TIM_clear_INT_ASM
	

.equ MS, 20000000
_start:
	bl clock_stop
	mov a1, #0xFF
	bl clock_reset
	bl PB_clear_edgecp_ASM
poll:
	mov a1, #0
	bl read_PB_edgecp_ASM
	ands a1, a1, #0xF
	blne PB_clear_edgecp_ASM
	tst a1, #2
	blne clock_stop
	tst a1, #1
	mov v1, a1
	blne clock_start
	tst v1, #4
	blne clock_reset

	
	bl ARM_TIM_read_INT_ASM
	tst a1, #1
	blne ARM_TIM_clear_INT_ASM
	blne inc_clock
b poll
