.global _start
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
	LDR A2, =SW_ADDR
    LDR A1, [A2]         // read slider switch state 
    BX  LR

// LEDs Driver
// writes the state of LEDs (On/Off state) in A1 to the LEDs’ memory location
// pre-- A1: data to write to LED state
.equ LED_ADDR, 0xFF200000
write_LEDs_ASM:
	LDR A2, =LED_ADDR
    STR A1, [A2]        // update LED state with the contents of A1
    BX  LR

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
	
_start:
	mov a1, #0x30
	bl HEX_flood_ASM
clear:
	mov a1, #0xF
	bl HEX_clear_ASM
	bl PB_clear_edgecp_ASM
run:
	bl read_slider_switches_ASM
	bl write_LEDs_ASM
	tst a1, #0x200
	bne clear
	and a2, a1, #15
	bl read_PB_edgecp_ASM
	ands a1, a1, #0xF
	blne PB_clear_edgecp_ASM
	blne HEX_write_ASM
	b run
	