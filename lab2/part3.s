.global _start

.section .vectors, "ax"
B _start            // reset vector
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0             // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

clock: .word 0
segment_encode:
.word 0b01001111010110110000011000111111 
.word 0b00000111011111010110110101100110
.word 0b01111100011101110110111101111111
.word 0b01110001011110010101111001011000

PB_int_flag:
    .word 0x0
tim_int_flag:
    .word 0x0

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
	push {v1, v4}
	ldr v1, =tim_int_flag
	mov v4, #0
	str v4, [v1]
	pop {v1, v4}
	ldr a1, =MS
	mov a2, #7
	b ARM_TIM_config_ASM

clock_stop:
	push {v1, v4, lr}	
	mov a2, #4
	bl ARM_TIM_config_ASM
	ldr v1, =tim_int_flag
	mov v4, #0
	str v4, [v1]
	pop {v1, v4, pc}

.equ MS, 20000000

_start:
	bl PB_clear_edgecp_ASM
	bl ARM_TIM_clear_INT_ASM
    /* Set up stack pointers for IRQ and SVC processor modes */
    MOV R1, #0b11010010      // interrupts masked, MODE = IRQ
    MSR CPSR_c, R1           // change to IRQ mode
    LDR SP, =0xFFFFFFFF - 3  // set IRQ stack to A9 onchip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV R1, #0b11010011      // interrupts masked, MODE = SVC
    MSR CPSR, R1             // change to supervisor mode
    LDR SP, =0x3FFFFFFF - 3  // set SVC stack to top of DDR3 memory
    BL  CONFIG_GIC               // configure the ARM GIC
    // To DO: write to the pushbutton KEY interrupt mask register
    // Or, you can call enable_PB_INT_ASM subroutine from previous task
	mov a1, #7
	bl enable_PB_INT_ASM
	
    // to enable interrupt for ARM A9 private timer, use ARM_TIM_config_ASM subroutine
	ldr a1, =MS
	mov a2, #4
	bl ARM_TIM_config_ASM
	

    // enable IRQ interrupts in the processor
    MOV R0, #0b01010011      // IRQ unmasked, MODE = SVC
    MSR CPSR_c, R0

	ldr v1, =tim_int_flag
	ldr v2, =PB_int_flag
	mov v4, #0
	str v4, [v1]
	str v4, [v2]
	bl clock_reset
IDLE:
	ldr v3, [v2]
	tst v3, v3
	strne v4, [v2]
	tst v3, #2
	blne clock_stop
	tst v3, #1
	blne clock_start
	tst v3, #4
	blne clock_reset

	ldr v3, [v1]
	tst v3, v3
	strne v4, [v1]
	tst v3, #1
	blne inc_clock

    B IDLE // This is where you write your objective task
	
	
/*--- Undefined instructions --------------------------------------*/
SERVICE_UND:
    B SERVICE_UND
/*--- Software interrupts ----------------------------------------*/
SERVICE_SVC:
    B SERVICE_SVC
/*--- Aborted data reads ------------------------------------------*/
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
/*--- Aborted instruction fetch -----------------------------------*/
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
/*--- IRQ ---------------------------------------------------------*/
SERVICE_IRQ:
    PUSH {R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C] // read from ICCIAR
/* To Do: Check which interrupt has occurred (check interrupt IDs)
   Then call the corresponding ISR
   If the ID is not recognized, branch to UNEXPECTED
   See the assembly example provided in the De1-SoC Computer_Manual on page 46 */
Pushbutton_check:
    CMP R5, #73
	BNE Timer_check
	BL KEY_ISR
	b EXIT_IRQ
Timer_check:
	CMP R5, #29
UNEXPECTED:
    BNE UNEXPECTED      // if not recognized, stop here
	BL ARM_TIMER_ISR
    
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
    STR R5, [R4, #0x10] // write to ICCEOIR
    POP {R0-R7, LR}
	SUBS PC, LR, #4
/*--- FIQ ---------------------------------------------------------*/
SERVICE_FIQ:
    B SERVICE_FIQ

CONFIG_GIC:
    PUSH {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
/* To Do: you can configure different interrupts
   by passing their IDs to R0 and repeating the next 3 lines */
    MOV R0, #73            // KEY port (Interrupt ID = 73)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT

	MOV R0, #29           // timer (Interrupt ID = 29)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT

/* configure the GIC CPU Interface */
    LDR R0, =0xFFFEC100    // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF        // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =0xFFFED000
    STR R1, [R0]
    POP {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
    LSR R4, R0, #3    // calculate reg_offset
    BIC R4, R4, #3    // R4 = reg_offset
    LDR R2, =0xFFFED100
    ADD R4, R2, R4    // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1        // enable
    LSL R2, R5, R2    // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
    LDR R3, [R4]      // read current register value
    ORR R3, R3, R2    // set the enable bit
    STR R3, [R4]      // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
    BIC R4, R0, #3    // R4 = reg_offset
    LDR R2, =0xFFFED800
    ADD R4, R2, R4    // R4 = word address of ICDIPTR
    AND R2, R0, #0x3  // N mod 4
    ADD R4, R2, R4    // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}
	
KEY_ISR:
	push {lr}
	bl read_PB_edgecp_ASM
	ldr a2, =PB_int_flag
	str a1, [a2]
	bl PB_clear_edgecp_ASM
	pop {pc}
ARM_TIMER_ISR:
	ldr a2, =tim_int_flag
	mov a1, #1
	str a1, [a2]
	b ARM_TIM_clear_INT_ASM