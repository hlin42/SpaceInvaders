	AREA	GPIO, CODE, READWRITE
	EXTERN output_string
	EXTERN FIQ_Handler
	EXTERN end_of_code
	EXTERN rng	
	EXTERN update_map
	EXTERN newline
	EXTERN endgame
	EXPORT eject_enemy_proj
	EXPORT enemy_proj_setups	
	EXPORT enemy_proj_motion
	EXPORT enemy_proj_hits_myship
promptoffset                   EQU 0x40007100
proj_offset                    EQU 0x40007400
ship_location                  EQU 0x40006000
proj_exist_on_board_flag       EQU 0x40007410
Ss_storing_address             EQU 0x40007420	
Ss2_storing_address            EQU 0x40007430
selected_enemy_that_shoot_proj EQU 0x40007440	
lives EQU 0x40005000	
IO0SET EQU 0xE0028004
IO0CLR EQU 0xE002800C
IO1SET EQU 0xE0028014	
IO1CLR EQU 0xE002801C
	
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
number_of_loops EQU 0x40007544	

enemy_proj_offset EQU 0x400074A0
enemy_proj_on_board EQU 0x400074B0 ; 0 means no proj on board, 1 means proj on board

current_score_1 EQU 0x40006900
current_score_10 EQU 0x40006904
current_score_100 EQU 0x40006908
current_score_1000 EQU 0x4000690C
	
total_score EQU   0x40006920
	
keystork_rng_counter EQU 0x40007990
current_keyboard_rng_input EQU 0x40007994	
T0TC  EQU 0xE0004008	
mothership_location EQU 0x40007A20
timeused_location EQU 0x40007A30
currentscore_location EQU 0x40007A40

		
enemy_proj_setups
	STMFD SP!, {r0-r1,lr}

	LDR r0, =enemy_proj_offset 
	MOV r1, #0
	STR r1, [r0]
	
	LDR r0, =number_of_loops 
	MOV r1, #0
	STR r1, [r0]
	
	
	
	LDR r0, =enemy_proj_on_board 
	MOV r1, #0
	STR r1, [r0]
	
	LDMFD SP!, {r0-r1,lr}
	BX lr
	
eject_enemy_proj
	STMFD SP!, { r0-r12 ,lr}

;########################################################################
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
continue_subb2
	CMP r1, r8 
	BLT done_diving2
	SUB r1, r1, r8
	B continue_subb2
done_diving2
	CMP r1, #1
	BNE eject_permission_rng_denied

;########################################################################	
dead_enemy_start_over	



;########################################################################
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
		
	MOV r8, #4  ; immediates enters here shows the range of random numbers
continue_subb3
	CMP r1, r8 
	BLT done_diving3
	SUB r1, r1, r8
	B continue_subb3
done_diving3

;########################################################################	
	
	; r12 has the reminder from 0 to 4, 0 1 2 3 4 
	; enemy[x+1]offset = enemyoffset + 0x10 * x
	MOV r10, #0x10
	MUL r9, r1, r10 ; r9 = 0x19 * x
	LDR r0, =enemyoffset
	ADD r8, r9, r0
	LDR r7, [r8]   ;r7 stores the starting point of differents rows according to rng
	LDR r0, =right_enemycounts
	ADD r6, r9, r0
	LDRB r5, [r6] ; r5 has the range conut for the next rng
	;use right_offset_enemy_counts to set the range of which enemys hits in row 
	CMP r5, #0
	BEQ dead_enemy_start_over
;########################################################################	
	MOV r11, r5
	
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
	BIC r6, r6, r2
	ADD r1, r1 ,r6 
		
	
	
	MOV r8, r5  ; immediates enters here shows the range of random numbers
continue_subb4
	CMP r1, r8 
	BLT done_diving4
	SUB r1, r1, r8
	B continue_subb4
done_diving4
	MOV r4, r1

;########################################################################	
	; r12 stores number range from 0 to right[0,1,2,3,4]_enemycounts
	LDRB r1, [r7, r4]! ; r1 has the content of randomly selected enemy
	
	LDR r5, =number_of_loops 
	LDRB r6, [r5]
	ADD r6, r6 ,#1 
	STRB r6, [r5]	
	
	
	CMP r1, #0x20
	BEQ dead_enemy_start_over
	; CMP r1, #??
	; BEQ dead_enemy_start_0ver
	
	; at this point, we have successfully found the enemy that will be shooting projectile
	; now, we look for that offset address + 0x19,
next_row_for_placing_v	
	LDRB r1, [r7, #0x19]!
	CMP r1, #0x20
	BNE next_row_for_placing_v
	
	LDR r0, =enemy_proj_offset
	STR r7, [r0]
	MOV r0, #0x76
	STRB r0, [r7]
	
	LDR r0, =enemy_proj_on_board
	;LDR r2, [rr
	MOV r1, #1
	STRB r1, [r0]
	; if its 0x20, set that location to our enemy_proj_offset
	; write 'v' to that location, 
	; write '1' to enemy_proj_on_board flag
	

eject_permission_rng_denied	

	;BL eject_enemy_proj 
	LDMFD SP!, {r0-r12,lr}
	BX lr
	
	
enemy_proj_motion
	STMFD SP!, {r0-r12,lr}
	LDR r0, =enemy_proj_offset
	LDR r1, [r0]
	
	LDRB r2, [r1,#-0x19]
	CMP r2, #0x7E
	BNE its_norrrmal
	MOV r2, #0x20
	STRB r2, [r1,#-0x19]
its_norrrmal	


	LDRB r2, [r1, #0x19]!
	; 5 Collision cases
	; 1. 'Space' 0x20, Space 
	;			 keep motioning
	CMP r2, #0x20
	BNE didnt_hit_space
	BL enemy_proj_hits_space
	B done_moving_once
didnt_hit_space	
	; 2. 'S'     0x?   Strong shield
	;               	write 0x20 to proj location
	;					write 's' to 'S' location
	;					set enemy_proj_on_board to 0
	CMP r2, #0x53
	BNE didnt_hit_Shield
	BL enemy_proj_hits_S
	B done_moving_once
didnt_hit_Shield	
	; 3. 's'     0x?   Weak shield
	;				   write 0x20 to both proj_location and 's' location
	;				   set enemy_proj_on_board to 0
	CMP r2, #0x73
	BNE didnt_hit_shield
	BL enemy_proj_hits_s
	B done_moving_once
didnt_hit_shield	
	; 4. '^'     0x5E  Myship_projectile
	;				   write 0x20 to current proj_location
	;				   write '~' to collision spot
	;					and more???????????????????
	CMP r2, #0x5E
	BNE didnt_hit_ourproj
	BL enemy_proj_hits_proj
	B done_moving_once
didnt_hit_ourproj	
	; 5. 'A'     0x41  Call enemy_proj_hits_myship
	CMP r2, #0x41
	BNE didnt_hit_A
	BL enemy_proj_hits_myship
	B done_moving_once
didnt_hit_A	
	; 6. '-' 0x2D Write 0x20 to current proj_location
	;    set flag back to 0, 
	CMP r2, #0x2D
	BNE didnt_hit_wall
	BL enemy_proj_hits_wall
	B done_moving_once
didnt_hit_wall	
done_moving_once
	;BL update_map
	
	LDMFD SP!, {r0-r12,lr}
	BX lr

enemy_proj_hits_space
	STMFD SP!, {lr}
	; 1. 'Space' 0x20, Space 
	;			 keep motioning
	; r1 is the collision location

	
	LDR r0, =enemy_proj_offset
	LDR r2, [r0]
	LDRB r3, [r2]
	CMP r3, #0x76
	BNE idkkkkk 
	MOV r3, #0x20
	STRB r3, [r2]
		
idkkkkk	

	MOV r3, #0x76
	STRB r3, [r1]
	STR r1, [r0]
	LDMFD SP!, {lr}
	BX lr
	
enemy_proj_hits_wall
	STMFD SP!, {lr}
	; 6. '-' 0x2D Write 0x20 to current proj_location
	;    set flag back to 0, 
	LDR r0, =enemy_proj_offset
	LDR r2, [r0]
	MOV r3, #0x20
	STRB r3, [r2]
	

	
	LDR r0, =enemy_proj_on_board
	MOV r3, #0
	STRB r3, [r0]
	LDMFD SP!, {lr}
	BX lr
	
		
	
	
enemy_proj_hits_S
	STMFD SP!, {lr}
	; 2. 'S'     0x?   Strong shield
	;               	write 0x20 to proj location
	;					write 's' to 'S' location
	;					set enemy_proj_on_board to 0
	
	LDR r0, =enemy_proj_offset
	LDR r2, [r0]
	MOV r3, #0x20
	STRB r3, [r2]
	
	MOV r3, #0x73
	STRB r3, [r1]
	
	LDR r0, =enemy_proj_on_board
	MOV r3, #0
	STRB r3, [r0]
	LDMFD SP!, {lr}
	BX lr
	
	
enemy_proj_hits_s
	STMFD SP!, {lr}
	; 3. 's'     0x?   Weak shield
	;				   write 0x20 to both proj_location and 's' location
	;				   set enemy_proj_on_board to 0
	LDR r0, =enemy_proj_offset
	LDR r2, [r0]
	MOV r3, #0x20
	STRB r3, [r2]
	
	STRB r3, [r1]
	
	LDR r0, =enemy_proj_on_board
	MOV r3, #0
	STRB r3, [r0]
	LDMFD SP!, {lr}
	BX lr
	
	
enemy_proj_hits_proj
	STMFD SP!, {lr}
	LDR r0, =enemy_proj_offset
	LDR r2, [r0]
	MOV r3, #0x20
	STRB r3, [r2]
	
	MOV r3, #0x7E
	STRB r3, [r1]
	STR r1, [r0]
	
	LDR r0, =proj_offset
	LDR r1, [r0]
	SUB r1, r1, #0x19
	STR r1, [r0]
	
	
	LDMFD SP!, {lr}
	BX lr
	

enemy_proj_hits_myship
	STMFD SP!, {lr}
	;4-3-2-1
	LDR r0, =current_score_100
	LDR r2, [r0]
	SUB r2, r2 , #1
	
	CMP r2, #-1
	BGE is_not_negative
	
	LDR r0, =current_score_1000
	LDR r1, [r0]
	CMP r1, #0
	BNE its_more_than_9000
	
	MOV r1, #0
	STR r1, [r0]
	LDR r0, =current_score_100
	STR r1, [r0]
	LDR r0, =current_score_10
	STR r1, [r0]
	LDR r0, =current_score_1
	STR r1, [r0]
	B done_with_subtracting_all2
	
its_more_than_9000
	MOV r2, #9
	LDR r0, =current_score_1000
	LDR r1, [r0]
	SUB r1, r1, #1
	STR r1, [r0]
	
is_not_negative	
	LDR r0, =current_score_100
	STR r2, [r0]
	
done_with_subtracting_all2	
	
	LDR r0, =enemy_proj_offset
	LDR r2, [r0]
	MOV r3, #0x20
	STRB r3, [r2]
	
	LDR r0, =enemy_proj_on_board
	MOV r3, #0
	STRB r3, [r0]
	
three_life_left ;4 minus 1 life
	;check flag, too see how many life left
	;check if flag is 4, when shot; call 3 life left.
	;SUB 100 from points
	LDR r0, =lives
	LDR r1, [r0]
	CMP r1, #4
	BNE two_life_left
	SUB r1, r1, #1
	STR r1, [r0]
	
	;lights up p1. 16 17 18 led only
	LDR r0, =IO1SET
	LDR r1, =0x00080000
	STR r1, [r0]
	B exit_this
two_life_left	;3 minus 1 life
	;check flag too see how mnay life left
	;check for 3, when shot 
	;sub 100 from points
	CMP r1, #3
	BNE one_life_left
	SUB r1, r1, #1
	STR r1, [r0]
	
	;lights up p1.16 and 17 led only
	LDR r0, =IO1SET
	LDR r1, =0x000C0000
	STR r1, [r0]

	B exit_this
one_life_left	;2 minues one life
	;sub 100 from points
	CMP r1, #2
	BNE game_over
	SUB r1, r1, #1
	STR r1, [r0]
	
	;lights up p1.16 led only
	LDR r0, =IO1SET
	LDR r1, =0x000E0000
	STR r1, [r0]

	B exit_this
	
game_over ;1 minus 1, gg
	;sub100 from points then output score
	
	LDR r0, =lives
	LDR r1, [r0]
	SUB r1, r1, #1
	STR r1, [r0]
	
	B endgame
	
	
exit_this
	
	LDMFD SP!, {lr}
	BX lr	


	END