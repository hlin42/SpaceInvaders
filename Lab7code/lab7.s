	AREA interrupts, CODE, READWRITE
	EXPORT lab7
	EXPORT FIQ_Handler
	EXPORT end_of_code
	EXPORT update_map
	EXPORT lab7_restart
	EXPORT endgame
	
	EXTERN enemy_motion
	EXTERN interrupt_init
	EXTERN uart_init
	EXTERN output_string
	EXTERN read_character
	EXTERN newline
	EXTERN read_string
	EXTERN seven_seg
	EXTERN lights_up_1000_LED
	EXTERN lights_up_100_LED
	EXTERN lights_up_10_LED
	EXTERN lights_up_1_LED
	EXTERN rng	

	EXTERN ship_setups
	EXTERN ship_shift_left	
	EXTERN ship_shift_right
		
	EXTERN enemy_setups	
	EXTERN enemy_motioning_right
	EXTERN enemy_motioning_left
		
	EXTERN proj_setups
	EXTERN eject_proj
	EXTERN proj_motion
	EXTERN enemy_eject_proj	

	EXTERN eject_enemy_proj
	EXTERN enemy_proj_setups
	EXTERN enemy_proj_motion
		
		
	EXTERN mothership_setup
	EXTERN mothership_starting_showup_left
	EXTERN mothership_starting_showup_right
	EXTERN mothership_right_move
	EXTERN mothership_left_move
	EXTERN output_character	
		
score_location_1 EQU 0x40007A10
score_location_2 EQU 0x40007A18
score_location_3 EQU 0x40007A20
score_location_4 EQU 0x40007A28
time_location_1 EQU 0x40007A30
time_location_2 EQU 0x40007A38
time_location_3 EQU 0x40007A40


lives EQU 0x40005000			
right_enemycounts  EQU 0x40007370
enemyoffset     EQU 0x40007120
enemy_proj_offset EQU 0x400074A0
enemy_proj_on_board EQU 0x400074B0 
IO0SET EQU 0xE0028004
IO0PIN EQU 0xE0028000
IO0CLR EQU 0xE002800C
IO0DIR EQU 0xE0028008 
IO1SET EQU 0xE0028014	
T0MR0 EQU 0xE0004018   ; Match Register
T0TCR EQU 0xE0004004   ; Timer control register use to control TC (time count)
T0TC  EQU 0xE0004008   ; Time count 	
T0MCR EQU 0xE0004014   ; Determines if an interrupt is generated and if the Time Count (TC)
T0IR  EQU 0xE0004000   ; 	
T0MR1 EQU 0xE000401C
T1IR EQU 0xE0008000
U0TRR EQU 0xE000C000	
T1TCR EQU 0xE0008004
IO1DIR EQU 0xE0028018 
UART0 EQU 0xE000C004
T1MCR EQU 0xE0008014
T1MR1 EQU 0xE000801C
strobing_flag EQU 0x40005040
	
previous_led_display EQU 0x40000100
promptoffset EQU 0x40007100
left_right_dir_flag EQU 0x40007290
proj_exist_on_board_flag EQU 0x40007410
ship_location EQU 0x40006000
current_level EQU 0x40000200
paused_game_flag EQU 0x40005010

keystork_rng_counter EQU 0x40007990
current_keyboard_rng_input EQU 0x40007994	
	
current_score_1 EQU 0x40006900
current_score_10 EQU 0x40006904
current_score_100 EQU 0x40006908
current_score_1000 EQU 0x4000690C
	
total_score_1 EQU   0x40006920
total_score_10 EQU   0x40006924
total_score_100 EQU   0x40006928
total_score_1000 EQU   0x4000692C

mothership_score_1	EQU 0x40006930
mothership_score_10	EQU 0x40006934
mothership_score_100 EQU 0x40006938

time_left_1		   EQU 0x40006944
time_left_10		EQU 0x40006948
time_left_100		EQU 0x4000694C
time_left_total		EQU 0x40006954

endpoint_location EQU 0x40006940	
mothership_exist_on_board EQU 0x400078A0
mothership_left_or_right_dir EQU 0x40007860 
timer_counter EQU 0x40007B00
promptend_offset EQU 0x40007A00

LED_1_command EQU 0x40007D00
seconds_increment_counter EQU 0x40007AA0

prompt_storage_offset EQU 0x40007E20
prompt_storage_offset_copy EQU 0x40007E24

mothership_appears_count EQU 0x40007E28
mothership_appears_hit   EQU 0x40007E2C
	
prompt = 12,"|---------------------|", 10,13 ,  "|                     |", 10,13 , "|       OOOOOOO       |", 10,13 ,  "|       MMMMMMM       |", 10,13 ,  "|       MMMMMMM       |", 10,13 ,  "|       WWWWWWW       |", 10,13 ,  "|       WWWWWWW       |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|   SSS   SSS   SSS   |", 10,13 ,  "|   S S   S S   S S   |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|          A          |", 10, 13 ,"|---------------------|" ,0
promptcopy = 12,"|---------------------|", 10,13 ,  "|                     |", 10,13 , "|       OOOOOOO       |", 10,13 ,  "|       MMMMMMM       |", 10,13 ,  "|       MMMMMMM       |", 10,13 ,  "|       WWWWWWW       |", 10,13 ,  "|       WWWWWWW       |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|   SSS   SSS   SSS   |", 10,13 ,  "|   S S   S S   S S   |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|          A          |", 10, 13 ,"|---------------------|" ,0
prompt1 = "PAUSED, HIT THE 'Enter' KEY TO CONTINUE" ,0	 ;ADDED THIS
prompt0 = 12,"Welcome to Space Invaders. Use 'A' and 'D' to move left and right, respectively. Use 'Spacebar' to shoot. Press 'Enter' to start.",0
promptdir = 12,"|---------------------|", 10,13 ,  "|   Welcome to Space  |", 10,13 , "|      Invaders       |", 10,13 ,  "|       A=left        |", 10,13 ,  "|       D=right       |", 10,13 ,  "|     Space=Shoot     |", 10,13 ,  "|     Hit P0.14 to    |", 10,13 ,  "|        Start        |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|   SSS   SSS   SSS   |", 10,13 ,  "|   S S   S S   S S   |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|          A          |", 10, 13 ,"|---------------------|" ,0
prompt_level = 10,13, "Level: ",0 	
prompt_mothership = 10,13,"Latest Mothership bounes score : ",0
prompt_timeleft = 10,13, "Time Elapse :" ,0 
promptend = 12,"|---------------------|", 10,13 ,  "|                     |", 10,13 , "|      GAME OVER      |", 10,13 , "|                     |", 10,13 ,"|                     |", 10,13 , "|     SCOREBOARD      |", 10,13 ,  "|   SCORE:            |", 10,13 ,  "|     BETTER LUCK     |", 10,13 ,  "|      NEXT TIME!     |", 10,13 ,  "|  Time used:     sec |", 10,13 ,"|                     |", 10,13,"|                     |",10,13, "|   Hit 'ENTER' to    |", 10,13 ,  "|     start again     |", 10,13 ,  "|---------------------|" ,10, 13, "Level Breakdown",0
promptend_level = 10,13,"---------------", 10, 13, "Level :" , 0
promptend_levelscore = 10, 13, "Score:" , 0
promptend_leveldeathcount = 10, 13, "Death Count:" , 0
promptend_levelmothership = 10, 13, "Mothership:" , 0
promptend_leveltime = 10, 13, "Total time Elapse:" , 0
prompt_storage = "                                                  " , 0

	ALIGN

lab7
	STMFD sp!, {lr}
	BL uart_init
	
	LDR r0, =time_left_total
	MOV r1, #0
	STR r1, [r0]
	
	LDR r0, =prompt_storage
	LDR r1, =prompt_storage_offset
	STR r0, [r1]
	LDR r2, =prompt_storage_offset_copy
	STR r0, [r2]
	
	LDR r0, =time_left_1
	MOV r1, #0x30
	STR r1, [r0]
	
	LDR r0, =time_left_10
	STR r1, [r0]
	LDR r0, =time_left_100
	STR r1, [r0]
	
	
	LDR r0, =LED_1_command
	LDR r1, =0x3780 ;0
	STR r1, [r0],#4
	
	LDR r1, =0x300;1
	STR r1, [r0],#4
	
	LDR r1, =0x9580;2
	STR r1, [r0],#4
	
	LDR r1, =0x8780;3
	STR r1, [r0],#4
	
	LDR r1, =0xA300;4
	STR r1, [r0],#4
	
	LDR r1, =0xA680;5
	STR r1, [r0],#4
		
	LDR r1, =0xB680;6
	STR r1, [r0],#4
	
	LDR r1, =0x380;7
	STR r1, [r0],#4
	
	LDR r1, =0xB780;8
	STR r1, [r0],#4
		
	LDR r1, =0xA780;9
	STR r1, [r0]

	
	
	
	
	
	LDR r0, =strobing_flag
	MOV r1, #1
	STR r1, [r0]
	
	LDR r0, =timer_counter
	MOV r1, #0
	STR r1, [r0]
	
	LDR r0, =total_score_1
	STR r1, [r0]
	LDR r0, =total_score_10
	STR r1, [r0]
	LDR r0, =total_score_100
	STR r1, [r0]
	LDR r0, =total_score_1000
	STR r1, [r0]
	
	LDR r0, =mothership_score_1
	STR r1, [r0]
	LDR r0, =mothership_score_10
	STR r1, [r0]
	LDR r0, =mothership_score_100
	STR r1, [r0]
	
	LDR r0, =seconds_increment_counter
	STR r1, [r0]
	
	LDR r0, =IO0DIR
	LDR r1, =0x26B7FF ;Makeing 7 segment pins as OUTPUT
	STR r1, [r0] ;dont know if it works..


	LDR r0, =IO1DIR
	LDR r1, = 0x00F0000 ; Making P1.16 ~ P1.19  (aka button LED as Output)
	STR r1, [r0] ;
	
	LDR r0, =lives
	MOV r1, #4 ; Making P1.16 ~ P1.19  (aka button LED as Output)
	STR r1, [r0] ;
	
	
	LDR r0, =current_level
	MOV r1, #0x30
	STR r1, [r0]
	
	LDR r0, =keystork_rng_counter
	STR r1, [r0]
	LDR r0, =current_keyboard_rng_input
	STR r1, [r0]
	

	LDR r0, =prompt
	LDR r1, =promptoffset
	STR r0, [r1]
	
	LDR r0, =promptoffset
	LDR r1, [r0]
	LDR r0, =0x106
	ADD r1 , r1, r0
	LDR r0, =endpoint_location
	STR r1,  [r0]
		
	LDR r0, =paused_game_flag
	MOV r1, #1
	STR r1, [r0]
	
	LDR r0, =promptdir
	BL output_string

lab7_restart ;where to put LTORG so game wont crash during new level


	LDR r0, =current_score_1
	MOV r1, #0
	STR r1, [r0]
	LDR r0, =current_score_10
	STR r1, [r0]
	LDR r0, =current_score_100
	STR r1, [r0]
	LDR r0, =current_score_1000
	STR r1, [r0]

	LDR r0,=mothership_appears_count
	STR r1,[r0]
	LDR r0,=mothership_appears_hit
	STR r1, [r0]

	
	LDR r0, =promptcopy
	LDR r2, =promptoffset
	LDR r3, [r2]
	
copying_again_loop
	LDRB r1, [r0], #1	
	STRB r1, [r3], #1
	CMP r1, #0x00
	BEQ done_copying
	B copying_again_loop
done_copying
	;LDR r0, =prompt
	;BL output_string
	BL ship_setups
	BL enemy_setups
	BL proj_setups
 	BL enemy_proj_setups
	BL mothership_setup	
		LDR r0, =0xE002C000
		LDR r1, [r0]
		ORR r1, r1, #0x20000000; set pin 29 on
		BIC r1, r1, #0x10000000; set pin 28 off, to 0 
		STR r1, [r0]  ; PINSEL0 bits 29:28 = 10
		
		;uart0 interrupt init
		LDR r0, =UART0 ;interrupt enable fucking register
		LDR r1, [r0]
		ORR r1, r1, #1
		BIC r1, r1, #2
		STR r1, [r0]

		;initiate/enable timer 
		LDR r0, =T0TCR
		LDR r1, [r0]
		ORR r1, r1, #0x1
		STR r1, [r0]
		
		LDR r0, =T0MCR
		LDR r1, [r0]
		ORR r1, r1, #0x18
		BIC r1, r1, #0x7
		STR r1, [r0]
		LDR r0, =current_level
		LDR r1, [r0]
		CMP r1, #0x30

		BNE level_1
		LDR r0, =T0MR1
		LDR r1, =0x01000000;
		STR r1, [r0]
		B continue_to
level_1
		CMP r1, #0x31
		BNE level_2
		LDR r0, =T0MR1
		LDR r1, =0x00A50000;
		STR r1, [r0]
		B continue_to
level_2
		CMP r1, #0x32
		BNE level_3
		LDR r0, =T0MR1
		LDR r1, =0x00550000;
		STR r1, [r0]
		B continue_to
level_3
		CMP r1, #0x33
		BNE level_4
		LDR r0, =T0MR1
		LDR r1, =0x000F0000;
		STR r1, [r0]
		B continue_to
level_4	
		LDR r0, =T0MR1
		LDR r1, =0x00010000;
		STR r1, [r0]
		
continue_to
		LDR r0, =T1TCR
		LDR r1, [r0]
		ORR r1, r1, #0x1
		STR r1, [r0]
		;LTORG
		LDR r0, =T1MCR
		LDR r1, [r0]
		ORR r1, r1, #0x18
		BIC r1, r1, #0x7
		STR r1, [r0]
	
		LDR r0, =T1MR1
		LDR r1, =0x00003000;0x11940000
		STR r1, [r0]
	
		; Classify sources as IRQ or FIQ
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0xC]
		LDR r2, =0x8070 ;8 for bit15 external int, 1 for bit4 timer, 
		;0x8050 for timer 0, 0x8070 timer 0 and 1
		ORR r1, r1, r2 ; External Interrupt 1
		STR r1, [r0, #0xC]

		; Enable Interrupts
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0x10] 
		ORR r1, r1, r2 ; External Interrupt 1
		STR r1, [r0, #0x10]

		; External Interrupt 1 setup for edge sensitive
		LDR r0, =0xE01FC148
		LDR r1, [r0]
		ORR r1, r1, #2  ; EINT1 = Edge Sensitive
		STR r1, [r0]

		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR
		BIC r0, r0, #0x40
		ORR r0, r0, #0x80
		MSR CPSR_c, r0




infinite_loop
	LDR r0, =paused_game_flag
	LDR r1, [r0]
	CMP r1, #0
	BEQ not_paused

paused_loop
	LDR r0, =paused_game_flag
	LDR r1, [r0]
	CMP r1, #0
	BEQ not_paused
	;BL newline
	; stop movement of everything, BASCIALLY STOPS TIMER
	LDR r0, =UART0 ;interrupt enable fucking register
	LDR r1, [r0]
	BIC r1, r1, #3
	STR r1, [r0]
		
	LDR r0, =T0TCR
	LDR r1, [r0]
	AND r1, r1, #0x0
	STR r1, [r0]
	
	LDR r0, =T1TCR
	LDR r1, [r0]
	AND r1, r1, #0x0
	STR r1, [r0]
	
	;light up blue led for paused
	LDR r0, =IO0CLR
	LDR r1, =0x260000;
	STR r1, [r0]  ;
	LDR r0, =IO0SET
	LDR r1, =0x220000
	STR r1, [r0]
	
	B paused_loop
	
not_paused
		LDR r0, =UART0 ;interrupt enable fucking register
		LDR r1, [r0]
		ORR r1, r1, #1
		BIC r1, r1, #2
		STR r1, [r0]
		
		LDR r0, =T0TCR
		LDR r1, [r0]
		ORR r1, r1, #0x1
		STR r1, [r0]
		
		LDR r0, =T1TCR
		LDR r1, [r0]
		ORR r1, r1, #0x1
		STR r1, [r0]
		
		;light up green led
		LDR r0, =IO0CLR
		LDR r1, =0x260000;
		STR r1, [r0] 
		LDR r0, =IO0SET
		LDR r1, =0x60000
		STR r1, [r0]
	
	B infinite_loop
	
end_of_code
	LDMFD sp!, {lr}
	BX lr

update_map 
	STMFD SP!, {r1,lr}
	LDR r1 , =promptoffset
	LDR r0, [r1]
	BL output_string
	
	LDR r0, =prompt_level
	BL output_string
	
	LDR r0, =current_level
	BL output_string
	
	LDR r0, =prompt_mothership
	BL output_string
	
	LDR r0, =mothership_score_100
	BL output_string
	LDR r0, =mothership_score_10
	BL output_string
	LDR r0, =mothership_score_1
	BL output_string
	
	LDR r0, =prompt_timeleft
	BL output_string
	LDR r0, =time_left_100
	BL output_string
	LDR r0, =time_left_10
	BL output_string
	LDR r0, =time_left_1
	BL output_string
	
	LDMFD SP!, {r1,lr}
	BX lr

FIQ_Handler
		STMFD SP!, {r0-r12, lr}   ; Save registers 
TIMER0 ;cehcking for timer interrupt
		LDR r2, =T0IR
		LDR r3, [r2]
		TST r3, #2
		BEQ TIMER1
		;start_timer_handle
		STMFD SP!, {r0-r12, lr}   ; Save registers
		
		LDR r0, =endpoint_location
		LDR r1, [r0]
		LDRB r2, [r1]
		CMP r2, #0x4F
		BEQ endgame
		CMP r2, #0x4D
		BEQ endgame
		CMP r2, #0x57
		BEQ endgame
		BL enemy_motion
		LDMFD SP!, {r0-r12, lr}   ; Restore registers	
		ORR r3, r3, #2
		STR r3, [r2]

TIMER1
		LDR r2, =T1IR
		LDR r3, [r2]
		TST r3, #2
		BEQ UART0_int
		
		STMFD SP!, {r0-r12, lr}
		
		LDR r0, =seconds_increment_counter
		LDR r1, [r0]
		ADD r1, r1 , #1
		STR r1, [r0]
		LDR r2, =0x600
		CMP r1, r2
		BNE skip_adding_second
		
		LDR r0, =seconds_increment_counter
		MOV r1, #0
		STR r1, [r0]
		
		
		
		LDR r0, =time_left_total
		LDR r1, [r0]
		CMP r1, #120
		BEQ endgame
		ADD r1, r1, #1
		STR r1, [r0]
		
		LDR r0, =time_left_1
		LDR r1, [r0]
		ADD r1, r1, #1
		
		CMP r1, #0x3A
		BNE its_regular
		SUB r1, r1, #10
		LDR r3, =time_left_10
		LDR r4, [r3]
		ADD r4, r4, #1
		CMP r4, #0x3A
		BNE its_reegular
		SUB r4, r4, #10
		LDR r5, =time_left_100
		LDR r6, [r5]
		ADD r6, r6 ,#1 
		STR r6 , [r5]
its_reegular
		STR r4, [r3]
		
its_regular		
		STR r1, [r0]
		
skip_adding_second		
			;###############################################	
			;strobing
	
	LDR r0, =strobing_flag
	LDRB r1, [r0]
	
	CMP r1, #1
	BNE strobing_100
	
	MOV r1, #2
	STRB r1, [r0]
	LDR r0, =IO0DIR
	LDR r1, =0x26B784 ;1000
	STR r1, [r0]
	LDR r6, =IO0CLR 
	LDR r7, =0xB780	
	STR r7, [r6]
	
	LDR r0, =current_score_1000
	LDRB r1, [r0]
	MOV r2, #4
	MUL r3, r2 , r1
	LDR r0, =LED_1_command
	ADD r0, r0, r3
	LDR r4, [r0]
	
	
	
	LDR r6, =IO0SET
	STR r4, [r6]
	B done_strobbing
	;###############################################	
strobing_100	
	CMP r1, #2
	BNE strobing_10
	
	MOV r1, #3
	STRB r1, [r0]
	
	LDR r0, =IO0DIR
	LDR r1, =0x26B788 ;100
	STR r1, [r0]
	LDR r6, =IO0CLR 
	LDR r7, =0xB780	
	STR r7, [r6]
	
	LDR r0, =current_score_100
	LDR r1, [r0]
	CMP r1, #0
	BLT negative_case
	MOV r2, #4
	MUL r3, r2 , r1
	B regular_case
negative_case
	MOV r3, #0
regular_case
	LDR r0, =LED_1_command
	ADD r0, r0, r3
	LDR r4, [r0]
	
	
	
	LDR r6, =IO0SET
	STR r4, [r6]
	B done_strobbing
	;###############################################
strobing_10
	CMP r1, #3
	BNE strobing_1
	
	MOV r1, #4
	STRB r1, [r0]
	
	LDR r0, =IO0DIR
	LDR r1, =0x26B790 ;10
	STR r1, [r0]
	LDR r6, =IO0CLR 
	LDR r7, =0xB780	
	STR r7, [r6]
	
	LDR r0, =current_score_10
	LDRB r1, [r0]
	MOV r2, #4
	MUL r3, r2 , r1
	LDR r0, =LED_1_command
	ADD r0, r0, r3
	LDR r4, [r0]
	
	
	
	LDR r6, =IO0SET
	STR r4, [r6]
	B done_strobbing
	;###############################################	
strobing_1	
	CMP r1, #4
	BNE strobing_0
	
	MOV r1, #1
	STRB r1, [r0]
	
	LDR r0, =IO0DIR
	LDR r1, =0x26B7A0 ;1
	STR r1, [r0]
	LDR r6, =IO0CLR 
	LDR r7, =0xB780	
	STR r7, [r6]
	
	LDR r0, =current_score_1
	LDRB r1, [r0]
	MOV r2, #4
	MUL r3, r2 , r1
	LDR r0, =LED_1_command
	ADD r0, r0, r3
	LDR r4, [r0]
	
	
	
	LDR r6, =IO0SET
	STR r4, [r6]
strobing_0		
done_strobbing
	
		LDR r0, =timer_counter
		LDR r1, [r0]
		ADD r1, r1, #1
		STR r1, [r0]
		LDR r2, =0x95
		;###############################################	
		CMP r1 , r2
		BNE skip_cuz_soft_timer
	
		LDR r0, =timer_counter
		MOV r1, #0
		STRB r1, [r0]
		
		LDR r0, =proj_exist_on_board_flag;       EQU 0x40007410
		LDRB r1, [r0]
		CMP r1, #1
		BEQ exist_on_board
		;BL eject_proj;This line is for test purpose, will be delete once i compare the proj_exist_flage
		B done_with_existflag
exist_on_board		

		LDR r0, =IO0CLR
		LDR r1, =0x260000;
		STR r1, [r0]  ;
		LDR r0, =IO0SET
		LDR r1, =0x240000
		STR r1, [r0]
		BL proj_motion
done_with_existflag	

	LDR r0, =mothership_exist_on_board
	LDRB r1, [r0]
	CMP r1, #0
	BNE mother_already_exist
	;add rng to % show up rate
	
	
		MOV r11, #50
		
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
	LDR r0,=mothership_appears_count
	LDR r2, [r0]
	ADD r1, r1 , r2
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
		
		
		
		
		
		
		CMP r12, #1
		BNE do_nothing
		LDR r0,=mothership_appears_count
		LDR r1, [r0]
		ADD r1, r1 , #1

		STRB r1, [r0]
		MOV r11, #2
		BL rng
		CMP r12, #1
		BNE idc_about_names
		BL mothership_starting_showup_left	
		B do_nothing
idc_about_names		
		BL mothership_starting_showup_right	
		B do_nothing	;BL from_left_motion
		
mother_already_exist	

		LDR r0, =mothership_left_or_right_dir
		LDRB r1, [r0]		
		CMP r1, #0
		BEQ nonames
		BL mothership_left_move									
		B do_nothing
nonames				
		BL mothership_right_move
	
do_nothing	
		LDR r0, =enemy_proj_on_board
		LDRB r1, [r0]
		CMP r1, #1
		BEQ denied_enemy_proj
		
		;LTORG
		
		BL eject_enemy_proj
		B idkkkkk
denied_enemy_proj
		BL enemy_proj_motion
idkkkkk	
		BL update_map
		
skip_cuz_soft_timer		
		LDMFD SP!, {r0-r12, lr}  	
		ORR r3, r3, #2
		STR r3, [r2]
		
UART0_int
		LDR r2, =0xE000C008
		LDR r3, [r2]
		TST r3, #1
		BNE EINT1
		STMFD SP!, {r0-r12, lr}
		
		LDR r0, =U0TRR
		LDR r1, [r0]
		
		LDR r0, =keystork_rng_counter
		LDR r2, [r0]
		ADD r2, r2 , #1 
		STR r2, [r0]
		
		CMP r1, #0x41
		BNE not_moving_left

		LDR r0, =current_keyboard_rng_input
		STR r1, [r0]

		LDR r0,=ship_location
		LDR r1, [r0]
		LDR r0, =promptoffset
		LDR r2, [r0]
		LDR r3, =0x179
		ADD r2, r2 , r3
		CMP r1, r2
		BEQ cant_move_left
		BL ship_shift_left
		BL update_map
		;LTORG
cant_move_left
		B done_once_key_input
		
not_moving_left
		CMP r1, #0x44
		BNE not_moving_right

		LDR r0, =current_keyboard_rng_input
		STR r1, [r0]

		LDR r0,=ship_location
		LDR r1, [r0]
		LDR r0, =promptoffset
		LDR r2, [r0]
		LDR r3, =0x18D
		ADD r2, r2 , r3
		CMP r1, r2
		BEQ cant_move_right
		
		BL ship_shift_right
		BL update_map
		;LTORG
cant_move_right		
		B done_once_key_input
not_moving_right
		CMP r1, #0x20
		BNE done_once_key_input		;ADDED THIS
		
		
		
		LDR r0, =current_keyboard_rng_input
		STR r1, [r0]
		LDR r0, =proj_exist_on_board_flag;       EQU 0x40007410
		LDRB r1, [r0]
		CMP r1, #1
		BEQ exist_on_board2
		
		BL eject_proj;This line is for test purpose, will be delete once i compare the proj_exist_flage
exist_on_board2

		BNE done_once_key_input
		
		
		
done_once_key_input		
		
		;ADDED ALL OF THIS

		LDMFD SP!, {r0-r12, lr}
		

EINT1			; Check for EINT1 interrupt
;ADD ALL OF THIS
		;using this to pause game
		LDR r0, =0xE01FC140
		LDR r1, [r0]
		TST r1, #2 ;if second bit of r1 is 1 that means clearing the bit, thus skip
		BEQ FIQ_Exit
	 ;start handling
		STMFD SP!, {r0-r12, lr}   ; Save registers 
		;pauses game, perhaps also show score on 7 seg. 
		
		
		LDR r0, =paused_game_flag
		LDRB r1, [r0]
		CMP r1, #0
		BNE not_1
		MOV r1, #1
		STRB r1, [r0]
		B done_flagging
not_1
		MOV r3, #0
		STRB r3, [r0];resumes game
done_flagging		
		BL newline
		LDR r0, =prompt1
		BL output_string
		
		LDMFD SP!, {r0-r12, lr}   ; Restore registers
		ORR r1, r1, #2		; Clear Interrupt
		STR r1, [r0]

FIQ_Exit
		LDMFD SP!, {r0-r12, lr}
		SUBS pc, lr, #4 
		
		
endgame
	STMFD sp!, {lr}
	LDR r0, =IO1SET
	LDR r1, =0xF0000
	STR r1, [r0]
	LDR r0, =IO0CLR
	LDR r1, =0x260000;LDR r1, =0x8000
	STR r1, [r0]  ;
	LDR r0, =IO0SET
	LDR r1, =0x200000
	STR r1, [r0]
	
	
	
	
	
	
	
	;--------------------------------------------------------
	LDR r0, =current_score_1000
	LDR r1, [r0]
	LDR r2, =total_score_1000
	LDR r3, [r2]
	ADD r3, r3, r1
	STR r3, [r2]

;--------------------------------------------------------	
;--------------------------------------------------------	

	LDR r0, =current_score_100
	LDR r1, [r0]
	LDR r2, =total_score_100
	LDR r3, [r2]
	ADD r3, r3, r1
	
	CMP r3, #10
	BLT its_totally_fine_3
	SUB r3, r3, #10
	LDR r4, =total_score_1000
	LDR r5, [r4]
	ADD r5, r5 , #1
	STR r5, [r4]
its_totally_fine_3	
	STR r3, [r2]
	
	
;--------------------------------------------------------	
;--------------------------------------------------------		
	
	LDR r0, =current_score_10
	LDR r1, [r0]
	LDR r2, =total_score_10
	LDR r3, [r2]
	ADD r3, r3, r1
	
	CMP r3, #10
	BLT its_totally_fine_2
	SUB r3, r3, #10
	LDR r4, =total_score_100
	LDR r5, [r4]
	ADD r5, r5, #1
	CMP r5, #10
	BLT its_totally_fine_fine_2
	SUB r5, r5 , #10
	LDR r6, =total_score_1000
	LDR r7, [r6]
	ADD r7, r7, #1
	STR r7, [r6]
its_totally_fine_fine_2
	STR r5, [r4]
its_totally_fine_2	
	STR r3, [r2]
	

;--------------------------------------------------------	
;--------------------------------------------------------	
	
	LDR r0, =current_score_1
	LDR r1, [r0]
	LDR r2, =total_score_1
	LDR r3, [r2]
	ADD r3, r3, r1
	;r4,r5,r6,r7,r8,r9
	CMP r3, #10
	BLT its_totally_fine
	SUB r3, r3, #10
	LDR r4, =total_score_10
	LDR r5, [r4]
	ADD r5, r5, #1 ; r5 is 10 digit
	CMP r5, #10
	BLT its_totally_fine_fine
	SUB r5, r5, #10
	LDR r6, =total_score_100
	LDR r7, [r6]
	ADD r7, r7, #1
	CMP r7, #10
	BLT its_totally_fine_fine_fine
	SUB r7, r7, #10
	LDR r8, =total_score_1000
	LDR r9, [r8]
	ADD r9, r9, #1
	
	STR r9, [r8]
its_totally_fine_fine_fine	
	STR r7, [r6]
its_totally_fine_fine	
	STR r5, [r4]
its_totally_fine	
	STR r3, [r2]


;--------------------------------------------------------	


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	LDR r0, =promptend
	LDR r5, =promptend_offset
	STR r0, [r5]
	
	LDR r0, =score_location_1
	LDR r2, [r5]
	ADD r2, r2, #0xA2 	;score offset
	STR r2, [r0]
	LDR r4, =total_score_1000
	LDRB r6, [r4]
	ADD r6, r6, #0x30
	STRB r6, [r2]
	
	LDR r0, =score_location_2
	LDR r2, [r5]
	ADD r2, r2, #0xA3 	;score offset
	STR r2, [r0]
	LDR r4, =total_score_100
	LDRB r6, [r4]
	ADD r6, r6, #0x30
	STRB r6, [r2]	
	
	LDR r0, =score_location_3
	LDR r2, [r5]
	ADD r2, r2, #0xA4 	;score offset
	STR r2, [r0]
	LDR r4, =total_score_10
	LDRB r6, [r4]
	ADD r6, r6, #0x30
	STRB r6, [r2]	
	
	LDR r0, =score_location_4
	LDR r2, [r5]
	ADD r2, r2, #0xA5 	;score offset
	STR r2, [r0]
	LDR r4, =total_score_1
	LDRB r6, [r4]
	ADD r6, r6, #0x30
	STRB r6, [r2]
	
	LDR r0, =time_location_1
	LDR r2, [r5]
	ADD r2, r2, #0xF0 	;time offset
	STR r2, [r0]
	LDR r4, =time_left_100
	LDRB r6, [r4]
	STRB r6, [r2]
	
	LDR r0, =time_location_2
	LDR r2, [r5]
	ADD r2, r2, #0xF1 	;time offset
	STR r2, [r0]
	LDR r4, =time_left_10
	LDRB r6, [r4]
	STRB r6, [r2]
	
	LDR r0, =time_location_3
	LDR r2, [r5]
	ADD r2, r2, #0xF2 	;time offset
	STR r2, [r0]
	LDR r4, =time_left_1
	LDRB r6, [r4]
	STRB r6, [r2]

	LDR r0, =promptend
	BL output_string





	LDR r0, =prompt_storage_offset
	LDR r1, [r0]
	MOV r2, #0
	STRB r2, [r1]
	STRB r2, [r1,#1]
	STRB r2, [r1,#2]
	STRB r2, [r1,#3]
	STRB r2, [r1,#4]
	STRB r2, [r1,#5]
	
	LDR r0, =prompt_storage_offset_copy
	LDR r8, [r0]
	MOV r12, #0x30
Loop_printingout_shit

	; dont touch r1, 
	LDRB r2, [r8]
	CMP r2, #0
	BEQ done_printing_shit

	LDR r0, =promptend_level
	BL output_string
	MOV r1, r12
	ADD r12, r12, #1
	BL output_character
	
	LDR r0, =promptend_levelscore ; printing out score
	BL output_string
	
	LDRB r2, [r8],#1
	MOV r1, r2
	BL output_character
	LDRB r2, [r8],#1
	MOV r1, r2
	BL output_character
	LDRB r2, [r8],#1
	MOV r1, r2
	BL output_character
	LDRB r2, [r8],#1
	MOV r1, r2
	BL output_character

	LDR r0, =promptend_leveldeathcount ; printingout death_count
	BL output_string
	
	LDRB r2, [r8],#1
	MOV r1, r2
	BL output_character
	
	LDR r0, =promptend_levelmothership
	BL output_string
	
	LDRB r2, [r8],#1
	MOV r1, r2
	BL output_character
	
	MOV r1, #0x2F
	BL output_character
	
	LDRB r2, [r8],#1
	MOV r1, r2
	BL output_character

	LDR r0, =promptend_leveltime
	BL output_string
	
	LDRB r2, [r8],#1
	MOV r1, r2
	BL output_character
		
	LDRB r2, [r8],#1
	;ADD r2, r2, #0x30
	MOV r1, r2
	BL output_character
		
	LDRB r2, [r8],#1
	MOV r1, r2
	BL output_character
	
	B Loop_printingout_shit
	
done_printing_shit

	LDR r0, =promptend_level
	BL output_string
	
	LDR r0, =current_level
	BL output_string
	
	LDR r0, =promptend_levelscore
	BL output_string
	
	LDR r0, =current_score_1000
	LDR r1, [r0]
	ADD r1, r1, #0x30
	STR r1, [r0]
	BL output_string
	
	LDR r0, =current_score_100
	LDR r1, [r0]
	ADD r1, r1, #0x30
	STR r1, [r0]
	BL output_string
	
	LDR r0, =current_score_10
	LDR r1, [r0]
	ADD r1, r1, #0x30
	STR r1, [r0]
	BL output_string
	
	LDR r0, =current_score_1
	LDR r1, [r0]
	ADD r1, r1, #0x30
	STR r1, [r0]	
	BL output_string
	
	LDR r0, =promptend_leveldeathcount
	BL output_string
	
	
	LDR r0, =lives
	LDR r1, [r0]
	RSB r1, r1, #4
	ADD r1, r1, #0x30
	BL output_character

	LDR r0, =promptend_levelmothership
	BL output_string
	
	LDR r0, =mothership_appears_hit
	LDRB r1, [r0]
	ADD r1, r1 , #0x30
	BL output_character
	
	MOV r1, #0x2F
	BL output_character
	
	LDR r0, =mothership_appears_count
	LDRB r1, [r0]
	ADD r1, r1, #0x30
	BL output_character
	
	LDR r0, =promptend_leveltime
	BL output_string
	
	LDR r0, =time_left_100
	LDRB r1, [r0]
	BL output_character
	LDR r0, =time_left_10
	LDRB r1, [r0]
	BL output_character
	LDR r0, =time_left_1
	LDRB r1, [r0]
	BL output_character
	
	

infinity_loop
	; CHECK FOR ENTER KEY TO BRANCH TO LAB7
	B infinity_loop
	

	LDMFD sp!, {lr}
	BX lr

	END