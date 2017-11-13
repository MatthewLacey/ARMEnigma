/*
l2n takes a string input in R0
validates it is a valid letter input
Returns the numeric value 1-26 corresponding to the letter in R0
Returns bool for success in R1

*/

			.global l2n
			.func l2n
l2n:
		@ Save registers 
			STMFD SP!, {R4-R12, R14}

		@ Rename registers
			stringPointer .req R4
				MOV stringPointer, #0
			input .req R5
				MOV input, R0
			currentChar .req R6

		@ See if letter or enigma command entered
			LDRB currentChar, [input, stringPointer]
			CMP currentChar, $dash
			MOV stringPointer, #1
			BEQ enigmaTools

		@ Make sure only one character was input
			LDRB currentChar, [input, stringPointer]
			CMP currentChar, $newline
			BNE invalid
		@ Make sure character is valid letter
			SUB stringPointer, stringPointer, #1
			LDRB currentChar, [input, stringPointer]
			CMP currentChar, $a_ascii
			BGE lc
			CMP currentChar, $Z_ascii
			BLE uc
			BAL invalid

lc:			
			CMP currentChar, $z_ascii
			BGT invalid
			SUB R0, currentChar, #96
			MOV R1, #0
			BAL done

uc:			
			CMP currentChar, $A_ascii
			BLT invalid
			SUB R0, currentChar, #64
			MOV R1, #0
			BAL done

invalid:	
			MOV R1, #1
			BAL done




enigmaTools:

		@ # check only one letter after dash
			MOV stringPointer, #2
			LDRB currentChar, [input, stringPointer]
			CMP currentChar, $newline
			BNE invalid

			MOV stringPointer, #1
			LDRB currentChar, [input, stringPointer]
			CMP currentChar, $h_ascii
			MOVEQ R1, #2
			BEQ done
			CMP currentChar, $t_ascii
			MOVEQ R1, #3
			BEQ done
			CMP currentChar, $r_ascii
			MOVEQ R1, #4
			BEQ done
			CMP currentChar, $w_ascii
			MOVEQ R1, #5
			BEQ done
			CMP currentChar, $q_ascii
			MOVEQ R1, #6
			BEQ done
			BAL invalid





done:
		@ Restore registers and return 
			LDMFD SP!, {R4-R12, R14}
			MOV PC, LR

			.data

invalidS:	.asciz "\nInvalid input.\n"

			.equ newline, 10
			.equ a_ascii, 97
			.equ z_ascii, 122
			.equ A_ascii, 65
			.equ Z_ascii, 90

			.equ dash, 45
			.equ h_ascii, 104
			.equ q_ascii, 113
			.equ w_ascii, 119
			.equ r_ascii, 114
			.equ t_ascii, 116





