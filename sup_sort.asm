Superfluous Sort     (sup_sort.asm)

; Author: Paul Adams
; Last Modified: 05 28 18
; Description: Gets 10-200 (as chosen by user) random numbers in the range 100-999.
; Displays the list. Sorts the list. Calculates and displays the median as an integer.
; Displays the sorted list.
; Dependencies: This program uses several procedures from Kip Irvine's MASM library,
; available at http://kipirvine.com/asm/gettingStartedVS2017/index.htm

INCLUDE Irvine32.inc

MIN_COUNT = 10		;minimum number of random integers the user can request
MAX_COUNT = 200		;maximum number of random integers the user can request
MIN_NUM   = 100		;minimum value of each random integer
MAX_NUM   = 999		;maximum value of each random integer
NUMS_PER_LINE = 10	;for formatting output

.data
intro1			BYTE	"You are running assignment_5 written by Paul Adams",0
intro2			BYTE	"This program generates a user-defined number of random integers.",0
intro3			BYTE	"The integers are displayed and then sorted. The median is calculated",0
intro4			BYTE	"as an integer and displayed. Finally, the sorted list is displayed.",0
promptInput		BYTE	"How many random integers do you want? Enter a number from ",0
to				BYTE	" to ",0
invalidInput	BYTE	"Out of range.",0
printUnsorted	BYTE	"The unsorted random integers:",0
printMedian		BYTE	"The median is: ",0
printSorted		BYTE	"The sorted random integers:",0
goodbye			BYTE	"Program ending.",0
numRandInts		DWORD	0							;number of random integers to be generated
array			DWORD	MAX_COUNT DUP(0)
median			DWORD	0

.code
main PROC
	call	Randomize

	push	OFFSET intro4
	push	OFFSET intro3
	push	OFFSET intro2
	push	OFFSET intro1
	call	intro

	push	OFFSET numRandInts
	push	OFFSET invalidInput
	push	OFFSET to
	push	OFFSET promptInput
	call	getData

	push	OFFSET array
	push	numRandInts
	call	fillArray

	push	numRandInts
	push	OFFSET	array
	push	OFFSET	printUnsorted
	call	displayList

	push	OFFSET	array
	push	numRandInts
	call	sortList

	push	OFFSET array
	push	numRandInts
	push	OFFSET printMedian
	call	displayMedian

	push	numRandInts
	push	OFFSET array
	push	OFFSET printSorted
	call	displayList

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

; Description: Prints an program introduction to the console
; Receives: Offsets of strings to be output
; Returns: N/A
; Preconditions: none
; Registers changed: edx
intro PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp + 8]		;Write introduction to console
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 12]
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 16]
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 20]
	call	WriteString
	call	Crlf
	call	Crlf

	pop ebp
	ret 16
intro ENDP

; Description: Gets unsigned integer input from user, checks if in [MIN_NUM .. MAX_NUM],
; re-prompts until valid input is given.
; Receives: Offsets of three strings and value of numRandInts
; Returns: User input in numRandInts
; Preconditions: MIN_NUM and MAX_NUM have meaningful values
; Registers changed: edx, eax
getData PROC
	push	ebp
	mov		ebp, esp
	jmp		Prompt

InvalidInputMsg:
	mov		edx, [ebp + 16]
	call	WriteString
	call	Crlf

Prompt:
	mov		edx, [ebp + 8]		;write instructions
	call	WriteString
	mov		eax, MIN_COUNT
	call	WriteDec
	mov		edx, [ebp + 12]
	call	WriteString
	mov		eax, MAX_COUNT
	call	WriteDec
	call	Crlf

	call	readDec				;get input
	cmp		eax, MIN_COUNT		;check if too small
	jb		InvalidInputMsg
	cmp		eax, MAX_COUNT		;check if too large
	ja		InvalidInputMsg		

	mov		edi, [ebp + 20]		;store valid input
	mov		[edi], eax

	pop		ebp
	ret		16
getData ENDP

; Description: Fills an array with numRandInts of random integers in the range [MIN_NUM ... MAX_NUM]
; Receives: An array offset and the value of numRandInts 
; Returns: The array full of random ints
; Preconditions: numRandInts has been given a meaningful value
; Registers changed: eax, ecx, edi
fillArray PROC
	push	ebp
	mov		ebp, esp

	mov		edi, [ebp + 12]		;put array offset into edi
	mov		ecx, [ebp + 8]		;put numRandInts into ecx

fillNext:
	mov		eax, MAX_NUM
	sub		eax, MIN_NUM
	inc		eax					;calculate range to feed to RandomRAnge
	call	RandomRange			;generate random number
	add		eax, MIN_NUM		;adjust random number into acceptable range
	mov		[edi], eax			;place into array eleemnts
	add		edi, 4				;move edi to point at next element
	loop	fillNext

	pop		ebp
	ret		8

fillArray ENDP

; Description: Sorts an array of integers into descending order
; Receives: an array offset by reference and the value of numRandInts
; Returns: The array sorted
; Preconditions: array has 2 or more elements
; Registers changed: eax, ebx, ecx, edx, edi
sortList PROC
.data
i		DWORD	0
j		DWORD	0
k		DWORD	0

.code  
	push	ebp
	mov		ebp, esp

OuterLoop:						;for(k = 0; k < numRandInts - 1; k++)
	mov		eax, k
	mov		i, eax				;i = k

	mov		eax, k
	inc		eax					
	mov		j, eax				;j = k + 1
InnerLoop:						;for(j = k+1; j < numRandInts; j++)
	mov		edi, [ebp + 12]
	mov		eax, j
	mov		ebx, 4
	mul		ebx					
	add		edi, eax			
	mov		ecx, [edi]			

	mov		edi, [ebp + 12]
	mov		eax, i
	mov		ebx, 4
	mul		ebx
	add		edi, eax
	mov		edx, [edi]		
	cmp		ecx, edx			;if(array[j] > array[i]
	jbe		UpdateInnerLoop
	mov		eax, j
	mov		i, eax				;i = j
	
UpdateInnerLoop:	
	mov		eax, j
	inc		eax
	mov		ebx, [ebp + 8]
	mov		j, eax
	cmp		eax, ebx
	jb		InnerLoop

	mov		edi, [ebp + 12]
	mov		eax, k
	mov		ebx, 4
	mul		ebx
	add		edi, eax
	push	edi

	mov		edi, [ebp + 12]
	mov		eax, i
	mov		ebx, 4
	mul		ebx
	add		edi, eax
	push	edi
	call	swap				;swap array[k] and array[i]

UpdateOuterLoop:
	mov		eax, k
	inc		eax
	mov		k, eax
	mov		ebx, [ebp + 8]
	dec		ebx
	cmp		eax, ebx
	jb		OuterLoop


	pop ebp
	ret 8
sortList ENDP

; Description: Swaps the values of two memory locations
; Receives: References to two memory locations
; Returns: The values of those two locations, swapped
; Preconditions: N/A
; Registers changed: eax, ebx, edi
swap PROC
	push	ebp
	mov		ebp, esp

	mov		edi, [ebp + 8]			;move one value into eax
	mov		eax, [edi]
	mov		edi, [ebp + 12]			;move another value into ebx
	mov		ebx, [edi]

	mov		[edi], eax				;swap into original mem locations
	mov		edi, [ebp + 8]
	mov		[edi], ebx

	pop ebp
	ret 8
swap ENDP

; Description: Prints the median element in a sorted array. If odd number of elements,
; prints the average of the middle 2 elements rounded down.
; Receives: Offsets to a label string and the array. Value of numRandInts
; Returns: N/A
; Preconditions: array has at least 2 elements
; Registers changed: eax, ebx, edx, esi
displayMedian PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp + 8]		;Print label
	call	WriteString
	call	Crlf

	mov		eax, [ebp + 12]		;Put middle (or just before middle, if odd) index in eax
	dec		eax
	cdq
	mov		ebx, 2
	div		ebx
	push	edx

	mov		esi, [ebp + 16]		;Calculate address of the above identified index
	mov		ebx, 4
	mul		ebx
	add		esi, eax

	mov		eax, [esi]			;Put the element in eax
	pop		edx
	cmp		edx, 0				;If there are an even number of elements, must find avg of middle 2
	je		PrintNow			;If odd number of elements, jump to print

AverageMiddleTwo:
	add		esi, 4				;Get address of next element
	add		eax, [esi]			;Add this element's value to eax
	cdq
	mov		ebx, 2				;Divide by 2 for average
	div		ebx

PrintNow:
	call	WriteDec
	call	Crlf

	pop		ebp
	ret		12
displayMedian ENDP

; Description: Displays an array of unsigned integers to the screen. On each line, prints
; up to NUMS_PER_LINE integers.
; Receives: Offset of list title and array to print. Value of array's size
; Returns: N/A
; Preconditions: array and numRandInts have been initialized
; Registers changed: eax, ebx, ecx, edx, edi
displayList PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp + 8]		;print title of list
	call	WriteString
	call	Crlf

	mov		edi, [ebp + 12]		;array offset
	mov		ecx, [ebp + 16]		;elements in array
	mov		ebx, 0				;number of ints printed on the current line

CheckLine:
	cmp		ebx, NUMS_PER_LINE	;check if line is full
	jb		PrintNext
	mov		ebx, 0				;if full, print newline and reset ebx
	call	Crlf

PrintNext:
	mov		eax, [edi]			;print current entry
	call	WriteDec
	mov		al, ' '
	call	WriteChar
	add		edi, 4
	inc		ebx					;add 1 to counter of nums on current line
	loop	CheckLine

	call	Crlf

	pop ebp
	ret 12
displayList ENDP


END main
