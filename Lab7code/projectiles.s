	AREA	GPIO, CODE, READWRITE	

	;EXTERN amount_of_lives
	EXTERN FIQ_Handler
	EXTERN end_of_code
	EXTERN rng	
	EXTERN update_map
	EXTERN uart_init
	EXPORT proj_setups
	EXPORT eject_proj
	EXPORT proj_motion
	EXTERN newline
	EXTERN lab7_restart
	EXTERN enemy_proj_setups
	EXTERN enemy_setups	
	EXTERN ship_setups
	EXTERN mothership_setup
	EXTERN output_string
	EXTERN interrupt_init
lives EQU 0x40005000
UART0 EQU 0xE000C004	
T0TCR EQU 0xE0004004
T0MCR EQU 0xE0004014
T1TCR EQU 0xE0008004
T1MCR EQU 0xE0008014
T0TC  EQU 0xE0004008	
number_of_loops EQU 0x40007544
	
mothership_score_1	EQU 0x40006930
mothership_score_10	EQU 0x40006934
mothership_score_100 EQU 0x40006938


mothership_exist_on_board EQU 0x400078A0	
promptoffset                   EQU 0x40007100
proj_offset                    EQU 0x40007400
ship_location                  EQU 0x40006000
proj_exist_on_board_flag       EQU 0x40007410
Ss_storing_address             EQU 0x40007420	
Ss2_storing_address            EQU 0x40007430
selected_enemy_that_shoot_proj EQU 0x40007440	
enemy_proj_offset              EQU 0x40007450	
; 0 means not on board
; 1 means on board
current_score_1 EQU 0x40006900
current_score_10 EQU 0x40006904
current_score_100 EQU 0x40006908
current_score_1000 EQU 0x4000690C

total_score_1 EQU   0x40006920
total_score_10 EQU   0x40006924
total_score_100 EQU   0x40006928
total_score_1000 EQU   0x4000692C

time_left_1		   EQU 0x40006944
time_left_10		EQU 0x40006948
time_left_100		EQU 0x4000694C
	
total_score EQU   0x40006920
current_level EQU 0x40000200
endpoint_location EQU 0x40006940	

enemyoffset     EQU 0x40007120
enemy2offset    EQU 0x40007130 
enemy3offset    EQU 0x40007140 
enemy4offset    EQU 0x40007150 
enemy5offset    EQU 0x40007160 
	
enemycounts  EQU 0x40007270
enemy2counts EQU 0x40007280
enemy3counts EQU 0x40007290
enemy4counts EQU 0x400072A0
enemy5counts EQU 0x400072B0
	
right_enemycounts  EQU 0x40007370
right_enemy2counts EQU 0x40007380
right_enemy3counts EQU 0x40007390
right_enemy4counts EQU 0x400073A0
right_enemy5counts EQU 0x400073B0

offset_hit_counts EQU  0x40007500
offset2_hit_counts EQU 0x40007510
offset3_hit_counts EQU 0x40007520
offset4_hit_counts EQU 0x40007530
offset5_hit_counts EQU 0x40007540
	
keystork_rng_counter EQU 0x40007990
current_keyboard_rng_input EQU 0x40007994	
paused_game_flag EQU 0x40005010
prompt_storage_offset EQU 0x40007E20
	
mothership_appears_count EQU 0x40007E28
mothership_appears_hit   EQU 0x40007E2C
	

prompt = 12,"|---------------------|", 10,13 ,  "|                     |", 10,13 , "|       OOOOOOO       |", 10,13 ,  "|       MMMMMMM       |", 10,13 ,  "|       MMMMMMM       |", 10,13 ,  "|       WWWWWWW       |", 10,13 ,  "|       WWWWWWW       |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|   SSS   SSS   SSS   |", 10,13 ,  "|   S S   S S   S S   |", 10,13 ,  "|                     |", 10,13 ,  "|                     |", 10,13 ,  "|          A          |", 10, 13 ,"|---------------------|" ,0
	ALIGN
		
proj_setups
	STMFD sp!, {r0-r12,lr}
	LDR r0, =proj_exist_on_board_flag
	MOV r1, #0
	STR r1, [r0]
	
	LDR r0, =Ss_storing_address
	MOV r1, #0
	STR r1, [r0]


	LDR r0, =Ss2_storing_address
	MOV r1, #0
	STR r1, [r0]

	LDR r0, =selected_enemy_that_shoot_proj
	MOV r1, #0
	STR r1, [r0]
	
	LDMFD sp!, {r0-r12,lr}
	BX lr



eject_proj
	STMFD sp!, {r0-r12,lr}
	LDR r0, =ship_location
	LDR r1, [r0]
	SUB r1, r1, #0x19
	LDR r0, =proj_offset
	STR r1, [r0]  
	
	LDR r0, =proj_offset
	LDR r2, [r0]
	MOV r1, #0x5E
	STRB r1, [r2] ; projectile while shows up at the front of A
	
	LDR r0, =proj_exist_on_board_flag
	MOV r1, #0x1
	STR r1, [r0]
	LDMFD sp!, {r0-r12,lr}
	BX lr

proj_motion 
	STMFD sp!, {r0-r12,lr}

	LDR r0, =proj_offset
	LDR r1, [r0]
	LDRB r3, [r1]
	CMP r3, #0x5E
	BEQ safe_skip
	CMP r3, #0x20
	BEQ safe_skip
	ADD r1, r1, #0x19
	STR r1, [r0]
	BL proj_hits_enemy
	
	B done_end
safe_skip	
	 
	LDR r2, [r0]
	MOV r3, #0x5E
	STRB r3, [r2]
	
	LDRB r2, [r1, #-0x19] ;  r2 contant what is up from the proejctile
	
	CMP r2, #0x20
	BEQ its_space
	
	CMP r2, #0x53 ;'S'
	BEQ its_Ss
	
	CMP r2, #0x73 ;'s'
	BEQ its_Ss
	
	CMP r2, #0x4F ;'O'
	BEQ its_OMW
	CMP r2, #0x4D ;'M'
	BEQ its_OMW
	CMP r2, #0x57 ;'W'
	BEQ its_OMW
	CMP r2, #0x2D ; '-'
	BEQ its_end
	CMP r2, #0x76 ; 'v'
	BEQ its_enemy_proj
	CMP r2, #0x58
	BEQ its_OMW
	
its_space
	LDR r0, =proj_offset
	LDR r1, [r0]
	SUB r5, r1, #0x19
	STR r5, [r0]
	MOV r3, #0x5E ; r3 stores '^'
	MOV r4, #0x20
	STRB r4, [r1]
	STRB r3, [r1, #-0x19]
	B done_end ; next_move
its_Ss
	CMP r2, #0x53
	BNE its_s
	MOV r12, #0x73
	STRB r12, [r1,#-0x19]
	B done_with_reduce
its_s
	MOV r12, #0x20
	STRB r12, [r1,#-0x19]
done_with_reduce	
	LDR r0, =proj_offset
	LDR r1, [r0]
	MOV r2, #0x20
	STRB r2, [r1]
	LDR r0, =proj_exist_on_board_flag
	MOV r1, #0
	STRB r1, [r0] 
	B done_once
its_OMW
	BL proj_hits_enemy
	B done_end
its_end
	LDR r0, =proj_offset
	LDR r1, [r0]
	MOV r2, #0x20
	STRB r2, [r1]
	LDR r0, =proj_exist_on_board_flag
	MOV r1, #0
	STRB r1, [r0] 
	B done_end	
its_enemy_proj
	LDR r0, =proj_offset
	LDR r1, [r0]
	SUB r1, r1, #0x19
	STR r1, [r0]
	B done_end
done_once
	LDR r3, =proj_offset
	LDR r7, [r3]
	LDRB r6, [r7, #-0x19]
	CMP r6, #0x53
	BEQ not_Sss 
	CMP r6, #0x73
	BEQ not_Sss
	CMP r6, #0x20
	BEQ one_barrier_case;r9 stores r2 thats before '^'  			; if r9 is S, s  Skip 
	
	LDR r0, =Ss_storing_address
	LDRB r1, [r0]
	CMP r1, #0;#0x53 = 'S'    0x73 = 's'
	BEQ not_Ss
	
	LDR r3, =proj_offset
	LDR r4, [r3]
	STRB r1, [r4, #0x19] ; storing it back
	MOV r2, #0
	STRB r2, [r0] ;reset it to 0
	B not_Sss
not_Ss
	LDR r0, =Ss2_storing_address
	LDRB r1, [r0]
	CMP r1, #0
	BEQ not_Sss
	
	LDR r3, =proj_offset
	LDR r4, [r3] 
	STRB r1, [r4, #0x19]
not_Sss	
	B done_end

one_barrier_case
	LDR r0, =Ss_storing_address
	LDRB r1, [r0]
	
	LDR r3, =proj_offset
	LDR r4, [r3]
	B done_end

done_once_Ss

done_end
	;BL update_map
	LDMFD sp!, {r0-r12,lr}
	BX lr


proj_hits_enemy
	STMFD SP!,{lr}
	LDR r0, =promptoffset
	LDR r1, [r0]
	LDR r3, =proj_offset
	LDR r4, [r3]
	LDRB r0, [r4]
	
	CMP r0, #0x5E
	BNE dont_care_anymore
	MOV r0, #0x20
	STRB r0, [r4]
dont_care_anymore	
	SUB r5, r4, #0x19 ; r5 has the enemy hit location

	LDRB r0, [r5]
	CMP r0, #0x4F
	BNE not_O_score
	LDR r0, =current_score_10
	MOV r1, #4
	LDRB r2, [r0]
	ADD r2, r2 , r1
	CMP r2, #10
	BLT its_normal
	SUB r2, r2, #10
	LDR r0, =current_score_100
	LDR r1, [r0]
	ADD r1, r1, #1
	CMP r1, #10
	BLT its_normal__2
	SUB r1, r1, #10
	LDR r0, =current_score_1000
	LDRB r3, [r0]
	ADD r3, r3 , r1
	STRB r3, [r0]
	
its_normal__2	
	LDR r0, =current_score_100
	STR r1, [r0]
its_normal	
	LDR r0, =current_score_10
	STRB r2, [r0]
	B done_adding_score
	
not_O_score	
	LDRB r0, [r5]
	CMP r0, #0x4D
	BNE not_M_score
	LDR r0, =current_score_10
	MOV r1, #2
	LDRB r2, [r0]
	ADD r2, r2 , r1
	CMP r2, #10
	BLT its_normal_1
	SUB r2, r2, #10
	LDR r0, =current_score_100
	LDR r1, [r0]
	ADD r1, r1, #1
	CMP r1, #10
	BLT its_normal_1_2
	SUB r1, r1, #10
	LDR r0, =current_score_1000
	LDRB r3, [r0]
	ADD r3, r3 , r1
	STRB r3, [r0]
its_normal_1_2	
	LDR r0, =current_score_100
	STR r1, [r0]
its_normal_1	
	LDR r0, =current_score_10
	STRB r2, [r0]
	B done_adding_score
	
not_M_score	

	LDRB r0, [r5]
	CMP r0, #0x57
	BNE not_W_score
	LDR r0, =current_score_10
	MOV r1, #1
	LDRB r2, [r0]
	ADD r2, r2 , r1
	CMP r2, #10
	BLT its_normal_2
	SUB r2, r2, #10
	LDR r0, =current_score_100
	LDR r1, [r0]
	ADD r1, r1, #1
	CMP r1, #10
	BLT its_normal_2_2
	SUB r1, r1, #10
	LDR r0, =current_score_1000
	LDRB r3, [r0]
	ADD r3, r3 , r1
	STRB r3, [r0]
its_normal_2_2	
	LDR r0, =current_score_100
	STR r1, [r0]
its_normal_2	
	LDR r0, =current_score_10
	STRB r2, [r0]
	B done_adding_score
	
not_W_score	
	
	LDRB r0, [r5]
	CMP r0, #0x58
	BNE not_x_score

	LDR r0,=mothership_appears_hit
	LDR r1, [r0]
	ADD r1 ,r1 , #1
	STR r1, [r0]
	MOV r11, #4  ; number in r11 determines prob = 1/(r11)
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
	LDR r10, =number_of_loops 
	LDRB r6, [r10]
	ADD r1, r1 ,r6 
	MOV r8, r11  ; immediates enters here shows the range of random numbers
continue_subb2
	CMP r1, r8 
	BLT done_diving2
	SUB r1, r1, r8
	B continue_subb2
done_diving2
;------------------------------------
	LDR r0, =current_score_100
	LDR r2, [r0]
	ADD r2, r1, r2
	CMP r2, #10
	BLT its_least_then_10_100
	SUB r2, r2 ,#10
	LDR r3, =current_score_1000
	LDR r4, [r3]
	ADD r4, r4 , #1
	STR r4, [r3]
its_least_then_10_100	
	STR r2, [r0]
	;need to do exception
;------------------------------------
	ADD r1, r1 ,#0x30
	LDR r4, =mothership_score_100 ; display only
	STR r1, [r4]


	MOV r11, #10  ; number in r11 determines prob = 1/(r11)
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
	LDR r10, =number_of_loops 
	LDRB r6, [r10]
	ADD r1, r1 ,r6 
	MOV r8, r11  ; immediates enters here shows the range of random numbers
continue_subb22
	CMP r1, r8 
	BLT done_diving22
	SUB r1, r1, r8
	B continue_subb22
done_diving22
;------------------------------------
	LDR r0, =current_score_10
	LDR r2, [r0]
	ADD r2, r1, r2
	CMP r2, #10
	BLT its_least_then_10_10
	SUB r2, r2 ,#10
	LDR r3, =current_score_100
	LDR r4, [r3]
	ADD r4, r4 , #1
	CMP r4, #10
	BLT its_least_then_100_10
	SUB r4, r4 , #10
	LDR r6, =current_score_1000
	LDR r7, [r6]
	ADD r7, r7, #1
	STR r7, [r6]
its_least_then_100_10	
	STR r4, [r3]
its_least_then_10_10	
	STR r2, [r0]
;------------------------------------
	ADD r1, r1 ,#0x30
	LDR r4, =mothership_score_10		
	STRB r1, [r4] 
	

	;MOV r2, #5
	
	MOV r11, #10  ; number in r11 determines prob = 1/(r11)
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
	LDR r10, =number_of_loops 
	LDRB r6, [r10]
	ADD r1, r1 ,r6 
	MOV r8, r11  ; immediates enters here shows the range of random numbers
continue_subb222
	CMP r1, r8 
	BLT done_diving222
	SUB r1, r1, r8
	B continue_subb222
done_diving222
;------------------------------------
	LDR r0, =current_score_1
	LDR r2, [r0]
	ADD r2, r1, r2
	CMP r2, #10
	BLT its_least_then_10_1
	SUB r2, r2 ,#10
	LDR r3, =current_score_10
	LDR r4, [r3]
	ADD r4, r4 , #1
	CMP r4, #10
	BLT its_least_then_100_1
	SUB r4, r4 , #10
	LDR r6, =current_score_100
	LDR r7, [r6]
	ADD r7, r7, #1
	CMP r7, #10
	BLT its_least_then_1000_1
	LDR r8, =current_score_1000
	LDR r9, [r8]
	ADD r9, r9, #1
	STR r9, [r8]
	
its_least_then_1000_1	
	STR r7, [r6]
its_least_then_100_1	
	STR r4, [r3]
its_least_then_10_1
	STR r2, [r0]
	
;------------------------------------		
	ADD r1, r1 ,#0x30
	LDR r4, =mothership_score_1	
	STRB r1, [r4]
	LDR r0, =mothership_exist_on_board
	MOV r1, #0
	STR r1, [r0]
	
	
	B done_adding_score_after_x
not_x_score	
done_adding_score	

	BL reducing_enemy_right_counts
	BL reducing_enemy_counts
	BL enemyoffset_hitted
	;r5 is collision spot
	MOV r0, #0x20
	STRB r0, [r5]
	; the reason why its deleting 2 is because offset address
	;if r4 is 5e then it will be clear!
	LDRB r9, [r4]
	CMP r9, #0x5E
	BNE dont_clear_its_not
	STRB r0, [r4]
dont_clear_its_not	

	LDR r0 , =proj_exist_on_board_flag
	MOV r1, #0
	STR r1, [r0]
	;4.Set proj_on_board_flag back to 0
	;5.Add score
	;6.????
	
	LDR r0, =enemycounts
	LDRB r1, [r0]
	CMP r1, #0
	BNE game_not_advance_yet
	
	LDR r0, =enemy2counts
	LDRB r1, [r0]
	CMP r1, #0
	BNE game_not_advance_yet
	
	LDR r0, =enemy3counts
	LDRB r1, [r0]
	CMP r1, #0
	BNE game_not_advance_yet
	
	LDR r0, =enemy4counts
	LDRB r1, [r0]
	CMP r1, #0
	BNE game_not_advance_yet
	
	LDR r0, =enemy5counts
	LDRB r1, [r0]
	CMP r1, #0
	BNE game_not_advance_yet
	
	LDMFD SP!,{lr}
	;deinitializing everything here
		LDR r0, =T0TCR
		LDR r1, [r0]
		AND r1, r1, #0x0
		STR r1, [r0]

		LDR r0, =T1TCR
		LDR r1, [r0]
		AND r1, r1, #0x0
		STR r1, [r0]
		
	;LTORG
	LDR r0, =current_level
	LDR r1, [r0]
	ADD r1, r1, #1
	STR r1, [r0]

;--------------------------------------------------------
	LDR r0, =current_score_1000
	LDR r1, [r0]
	LDR r2, =total_score_1000
	LDR r3, [r2]
	ADD r3, r3, r1
	STR r3, [r2]
	LDR r4, =prompt_storage_offset
	LDR r5, [r4]  ; r5 contains the current address for offset
	ADD r7, r1, #0x30
	STRB r7, [r5],#1
	STR r5, [r4]	
	MOV r1, #0
	STR r1, [r0]
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
	
	
	LDR r4, =prompt_storage_offset
	LDR r5, [r4]  ; r5 contains the current address for offset
	ADD r7, r1, #0x30
	STRB r7, [r5],#1
	STR r5, [r4]
	MOV r1, #0
	STR r1, [r0]
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
	
	LDR r4, =prompt_storage_offset
	LDR r5, [r4]  ; r5 contains the current address for offset
	ADD r7, r1, #0x30
	STRB r7, [r5],#1
	STR r5, [r4]
	MOV r1, #0
	STR r1, [r0]
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

	
	
	
	LDR r4, =prompt_storage_offset
	LDR r5, [r4]  ; r5 contains the current address for offset
	ADD r7, r1, #0x30
	STRB r7, [r5],#1
	STR r5, [r4]
	MOV r1, #0
	STR r1, [r0]
;--------------------------------------------------------	


;--------------------------------------------------------	
				;Storing Death counts
	LDR r0, =lives
	LDRB r1, [r0]
	RSB r1, r1 ,#4
	LDR r4, =prompt_storage_offset
	LDR r5, [r4]
	ADD r1, r1, #0x30
	STRB r1, [r5], #1
	STR r5, [r4]
;--------------------------------------------------------	
;--------------------------------------------------------	
				;Storing Motherships Appears/Hits
				
	LDR r0, =mothership_appears_hit
	LDR r1, [r0]
	LDR r2, =prompt_storage_offset
	LDR r3, [r2]
	ADD r1, r1 , #0x30
	STRB r1, [r3],#1
	STR r3, [r2]
	
	LDR r0, =mothership_appears_count
	LDR r1, [r0]
	LDR r2, =prompt_storage_offset
	LDR r3, [r2]
	ADD r1, r1, #0x30
	STRB r1, [r3],#1
	STR r3, [r2]
	
;--------------------------------------------------------	
;--------------------------------------------------------	
				;Storing Time 

		LDR r0, =time_left_100
		LDR r1, [r0]
		LDR r2, =prompt_storage_offset
		LDR r3, [r2]
		STRB r1, [r3],#1
		STR r3, [r2]
		
		LDR r0, =time_left_10
		LDR r1, [r0]
		LDR r2, =prompt_storage_offset
		LDR r3, [r2]
		STRB r1, [r3],#1
		STR r3, [r2]
		
		LDR r0, =time_left_1
		LDR r1, [r0]
		LDR r2, =prompt_storage_offset
		LDR r3, [r2]
		STRB r1, [r3],#1
		STR r3, [r2]
		
	

	
	B lab7_restart
	
done_adding_score_after_x
game_not_advance_yet	
	
	LDMFD SP!,{lr}
	BX lr

reducing_enemy_right_counts
	STMFD sp!, {lr}
	
	LDR r0, =enemy5offset
	LDR r1, [r0]
	LDR r3, =right_enemy5counts
	LDR r2, [r3]
	SUB r2, r2, #1
	ADD r3, r1, r2
	ADD r2, r2, #1
	CMP r3, r5
	BNE not_5th_right_enemy
;===========================
	SUB r2 , r2 , #1
didnt_find_next_rightmost5	
	LDR r4, =right_enemy5counts	
	CMP r2,#-1
	BEQ found_the_next_rightmost5
	SUB r2, r2, #1
	LDRB r0, [r1,r2] ; checking if the previous spot is empty
	ADD r2, r2, #1
	CMP r0, #0x20  ; if its empty, that means enemy has been destroyed, loop back
	BNE found_the_next_rightmost5
	SUB r2, r2 , #1
	B didnt_find_next_rightmost5
found_the_next_rightmost5
	STRB r2, [r4]
	B done_reducing_enemy_right_counts
;====================================

not_5th_right_enemy

	LDR r0, =enemy4offset
	LDR r1, [r0]
	LDR r3, =right_enemy4counts
	LDR r2, [r3]
	SUB r2, r2, #1
	ADD r3, r1, r2
	ADD r2, r2, #1
	CMP r3, r5
	BNE not_4th_right_enemy
	
;==============================
	SUB r2 , r2 , #1
didnt_find_next_rightmost4	
	LDR r4, =right_enemy4counts	
	CMP r2,#-1
	BEQ found_the_next_rightmost4	
	SUB r2, r2, #1
	LDRB r0, [r1,r2] ; checking if the previous spot is empty
	ADD r2, r2, #1
	CMP r0, #0x20  ; if its empty, that means enemy has been destroyed, loop back
	BNE found_the_next_rightmost4
	SUB r2, r2 , #1
	B didnt_find_next_rightmost4
found_the_next_rightmost4	
	STRB r2, [r4]
	B done_reducing_enemy_right_counts
;====================================

not_4th_right_enemy	

	LDR r0, =enemy3offset
	LDR r1, [r0]
	LDR r3, =right_enemy3counts
	LDR r2, [r3]
	SUB r2, r2, #1
	ADD r3, r1, r2
	ADD r2, r2, #1
	CMP r3, r5
	BNE not_3th_right_enemy
	LDR r3, =right_enemy3counts
;===============================
	SUB r2 , r2 , #1
didnt_find_next_rightmost3	
	LDR r4, =right_enemy3counts	
	CMP r2,#0
	BEQ found_the_next_rightmost3
	SUB r2, r2, #1
	LDRB r0, [r1,r2] ; checking if the previous spot is empty
	ADD r2, r2, #1
	CMP r0, #0x20  ; if its empty, that means enemy has been destroyed, loop back
	BNE found_the_next_rightmost3
	SUB r2, r2 , #1
	B didnt_find_next_rightmost3
found_the_next_rightmost3	
	STRB r2, [r4]
	B done_reducing_enemy_right_counts
;=====================================

not_3th_right_enemy	
		
	LDR r0, =enemy2offset
	LDR r1, [r0]
	LDR r3, =right_enemy2counts
	LDR r2, [r3]
	SUB r2, r2, #1
	ADD r3, r1, r2
	ADD r2, r2, #1
	CMP r3, r5
	BNE not_2th_right_enemy
	LDR r3, =right_enemy2counts
;===============================
	SUB r2 , r2 , #1
didnt_find_next_rightmost2	
	LDR r4, =right_enemy2counts	
	CMP r2,#0
	BEQ found_the_next_rightmost2
	SUB r2, r2, #1
	LDRB r0, [r1,r2] ; checking if the previous spot is empty
	ADD r2, r2, #1
	CMP r0, #0x20  ; if its empty, that means enemy has been destroyed, loop back
	BNE found_the_next_rightmost2
	SUB r2, r2 , #1
	B didnt_find_next_rightmost2
found_the_next_rightmost2	
	STRB r2, [r4]
	B done_reducing_enemy_right_counts
;=====================================
not_2th_right_enemy	
	LDR r0, =enemyoffset
	LDR r1, [r0]
	LDR r3, =right_enemycounts
	LDR r2, [r3]
	SUB r2, r2, #1
	ADD r3, r1, r2
	ADD r2, r2, #1
	CMP r3, r5
	BNE not_1th_right_enemy
	LDR r3, =right_enemycounts
;================================	
	SUB r2 , r2 , #1
didnt_find_next_rightmost	
	LDR r4, =right_enemycounts	
	CMP r2,#0
	BEQ found_the_next_rightmost
	SUB r2, r2, #1
	LDRB r0, [r1,r2] ; checking if the previous spot is empty
	ADD r2, r2, #1
	CMP r0, #0x20  ; if its empty, that means enemy has been destroyed, loop back
	BNE found_the_next_rightmost
	SUB r2, r2 , #1
	B didnt_find_next_rightmost
found_the_next_rightmost
	STRB r2, [r4]
	B done_reducing_enemy_right_counts
;====================================

not_1th_right_enemy	
		
done_reducing_enemy_right_counts	
	LDMFD sp!, {lr}
	BX lr
	
reducing_enemy_counts
	;r5 has the hit locaiton
	STMFD sp!, {lr}
	LDR r0, =enemy5offset
	LDR r1, [r0]
	CMP r1, r5
	BGT not_5th_formation_next
	
	LDR r0, =enemy5counts
	LDR r1, [r0]
	SUB r1, r1, #1
	STR r1, [r0]
	B done_subtracting
not_5th_formation_next	
	
	LDR r0, =enemy4offset
	LDR r1, [r0]
	CMP r1, r5
	BGT not_4th_formation_next
	
	LDR r0, =enemy4counts
	LDR r1, [r0]
	SUB r1, r1 ,#1
	STR r1, [r0]
	B done_subtracting
not_4th_formation_next

	LDR r0, =enemy3offset
	LDR r1, [r0]
	CMP r1, r5
	BGT not_3th_formation_next
	
	LDR r0, =enemy3counts
	LDR r1, [r0]
	SUB r1 ,r1 , #1
	STR r1, [r0]
	B done_subtracting
not_3th_formation_next

	LDR r0, =enemy2offset
	LDR r1,[r0]
	CMP r1, r5
	BGT not_2th_formation_next
	
	LDR r0, =enemy2counts
	LDR r1, [r0]
	SUB r1, r1, #1
	STR r1, [r0]
	B done_subtracting
not_2th_formation_next

	LDR r0, =enemycounts
	LDR r1, [r0]
	SUB r1, r1, #1
	STR r1, [r0]
	
done_subtracting
	LDMFD sp!, {lr}
	BX lr

	
enemyoffset_hitted
	STMFD sp!, {lr}
		; if collision happens on enemy's offset, search next character
	LDR r0, =enemyoffset
	LDR r1, [r0]
	CMP r5, r1 
	BNE collision_no_on_1st_line
	;##############
	LDR r3, =offset_hit_counts
	LDR r4, [r3]
search_1_nextone
	ADD r4, r4, #1
	LDRB r2, [r1, #1]!
	CMP r2, #0x7C
	BNE not_all_died

not_all_died	
	CMP r2, #0x4F
	BNE search_1_nextone
	STR r1, [r0]
	STR r4, [r3]
	;##############
	B none_of_them_colliated
collision_no_on_1st_line
	
	LDR r0, =enemy2offset
	LDR r1, [r0]
	CMP r5, r1
	BNE collision_no_on_2nd_line
	LDR r3, =offset2_hit_counts
	LDR r4, [r3]

search_2_nextone	
	ADD r4, r4, #1
	LDRB r2, [r1, #1]!
	CMP r2, #0x7C
	BNE not_all_died_2
not_all_died_2	
	CMP r2, #0x4D
	BNE search_2_nextone
	STR r1, [r0]
	STR r4, [r3]
	;##############
	B none_of_them_colliated		
collision_no_on_2nd_line

	LDR r0, =enemy3offset
	LDR r1, [r0]
	CMP r5, r1
	BNE collision_no_on_3rd_line
	LDR r3, =offset3_hit_counts
	LDR r4, [r3]
	
search_3_nextone	
	ADD r4, r4, #1
	LDRB r2, [r1, #1]!
	CMP r2, #0x7C
	BNE not_all_died_3
	;??????????????????
not_all_died_3	
	CMP r2, #0x4D
	BNE search_3_nextone
	STR r1, [r0]
	STR r4, [r3]
	;##############
	B none_of_them_colliated	
collision_no_on_3rd_line
	
	LDR r0, =enemy4offset
	LDR r1, [r0]
	CMP r5, r1
	BNE collision_no_on_4th_line
	LDR r3, =offset4_hit_counts
	LDR r4, [r3]

search_4_nextone	
	ADD r4, r4, #1
	LDRB r2, [r1, #1]!
	CMP r2, #0x7C
	BNE not_all_died_4
	;??????????????????
not_all_died_4	
	CMP r2, #0x57
	BNE search_4_nextone
	STR r1, [r0]
	STR r4, [r3]	
	;##############
	B none_of_them_colliated	
collision_no_on_4th_line
	
	LDR r0, =enemy5offset
	LDR r1, [r0]
	CMP r5, r1
	BNE none_of_them_colliated
	LDR r3, =offset5_hit_counts
	LDR r4, [r3]

search_5_nextone	
	ADD r4, r4, #1
	LDRB r2, [r1, #1]!
	CMP r2, #0x7C
	BNE not_all_died_5
	;??????????????????
not_all_died_5	
	CMP r2, #0x57
	BNE search_5_nextone
	STR r1, [r0]
	STR r4, [r3]	
	;#############
	
none_of_them_colliated	
	LDMFD sp!, {lr}
	BX lr

	END