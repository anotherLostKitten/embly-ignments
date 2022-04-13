.global _start
_start:
	bl VGA_clear_charbuff_ASM
        bl      input_loop
end:
        b       end

// VGA drivers

// x, y, color
VGA_draw_point_ASM:
	lsl a1, a1, #1
	orr a1, a1, #0xc8000000
	bfi a1, a2, #10, #8
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
	
yu_colors:
	.word 0x01D2 // blue
	.word 0xFFFF // white
	.word 0xD800 // red
	.word 0xFE82 // yellow
draw_real_life_flag:
	push {lr}
	sub sp, sp, #4
	
	ldr a1, yu_colors
	str a1, [sp]
	mov a1, #0
	mov a2, #0
	mov a3, #320
	mov a4, #80
	bl draw_rectangle
	ldr a1, yu_colors+4
	str a1, [sp]
	mov a1, #0
	mov a2, #80
	mov a3, #320
	mov a4, #80
	bl draw_rectangle
	ldr a1, yu_colors+8
	str a1, [sp]
	mov a1, #0
	mov a2, #160
	mov a3, #320
	mov a4, #80
	bl draw_rectangle
	
	ldr a4, yu_colors+12
	mov a1, #160
	mov a2, #105
	mov a3, #75
	bl draw_star
	ldr a4, yu_colors+8
	mov a1, #160
	mov a2, #107
	mov a3, #62
	bl draw_star
	
	add sp, sp, #4
	pop {pc}

td_colors:
	.word 0x57FF // light cyan
	.word 0xFFEA // yellow
	.word 0xAD55 // light grey
	.word 0x0000 // black
	
draw_imaginary_flag:
	push {lr}
	sub sp, sp, #4
	
	ldr a1, td_colors
	str a1, [sp]
	mov a1, #0
	mov a2, #0
	mov a3, #320
	mov a4, #93
	bl draw_rectangle
	ldr a1, td_colors+4
	str a1, [sp]
	mov a1, #0
	mov a2, #93
	mov a3, #320
	mov a4, #147
	bl draw_rectangle
	
	ldr a3, td_colors+12
	str a3, [sp]
	//eye
	mov a1, #81
	mov a2, #75
	bl VGA_draw_point_ASM
	mov a1, #81
	mov a2, #76
	bl VGA_draw_point_ASM
	//main body
	mov a3, #206
	mov a4, #58
	mov a1, #231
	mov a2, #72
	bl draw_line
	mov a3, #206
	mov a4, #58
	mov a1, #184
	mov a2, #76
	bl draw_line
	mov a3, #184
	mov a4, #76
	mov a1, #184
	mov a2, #100
	bl draw_line
	mov a3, #215
	mov a4, #220
	mov a1, #184
	mov a2, #100
	bl draw_line
	mov a3, #215
	mov a4, #220
	mov a1, #227
	mov a2, #224
	bl draw_line
	mov a3, #235
	mov a4, #213
	mov a1, #227
	mov a2, #224
	bl draw_line
	mov a3, #235
	mov a4, #213
	mov a1, #220
	mov a2, #153
	bl draw_line
	mov a3, #235
	mov a4, #110
	mov a1, #220
	mov a2, #153
	bl draw_line
	mov a3, #235
	mov a4, #110
	mov a1, #233
	mov a2, #78
	bl draw_line
	mov a3, #250
	mov a4, #112
	mov a1, #233
	mov a2, #78
	bl draw_line
	mov a3, #250
	mov a4, #112
	mov a1, #252
	mov a2, #110
	bl draw_line
	mov a3, #233
	mov a4, #68
	mov a1, #252
	mov a2, #110
	bl draw_line
	mov a3, #233
	mov a4, #68
	mov a1, #195
	mov a2, #46
	bl draw_line
	mov a3, #143
	mov a4, #43
	mov a1, #195
	mov a2, #46
	bl draw_line
	mov a3, #143
	mov a4, #43
	mov a1, #104
	mov a2, #32
	bl draw_line
	mov a3, #79
	mov a4, #40
	mov a1, #104
	mov a2, #32
	bl draw_line
	mov a3, #79
	mov a4, #40
	mov a1, #66
	mov a2, #76
	bl draw_line
	mov a3, #60
	mov a4, #195
	mov a1, #66
	mov a2, #76
	bl draw_line
	mov a3, #60
	mov a4, #195
	mov a1, #63
	mov a2, #198
	bl draw_line
	mov a3, #69
	mov a4, #196
	mov a1, #63
	mov a2, #198
	bl draw_line
	mov a3, #69
	mov a4, #196
	mov a1, #72
	mov a2, #146
	bl draw_line
	mov a3, #83
	mov a4, #104
	mov a1, #72
	mov a2, #146
	bl draw_line
	mov a3, #83
	mov a4, #104
	mov a1, #81
	mov a2, #123
	bl draw_line
	mov a3, #102
	mov a4, #100
	mov a1, #81
	mov a2, #123
	bl draw_line
	mov a3, #102
	mov a4, #100
	mov a1, #97
	mov a2, #201
	bl draw_line
	mov a3, #104
	mov a4, #205
	mov a1, #97
	mov a2, #201
	bl draw_line
	
	// ear
	mov a1, #116
	mov a2, #50
	mov a3, #101
	mov a4, #38
	bl draw_line
	mov a1, #116
	mov a2, #50
	mov a3, #119
	mov a4, #77
	bl draw_line
	mov a1, #100
	mov a2, #92
	mov a3, #119
	mov a4, #77
	bl draw_line
	
	// front leg
	mov a1, #137
	mov a2, #91
	mov a3, #119
	mov a4, #95
	bl draw_line
	mov a1, #105
	mov a2, #174
	mov a3, #119
	mov a4, #95
	bl draw_line
	mov a1, #105
	mov a2, #174
	mov a3, #119
	mov a4, #95
	bl draw_line
	mov a1, #105
	mov a2, #174
	mov a3, #105
	mov a4, #229
	bl draw_line
	mov a1, #110
	mov a2, #233
	mov a3, #105
	mov a4, #229
	bl draw_line
	mov a1, #110
	mov a2, #233
	mov a3, #118
	mov a4, #229
	bl draw_line
	mov a1, #120
	mov a2, #174
	mov a3, #118
	mov a4, #229
	bl draw_line
	mov a1, #120
	mov a2, #174
	mov a3, #144
	mov a4, #115
	bl draw_line
	mov a1, #137
	mov a2, #91
	mov a3, #144
	mov a4, #115
	bl draw_line
	
	//back leg
	mov a1, #196
	mov a2, #148
	mov a3, #188
	mov a4, #163
	bl draw_line
	mov a1, #188
	mov a2, #193
	mov a3, #188
	mov a4, #163
	bl draw_line
	mov a1, #188
	mov a2, #193
	mov a3, #191
	mov a4, #203
	bl draw_line
	mov a1, #182
	mov a2, #207
	mov a3, #191
	mov a4, #203
	bl draw_line
	mov a1, #182
	mov a2, #207
	mov a3, #175
	mov a4, #206
	bl draw_line
	mov a1, #175
	mov a2, #169
	mov a3, #175
	mov a4, #206
	bl draw_line
	mov a1, #175
	mov a2, #169
	mov a3, #182
	mov a4, #128
	bl draw_line
	
	//belly
	mov a1, #190
	mov a2, #126
	mov a3, #155
	mov a4, #131
	bl draw_line
	mov a1, #141
	mov a2, #125
	mov a3, #155
	mov a4, #131
	bl draw_line
	
	ldr a3, td_colors+8
	ldr a4, td_colors+12
	//fill body
	mov a1, #137
	mov a2, #95
	bl draw_fill
	mov a1, #82
	mov a2, #42
	bl draw_fill
	mov a1, #190
	mov a2, #130
	bl draw_fill
	
	add sp, sp, #4
	pop {pc}
		
// x0, y0, x1, y1, stack: color
// (internally...)
// a1: x, a2: y, a3: color, a4: err
// v1: dx, v2: dy, v3: x/y end, v4: inc/dec
draw_line:
	push {v1,v2,v3,v4,lr}
	subs v1, a1, a3
	rsblt v1, v1, #0
	subs v2, a2, a4
	rsblt v2, v2, #0
	cmp v1, v2
	blt y_maj // steep / shallow slope
x_maj:
	cmp a2, a4 // guarantee increasing y0 -> y1
	movgt v3, a2 // swap if not
	movgt a2, a4
	movgt a4, v3
	movgt v3, a1
	movgt a1, a3
	movgt a3, v3
	
	cmp a1, a3 //check a1->a3 or a3->a1
	mov v4, #1
	add v3, a3, #1
	movgt v4, #-1
	addgt v3, a3, #-1
	lsl v2, v2, #1 // set error
	sub a4, v2, v1
	lsl v1, v1, #1
	ldr a3, [sp, #20] // get color
x_loop:
	push {a1}
	bl VGA_draw_point_ASM
	pop {a1}
	cmp a4, #0
	addgt a2, a2, #1
	add a4, a4, v2
	subgt a4, a4, v1
	
	add a1, a1, v4
	cmp a1, v3
	bne x_loop
	pop {v1,v2,v3,v4,pc}
y_maj:
	cmp a1, a3 // guarantee increasing x0 -> x1
	movgt v3, a2 // swap if not
	movgt a2, a4
	movgt a4, v3
	movgt v3, a1
	movgt a1, a3
	movgt a3, v3
	
	cmp a2, a4 //check y0->y1 or y1->y0
	mov v4, #1
	add v3, a4, #1
	movgt v4, #-1
	addgt v3, a4, #-1
	lsl v1, v1, #1 // set error
	sub a4, v1, v2
	lsl v2, v2, #1
	ldr a3, [sp, #20] // get color
y_loop:
	push {a1}
	bl VGA_draw_point_ASM
	pop {a1}
	cmp a4, #0
	addgt a1, a1, #1
	add a4, a4, v1
	subgt a4, a4, v2
	
	add a2, a2, v4
	cmp a2, v3
	bne y_loop
	pop {v1,v2,v3,v4,pc}

// x, y, fill color, boundary color
// v3: stack end, v1: tmp x, v2: tmp y
// will probably stack overflow for certain large reigons
// will definitely start writing to random memory if the reigon to be filled is not
//    fully enclosed inside the drawing (draw a line on edge with fill color beforehand)
draw_fill:
	push {v1, v2, v3, lr}
	mov v3, sp
fill_loop:
	mov v1, a1
	mov v2, a2
	
	add a1, v1, #1
	bl can_fill
	addne a1, v1, #1
	bfine a1, v2, #16, #16
	pushne {a1}
	
	add a1, v1, #-1
	mov a2, v2
	bl can_fill
	addne a1, v1, #-1
	bfine a1, v2, #16, #16
	pushne {a1}
	
	mov a1, v1
	add a2, v2, #1
	bl can_fill
	movne a1, v1
	addne a2, v2, #1
	bfine a1, a2, #16, #16
	pushne {a1}
	
	mov a1, v1
	add a2, v2, #-1
	bl can_fill
	movne a1, v1
	addne a2, v2, #-1
	bfine a1, a2, #16, #16
	pushne {a1}
	
	cmp sp, v3
	popne {a1}
	lsrne a2, a1, #16
	lslne a1, a1, #16
	lsrne a1, a1, #16
	bne fill_loop
	
	pop {v1, v2, v3, lr}
	bx lr
can_fill: // can fill if ne (don't use over edges of screen, will invalid mem access)
	lsl a1, a1, #1
	orr a1, a1, #0xc8000000
	lsl a2, a2, #10
	orr a1, a2, a1
	ldrh a2, [a1]
	cmp a2, a3
	cmpne a2, a4
	bxeq lr
	strh a3, [a1]
	bx lr

draw_texan_flag:
        push    {r4, lr}
        sub     sp, sp, #8
        ldr     r3, .flags_L32
        str     r3, [sp]
        mov     r3, #240
        mov     r2, #106
        mov     r1, #0
        mov     r0, r1
        bl      draw_rectangle
        ldr     r4, .flags_L32+4
        mov     r3, r4
        mov     r2, #43
        mov     r1, #120
        mov     r0, #53
        bl      draw_star
        str     r4, [sp]
        mov     r3, #120
        mov     r2, #214
        mov     r1, #0
        mov     r0, #106
        bl      draw_rectangle
        ldr     r3, .flags_L32+8
        str     r3, [sp]
        mov     r3, #120
        mov     r2, #214
        mov     r1, r3
        mov     r0, #106
        bl      draw_rectangle
        add     sp, sp, #8
        pop     {r4, pc}
.flags_L32:
        .word   2911
        .word   65535
        .word   45248

draw_rectangle:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        ldr     r7, [sp, #32]
        add     r9, r1, r3
        cmp     r1, r9
        popge   {r4, r5, r6, r7, r8, r9, r10, pc}
        mov     r8, r0
        mov     r5, r1
        add     r6, r0, r2
        b       .flags_L2
.flags_L5:
        add     r5, r5, #1
        cmp     r5, r9
        popeq   {r4, r5, r6, r7, r8, r9, r10, pc}
.flags_L2:
        cmp     r8, r6
        movlt   r4, r8
        bge     .flags_L5
.flags_L4:
        mov     r2, r7
        mov     r1, r5
        mov     r0, r4
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        cmp     r4, r6
        bne     .flags_L4
        b       .flags_L5
should_fill_star_pixel:
        push    {r4, r5, r6, lr}
        lsl     lr, r2, #1
        cmp     r2, r0
        blt     .flags_L17
        add     r3, r2, r2, lsl #3
        add     r3, r2, r3, lsl #1
        lsl     r3, r3, #2
        ldr     ip, .flags_L19
        smull   r4, r5, r3, ip
        asr     r3, r3, #31
        rsb     r3, r3, r5, asr #5
        cmp     r1, r3
        blt     .flags_L18
        rsb     ip, r2, r2, lsl #5
        lsl     ip, ip, #2
        ldr     r4, .flags_L19
        smull   r5, r6, ip, r4
        asr     ip, ip, #31
        rsb     ip, ip, r6, asr #5
        cmp     r1, ip
        bge     .flags_L14
        sub     r2, r1, r3
        add     r2, r2, r2, lsl #2
        add     r2, r2, r2, lsl #2
        rsb     r2, r2, r2, lsl #3
        ldr     r3, .flags_L19+4
        smull   ip, r1, r3, r2
        asr     r3, r2, #31
        rsb     r3, r3, r1, asr #5
        cmp     r3, r0
        movge   r0, #0
        movlt   r0, #1
        pop     {r4, r5, r6, pc}
.flags_L17:
        sub     r0, lr, r0
        bl      should_fill_star_pixel
        pop     {r4, r5, r6, pc}
.flags_L18:
        add     r1, r1, r1, lsl #2
        add     r1, r1, r1, lsl #2
        ldr     r3, .flags_L19+8
        smull   ip, lr, r1, r3
        asr     r1, r1, #31
        sub     r1, r1, lr, asr #5
        add     r2, r1, r2
        cmp     r2, r0
        movge   r0, #0
        movlt   r0, #1
        pop     {r4, r5, r6, pc}
.flags_L14:
        add     ip, r1, r1, lsl #2
        add     ip, ip, ip, lsl #2
        ldr     r4, .flags_L19+8
        smull   r5, r6, ip, r4
        asr     ip, ip, #31
        sub     ip, ip, r6, asr #5
        add     r2, ip, r2
        cmp     r2, r0
        bge     .flags_L15
        sub     r0, lr, r0
        sub     r3, r1, r3
        add     r3, r3, r3, lsl #2
        add     r3, r3, r3, lsl #2
        rsb     r3, r3, r3, lsl #3
        ldr     r2, .flags_L19+4
        smull   r1, ip, r3, r2
        asr     r3, r3, #31
        rsb     r3, r3, ip, asr #5
        cmp     r0, r3
        movle   r0, #0
        movgt   r0, #1
        pop     {r4, r5, r6, pc}
.flags_L15:
        mov     r0, #0
        pop     {r4, r5, r6, pc}
.flags_L19:
        .word   1374389535
        .word   954437177
        .word   1808407283
draw_star:
        push    {r4, r5, r6, r7, r8, r9, r10, fp, lr}
        sub     sp, sp, #12
        lsl     r7, r2, #1
        cmp     r7, #0
        ble     .flags_L21
        str     r3, [sp, #4]
        mov     r6, r2
        sub     r8, r1, r2
        sub     fp, r7, r2
        add     fp, fp, r1
        sub     r10, r2, r1
        sub     r9, r0, r2
        b       .flags_L23
.flags_L29:
        ldr     r2, [sp, #4]
        mov     r1, r8
        add     r0, r9, r4
        bl      VGA_draw_point_ASM
.flags_L24:
        add     r4, r4, #1
        cmp     r4, r7
        beq     .flags_L28
.flags_L25:
        mov     r2, r6
        mov     r1, r5
        mov     r0, r4
        bl      should_fill_star_pixel
        cmp     r0, #0
        beq     .flags_L24
        b       .flags_L29
.flags_L28:
        add     r8, r8, #1
        cmp     r8, fp
        beq     .flags_L21
.flags_L23:
        add     r5, r10, r8
        mov     r4, #0
        b       .flags_L25
.flags_L21:
        add     sp, sp, #12
        pop     {r4, r5, r6, r7, r8, r9, r10, fp, pc}
input_loop:
        push    {r4, r5, r6, r7, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      draw_texan_flag
        mov     r6, #0
        mov     r4, r6
        mov     r5, r6
        ldr     r7, .flags_L52
        b       .flags_L39
.flags_L46:
        bl      draw_real_life_flag
.flags_L39:
        strb    r5, [sp, #7]
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .flags_L39
        cmp     r6, #0
        movne   r6, r5
        bne     .flags_L39
        ldrb    r3, [sp, #7]    @ zero_extendqisi2
        cmp     r3, #240
        moveq   r6, #1
        beq     .flags_L39
        cmp     r3, #28
        subeq   r4, r4, #1
        beq     .flags_L44
        cmp     r3, #35
        addeq   r4, r4, #1
.flags_L44:
        cmp     r4, #0
        blt     .flags_L45
        smull   r2, r3, r7, r4
        sub     r3, r3, r4, asr #31
        add     r3, r3, r3, lsl #1
        sub     r4, r4, r3
        bl      VGA_clear_pixelbuff_ASM
        cmp     r4, #1
        beq     .flags_L46
        cmp     r4, #2
        beq     .flags_L47
        cmp     r4, #0
        bne     .flags_L39
        bl      draw_texan_flag
        b       .flags_L39
.flags_L45:
        bl      VGA_clear_pixelbuff_ASM
.flags_L47:
        bl      draw_imaginary_flag
        mov     r4, #2
        b       .flags_L39
.flags_L52:
        .word   1431655766
