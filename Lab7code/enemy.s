	AREA	GPIO, CODE, READWRITE	
	
	EXPORT enemy_setups
	EXPORT enemy_motioning_right
	EXPORT enemy_motioning_left
	EXTERN FIQ_Handler
	EXTERN update_map
	EXPORT enemy_motion	
	EXTERN output_string
	EXTERN newline
		
	EXTERN div_and_mod

 
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
	
promptoffset   EQU 0x40007100
left_right_dir_flag EQU 0x400072F0
address_of_5counts EQU 0x400077F0
flagof_just_reached_left_wall EQU 0x4000700f
	
enemy_setups
	STMFD sp!, {lr}
	LDR r0, =address_of_5counts 
	MOV r1, #0
	STR r1, [r0]
	
	LDR r0, =flagof_just_reached_left_wall
	MOV r1, #0
	STR r1, [r0]
	
	LDR r0, =left_right_dir_flag 
	MOV r1, #0
	STR r1, [r0]  ; 0 means shifts right
	
	LDR r0, =promptoffset
	LDR r1, [r0]
	ADD r1, r1, #0x3B
	LDR r2, =enemyoffset ; location of the first enemy 
	STR r1, [r2]
	ADD r1, r1, #0x19
	LDR r2, =enemy2offset
	STR r1, [r2]
	ADD r1, r1, #0x19
	LDR r2, =enemy3offset
	STR r1, [r2]
	ADD r1, r1, #0x19
	LDR r2, =enemy4offset
	STR r1, [r2]
	ADD r1, r1, #0x19
	LDR r2, =enemy5offset
	STR r1, [r2]

	LDR r0, =enemycounts
	MOV r1, #7
	STR r1, [r0]
	LDR r0, =enemy2counts
	STR r1, [r0]
	LDR r0, =enemy3counts
	STR r1, [r0]
	LDR r0, =enemy4counts
	STR r1, [r0]
	LDR r0, =enemy5counts
	STR r1, [r0]
	
	LDR r0, =right_enemycounts
	MOV r1, #7
	STR r1, [r0]
	LDR r0, =right_enemy2counts
	STR r1, [r0]
	LDR r0, =right_enemy3counts
	STR r1, [r0]
	LDR r0, =right_enemy4counts
	STR r1, [r0]
	LDR r0, =right_enemy5counts
	STR r1, [r0]
	
	LDR r0, =offset_hit_counts
	MOV r1, #0
	STR r1, [r0]
	LDR r0, =offset2_hit_counts
	STR r1, [r0]
	LDR r0, =offset3_hit_counts
	STR r1, [r0]
	LDR r0, =offset4_hit_counts
	STR r1, [r0]
	LDR r0, =offset5_hit_counts
	STR r1, [r0]
	LDMFD sp!, {lr}
	BX lr
	
enemy_motion
	STMFD SP!, {lr}
keep_moving2


	LDR r0, =left_right_dir_flag
	LDR r1, [r0]
	
	CMP r1, #0
	BNE shifts_left
	;the code below is shifting right
	BL enemy_motioning_right
	
	LDR r1 , =promptoffset
	LDR r0, [r1]
	BL output_string
	
	;B keep_moving2
	B idc
shifts_left	
	; the code below is shifting left
	BL enemy_motioning_left
	
	
	LDR r1 , =promptoffset
	LDR r0, [r1]
	BL output_string

	;B keep_movin

idc	
	;CMP AND (enemyformation, =0x100000 ) , 0
	; This mean the formation of enemy has reach the left most  wall and ready to bounce back 

	LDMFD SP!, {lr}
	BX lr
	
enemy_motioning_right
	STMFD SP!, {r0-r12,lr}

    ;CMP  AND (enemyformation, #1) , 0
	;This means the formation of enemy has reach the right most wall and ready to bounce back
		
	BL checking_if_next_step_is_right_wall
	
	CMP r12, #0 
	BNE reached_right_wall
	 ;right most bit on enemyformation is 0
	;Here is my new idea, stores 7 in a r3 
	;start with offset + r3 enemy location, store that into offset + r3 + 1 location
	;Decrement r3 
	;exit when r3 is 0 or less than depends on if the left most is moving
	LDR r4, =enemyoffset
	LDR r9, =enemycounts
	LDR r8, =right_enemycounts
	LDR r0, =offset_hit_counts
	
repeating	
	LDR r2, [r8]
	
	CMP r2, #0
	BNE next_row
	ADD r9, r9, #0x10
	ADD r4, r4, #0x10
	ADD r8, r8, #0x10
	B repeating
next_row

	LDR r3, =0x40007170
	CMP r4, r3 
	BEQ done_with_all_row_movement_once
	;SUB r2, r2, #1
	MOV r3, r2;
	LDRB r7, [r0]
	LDR r5, [r4]
	
	;CMP r6, flagof just reached left wall
	LDR r6, =flagof_just_reached_left_wall
	LDR r1, [r6]
	CMP r1, #0
	BEQ didnt_just_reached_left_wall
	
;	SUB r1, r1 , #1
;	STR r1, [r6]
	B keep_moving
;	LDRB r6, [r5,-r7]
didnt_just_reached_left_wall
	LDRB r6, [r0]
	SUB r5, r5, r6
	
keep_moving

	CMP r3, #-2
	BEQ every_enemy_has_shifted_one_position
	CMP r3, #-1
	BEQ speical_case_store_space_into_enemyoffset

	
	LDRB r6, [r5, r3]
no_exception_okay	
	
	
	CMP r6, #0x5E
	BNE its_okay
	;if r6 is 0x5e, i shouldnt skip, i should store 0x20 to
	MOV r6, #0x20
	;SUB r3, r3 , #1
;	B keep_moving
	B its_okay22
its_okay

	CMP r6, #0x76
	BNE its_okay22
	;if r6 is 0x5e, i shouldnt skip, i should store 0x20 to
	MOV r6, #0x20
	;SUB r3, r3 , #1
;	B keep_moving
its_okay22


	ADD r3, r3 , #1
	LDRB r7, [r5,r3]
	SUB r3, r3 , #1
	CMP r7, #0x7C
	BNE its_fine
	SUB r3, r3, #1
	B keep_moving
its_fine	
	
	
	ADD r3, r3 , #1
	STRB r6, [r5,r3]
	SUB r3, r3 , #2
	
	B keep_moving
	
speical_case_store_space_into_enemyoffset
	LDR r10, [r4]
	LDR r11, =0x20
	STRB r11, [r10]
	SUB r3, r3, #1
	B keep_moving
	
every_enemy_has_shifted_one_position	
	LDR r5, [r4]
	ADD r5, r5, #1 
	STR r5,[r4] ;update offset address by 1
	
row_has_0_enemy	
	ADD r4, r4 , #0x10
	LDR r3, =0x40007170
	CMP r4, r3
	BEQ next_row
	ADD r8, r8, #0x10
	ADD r0, r0, #0x10 ;?
	ADD r9, r9, #0x10
	LDR r10, [r9]
	CMP r10, #0
	BEQ row_has_0_enemy
	LDR r2, [r8]
	B next_row
	
done_with_all_row_movement_once

	;LDR r7, =0x40007120
	;STR r7, [r4]	
	;LDR r4, =enemy2offset
	LDR r6, =flagof_just_reached_left_wall
	LDR r1, [r6]
	CMP r1, #0
	BLE stop_it
	SUB r1, r1, #1
	STRB r1, [r6]
	B stop_it

reached_right_wall	
	;BL update_map
	;right most bit on enemyformation is 1
	;that means enemy can no longer move right
	
	LDR r5, =0x40007110
	;MOV r6, #6 ; 5 rows of enemy
	;ADD functionality that shifts everyrow down 
	MOV r2, #6 ;
	;;;;;;; MAKE r6 varibable,, compare statement, if enemy5counts is 0
	; check decreasing order, and set to lowest non 0 enemyoffset
	LDR r11, =enemy5offset
	MOV r6, #6 
	LDR r8, =offset5_hit_counts
	LDR r0, =enemy5counts              ; usable regi,  r0, r3, r11
	LDRB r3, [r0]
	CMP r3, #0
	BNE done_with_filtering ;if 5th line enemy isnt all die, we dont do anything
	
	;following code is what happen when 5th line enemy died
	
	LDR r11, =enemy4offset ;1.first, re-set the enemy5offset to corresponding enemy?offset
	SUB r6, r6, #1         ;2.subtract r6, by 1
	LDR r8, =offset4_hit_counts
	LDR r0, =enemy4counts 
	LDRB r3, [r0]		   ;3.Check if 4th enemycount is 0
	CMP r3, #0
	BNE done_with_filtering;4. if its greater than 0, break out loops and everything should remain fine
	
	                       ;5. if its 0, loop again with decending order
	LDR r11,=enemy3offset
	SUB r6, r6, #1
	LDR r8, =offset3_hit_counts
	LDR r0, =enemy3counts
	LDRB r3, [r0]
	CMP r3, #0
	BNE done_with_filtering
	
	LDR r11,=enemy2offset
	SUB r6, r6, #1
	LDR r8, =offset2_hit_counts
	LDR r0, =enemy2counts
	LDRB r3, [r0]
	CMP r3, #0
	BNE done_with_filtering
	
	LDR r11,=enemyoffset
	SUB r6, r6, #1
	LDR r8, =offset_hit_counts
	LDR r0, =enemycounts
	LDRB r3, [r0]
	CMP r3, #0
	BNE done_with_filtering
	
	
	
	
done_with_filtering	
	MOV r12, r6
	LDR r1, [r11] ; r1 has the address
	LDR r9, [r8]
	SUB r1, r1, r9
	
	
continue_on_same_col	

	CMP r6, #0
	BEQ one_col_is_done_next_col_ready
	LDRB r3, [r1, r2] ; r3 has the value
	CMP r3, #0x58
	BNE jump_this
	MOV r3, #0x20
jump_this	
	ADD r2, r2, #0x19
	STRB r3, [r1, r2]
	SUB r2, r2, #0x19 	
	SUB r1, r1 , #0x19 ;decrement r1
	SUB r6, r6 , #1
	B continue_on_same_col

one_col_is_done_next_col_ready

	LDR r1, [r11] ; r1 has the address
	;LDR r8, =offset5_hit_counts
	LDR r9, [r8]
	SUB r1, r1, r9
	SUB r2, r2, #1 
	


	MOV r6, r12  ;
	CMP r2, #-1
	BNE continue_on_same_col
	
all_col_done

	LDR r0, =enemy5offset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	
	LDR r0, =enemy4offset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	LDR r0, =enemy3offset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	LDR r0, =enemy2offset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	LDR r0, =enemyoffset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	;Set flag so the system will know its time to rutn left 
	LDR r0, =left_right_dir_flag 
	MOV r1, #1
	STR r1, [r0]  ; 0 means shifts right
				  ; 1 means shifts left
	;B enemy_motioning_left
 ;line  and  should be remove and replace inside FIQ so every 1 sec it shifts left

stop_it
	LDMFD SP!, {r0-r12,lr}
	BX lr
	
	
	
	
	
	
	
enemy_motioning_left
	STMFD SP!, {r0-r12,lr}

    ;CMP  AND (enemyformation, #1) , 0
	;This means the formation of enemy has reach the right most wall and ready to bounce back
	LDR r0, =enemyoffset
	LDR r1, [r0]
	LDRB r2, [r1, #-1]	
	CMP r2, #0x7C
	BEQ Reached_left_wall
	
	LDR r0, =enemy2offset
	LDR r1, [r0]
	LDRB r2, [r1, #-1]	
	CMP r2, #0x7C
	BEQ Reached_left_wall
	
	LDR r0, =enemy3offset
	LDR r1, [r0]
	LDRB r2, [r1, #-1]	
	CMP r2, #0x7C
	BEQ Reached_left_wall
	
	LDR r0, =enemy4offset
	LDR r1, [r0]
	LDRB r2, [r1, #-1]	
	CMP r2, #0x7C
	BEQ Reached_left_wall
	
	LDR r0, =enemy5offset
	LDR r1, [r0]
	LDRB r2, [r1, #-1]	
	CMP r2, #0x7C
	BEQ Reached_left_wall
	
		
	;Here is my new idea, stores 7 in a r3 
	;start with offset + r3 enemy location, store that into offset + r3 + 1 location
	;Decrement r3 
	;exit when r3 is 0 or less than depends on if the left most is moving
	LDR r4, =enemyoffset
	LDR r9, =enemycounts
	LDR r5, [r4]
	SUB r5, r5, #1
	STR r5, [r4]
	MOV r3, #0
	B left_keep_moving
left_next_row
	LDR r3, =0x40007170
	CMP r4, r3 
	BEQ left_done_with_all_row_movement_once
	MOV r3, #0
	LDR r5, [r4]
	SUB r5, r5, #1
	STR r5, [r4]

left_keep_moving
	;1. set enemyoffset -= 1,
	;2. Store EO+1 into EO
	;         E0+2 into E0+1
    ;         E0+4 into E0+3
	
	CMP r3, #8
	BEQ left_every_enemy_has_shifted_one_position
	CMP r3, #7
	BEQ left_speical_case_store_space_into_enemyoffset	
	
	ADD r3, r3, #1
	
	LDRB r6, [r5, r3]
	CMP r6, #0x7C
	BNE didnt_hit_wall
	MOV r6, #0x20
	SUB r3, r3 , #1
	STRB r6, [r5,r3]
	ADD r3, r3, #1 
	B left_every_enemy_has_shifted_one_position
didnt_hit_wall	
	CMP r6, #0x5E
	BNE left_its_okay
	MOV r6, #0x20
	B left_its_okay222

left_its_okay

	CMP r6, #0x76
	BNE left_its_okay22
	MOV r6, #0x20
	B left_its_okay222
left_its_okay22

	CMP r6, #0x7E
	BNE left_its_okay222
	MOV r6, #0x20

left_its_okay222





	SUB r3, r3 , #1
	STRB r6, [r5,r3]
	ADD r3, r3 , #1
	B left_keep_moving
	
left_speical_case_store_space_into_enemyoffset
	ADD r10, r5, r3
	LDR r11, =0x20
	STRB r11, [r10]; eror
	ADD r3, r3, #1
	B left_keep_moving
	
left_every_enemy_has_shifted_one_position	
;Add compare statement, to see if corresponding enemy(1,2,3,4,5)_left is 0 or not
; it its 0, then add another 0x10 to skip
row_empty_next
	ADD r4, r4 , #0x10
	LDRB r5, [r9,#0x10]!
	CMP r5, #0
	BEQ row_empty_next
	B left_next_row
	
left_done_with_all_row_movement_once

	;LDR r7, =0x40007120
	;STR r7, [r4]	
	;LDR r4, =enemy2offset
	
	B done_move_right_once


	
Reached_left_wall

	;Code below is what happen when the enemy reaches the left most wall	
	; I need to relocate leftmost_available space to default state, ; i dont know why exactly but i feel like its necessary
    ;Prompt 0x40000CDC
	;enemy5offset 0x40000D74
		LDR r0, =flagof_just_reached_left_wall
		MOV r1, #7
		STRB r1, [r0]
		;This is where i insert how to indentify that one line is empty, the structure should be same as moving down on 
		; right wall
		
		
		
	LDR r0, =enemy5offset
	LDR r2,=enemy5counts
	LDRB r4, [r2]
	CMP r4, #0
	BNE done_left_filter_setup
	
	LDR r0, =enemy4offset
	LDR r2,=enemy4counts
	LDRB r4, [r2]
	CMP r4, #0
	BNE done_left_filter_setup
	
	LDR r0, =enemy3offset
	LDR r2,=enemy3counts
	LDRB r4, [r2]
	CMP r4, #0
	BNE done_left_filter_setup
	
	LDR r0, =enemy2offset
	LDR r2,=enemy2counts
	LDRB r4, [r2]
	CMP r4, #0
	BNE done_left_filter_setup
	
	LDR r0, =enemyoffset
	LDR r2,=enemycounts
	LDRB r4, [r2]
	CMP r4, #0
	BNE done_left_filter_setup
	
	
	
	
	
done_left_filter_setup

	LDR r1, [r0] ; r1 stores address of enenmy5offset
	MOV r12, r1
	
	LDR r0, =promptoffset
	LDR r2, [r0]
	SUB r1 ,r1 ,r2
	SUB r1, r1, #2
	MOV r7, r1
	MOV r8, #0x19
	BL div_and_mod
	
	MOV r2, r12 ; r1 stores address of enenmy5offset
	
	SUB r1, r2 , r1
	
	MOV r2, r1 ; I plan to use r2 for veritcal operation
	MOV r3, r1 ; I plan using r3 for horizontal operation 
	MOV r5, #0 ; this represent 5 rows of enemy
	MOV r6, #0 ; this represents 7 cols of enemy
continue_on_same_coll	
	CMP r5, #6
	BEQ one_row_done_next_row_ready
	LDRB r4, [r2]
	CMP r4, #0x58
	BNE not_x_copy
	MOV r4, #0x20
not_x_copy	
	CMP r4, #0x2D
	BNE not_wall_copy
	MOV r4, #0x20
not_wall_copy	
	STRB r4, [r2, #0x19]
	SUB r2, r2, #0x19
	ADD r5, r5, #1
	B continue_on_same_coll
	;create copy of enemy5offset
	;and manuiplate it 
	;MOV D74 to D8D differnce 0x19
	;MOV D58 to D74
	;..............
	;MOV CF7 to D10
	
one_row_done_next_row_ready
	
	CMP r6, #6
	BEQ ready_tocall_enemy_motioning_right
	ADD r3, r3 , #1
	MOV r2, r3 
	MOV r5, #0
	ADD r6, r6, #1
	B continue_on_same_coll
	;After one col is done shifting down
	;create a new copy of enemy5offset, increment by 1 
	;and start looping again
	;
done_shifting_once

	B done_move_right_once

ready_tocall_enemy_motioning_right

	LDR r0, =enemy5offset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	
	LDR r0, =enemy4offset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	
	LDR r0, =enemy3offset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	
	LDR r0, =enemy2offset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	
	LDR r0, =enemyoffset
	LDR r1, [r0]
	ADD r1, r1, #0x19
	STR r1, [r0]
	
	LDR r0, =left_right_dir_flag 
	MOV r1, #0
	STR r1, [r0]  ; 0 means shifts right
	

	
	

done_move_right_once
	
	LDMFD SP!, {r0-r12,lr}
	BX lr 
	
	

		
checking_if_next_step_is_right_wall
	STMFD SP!, {r0-r2,lr}
	MOV r12, #0
	LDR r0, =promptoffset
	LDR r1, [r0]
	
	LDRB r2, [r1, #0x48]!
	BIC r2, #0xFE
	CMP r2, #1
	BNE line_1_movable
	MOV r12, #1
	B done_sensing
line_1_movable
	
	LDRB r2, [r1, #0x19]!
	BIC r2, #0xFE
	CMP r2, #1
	BNE line_2_movable
	MOV r12, #1
	B done_sensing

line_2_movable

	LDRB r2, [r1, #0x19]!
	BIC r2, #0xFE
	CMP r2, #1
	BNE line_3_movable
	MOV r12, #1
	B done_sensing
	
line_3_movable

	LDRB r2, [r1, #0x19]!
	BIC r2, #0xFE 
	CMP r2, #1 
	BNE line_4_movable
	MOV r12, #1
	B done_sensing
	
line_4_movable
	
	LDRB r2, [r1, #0x19]!
	BIC r2, #0xFE
	CMP r2, #1
	BNE line_5_movable
	MOV r12, #1
	B done_sensing

line_5_movable
	
	LDRB r2, [r1, #0x19]!
	BIC r2, #0xFE
	CMP r2, #1
	BNE line_6_movable
	MOV r12, #1
	B done_sensing

line_6_movable
	
	LDRB r2, [r1, #0x19]!
	BIC r2, #0xFE
	CMP r2, #1
	BNE line_7_movable
	MOV r12, #1
	B done_sensing

line_7_movable
	
	LDRB r2, [r1, #0x19]!
	BIC r2, #0xFE
	CMP r2, #1
	BNE line_8_movable
	MOV r12, #1
	B done_sensing

line_8_movable
	
	LDRB r2, [r1, #0x19]!
	BIC r2, #0xFE
	CMP r2, #1
	BNE done_sensing
	MOV r12, #1


done_sensing
	LDMFD SP!, {r0-r2,lr}
	BX lr
	
	
	
check_less_of_offset_hit_counts
	STMFD SP!, {lr}
	
	LDR r0, =offset_hit_counts
	LDR r1, [r0]
	
	LDR r0, =offset2_hit_counts
	LDR r2, [r0]; r1 should store the lowest count
	CMP r2, r1
	BGT comparing_3
	MOV r1, r2
	
comparing_3	

	LDR r0, =offset3_hit_counts
	LDR r2, [r0]
	CMP r2, r1
	BGT comparing_4
	MOV r1, r2
	
comparing_4
	
	LDR r0, =offset4_hit_counts
	LDR r2, [r0]
	CMP r2, r1
	BGT comparing_5
	MOV r1, r2

comparing_5

	LDR r0, =offset5_hit_counts
	LDR r2, [r0]
	CMP r2, r1
	BGT done_comparing
	MOV r1, r2
	
done_comparing

	LDR r0, =flagof_just_reached_left_wall
	STR r1 , [r0]
	
	LDMFD SP!, {lr}
	BX lr
	END
