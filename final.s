/*
# This is an simulated version of the Enigma Machine used in WWII.
# There are three predefined cogs, and a reflector. There
# is no plug board. 
*/

			.global _start
_start:
		@ Rename registers

		@ R12 - coglSP (Stack pointer for left cog)
			coglSP .req R12		
			
		@ R11 - cogmSP (Stack pointer for medium cog)
			cogmSP .req R11	
			
		@ R10 - cogrSP (Stack pointer for right cog)
			cogrSP .req R10		
			
		@ R9 - reflSP (Stack pointer for reflector)
			reflSP .req R9		
			
		@ R8 - buffer1SP (Stack pointer for first buffer)
			buffer1SP .req R8		
			
		@ R7 - buffer2SP (Stack pointer for second buffer)
			buffer2SP .req R7	

		@ Display Welcome Message
			LDR R0, =welcome
			BL stro

		@ initialize wipe screen String
		@ This enables us to use the -w command later
			LDR R1, =wipeString
			MOV R2, #0
			MOV R3, $esc_ascii
			STRB R3, [R1, R2]

refresh: @ Where program returns to when -r command is entered				
			
		@ This section is commented out. Uncomment to print 
			@ strings that cogs are initialized to for debugging
			@LDR R0, =coglString
			@BL stro
			@LDR R0, =nl
			@BL stro
			@LDR R0, =cogmString
			@BL stro
			@LDR R0, =nl
			@BL stro
			@LDR R0, =cogrString
			@BL stro
			@LDR R0, =nl
			@BL stro
			@LDR R0, =reflString
			@BL stro
			@LDR R0, =nl
			@BL stro


		@ prime all static registers
			LDR coglSP, =coglS
			LDR cogmSP, =cogmS
			LDR cogrSP, =cogrS
			LDR reflSP, =reflS
			LDR buffer1SP, =buffer1S
			LDR buffer2SP, =buffer2S
/*######## ~ Prime Cogs and Reflector ~ #########*/

	/* 
	# This section takes the strings of letters
	# that represent each cog and put them into 
	# the corresponding stacks. This is the base
	# setting before the user sets the ringstellung
	# and grundstellung.
	*/
		@ R1 - Initialization String 
		@ R2 - String Pointer 
		@ R3 - Current Character

	@ ######## Prime Left Cog ########
			LDR R1, =coglString
			MOV R2, #0

	cogLInitWhile:	
			CMP R2, #26
			BEQ CogLInitEndWhile
		@ Set current ascii value
			LDRB R3, [R1, R2]
		@ Get numeric value 1 - 26
			SUB R0, R3, #64
			STMFA coglSP!, {R0}
			ADD R2, R2, #1
			BAL cogLInitWhile
	CogLInitEndWhile:

	@ ######## Prime Middle Cog ########
			LDR R1, =cogmString
			MOV R2, #0

	cogMInitWhile:	
			CMP R2, #26
			BEQ CogMInitEndWhile
		@ Set current ascii value
			LDRB R3, [R1, R2]
		@ Get numeric value 1 - 26
			SUB R0, R3, #64
			STMFA cogmSP!, {R0}
			ADD R2, R2, #1
			BAL cogMInitWhile
	CogMInitEndWhile:

	@ ######## Prime Right Cog ########
			LDR R1, =cogrString
			MOV R2, #0

	cogRInitWhile:	
			CMP R2, #26
			BEQ CogRInitEndWhile
		@ Set current ascii value
			LDRB R3, [R1, R2]
		@ Get numeric value 1 - 26
			SUB R0, R3, #64
			STMFA cogrSP!, {R0}
			ADD R2, R2, #1
			BAL cogRInitWhile
	CogRInitEndWhile:

	@ ######## Prime Reflector ########
			LDR R1, =reflString
			MOV R2, #0

	reflInitWhile:	
			CMP R2, #26
			BEQ reflInitEndWhile
		@ Set current ascii value
			LDRB R3, [R1, R2]
		@ Get numeric value 1 - 26
			SUB R0, R3, #64
			STMFA reflSP!, {R0}
			ADD R2, R2, #1
			BAL reflInitWhile
	reflInitEndWhile:

/*######## ~ End Priming of Cogs and Reflector ~ #########*/


/*######## ~ User Initialization of Cogs ~ #########*/
		/*
		# This section prompts the user and sets
		# the ringstellung and grundstellung
		# (ring settings and ground settings).
		# This section goes through and rotates the
		# stack to the specified number without increasing
		# the rotation count for the ringstellung. This 
		# simulates changing the connectors. It then
		# repeats the process again for the grundstellung
		# and increases the rotation count. 
		*/

		@ Prompt user for input string
init:		
			LDR R0, =initMsg
			BL stro
			LDR R0, =input
			BL stri 
ginit:
	/*#### Initialization Validation ####*/
		@ R6 = initialization String
			LDR R6, =input
		@ R5 = string pointer 
			MOV R5, #3
		@ R4 = current letter 

		@ Make sure only 3 letters were entered
			LDRB R4, [R6, R5]
			CMP R4, $newline
			BNE invalidInit

		@ Make sure First 3 letters are valid letters
			MOV R5, #0
initWhile:
		@ # if more than 3 letters entered break to invalid
			CMP R5, #3
			BEQ endInitWhile
		@ # if ascii value >= a_ascii break to lower case
		@ # if ascii value <= Z_ascii break to upper case
			LDRB R4, [R6, R5]
			CMP R4, $a_ascii
			BGE lc
			CMP R4, $Z_ascii
			BLE uc
			BAL invalidInit

lc:		@ # lower case instructions	
		@ # if greater than z_ascii break to invalid	
			CMP R4, $z_ascii
			BGT invalidInit
		@ # subtract 1 less than the ascii value for a (97)
		@ # this gives us a numeric value for the letter
		@ # i.e. a = 1, z = 26
			SUB R0, R4, #96
		@ # break to the appropriate string based
		@ # off the string pointer of the input string
			CMP R5, #1
			BLT lCogInit
			BEQ mCogInit
			BGT rCogInit

uc:		@ # upper case instructions	
		@ # if less than A_ascii break to invalid
			CMP R4, $A_ascii
			BLT invalidInit
		@ # subtract 1 less than the ascii value for A (65)
		@ # this gives us a numeric value for the letter
		@ # i.e. A = 1, Z = 26
			SUB R0, R4, #64
		@ # break to the appropriate string based
		@ # off the string pointer of the input string
			CMP R5, #1
			BLT lCogInit
			BEQ mCogInit
			BGT rCogInit

initDone:
		@ # increase string pointer by 1
			ADD R5, R5, #1
		@ # break to initwhile
			BAL initWhile

invalidInit:
			LDR R0, =invalidMsg
			BL stro
			BAL init 

lCogInit:
		@ # Starting conditions: 
		@ # R0 = Numeric Value of letter Left Cog will be primed to (n)

		@ # End conditions:
		@ # left cog rotation count increased to (n)
		@ # (nth) value in left cog stack to brought to the top of the stack
		@ # all values above the (nth) value in the stack are rotated to the bottom of the stack



		@ # Move the specified letter number value 
		@ # as the rotation count. i.e. if the left
		@ # cog is initialized as 'C,' the rotation
		@ # count will be three
			LDR R1, =coglRotationCount
			MOV R2, R0
			STR R2, [R1]
			MOV R3, #1
	lCogPluck: @ # pop values off left cog stack into a buffer stack until the (nth) value is reached
			@ # for (R3 = 0; R3 = R0; R3++)
				CMP R3, R0
				BEQ lCogStore
				LDMFA coglSP!, {R1}
				STMFA buffer1SP!, {R1}
				ADD R3, R3, #1
				BAL lCogPluck

	lCogStore: @ # save (nth) value in R2
				LDMFA coglSP!, {R2}
				ADD R3, R3, #1

	lCogClean: @ # store the remaining values from left cog stack into buffer 2
				@ # for (R3 = R0+1; R3 > 26; R3++)
				CMP R3, #26
				BGT lCogRebuild
				LDMFA coglSP!, {R1}
				STMFA buffer2SP!, {R1}
				ADD R3, R3, #1
				BAL lCogClean

	lCogRebuild:
				MOV R3, #1
		lCogRefill1: @ # store buffer 1 back into left cog stack
					@ # for (R3 = 0; R3 = R0; R3++)
					CMP R3, R0
					BEQ lCogRefill2
					LDMFA buffer1SP!, {R1}
					STMFA coglSP!, {R1}
					ADD R3, R3, #1
					BAL lCogRefill1

		lCogRefill2: @ # store buffer 2 back into left cog stack
					@ # for (R3 = R0; R3 = 26; R3++)
					CMP R3, #26
					BEQ lCogFinish
					LDMFA buffer2SP!, {R1}
					STMFA coglSP!, {R1}
					ADD R3, R3, #1
					BAL lCogRefill2

		lCogFinish: @ # store the (nth) value back onto the top of the stack
					STMFA coglSP!, {R2}
					BAL initDone


mCogInit:
		@ # Starting conditions: 
		@ # R0 = Numeric Value of letter Middle Cog will be primed to (n)

		@ # End conditions:
		@ # Middle cog rotation count increased to (n)
		@ # (nth) value in middle cog stack to brought to the top of the stack
		@ # all values above the (nth) value in the stack are rotated to the bottom of the stack



		@ # Move the specified letter number value 
		@ # as the rotation count. i.e. if the middle
		@ # cog is initialized as 'C,' the rotation
		@ # count will be three
			LDR R1, =cogmRotationCount
			MOV R2, R0
			STR R2, [R1]
			MOV R3, #1
	mCogPluck: @ # pop values off middle cog stack into a buffer stack until the (nth) value is reached
			@ # for (R3 = 0; R3 = R0; R3++)
				CMP R3, R0
				BEQ mCogStore
				LDMFA cogmSP!, {R1}
				STMFA buffer1SP!, {R1}
				ADD R3, R3, #1
				BAL mCogPluck

	mCogStore: @ # save (nth) value in R2
				LDMFA cogmSP!, {R2}
				ADD R3, R3, #1

	mCogClean: @ # store the remaining values from middle cog stack into buffer 2
			@ # for (R3 = R0+1; R3 > 26; R3++)
				CMP R3, #26
				BGT mCogRebuild
				LDMFA cogmSP!, {R1}
				STMFA buffer2SP!, {R1}
				ADD R3, R3, #1
				BAL mCogClean

	mCogRebuild:
				MOV R3, #1
		mCogRefill1: @ # store buffer 1 back into middle cog stack
				@ # for (R3 = 0; R3 = R0; R3++)
					CMP R3, R0
					BEQ mCogRefill2
					LDMFA buffer1SP!, {R1}
					STMFA cogmSP!, {R1}
					ADD R3, R3, #1
					BAL mCogRefill1

		mCogRefill2: @ # store buffer 2 back into middle cog stack
				@ # for (R3 = R0; R3 = 26; R3++)
					CMP R3, #26
					BEQ mCogFinish
					LDMFA buffer2SP!, {R1}
					STMFA cogmSP!, {R1}
					ADD R3, R3, #1
					BAL mCogRefill2

		mCogFinish: @ # store the (nth) value back onto the top of the stack
					STMFA cogmSP!, {R2}
					BAL initDone


rCogInit:
		@ # Starting conditions: 
		@ # R0 = Numeric Value of letter Right Cog will be primed to (n)

		@ # End conditions:
		@ # Right cog rotation count increased to (n)
		@ # (nth) value in right cog stack to brought to the top of the stack
		@ # all values above the (nth) value in the stack are rotated to the bottom of the stack



		@ # Move the specified letter number value 
		@ # as the rotation count. i.e. if the right
		@ # cog is initialized as 'C,' the rotation
		@ # count will be three
			LDR R1, =cogrRotationCount
			MOV R2, R0
			STR R2, [R1]
			MOV R3, #1
	rCogPluck: @ # pop values off right cog stack into a buffer stack until the (nth) value is reached
			@ # for (R3 = 0; R3 = R0; R3++)
				CMP R3, R0
				BEQ rCogStore
				LDMFA cogrSP!, {R1}
				STMFA buffer1SP!, {R1}
				ADD R3, R3, #1
				BAL rCogPluck

	rCogStore: @ # save (nth) value in R2
				LDMFA cogrSP!, {R2}
				ADD R3, R3, #1

	rCogClean: @ # store the remaining values from right cog stack into buffer 2
			@ # for (R3 = R0+1; R3 > 26; R3++)
				CMP R3, #26
				BGT rCogRebuild
				LDMFA cogrSP!, {R1}
				STMFA buffer2SP!, {R1}
				ADD R3, R3, #1
				BAL rCogClean

	rCogRebuild:
				MOV R3, #1
		rCogRefill1: @ # store buffer 1 back into right cog stack
				@ # for (R3 = 0; R3 = R0; R3++)
					CMP R3, R0
					BEQ rCogRefill2
					LDMFA buffer1SP!, {R1}
					STMFA cogrSP!, {R1}
					ADD R3, R3, #1
					BAL rCogRefill1

		rCogRefill2: @ # store buffer 2 back into right cog stack
				@ # for (R3 = R0; R3 = 26; R3++)
					CMP R3, #26
					BEQ rCogFinish
					LDMFA buffer2SP!, {R1}
					STMFA cogrSP!, {R1}
					ADD R3, R3, #1
					BAL rCogRefill2

		rCogFinish: @ # store the (nth) value back onto the top of the stack
					STMFA cogrSP!, {R2}
					BAL initDone
			
endInitWhile:
			/* 
			# This section ends intialization but first
			# checks to see if we are initializing the
			# ringstellung or grundstellung. We do this 
			# with a flag (i). i is initially set to off.
			# After going through initialization once the 
			# flag is set to on and the user is prompted
			# to initialize the grundstellung. once the
			# program loops back to this point with the 
			# flag set to on, the program will break to 
			# the end of the initialization phase.
			*/
			@ # if i = 0
					LDR R2, =i 
					LDR R1, [R2]
					CMP R1, #0
				@ # i++
					ADDEQ R1, R1, #1
					STREQ R1, [R2]
				@ # Break to grundstellung settings
					BEQ grundstellung
			@ # end if 
				MOV R1, #0
				STR R1, [R2]
			@ # Check tflag and break accordingly
				LDR R2, =tflag
				LDR R1, [R2]
				CMP R1, #0
				BEQ inputPrompt
				BAL s2s 

grundstellung:
			LDR R0, =ginitMsg
			BL stro
			LDR R0, =input
			BL stri
			BAL ginit

/*######## ~ End User Initialization of Cogs ~ #########*/













/*######## !!!! The UI Loop !!!! ########*/
inputPrompt:

		@ uncomment this sectio to print stacks for debugging purposes.
		@ NOTE: also must add printStack.s to your makefile
			@ MOV R0, cogrSP
			@ LDR R1, =cogrS 
			@ BL printStack
			@ MOV R0, cogmSP
			@ LDR R1, =cogmS 
			@ BL printStack
			@ MOV R0, coglSP
			@ LDR R1, =coglS 
			@ BL printStack
			@ MOV R0, reflSP
			@ LDR R1, =reflS 
			@ BL printStack


			BAL printCogPosition
printCogPositionReturn: 

		@ Prompt the user for input
			LDR R0, =prompt
			BL stro
			LDR R0, =input 
			BL stri
			LDR R0, =input
			BL l2n

		@ Check flags
		@ # l2n returns a flag in R1 which lets us know 
		@ # what type of input was given by the user
			CMP R1, #1
			LDREQ R0, =invalidMsg
			BLEQ stro 
			BEQ inputPrompt

			CMP R1, $h
				LDREQ R0, =helpMsg
				BLEQ stro
				BEQ inputPrompt

			CMP R1, $r 
				BEQ refresh 

			CMP R1, $t
				LDREQ R2, =tflag
				MOVEQ R1, #1
				STREQ R1, [R2]
				BEQ s2s 

			CMP R1, $w
				LDREQ R0, =wipeString
				BLEQ stro
				BEQ inputPrompt
				 
			CMP R1, $q
				BEQ alldone 		
			
		@ End check flags


		@ R4 = number of input value
			MOV R4, R0
			BAL rcep_r2l 



















/*######## ~ Encryption Processes ~ ########*/

	/*
	# Right Cog Encryption Process: Right to Left (rcep_r2l)
	# starting condition: R4 = numeric value (n) of letter to be encoded
	# ending conditions: The (nth) value in the right stack is stored in R4.
	# 				    The new R4 value is passed to mcep_r2l.
	*/
rcep_r2l:		@ (Right Cog Encryption Process - Right to Left)
		@ Assume R4 is input value 
			MOV R3, #1
			MOV R1, #0
	rcep_r2l_for:	
				CMP R3, R4
				BEQ rcep_r2l_endfor
				LDMFA cogrSP!, {R1}
				STMFA buffer1SP!, {R1}
				ADD R3, R3, #1
				BAL rcep_r2l_for
	rcep_r2l_endfor: 
			LDMFA cogrSP!, {R2}
			MOV R0, R2
			MOV R3, #1
			STMFA cogrSP!, {R2}
	rcep_r2l_for2:	
				CMP R3, R4
				BEQ rcep_r2l_endfor2
				LDMFA buffer1SP!, {R1}
				STMFA cogrSP!, {R1}
				ADD R3, R3, #1
				BAL rcep_r2l_for2
	rcep_r2l_endfor2:
			MOV R4, R0


	/*
	# Middle Cog Encryption Process: Right to Left (mcep_r2l)
	# starting condition: R4 = numeric value (n) of letter to be encoded
	#						   This value has already been changed through rcep_r2l
	# ending conditions: The (nth) value in the middle stack is stored in R4.
	# 				     The new R4 value is passed to lcep_r2l.
	*/
mcep_r2l:		
		@ Assume R4 is input value 
			MOV R3, #1
	mcep_r2l_for:	
				CMP R3, R4
				BEQ mcep_r2l_endfor
				LDMFA cogmSP!, {R1}
				STMFA buffer1SP!, {R1}
				ADD R3, R3, #1
				BAL mcep_r2l_for
	mcep_r2l_endfor: 
			LDMFA cogmSP!, {R2}
			MOV R0, R2
			MOV R3, #1
			STMFA cogmSP!, {R2}
	mcep_r2l_for2:	
				CMP R3, R4
				BEQ mcep_r2l_endfor2
				LDMFA buffer1SP!, {R1}
				STMFA cogmSP!, {R1}
				ADD R3, R3, #1
				BAL mcep_r2l_for2
	mcep_r2l_endfor2:
			MOV R4, R0


	/*
	# Left Cog Encryption Process: Right to Left (lcep_r2l)
	# starting condition: R4 = numeric value (n) of letter to be encoded
	#					  This value has already been changed through rcep_r2l and mcep_r2l
	# ending conditions: The (nth) value in the left stack is stored in R4.
	# 				     The new R4 value is passed to reflScramble.
	*/
lcep_r2l:		
		@ Assume R4 is input value 
			MOV R3, #1
	lcep_r2l_for:	
				CMP R3, R4
				BEQ lcep_r2l_endfor
				LDMFA coglSP!, {R1}
				STMFA buffer1SP!, {R1}
				ADD R3, R3, #1
				BAL lcep_r2l_for
	lcep_r2l_endfor: 
			LDMFA coglSP!, {R2}
			MOV R0, R2
			MOV R3, #1
			STMFA coglSP!, {R2}
	lcep_r2l_for2:	
				CMP R3, R4
				BEQ lcep_r2l_endfor2
				LDMFA buffer1SP!, {R1}
				STMFA coglSP!, {R1}
				ADD R3, R3, #1
				BAL lcep_r2l_for2
	lcep_r2l_endfor2:
			MOV R4, R0


	/*
	# Reflector Scramble (reflScramble)
	# starting condition: R4 = numeric value (n) of letter to be encoded
	#					  This value has already been changed through all three right to left encryption processes
	# ending conditions: The reflector takes the value from R4 and changes it to its number pair.
	# 				     The new R4 value is passed to lcep_l2r.
	*/
reflScramble:
		@ Assume R4 is input value
			CMP R4, #13
			ADDLE R4, R4, #13
			SUBGT R4, R4, #13


	/*
	# Left Cog Encryption Process: Left to Right (lcep_l2r)
	# starting condition: R4 = numeric value (n) of letter to be encoded
	#				      This value has already been changed through all three right to left encryption processes, and the reflector
	# ending conditions: Finds the value (n) in the left stack. 
	#					 Passes the location of (n) in the stack to R4
	*/
lcep_l2r:		
		@ Assume R4 is input value 
			MOV R3, #0
	lcep_l2r_while:	
				ADD R3, R3, #1
				LDMFA coglSP!, {R1}
				CMP R1, R4
				BEQ lcep_l2r_endwhile
				STMFA buffer1SP!, {R1}
				BAL lcep_l2r_while
	lcep_l2r_endwhile: 
			STMFA coglSP!, {R1}
			MOV R4, R3
			MOV R3, #1
	lcep_l2r_for:	
				CMP R3, R4
				BEQ lcep_l2r_endfor
				LDMFA buffer1SP!, {R1}
				STMFA coglSP!, {R1}
				ADD R3, R3, #1
				BAL lcep_l2r_for
	lcep_l2r_endfor:
			MOV R0, R4


	/*
	# Middle Cog Encryption Process: Left to Right (mcep_l2r)
	# starting condition: R4 = how far down in the previous stack the encoded letter was (n).
	#				      This value has already been changed through all three right to left encryption processes, the reflector, and lcep_l2r
	# ending conditions: Finds the value (n) in the middle stack. 
	#					 Passes the location of (n) in the stack to R4
	*/
mcep_l2r:		
		@ Assume R4 is input value 
			MOV R3, #0
	mcep_l2r_while:	
				ADD R3, R3, #1
				LDMFA cogmSP!, {R1}
				CMP R1, R4
				BEQ mcep_l2r_endwhile
				STMFA buffer1SP!, {R1}
				BAL mcep_l2r_while
	mcep_l2r_endwhile: 
			STMFA cogmSP!, {R1}
			MOV R4, R3
			MOV R3, #1
	mcep_l2r_for:	
				CMP R3, R4
				BEQ mcep_l2r_endfor
				LDMFA buffer1SP!, {R1}
				STMFA cogmSP!, {R1}
				ADD R3, R3, #1
				BAL mcep_l2r_for
	mcep_l2r_endfor:
			MOV R0, R4


	/*
	# Right Cog Encryption Process: Left to Right (rcep_l2r)
	# starting condition: R4 = how far down in the previous stack the encoded letter was (n).
	#				      This value has already been changed through all three right to left encryption processes, the reflector, lcep_l2r, and mcep_l2r
	# ending conditions: Finds the value (n) in the right stack. 
	#					 Passes the location of (n) in the stack to R4
	*/
rcep_l2r:		
		@ Assume R4 is input value 
			MOV R3, #0
	rcep_l2r_while:	
				ADD R3, R3, #1
				LDMFA cogrSP!, {R1}
				CMP R1, R4
				BEQ rcep_l2r_endwhile
				STMFA buffer1SP!, {R1}
				BAL rcep_l2r_while
	rcep_l2r_endwhile: 
			STMFA cogrSP!, {R1}
			MOV R4, R3
			MOV R3, #1
	rcep_l2r_for:	
				CMP R3, R4
				BEQ rcep_l2r_endfor
				LDMFA buffer1SP!, {R1}
				STMFA cogrSP!, {R1}
				ADD R3, R3, #1
				BAL rcep_l2r_for
	rcep_l2r_endfor:

printResult:
		@ # prints resulting encoded letter in character mode
		@ # breaks to store encoded letter into string in string mode
		@ Check tflag and break accordingly
			LDR R2, =tflag
			LDR R1, [R2]
			CMP R1, #1
			BEQ rotateRightCog
			MOV R0, R4 
			BL n2l
			LDR R0, =nl
			BL stro 
			BAL rotateRightCog





/*######## ~ Rotation of Cogs ~ #########*/

	/*
	# This section rotates the right cog after each
	# character is encoded. If the notch in the right
	# cog is reached the middle cog is rotated. If the
	# notch in the middle cog is reached, the right cog
	# is rotated and the middle cog is rotated again. 
	# (The infamous double step)
	*/

rotateRightCog:
		@ # Pop top of stack off into R0
			LDMFA cogrSP!, {R0}
			MOV R3, #1
	rrc_for:
		@ # store rest of stack into buffer
				@ for (R3 = 2; R3 <= 26; R3++)
				CMP R3, #26
				BEQ rrc_endfor
				LDMFA cogrSP!, {R1}
				STMFA buffer1SP!, {R1}
				ADD R3, R3, #1
				BAL rrc_for 
	rrc_endfor: 
		@ # store original top of stack into now empty stack
			STMFA cogrSP!, {R0}
			MOV R3, #1
	rrc_for2:
		@ # store rest of stack on top.
				@ for (R3 = 2; R3 <= 26; R3++)
				CMP R3, #26
				BEQ rrc_endfor2
				LDMFA buffer1SP!, {R1}
				STMFA cogrSP!, {R1}
				ADD R3, R3, #1
				BAL rrc_for2 
	rrc_endfor2:		
		@ Increase rotation count 
			LDR R1, =cogrRotationCount
			LDR R0, [R1]
			CMP R0, #26
			ADDLT R0, R0, #1
			SUBEQ R0, R0, #25
			STR R0, [R1]
		@ if rotation count == notch rotate middle cog
			LDR R2, =notch1
			LDR R1, [R2]
			CMP R0, R1
			BEQ rotateMiddleCog
			@ Check tflag and break accordingly
				LDR R2, =tflag
				LDR R1, [R2]
				CMP R1, #0
				BEQ inputPrompt
				BAL return 

rotateMiddleCog: @ # section identical to right cog. check pseudocode above
			LDMFA cogmSP!, {R0}
			MOV R3, #1
	rmc_for:
				@ for (R3 = 2; R3 <= 26; R3++)
				CMP R3, #26
				BEQ rmc_endfor
				LDMFA cogmSP!, {R1}
				STMFA buffer1SP!, {R1}
				ADD R3, R3, #1
				BAL rmc_for 
	rmc_endfor: 
			STMFA cogmSP!, {R0}
			MOV R3, #1
	rmc_for2:
				@ for (R3 = 2; R3 <= 26; R3++)
				CMP R3, #26
				BEQ rmc_endfor2
				LDMFA buffer1SP!, {R1}
				STMFA cogmSP!, {R1}
				ADD R3, R3, #1
				BAL rmc_for2 
	rmc_endfor2:		
		@ Increase rotation count 
			LDR R1, =cogmRotationCount
			LDR R0, [R1]
			CMP R0, #26
			ADDLT R0, R0, #1
			SUBEQ R0, R0, #25
			STR R0, [R1]
		@ if rotation count == notch 2 rotate left cog
			LDR R2, =notch2
			LDR R1, [R2]
			CMP R0, R1
			BEQ rotateLeftCog
			@ Check tflag and break accordingly
				LDR R2, =tflag
				LDR R1, [R2]
				CMP R1, #0
				BEQ inputPrompt
				BAL return  

rotateLeftCog:
			LDMFA coglSP!, {R0}
			MOV R3, #1
	rlc_for:
				@ for (R3 = 2; R3 <= 26; R3++)
				CMP R3, #26
				BEQ rlc_endfor
				LDMFA coglSP!, {R1}
				STMFA buffer1SP!, {R1}
				ADD R3, R3, #1
				BAL rlc_for 
	rlc_endfor: 
			STMFA coglSP!, {R0}
			MOV R3, #1
	rlc_for2:
				@ for (R3 = 2; R3 <= 26; R3++)
				CMP R3, #26
				BEQ rlc_endfor2
				LDMFA buffer1SP!, {R1}
				STMFA coglSP!, {R1}
				ADD R3, R3, #1
				BAL rlc_for2 
	rlc_endfor2:		
		@ Increase rotation count 
			LDR R1, =coglRotationCount
			LDR R0, [R1]
			CMP R0, #26
			ADDLT R0, R0, #1
			SUBEQ R0, R0, #25
			STR R0, [R1]
		@ # we always return to rotate the middle cog again (double step)
			BAL rotateMiddleCog


/*######## ~ Exit From Program ~ ########*/
alldone:	MOV R7, #1
			SWI 0

@ # This section displays the three cogs on the screen
printCogPosition:
			LDR R0, =PCP1
			BL stro
			LDR R2, =coglRotationCount
			LDR R0, [R2]
			BL n2l
			LDR R0, =PCP2
			BL stro
			LDR R2, =cogmRotationCount
			LDR R0, [R2]
			BL n2l
			LDR R0, =PCP2
			BL stro
			LDR R2, =cogrRotationCount
			LDR R0, [R2]
			BL n2l
			LDR R0, =PCP3
			BL stro
			BAL printCogPositionReturn





















/*######## ~ String to String Encryption Section ~ ########*/

/*
# Here we will be recieving a string instead of a character
# from the user. We will then encrypt the entire message and
# output it to the user using proper enigma formatting.
*/

s2s:
		@ # Print cog position
			LDR R0, =PCP1
			BL stro
			LDR R2, =coglRotationCount
			LDR R0, [R2]
			BL n2l
			LDR R0, =PCP2
			BL stro
			LDR R2, =cogmRotationCount
			LDR R0, [R2]
			BL n2l
			LDR R0, =PCP2
			BL stro
			LDR R2, =cogrRotationCount
			LDR R0, [R2]
			BL n2l
			LDR R0, =PCP3
			BL stro

		@ #prompt user for input string
			LDR R0, =s2sPrompt
			BL stro

		@ #store input into s2sInput
			LDR R0, =s2sInput
			BL stri 

		@ #icount = 0
		@ #let R6 = icount
			MOV R6, #0

		@ #ocount = 0
		@ #let R5 = ocount
			MOV R5, #0

		@ #lblockcount = 0
			LDR R2, =lblockcount
			MOV R1, #0
			STR R1, [R2]

		@ #Check to see if input is an emuator command
			LDR R0, =s2sInput
			LDRB R3, [R0, R6]
			@ # is first character a dash? if not break to encryption loop
			CMP R3, $dash_ascii
			BNE s2sWhile

		@ # check only one letter after dash
			MOV R6, #2
			LDRB R3, [R0, R6]
			CMP R3, $newline
			BNE s2sinvalid

			@ # see which emulator command is input and react accordingly
			MOV R6, #1
			LDRB R3, [R0, R6]

			@ # help menu
			CMP R3, $h_ascii @hqwrt
			LDREQ R0, =helpMsg
			BLEQ stro 
			BEQ s2s

			@ # quit program
			CMP R3, $q_ascii
			BEQ alldone

			@ # wipe screen
			CMP R3, $w_ascii
			LDREQ R0, =wipeString
			BLEQ stro
			BEQ s2s

			@ # reset rotors
			CMP R3, $r_ascii 
			BEQ refresh 

			@ # change to char mode
			CMP R3, $t_ascii
			LDREQ R2, =tflag
			MOVEQ R1, #0
			STREQ R1, [R2]
			BEQ inputPrompt

			BAL s2sinvalid

		@ #While icount < 84 {
s2sWhile:	
			CMP R6, #84
			BEQ s2sEndWhile
		@ #	load the [icount]th byte into current byte (R3)
			LDR R0, =s2sInput
			LDRB R3, [R0, R6]

		@ #	if a nl - end while
			CMP R3, $newline
			BEQ s2sEndWhile

		@ #	compare current value to a letter, period or space.
			CMP R3, $a_ascii
			BGE s2slc
			CMP R3, $Z_ascii
			BLE s2suc
			BAL s2sinvalid

s2slc:			
			CMP R3, $z_ascii
			BGT s2sinvalid
			SUB R4, R3, #96
			BAL sendOff

s2suc:			
			CMP R3, $A_ascii
			BLT s2snlc
			SUB R4, R3, #64
			BAL sendOff

s2snlc:
		@ #	if a period send X to be encoded.
			CMP R3, $period_ascii
			MOVEQ R4, #24
			BEQ sendOff
		@ #	if a space increase icount by one
		@ #		break to while
			CMP R3, $space_ascii
			ADDEQ R6, R6, #1
			BEQ s2sWhile
			BAL s2sinvalid

sendOff:
			BAL rcep_r2l
return: @ # result is stored in R4
			@ MOV R0, R4
			@ BL deco
			ADD R4, R4, #64
		@ #	if lblockcount == 4, increase 0count by one and set lblockcount back to zero
			LDR R2, =lblockcount
			LDR R1, [R2]
			CMP R1, #4
			ADDEQ R5, R5, #1
			MOVEQ R1, #0
			STREQ R1, [R2]

		@ # store encoded letter into [s2sOutput, ocount]
			LDR R0, =s2sOutput
			STRB R4, [R0, R5]
			@ BL stro
			@ LDR R0, =nl 
			@ BL stro 
		@ #		increase icount ocount and lblockcount by 1
			ADD R5, R5, #1
			ADD R6, R6, #1
			LDR R2, =lblockcount
			LDR R1, [R2]
			ADD R1, R1, #1
			STR R1, [R2]
		@ #		break to while
			BAL s2sWhile
		

		@ # end while
s2sEndWhile:
			LDR R0, =s2sOutput
			BL stro
			LDR R0, =nl
			BL stro
			
		@ # recalibrate input and output strings to zero
			LDR R1, =s2sOutput
			LDR R2, =s2sInput
			MOV R3, #0
nextChar:	
			LDRB R0, [R1, R3]
			CMP R0, #0
			BEQ s2s
			MOV R0, #' '
			STRB R0, [R1, R3]
			STRB R0, [R2, R3]
			ADD R3, R3, #1
			BAL nextChar
  


s2sinvalid:	
			LDR R0, =invalidMsg
			BL stro
			BAL s2s 














			.data

coglS:		.space 108 @ space for 26 32bit values 
coglString: .asciz "EKMFLGDQVZNTOWYHXUSPAIBRCJ"

cogmS:		.space 108 
cogmString: .asciz "AJDKSIRUXBLHWTMCQGZNPYFVOE"

cogrS:		.space 108
cogrString: .asciz "BDFHJLCPRTXVZNYEIWGAKMUSQO"

reflS:		.space 108 
reflString: .asciz "YRUHQSLDPXNGOKMIEBFZCWVJAT"

notch1:		.word 12 @ # trigger for middle cog to rotate
notch2:		.word 5 @ # trigger for right cog to rotate

cogrRotationCount: .word 0 @ # how many times right cog has rotated.
cogmRotationCount: .word 0
coglRotationCount: .word 0

		@ # The following values are the flag values returned by l2n
		@ # These flags instruct the emulator to perform the corresponding
		@ # emulator commands
			.equ h, 2 
			.equ t, 3
			.equ r, 4
			.equ w, 5
			.equ q, 6

buffer1S:	.space 104

buffer2S:	.space 104

i:			.word 0  @ # flag tells us if we are initializing ringstellung or grundstellung

input:		.asciz "                      "
output: 	.asciz "  "

nl:			.asciz "\n"

welcome:	.asciz "********************************************************\n*                                                      *\n*               Enigma Machine Simulator               *\n*               Created by Matthew Lacey               *\n*                                                      *\n********************************************************\n"
initMsg:	.asciz "\nInitialize Ringstellung (Three Letters): "
ginitMsg:	.asciz "\nInitialize Grundstellung (Three Letters): "
invalidMsg: .asciz "\nInvalid Input.\n"
prompt:		.asciz "\nEnter Letter: "
PCP1:		.asciz "\n*******************************************************\n*                                                     *\n*                      "
PCP2:		.asciz " | "
PCP3:		.asciz "                      *\n*                                                     *\n*******************************************************\n"
helpMsg:	.asciz "~~ Help Menu ~~\n\nFormatting Help:\n\nSpacer Character:\nTo add a stop between words or sentences you can use an \"X\" character. \nThis is not required but it helps.\n\nEncoding Numbers:\nThe Enigma Machine can only output letters. One way to send numbers is to \nspell them out, but this is tedious and longer messages are easier to break. \nThe short hand for numbers on enigma is:\nQ:1 W:2 E:3 R:4 T:5 Z:6 U:7 I:8 O:9 P:0\nTo include numbers in your message, you first need to indicate that you \nare about to use a number by entering the letter \"Y\" before each number. \nThe number 8 would be YI and the number 57 would be YTU\n\nLetter Blocks: \nYour output should be put into letter blocks of four to six letters.\n\nEmulator Commands:\n-h: display help menu\n-t: switch between character and sentence input\n-r: reinitialize cogs\n-w: wipe screen\n-q: quit Enigma\n\n"
wipeString:	.asciz "E[2J" @ #Wipe string is "'esc'[2J" is initialized to replace E with 'esc' at beginning of program

			.equ newline, 10

			.equ A_ascii, 65
			.equ Z_ascii, 90

			.equ a_ascii, 97
			.equ z_ascii, 122

			.equ esc_ascii, 27

	/* #### String to String Data #### */
s2sPrompt:	.asciz "\nEnter Message to be Encoded: "
s2sInput:	.asciz "                                                                                    "
s2sOutput:	.asciz "                                                                                    "

tflag:		.word 0 @ # flag for whether we are in character or string input

			.equ period_ascii, 46
			.equ space_ascii, 32

			.equ dash_ascii, 45
			.equ h_ascii, 104
			.equ q_ascii, 113
			.equ w_ascii, 119
			.equ r_ascii, 114
			.equ t_ascii, 116

lblockcount: .word 0 @ # number of letters in a block of encrypted output before a space














