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
	diceState dd 4,5,6,1,2,3
	playerScore dd 0

	cursorOffset db 0

	; this is the ascii art for dice side one through six
	oneDice db ' _______ ', 10, '|       |', 10, '|   O   |', 10,'|_______|', 10, 0
	twoDice db ' _______ ', 10, '|   O   |', 10, '|       |', 10,'|___O___|', 10, 0 
	threeDice db ' _______ ', 10, '|   O   |', 10, '|   O   |', 10,'|___O___|', 10, 0
	fourDice db ' _______ ', 10, '| O   O |', 10, '|       |', 10,'|_O___O_|', 10, 0
	fiveDice db ' _______ ', 10, '| O   O |', 10, '|   O   |', 10,'|_O___O_|', 10, 0
	sixDice db ' _______ ', 10, '| O   O |', 10, '| O   O |', 10,'|_O___O_|', 10, 0 

	;this is the null terminated strings for game output
	scorePrompt db 'Your Score: ', 0


.code
main proc

	call rollDice
	call printDice
	call printScore
	call countDice
	call printDiceCount
	call DumpRegs
	
	invoke ExitProcess,0
main endp

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

		;do something here
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

		;do something here
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

end main