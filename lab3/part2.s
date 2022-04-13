.global _start
_start:
        bl      input_loop
end:
        b       end

// VGA drivers

// x, y, color
VGA_draw_point_ASM:
	lsl a1, a1, #1
	orr a1, a1, #0xc8000000
	lsl a2, a2, #10
	orr a1, a2, a1
	strh a3, [a1]
	bx lr

VGA_clear_pixelbuff_ASM:
	mov a3, #0
	mov a2, #640
	mov a1, #0xc8000000
	add a4, a1, #0b111100000000000000
pixl_loop:
	subs a2, a2, #4
	str a3, [a1, a2]
	bne pixl_loop
	add a1, a1, #1024
	teq a1, a4
	mov a2, #640
	bne pixl_loop
	bx lr
	
// x, y, char
VGA_write_char_ASM:
	cmp a1, #79
	cmpls a2, #59
	bxhi lr
	orr a1, a1, #0xc9000000
	lsl a2, a2, #7
	orr a1, a2, a1
	strb a3, [a1]
	bx lr
	
VGA_clear_charbuff_ASM:
	mov a3, #0
	mov a2, #80
	mov a1, #0xc9000000
	add a4, a1, #7680
char_loop:
	subs a2, a2, #4
	str a3, [a1, a2]
	bne char_loop
	add a1, a1, #128
	teq a1, a4
	mov a2, #80
	bne char_loop
	bx lr

.equ PS2_ADDR, 0xff200100
// char* keycode address -> boolean valid?
read_PS2_data_ASM:
	ldr a2, =PS2_ADDR
	ldr a2, [a2]
	tst a2, #0x8000
	moveq a1, #0
	bxeq lr
	
	strb a2, [a1]
	
	mov a1, #1
	bx lr
	

write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
