TITLE Combination Calculator     (prog6.asm)

; Author: Haewon Cho
; OSU Email : choha@oregonstate.edu
; CS271-400 / Program6                 Date: 3/10/2018
; Description: This program gives user a random combination problem, 
;			 : then user enters an answer, then it let the user know if the answer is right or wrong

INCLUDE Irvine32.inc


;macro for printing string

myWriteString	MACRO buffer
push		edx
mov			edx, OFFSET buffer
call		WriteString
pop			edx
ENDM


;constant

MAX		=	80						
chInt1	=	48
chInt2	=	57


.data

welcome			BYTE		"Welcome to the Combination Calculator", 0dh, 0ah,
							"Implemented by Haewon Cho",0dh, 0ah, 0dh, 0ah, 0

wayToDo			BYTE		"I'll give you a combinations problem.", 0dh, 0ah,
							"You enter your answer, and I'll let you know if you are right.", 0dh, 0ah, 0dh, 0ah, 0

problem1		BYTE		"Problem:", 0dh, 0ah, 0
problem2		BYTE		"Number of elements in the set: ", 0
problem3		BYTE		"Number of elements to choose from the set: ", 0
problem4		BYTE		"How many ways can you choose? ", 0


answer1			BYTE		"There are ",0
answer2			BYTE		" combinations of ", 0
answer3			BYTE		" items  from a set of ",0
answer4			BYTE		" .", 0dh, 0ah, 0
answer5			BYTE		"You need more practice.", 0dh, 0ah, 0
answer6			BYTE		"You are correct!", 0dh, 0ah, 0
answer7			BYTE		"Another problem? (y/n): ", 0
answer8			BYTE		"Invalid response.", 0

goodBye			BYTE		"OK ... goodbye.", 0dh, 0ah, 0



n				DWORD		?
r				DWORD		?
userData		DWORD		?
result			DWORD		?
vData			BYTE	MAX+1 DUP(?)
f1				DWORD		1
f2				DWORD		1
f3				DWORD		1
i				DWORD		1






;-----------------------------------
;Procedure to call procedures
;receives: none
;returns: none
;precondition: none
;registers changed: edx, eax
;-----------------------------------



.code
main PROC


call		randomize					; to make random numbers for n and r


call		introduction				


again:									; when user wants to do again


;showing random problem for user

push		OFFSET n
push		OFFSET r
call		showProblem



; get user's answer

push		OFFSET userData
call		getData




;calculate combination

push		OFFSET result
push		n
push		r
call		combinations




;showing the result

push		n
push		r
push		userData
push		result
call		showResults





again2:									; when user input invalid thing


myWriteString answer7					; ask user if user wants to do again

call		ReadChar					; get user's answer
call		WriteChar					
call		Crlf
call		Crlf



; if user enter y then go to again to do one more problem
cmp			al, 'y'						
je			again
cmp			al, 'Y'		
je			again



; if user enter n then go to bye to end the program
cmp			al, 'n'
je			bye
cmp			al, 'N'
je			bye


; if user enter invalid answer then prompt user to enter again
jne			invalid


invalid:

myWriteString answer8							; let user know the answer was invalid

call		Crlf
call		Crlf
jmp			again2



bye:

myWriteString goodBye							; say bye to user



	exit	; exit to operating system
main ENDP





;------------------------------------
;Procedure to introduce the program
;receives: none
;returns: none
;precondition: none
;registers changed: edx
;------------------------------------


introduction PROC


myWriteString welcome							; saying welcome

myWriteString wayToDO							; let user know how to do 



call		 Crlf


ret

introduction ENDP





;-----------------------------------------------------------------
;Procedure to make random combination problem and show it to user
;receives: offset of n and r
;returns: value of n and r
;precondition: none
;registers changed: ebp, eax, ebx
;------------------------------------------------------------------



showProblem PROC



; set up stack frame
push		ebp
mov			ebp, esp


; save registers to use
push		eax						
push		ebx


; get random number for n
mov			eax, 12							;set eax with 12 to get number between 3 and 12
sub			eax, 3
inc			eax								;add one for range = 12 - 3 + 1, put range in eax

call		RandomRange						; produce random number

add			eax, 3							;now eax has [3 - 12] random num

mov			ebx, [ebp+12]					

mov			[ebx], eax						; mov the value into n


; get random number for r
mov			eax, n							;set eax with n to get number between 1 and n
sub			eax, 1
inc			eax

call		RandomRange 
add			eax, 1							; now eax has [1 - n] random number
mov			ebx, [ebp+8]					
mov			[ebx], eax						; mov the value into r



myWriteString problem1						
myWriteString problem2						; show n to user


mov			eax, n							; show n that set before
call		WriteDec
call		Crlf



myWriteString problem3						; show r to user



mov			eax, r							; show r that set before
call		WriteDec
call		Crlf




; restore the registers that used
pop			ebx
pop			eax
pop			ebp


ret			8
showProblem ENDP







;-----------------------------------------------------------------
;Procedure to get user's answer
;receives: offset of userData, offset of vData, to velify data
;returns: value of userData
;precondition: user should enter something
;registers changed: ebp, eax, ebx, ecx, edx, edi, esi
;------------------------------------------------------------------



getData PROC

;set stack frame
push		ebp
mov			ebp, esp

; save registers that would be used
push		eax
push		ebx
push		ecx
push		edx
push		edi
push		esi




	
again:												; when user enter invalid input

myWriteString problem4								; prompt user to input data


mov			edx, OFFSET vData						; user input
mov			esi, edx								; to move next number, set esi with edx
	
mov			ecx, MAX								
call		ReadString								; get the numbers as string to verify the user input

push		eax										; save eax which is the lenth of user input
mov			ecx, eax								; set ecx with the length of user input

mov			eax, 1									
mov			ebx, 10
mov			edi, 0									; to add numbers



; to make eax 10^n where n = ecx 
L1:
mul			ebx										; when the length of user's input is 3 such as 100 then eax become 1000 = 10^3				
loop		L1					


mov			ebx, eax								; save eax in ebx to mov the length of user input into ecx again
pop			eax										; restore eax
mov			ecx, eax								; set ecx to the length of user input again
mov			eax, ebx								; set eax 10^n again



; multiply first array with 10^n/10, .... muliply last array with 1 and add all of them
L2:								

mov			ebx, 0									; empty ebx to save the first array into bl becuse bl is only 1byte
mov			bl, [esi]								; bl - 1byte, char in esi - 1byte


push		edi										; save edi
mov			edi, 10									; mov 10 into edi to divide 10^n


xor			edx, edx								; make edx to save remainder
div			edi										

pop			edi										; restore edi


; verify the user input if it is number
cmp			ebx, chInt1								; compare ebx with 48 which is 0 in ascii
jl			inValid									; if if's less than 48 then go to invalid


cmp			ebx, chInt2								; compare ebx with 57 wich is 9 in ascii
jg			inValid									; if it's bigger than 57 then go to invalid


sub			ebx, 48									; sub 48 from ebx to make number


; a * 10^n-1 + b * 10^n-2 + c * 10^n-3 ... + x * 1

push		eax										; save eax
mul			ebx										; multiply the number with 10^n-1


add			edi, eax								; add the number with the number already calculated (at first it was 0)
inc			esi										; increment esi to move to next number


pop			eax										; restore eax


loop		L2


mov			ebx, [ebp+8]							; move offset of userData into ebx
mov			[ebx], edi								; move the calculated value in userData

jmp			theEnd




;when user input invalid data

inValid:
call		Crlf


myWriteString answer8								; let user know that the input is invalid

call		Crlf
call		Crlf
jmp			again


theEnd:



; restore registers that used

pop			esi
pop			edi
pop			edx
pop			ecx
pop			ebx
pop			eax
pop			ebp

ret			4


getData ENDP





;-----------------------------------------------------------------
;Procedure to calcualte combinations
;receives: value of n r and offset of result
;returns: the answer of the problem
;precondition: userInput is integer
;registers changed: ebp, ebx, ecx, edi
;------------------------------------------------------------------


combinations PROC

; set stack frame
push		ebp
mov			ebp, esp


; save registers 
push		eax
push		ebx
push		ecx
push		edx
push		edi


mov			ebx, [ebp+16]							; offet of result
mov			edi, [ebp+12]							; value n
mov			ecx, [ebp+8]							;value r


;get fatorial of n
push		1										
push		OFFSET f1								; answer of factorial of n
push		edi
call		factorial



;get fatorial of r
push		1
push		OFFSET f2								; answer of facotrial of r
push		ecx
call		factorial



mov			eax, edi								
sub			eax, ecx								; get n-r
mov			edi, eax	

cmp			edi, 0									; if n-r is 0 then don't need to get factorial
je			nofac	
jne			fac										


; when n-r = 0
nofac:

mov			f3, 1									; set f3 with 1
jmp			cal



;when n-r is not 0
; get fatorial of n-r
fac:
push		1
push		OFFSET f3								; answer of f3
push		edi
call		factorial
jmp			cal





; calculate n!/(r!(n-r)!)
cal:

mov			eax, f2
mul			f3										; r!(n-r)!


mov			ecx, eax
mov			eax, f1
xor			edx, edx								; empty edx to divide eax by ecx

div			ecx										; now n!/(r!(n-r)!)is in eax
	
mov			[ebx], eax								; put the value in the result



; restore registers
pop			edi
pop			edx
pop			ecx
pop			ebx
pop			eax
pop			ebp




ret			12
combinations ENDP





;----------------------------------------------------------------------------
;Recursive Procedure to calcualte factorial
;receives: value of n r and n-r and offset of results of factorial, f1 f2 f3
;returns: the answer of the factorials
;precondition: userInput is integer, n-r is not 0
;registers changed: ebp, ebx, ecx, edi
;----------------------------------------------------------------------------


factorial PROC

;set stack frame
push		ebp
mov			ebp, esp


;save registers
push		edi
push		ebx
push		ecx






mov			eax, [ebp+16]					;1
mov			ecx, [ebp+12]					; offset of result of factorial
mov			ebx, [ebp+8]					; number for do factorial

mul			ebx								; eax = n * n-1 ... 1

cmp			ebx, 1							; compare n and if it becomes 1 then quit
je			quit



;recursion that call the procedure again
recurse:

dec			ebx								; decrement ebx to make n -1, n-2, n-3 ... 1


; save registers to use again
push		eax
push		ecx
push		ebx


call		factorial						; recursive procedure


quit:

mov			[ecx], eax						; move the calculated answer into the reuslt



; restore registers
pop			ecx
pop			ebx
pop			edi
pop			ebp
ret			12


factorial ENDP





;----------------------------------------------------------------------------
;Procedure to show result
;receives: n, r, userData, result values
;returns: none
;precondition: none
;registers changed: ebp, eax
;----------------------------------------------------------------------------


showResults PROC


;set stack frame
push		ebp
mov			ebp, esp

;save register
push		eax




myWriteString answer1


mov			eax, [ebp+8]								; show answer
call		WriteDec


myWriteString answer2


mov			eax, [ebp+16]								;r
call		WriteDec


myWriteString answer3


mov			eax, [ebp+20]								; n
call		WriteDec


myWriteString answer4

mov			eax, [ebp+8]
cmp			eax, [ebp+12]								; compare answer and userData

je correct												; when the answer is correct
jne wrong												; when the asnwer is wrong



;when the answer is right
correct:

call		Crlf

myWriteString answer6									; let user know that answer is right

call		Crlf
jmp			theEnd



; when the answer is wrong
wrong:

call		Crlf

myWriteString answer5									; let user know that answer is wrong

call		Crlf
jmp			theEnd



theEnd:


; restore register

pop			eax
pop			ebp



ret			16
showResults ENDP






END main


