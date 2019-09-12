	AREA	GPIO, CODE, READWRITE	
	
	EXPORT mothership_setup
	EXPORT mothership_starting_showup_left
	EXPORT mothership_starting_showup_right
	EXPORT mothership_right_move
	EXPORT mothership_left_move
		
	EXTERN update_map	
;Jay version mothership

mothership_left_or_right_dir EQU 0x40007860 
	; 0 means from X-------------> from left
	; 1 means from <-------------X from right
mothership_offset EQU 0x40007880	
mothership_exist_on_board EQU 0x400078A0
promptoffset EQU 0x40007100
mothership_setup
	STMFD SP!, {lr}
	LDR r0, =mothership_exist_on_board
	MOV r1, #0
	STR r1, [r0]
	LDMFD SP!, {lr}
	BX lr


mothership_starting_showup_left
	STMFD SP!, {lr}
	
	LDR r0, =mothership_left_or_right_dir
	MOV r1, #0
	STR r1, [r0]
	
	
	
	LDR r0, =promptoffset
	LDR r1, [r0]
	MOV r2, #0x58
	LDR r0, =mothership_offset
	STRB r2, [r1, #0x1B]!
	STR r1, [r0]
	LDR r0, =mothership_exist_on_board
	MOV r1, #1
	STR r1, [r0]
	
	LDMFD SP!, {lr}
	BX lr
	
mothership_starting_showup_right
	STMFD SP!, {lr}
	
	LDR r0, =mothership_left_or_right_dir
	MOV r1, #1
	STR r1, [r0]
	
	LDR r0, =promptoffset
	LDR r1, [r0]
	MOV r2, #0x58
	LDR r0, =mothership_offset
	STRB r2, [r1, #0x2F]!
	STR r1, [r0]
	LDR r0, =mothership_exist_on_board
	MOV r1, #1
	STR r1, [r0]
	
	LDMFD SP!, {lr}
	BX lr
	
mothership_left_move
	STMFD SP! ,{lr}
	LDR r0, =mothership_offset
	LDR r1, [r0]
	LDRB r5, [r1,#-1]

	MOV r2, #0x20
	STRB r2, [r1]
	
	CMP r5, #0x7C
	BNE no_worries2
	
	LDR r0, =mothership_exist_on_board
	MOV r1, #0
	STR r1, [r0]
	
	B done_right_once2
no_worries2		
	MOV r2, #0x58
	STRB r2, [r1,#-1]!
	STR r1, [r0]
	
done_right_once2	
	;BL update_map
	LDMFD SP!, {lr}
	BX lr



mothership_right_move
	STMFD SP! ,{lr}
	LDR r0, =mothership_offset
	LDR r1, [r0]
	LDRB r5, [r1,#1]

	MOV r2, #0x20
	STRB r2, [r1]
	
	CMP r5, #0x7C
	BNE no_worries
	
	LDR r0, =mothership_exist_on_board
	MOV r1, #0
	STR r1, [r0]
	
	B done_right_once
no_worries		
	MOV r2, #0x58
	STRB r2, [r1,#1]!
	STR r1, [r0]
	
done_right_once	

	;BL update_map
	LDMFD SP!, {lr}
	BX lr


	END
	