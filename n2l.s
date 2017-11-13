/*
n2l takes a number input in R0
Outputs a string with the letter equivalent
returns the ascii value of its corresponding letter

*/

			.global n2l
			.func n2l
n2l:
		@ Save registers 
			STMFD SP!, {R4-R12, R14}

			LDR R1, =output

			ADD R0, R0, #64

			STR R0, [R1]

			LDR R0, =output
			BL stro


		@ Restore registers and return 
			LDMFD SP!, {R4-R12, R14}
			MOV PC, LR


			.data

output: 	.asciz "  "



