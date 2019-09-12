	AREA	GPIO, CODE, READWRITE	


	EXPORT read_character
	EXPORT output_character
	EXPORT read_string
	EXPORT output_string
	EXPORT newline
	EXPORT pin_connect_block_setup_for_uart0
	EXPORT uart_init
	EXPORT rng
	EXPORT div_and_mod
	EXTERN end_of_code

IO0SET EQU 0xE0028004
IO0CLR EQU 0xE002800C
IO0DIR EQU 0xE0028008 
IO0PIN EQU 0xE0028000
	
IO1SET EQU 0xE0028014	
IO1CLR EQU 0xE002801C
IO1DIR EQU 0xE0028018 
IO1PIN EQU 0xE0028010
	
U0LSR EQU 0xE000C014	
U0TRR EQU 0xE000C000	
UART0 EQU 0xE000C004	;uart0 interrupt enabler

T0TCR EQU 0xE0004004   ; Timer control register use to control TC (time count)
T0TC  EQU 0xE0004008   ; Time count 	
T0MCR EQU 0xE0004014   ; Determines if an interrupt is generated and if the Time Count (TC)
T0IR  EQU 0xE0004000   ; 	
T0MR1 EQU 0xE000401C	;match register

T1IR EQU 0xE0008000
T1MCR EQU 0xE0008014
T1TC EQU 0xE0008008
T1TCR EQU 0xE0008004
T1MR1 EQU 0xE000801C   ; Match Register

current_level EQU 0x40000200
store_read_address EQU 0x40000000
stateaddress EQU 0x40004000
previous_led_display EQU 0x40000100
	
keystork_rng_counter EQU 0x40007990
current_keyboard_rng_input EQU 0x40007994	
	
digit_1000 EQU 0x40007000
digit_100  EQU 0x40007010
digit_10   EQU 0x40007020
digit_1    EQU 0x40007030

strobing_flag EQU 0x40005040
	
rng
	STMFD SP!,{r0-r1,r7,r8,lr}
	
	LDR r0, =T0TC
	LDR r1, [r0]
	LDR r2, =0xFFFFFF00
	BIC r1, r1 , r2
	
	LDR r0, =keystork_rng_counter
	LDR r2, [r0]
	ADD r1, r1 ,r2
	
	LDR r0, =current_keyboard_rng_input
	LDR r2, [r0]
	ADD r1, r1 ,r2
	
	LDR r2, =0xFFFFFF00
	BIC r1, r1 , r2
	
	
	
	
	MOV r8, r11  ; immediates enters here shows the range of random numbers

continue_subb

	CMP r1, r8 
	BLT done_diving
	
	SUB r1, r1, r8
	B continue_subb

done_diving
	MOV r12 , r1 
	
	LDMFD SP!,{r0-r1,r7,r8,lr}
	BX lr
	
	
newline
	STMFD SP!,{lr}	; Store register lr on stack
	MOV r1, #0xA
	BL output_character
	MOV r1, #0xD
	BL output_character
	;MOV r1, #0x32
	;BL output_character ;delete this line
	LDMFD sp!, {lr}
	BX lr
	
read_character
	STMFD SP!,{r0-r3,lr} 
	LDR r0, =U0LSR
	LDR r2, =U0TRR	
LOOP_readchar 

	LDRB r1, [r0]  
	AND r3, r1, #1 
	CMP r3, #0
	BEQ LOOP_readchar
	LDRB r1, [r2]
	
	BL output_character

	LDMFD sp!, {r0-r3,lr}
	BX lr 

output_character
	STMFD SP!,{r0-r3,lr}
	LDR r0, =U0LSR
LOOP_outchar
	LDRB r2, [r0]
	AND r3, r2, #32
	CMP r3, #0
	BEQ LOOP_outchar 

not_enters	
	LDR r0, =U0TRR
	STRB r1, [r0] 
	LDMFD sp!, {r0-r3,lr}
	BX lr
	
output_string
	STMFD SP!, {r0-r1,lr}
LOOP_outstr
	LDRB r1, [r0], #1  
	CMP r1, #0 
	BNE outPrompt
	B STOP
outPrompt	



	LDR r4, =U0LSR
LOOP_outchar2
	LDRB r2, [r4]
	AND r3, r2, #32
	CMP r3, #0
	BEQ LOOP_outchar2 
	
	LDR r4, =U0TRR
	STRB r1, [r4] 
	
	B LOOP_outstr
	
STOP
	LDMFD sp!, {r0-r1,lr}
	BX lr
	
read_string
	STMFD SP!,{lr}
	LDR r0 , =store_read_address
LOOP_readstr
	BL read_character
	CMP r1, #0x51
	BEQ end_of_code
	LDRB r1, [r0], #1
	B LOOP_readstr
	LDMFD sp!, {lr}
	BX lr 
	
uart_init
	STMFD sp!, {r0-r1,lr}		
	LDR r0, =0xE000C00C
	MOV r1, #131
	STRB r1, [r0]
	
	LDR r0, =0xE000C000
	MOV r1, #1
	STRB r1, [r0]
	
	LDR r0, =0xE000C004
	MOV r1, #0
	STRB r1, [r0]
	
	LDR r0, =0xE000C00C
	MOV r1, #3
	STRB r1, [r0]
	LDMFD sp!, {r0-r1,lr}
	BX lr 
	
		
div_and_mod	
	; The dividend is passed in r1 and the divisor in r0.
	; The quotient is returned in r0 and the remainder in r1. 
	MOV r1, r7
	MOV r0, r8
	MOV r2, #16	;initialize counter to 16
	MOV r3, #0	;initialize quotient to 0	
	
	MOV r0, r0, LSL #16	;logical shift left divisor 16 places
	MOV r4, r1	;Initialize Remainder to dividend
	
DEC	SUB r4, r4, r0 ;remainder = remainder - divisor
	CMP r4, #0 	;comparing remainder to 0
	BLT TRU		;remainder is less than 0
	
	MOV r3, r3, LSL #1 ;Left shit quotient LSB = 1
	ADD r3, r3, #1 ;adding 1 to make LSB = 1
	B RSD		
	
TRU	ADD r4, r4, r0		;restore remainder.
	MOV r3, r3, LSL #1 ;left shit in 0 to quotient
	B RSD 			

RSD	MOV r0, r0, LSR #1 ;right shift divisor = 0
	CMP r2, #0	;comparing counter
	BGT CNT;
	B DONE ; sign first step
	
CNT SUB r2, r2, #1	;decrementing counter
	BGT DEC
	
	
DONE MOV r0, r3 ;return quotient into r0
	 MOV r1, r4 ;return remainder to r1
	 
	BX lr 
	
pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000  ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr
	

	
	END