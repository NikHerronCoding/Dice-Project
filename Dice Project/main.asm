;CSC 2025 Final Project
;Nik Herron
;04/28/2024
;This project is a dice game that uses the Irvine library to create a functional dice game in the windows terminal
;please see the design document to see usage and specifications of how this program fully works
;

Include Irvine32.inc
.386

.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data

	diceCount dd 2,2,2,2,2,2
	diceState dd 1,1,2,2,3,3
	playerScore dd 0
	currentChar db ' '

	cursorOffset db 0

	; this is the ascii art for dice side one through six
	oneDice db ' _______ ', 10, '|       |', 10, '|   O   |', 10,'|_______|', 10, 0
	twoDice db ' _______ ', 10, '|   O   |', 10, '|       |', 10,'|___O___|', 10, 0 
	threeDice db ' _______ ', 10, '|   O   |', 10, '|   O   |', 10,'|___O___|', 10, 0
	fourDice db ' _______ ', 10, '| O   O |', 10, '|       |', 10,'|_O___O_|', 10, 0
	fiveDice db ' _______ ', 10, '| O   O |', 10, '|   O   |', 10,'|_O___O_|', 10, 0
	sixDice db ' _______ ', 10, '| O   O |', 10, '| O   O |', 10,'|_O___O_|', 10, 0 

	;this is the null terminated strings for game output
	introPrompt db 'Welcome to my dice game.', 10, 0
	roundPrompt db 'Please enter e to roll, q to quit!', 0
	scorePrompt db 'Your Score: ', 0
	exitPrompt db 'Thank you for playing!  ', 0
	errorPrompt db 'Error, please put in either lowercase q to quit or e to play a round of dice.', 0
	infoPrompt db 'Your dice roll is: ', 10, 0
	twoOfKindPrompt db 'Two of a kind. 10 Points have been added to your score', 10, 0
	threeOfKindPrompt db 'Three of a kind!  50 points have been added to your score', 10, 0
	fourOfKindPrompt db 'Four of a kind!!  100 points have been added to your score', 10, 0
	fiveOfKindPrompt db 'Five of a kind!!!  500 points have been added to your score', 10, 0
	sixOfKindPrompt db 'Six of a kind!!!!  1000 points have been added to your score', 10, 0
	straightPrompt db 'Straight!!!! 1000 points have been added to your score',  10, 0
	fullHousePrompt db ' Full House!!! 1000 points have been added to your score',  10, 0


.code
main proc

	call runGame
	
	invoke ExitProcess,0
main endp

runGame proc

	init:

		call Clrscr

		;write prompt text for the game output
		mov edx, offset introPrompt
		call WriteString
		mov eax, 10
		call WriteChar

	getting_input:
		;outputting prompt for roll
		mov edx, offset roundPrompt
		call WriteString
		mov eax, 10
		call WriteChar
		;getting input from the player
		call readChar
		mov currentChar, al

		;determining on continue game or quit
		cmp currentChar, 'q'
		je quit

		cmp currentChar, 'e'
		je play_round

		mov edx, offset errorPrompt
		call WriteString
		mov eax, 10
		call WriteChar

		jmp getting_input
	
	play_round:
		call Clrscr
		call RollDice
		call countDice
		call printDice
		mov eax, 10
		call WriteChar
		mov eax, 10
		call WriteChar
		call determineScore
		call printScore
		jmp getting_input		

	quit:
		mov edx, offset exitPrompt
		call writeString

		mov edx, offset scorePrompt
		call writeString

		mov edx, offset playerScore
		call writeInt
		ret

runGame endp

printDice proc
	
	;using ecx as counter, set counter to 0
	mov ecx, 0

	loop_start:
		;FOR DICE 0-5 (6 TOTAL), LOOP THROUGH AND PRINT THE DICE STATE THAT IT REPRESENTS
		mov eax, [diceState + ecx]

		cmp eax, 1
		je print_one

		cmp eax, 2
		je print_two

		cmp eax, 3
		je print_three

		cmp eax, 4
		je print_four

		cmp eax, 5
		je print_five

		cmp eax, 6
		je print_six

		;section that compares the current counter to the count that would represent index 6
		loop_compare:
			add ecx, 4
			cmp ecx, 24
			jl loop_start
			jmp loop_exit

		;sections that print the current die state
		print_one:
			mov edx, offset oneDice
			call WriteString
			jmp loop_compare

		print_two:
			mov edx, offset twoDice
			call WriteString
			jmp loop_compare

		print_three:
			mov edx, offset threeDice
			call WriteString
			jmp loop_compare

		print_four:
			mov edx, offset fourDice
			call WriteString
			jmp loop_compare

		print_five:
			mov edx, offset fiveDice
			call WriteString
			jmp loop_compare

		print_six:
			mov edx, offset sixDice
			call WriteString
			jmp loop_compare

	loop_exit:
		ret

printDice endp

printScore proc
	mov eax, 10
	call WriteChar

	mov edx, offset scorePrompt
	call WriteString
	
	mov eax, playerScore
	call WriteInt

	mov eax, 10
	call WriteChar

	ret
printScore endp

rollDice proc

	;using ecx as counter and setting to 0
	mov ecx, 0;

	start_loop:

		mov eax, 15
		call Delay
		call Randomize
	
		mov eax, 6
		call RandomRange
		inc eax
		mov  [diceState + ecx], eax

		;incrementing counter by 4 bytes
		add ecx, 4

		cmp ecx, 24
		jl start_loop
		jmp end_loop

	end_loop:
		ret

rollDice endp

determineScore proc
	determine_roll:
		;determines if the roll is a full house
		 call isFullHouse
		 cmp eax, 1
		 je full_house

		 ;determines if the roll is a straight
		 call isStraight
		 cmp eax, 1
		 je straight

		;determines if the roll is a six of a kind
		call sixOfKind
		cmp eax, 1
		je five_of_kind

		;determines if the roll is a five of a kind
		call fiveOfKind
		cmp eax, 1
		je five_of_kind

		;determines if the roll is a four of a kind
		call fourOfKind
		cmp eax, 1
		je four_of_kind

		 ;determines if the roll is a three of a kind
		call threeOfKind
		cmp eax, 1
		je three_of_kind

		;determines if the roll is a two of a kind
		call twoOfKind
		cmp eax, 1
		je two_of_kind

		
		
		
		;after checking all conditions and nothing happens, jump to end.
		jmp exit_loop


	two_of_kind:
		mov edx, offset twoOfKindPrompt
		call WriteString
		add playerScore, 10
		jmp exit_loop

	three_of_kind:
		mov edx, offset threeOfKindPrompt
		call WriteString
		add playerScore, 50
		jmp exit_loop

	four_of_kind:
		mov edx, offset fourOfKindPrompt
		call WriteString
		add playerScore, 100
		jmp exit_loop

	five_of_kind:
		mov edx, offset fiveOfKindPrompt
		call WriteString
		add playerScore, 500
		jmp exit_loop

	six_of_kind:
		mov edx, offset sixOfKindPrompt
		call WriteString
		add playerScore, 1000
		jmp exit_loop

	full_house:
		mov edx, offset fullHousePrompt
		call WriteString
		add playerScore, 1000
		jmp exit_loop

	straight:
		mov edx, offset straightPrompt
		call WriteString
		add playerScore, 1000
		jmp exit_loop

	exit_loop:
		ret
determineScore endp

;this subroutine goes through diceState and counts the number of each die by incrementing the dice count in the array that corresponds with that specific number
countDice proc

	init:
	;clearing current dice count
	call clearDiceCount

	;creating counter in ecx register and setting to 0
	mov ecx, 0

	start_loop:

		;do something here
		mov ebx, [diceState + ecx]
		inc [diceCount + ebx * 4 - 4]



		;increment counter by 4 
		add ecx, 4
		cmp ecx, 24
		jl start_loop
		jmp exit_loop
	exit_loop:
	ret

countDice endp

clearDiceCount proc

	;creating counter in ecx register and setting to 0
	mov ecx, 0
	start_loop:

		;set diceount[ ecx / 4 ] to 0
		mov [diceCount + ecx], 0;


		;increment counter by 4 
		add ecx, 4
		cmp ecx, 24
		jl start_loop
		jmp exit_loop
	exit_loop:
	ret

clearDiceCount endp

printDiceCount proc

	;creating counter in ecx register and setting to 0
	mov ecx, 0
	start_loop:

		;call WriteInt on dice state
		mov eax, [diceCount + ecx];
		call WriteInt

		;increment counter by 4 
		add ecx, 4
		cmp ecx, 24
		jl start_loop
		jmp exit_loop
	exit_loop:
	ret
	
printDiceCount endp

twoOfKind proc

	;creating counter in ecx register and setting to 0
	mov ecx, 0

	;start with 0 in eax - false value
	mov eax, 0
	start_loop:

		;if diceCount[ecx] == 2 return 1
		cmp diceCount[ecx], 2
		je return_one;


		;increment counter by 4 
		add ecx, 4
		cmp ecx, 24
		jl start_loop
		jmp exit_loop

	return_one:
		mov eax, 1
		jmp exit_loop


	exit_loop:
		ret


twoOfKind endp

threeOfKind proc

	;creating counter in ecx register and setting to 0
	mov ecx, 0

	;start with 0 in eax - false value
	mov eax, 0
	start_loop:

		;if diceCount[ecx] == 3 return 1
		cmp diceCount[ecx], 3
		je return_one;


		;increment counter by 4 
		add ecx, 4
		cmp ecx, 24
		jl start_loop
		jmp exit_loop

	return_one:
		mov eax, 1
		jmp exit_loop


	exit_loop:
		ret


threeOfKind endp

fourOfKind proc

	;creating counter in ecx register and setting to 0
	mov ecx, 0

	;start with 0 in eax - false value
	mov eax, 0
	start_loop:

		;if diceCount[ecx] == 4 return 1
		cmp diceCount[ecx], 4
		je return_one;


		;increment counter by 4 
		add ecx, 4
		cmp ecx, 24
		jl start_loop
		jmp exit_loop

	return_one:
		mov eax, 1
		jmp exit_loop


	exit_loop:
		ret


fourOfKind endp

fiveOfKind proc

	;creating counter in ecx register and setting to 0
	mov ecx, 0

	;start with 0 in eax - false value
	mov eax, 0
	start_loop:

		;if diceCount[ecx] == 5 return 1
		cmp diceCount[ecx], 5
		je return_one;


		;increment counter by 4 
		add ecx, 4
		cmp ecx, 24
		jl start_loop
		jmp exit_loop

	return_one:
		mov eax, 1
		jmp exit_loop


	exit_loop:
		ret


fiveOfKind endp

sixOfKind proc

	;creating counter in ecx register and setting to 0
	mov ecx, 0

	;start with 0 in eax - false value
	mov eax, 0
	start_loop:

		;if diceCount[ecx] == 6 return 1
		cmp diceCount[ecx], 6
		je return_one;


		;increment counter by 4 
		add ecx, 4
		cmp ecx, 24
		jl start_loop
		jmp exit_loop

	return_one:
		mov eax, 1
		jmp exit_loop


	exit_loop:
		ret

sixOfKind endp

isStraight proc

	;creating counter in ecx register and setting to 0
	mov ecx, 0

	;start with 1 in eax
	mov eax, 1
	start_loop:

		;if !diceCount[ecx] == 1 return 0
		cmp diceCount[ecx], 1
		jne return_zero;


		;increment counter by 4 
		add ecx, 4
		cmp ecx, 24
		jl start_loop
		jmp exit_loop

	return_zero:
		mov eax, 0
		jmp exit_loop


	exit_loop:
		ret
	
	
isStraight endp

isFullHouse proc

	twoCheck:
		call twoOfKind
		cmp eax, 0
		je return_zero
		jmp threeCheck

	threeCheck:
		call threeOfKind
		cmp eax, 0
		je return_zero
		mov eax, 1
		ret

	return_zero:
		mov eax, 0
		ret

isFullHouse endp


end main