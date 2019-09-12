	AREA	GPIO, CODE, READWRITE	

	EXPORT ship_setups
	EXPORT ship_shift_left
	EXPORT ship_shift_right

	EXTERN FIQ_Handler
	EXTERN end_of_code
	EXTERN endgame
current_score_1 EQU 0x40006900
current_score_10 EQU 0x40006904
current_score_100 EQU 0x40006908
current_score_1000 EQU 0x4000690C
	
promptoffset  EQU 0x40007100
ship_location EQU 0x40006000
lives EQU 0x40005000	
IO1SET EQU 0xE0028014	
enemy_proj_offset EQU 0x400074A0
enemy_proj_on_board EQU 0x400074B0 ; 0 means no proj on board, 1 means proj on board

ship_setups
	STMFD SP!, {r1-r3,lr}
	LDR r0, =ship_location
	LDR r1, =promptoffset ;SHIPS Location, Row: 14, Collum : 11
	LDR r2, [r1]
	LDR r3, =0x183 
	ADD r2, r2, r3
	STR r2 , [r0]

	LDMFD SP!, {r1-r3,lr}
	BX lr

ship_shift_left
	;Load current address
	;Swap current content with address thats Incremented by ? 
	LDR r0, =ship_location
	LDR r1, [r0]
	SUB r2, r1, #1 ;r2 stores address that will be swap with current address
	LDRB r5, [r1]
	; r1 stores Original Address
	LDRB r3, [r2]
	
	CMP r3, #0x76
	BNE its_not_v
	
	LDR r0, =current_score_100
	MOV r1, #1
	LDR r2, [r0]
	SUB r2, r2 , r1
	
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
	B done_with_subtracting_all
	
its_more_than_9000
	MOV r2, #9
	LDR r0, =current_score_1000
	LDR r1, [r0]
	SUB r1, r1, #1
	STR r1, [r0]
	
is_not_negative	
	LDR r0, =current_score_100
	STR r2, [r0]
	
done_with_subtracting_all	
	
	
	STR r2, [r0]
	LDR r0, =enemy_proj_offset
	LDR r2, [r0]
	MOV r3, #0x20
	STRB r3, [r2]
	LDR r0, =enemy_proj_on_board
	MOV r3, #0
	STRB r3, [r0]
	
three_life_left 
	LDR r0, =lives
	LDR r1, [r0]
	CMP r1, #4
	BNE two_life_left
	SUB r1, r1, #1
	STR r1, [r0]
	LDR r0, =IO1SET
	LDR r1, =0x00080000
	STR r1, [r0]
	B exit_this
two_life_left
	CMP r1, #3
	BNE one_life_left
	SUB r1, r1, #1
	STR r1, [r0]
	LDR r0, =IO1SET
	LDR r1, =0x000C0000
	STR r1, [r0]
	B exit_this
one_life_left
	CMP r1, #2
	BNE game_over
	SUB r1, r1, #1
	STR r1, [r0]
	LDR r0, =IO1SET
	LDR r1, =0x000E0000
	STR r1, [r0]
	B exit_this
game_over 
	B endgame
	
	
exit_this
	B enddddd
its_not_v
	; r2 stores address left to the original address
	; r5 stores 41, 
	; r3 stores 20, which is 0
	STRB r3, [r1]
	STRB r5, [r2]
	STR r2, [r0]
	
enddddd	
	;im need to update ship address
	BX lr

ship_shift_right
	
		;Load current address
	;Swap current content with address thats Incremented by ? 
	LDR r0, =ship_location
	LDR r1, [r0]
	ADD r2, r1, #1 ;r2 stores address that will be swap with current address
	LDRB r5, [r1]
	; r1 stores Original Address
	LDRB r3, [r2]
	CMP r3, #0x76
	BNE its_not_vv

	LDR r0, =current_score_100
	MOV r1, #1
	LDR r2, [r0]
	SUB r2, r2 , r1
	
	CMP r2, #-1
	BGE is_not_negative2
	
	LDR r0, =current_score_1000
	LDR r1, [r0]
	CMP r1, #0
	BNE its_more_than_90002
	
	MOV r1, #0
	STR r1, [r0]
	LDR r0, =current_score_100
	STR r1, [r0]
	LDR r0, =current_score_10
	STR r1, [r0]
	LDR r0, =current_score_1
	STR r1, [r0]
	B done_with_subtracting_all2
	
its_more_than_90002
	MOV r2, #9
	LDR r0, =current_score_1000
	LDR r1, [r0]
	SUB r1, r1, #1
	STR r1, [r0]
	
is_not_negative2
	LDR r0, =current_score_100
	STR r2, [r0]
	
done_with_subtracting_all2	
		
	
	
	
	
	
	
	
	
	
	
	STR r2, [r0]
	LDR r0, =enemy_proj_offset
	LDR r2, [r0]
	MOV r3, #0x20
	STRB r3, [r2]
	LDR r0, =enemy_proj_on_board
	MOV r3, #0
	STRB r3, [r0]
	
three_life_left2
	LDR r0, =lives
	LDR r1, [r0]
	CMP r1, #4
	BNE two_life_left2
	SUB r1, r1, #1
	STR r1, [r0]
	LDR r0, =IO1SET
	LDR r1, =0x00080000
	STR r1, [r0]
	B exit_this2
two_life_left2
	CMP r1, #3
	BNE one_life_left2
	SUB r1, r1, #1
	STR r1, [r0]
	LDR r0, =IO1SET
	LDR r1, =0x000C0000
	STR r1, [r0]
	B exit_this2
one_life_left2
	CMP r1, #2
	BNE game_over2
	SUB r1, r1, #1
	STR r1, [r0]
	LDR r0, =IO1SET
	LDR r1, =0x000E0000
	STR r1, [r0]
	B exit_this2
game_over2 
	B endgame
	
	
exit_this2
	







	B enddddd2
its_not_vv
	; r3, stores address left to the original address
	; r5 stores 41, 
	; r3 stores 20, which is 0
	STRB r3, [r1]
	STRB r5, [r2]
	STR r2, [r0]
enddddd2	
	;im need to update ship address
	BX lr
	


	END