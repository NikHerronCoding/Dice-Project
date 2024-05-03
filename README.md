CSC 2025 Final Project Dice Game Design
Nik Herron 
CSC 2025
April – May 2024
Project Overview:
For this project I decided to make a simple dice game in x86 assembly using the Irvine library to text IO to standard output (console). 
The use will have the choice to roll the dice and be given a score based on what the score the dice roll is worth. The score is dependent on if there are any combinations that satisfy the following 
Type	Score
2 of a kind	10
3 of a kind	50
4 of a kind 	100
5 of a kind	500
6 of a kind	1000
straight	1000
Full house (2 of kind and 3 of kind simultaneous)	1000

Game Logic:
Main calls for game to run (runGame)
runGame runs the game in the following steps:
1.	Outputs initial prompt and asks user for input.
2.	Processes input data and begins round of dice.
3.	Process calculates the dice roll and prompts the user to play more.
4.	Process loops until q is input
5.	Process the displays exit prompt and begins exit process.
Data Section:
Data name	Type	Purpose
playerScore	Int, 4 byte	Section  of data to keep track of score
diceState	Array of 6, 4-byte ints	Section of data to keep track of the dice state (1-6)
oneDice - sixDice	Array of ASCII characters, null terminated	Section of data to define the print outputs representing each die
diceCount	Array, 6 dword ints	Is used to count the frequency of each die in a roll, later used to determine scores.
currentChar	1 byte	Is used to keep track of current user input
prompts	Array of ascii chars, null terminated	Used to store the prompts for the game. Input, output and scoring prompts are all used
		


Code Section:
This project makes heavy use of the Irvine library. See documentation at: https://csc.csudh.edu/mmccullough/asm/help/index.html?page=source%2Firvinelib%2Freadchar.htm  for more detailed information on its usage.
printDice
This subroutine takes no arguments and refers to the global data diceState to iterate through and print the dice states to the console representing the current state of the game. There will also be some formatting text to make sure the output of the program looks good. This code will iterate from the array indices 0 – 5 and will do so using a label and comparison system. Pseudo code is as follows:
	Goto index 0 of diceState
	Compare state to 1, if equal print OneDice to console using WriteString
Compare state to 2, if equal print TwoDice to console using WriteString
Compare state to 3, if equal print ThreeDice to console using WriteString
Compare state to 4, if equal print FourDice to console using WriteString
Compare state to 5, if equal print FiveDice to console using WriteString
Compare state to 6, if equal print SixDice to console using WriteString
Perform the same logic to indices 1-5.
printScore
	This subroutine outputs the score to console from the global data "playerScore"

rollDice
This subroutine simulates the roll of dice to give each dice a random number between 1 and 6. This function uses the Irvine function: Random32.
countDice
Iterates through the diceState array and counts the number of each dice to the diceCount array.
	Logic:
		go to countDice[diceNum - 1] and increment by 1 to count the dice 
		loop through entire array
clearDiceCount
	sets the array diceCount to all zeroes. Needs to be done every dice roll to ensure accurate counts.
runGame 
•	This subroutine is responsible for the execution and logic of the game the logic is as follows:
•	run init - calls clear screen and writes the prompt for the start of the game
•	;gets input from the user, validates the response and then executes based on what the input is (q: quit e:roll)
•	calls playRound which rolls the dice, prints the dice to screen and performs logic to determine the amount of points to add
•	when the game is complete, the quit label is used in which the program outputs the exit prompt and ends the game
determineScore
This function determines what points the roll is worth by checking for each kind of scoring roll
Logic:	
Calls isStraight, if result is true add 1000 points
Calls isFullHouse, if result is true add 1000 points
	Calls twoOfKind, if result is true add 10 points
Calls threeOfKind, if result is true add 50 points
Calls fourOfKind, if result is true add 100 points
Calls fiveOfKind, if result is true add 500 points
Calls sixOfKind, if result is true add 1000 points
twoOfKind
Iterates through diceCount to determine if there are any two of a kinds, returns 1 in eax if there is, 0 if not
threeOfKind
Iterates through diceCount to determine if there are any three of a kinds, returns 1 in eax if there is, 0 if not
fourOfKind
Iterates through diceCount to determine if there are any four of a kinds, returns 1 in eax if there is, 0 if not
fiveOfKind
Iterates through diceCount to determine if there are any five of a kinds, returns 1 in eax if there is, 0 if not
sixOfKind
Iterates through diceCount to determine if there are any six of a kinds, returns 1 in eax if there is, 0 if not
isStraight
Iterates through diceCount to determine if there is a straight, returns 1 in eax if there is, 0 if not
isFullHouse
Iterates through diceCount to determine if there are any Full Houses, returns 1 in eax if there is, 0 if not




