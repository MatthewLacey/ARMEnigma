/*
Pass in SP to R0
Pass in Stack Base to R1
*/


			.global printStack
			.func printStack
printStack:

		@ Save registers 
			STMFD SP!, {R4-R12, R14}

		@ # Let R6 = SP
			MOV R6, R0

		@ # Let R5 = Stack Base
			MOV R5, R1

			LDR R0, =nl
			BL stro
	xwhile:	
			CMP R6, R5		@ Is the stack empty?
			BLE xdone
			LDR R0, [R6]		@ Get word from stack and display
			BL deco	
			LDR R0, =nl
			BL stro
			SUB R6, R6, #4		@ Point to next entry in stack
			BAL xwhile
	xdone:
			LDR R0, =nl
			BL stro

		@ Restore registers and return 
			LDMFD SP!, {R4-R12, R14}
			MOV PC, LR

			.data
nl:			.asciz "\n"