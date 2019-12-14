include irvine32.inc

.data
;put your static data
.code
;Write your functions here

;-----------------------------------------------------
;SumArr PROC Calculates Sum of an array
;Recieves: Offset and the size of an array
;Return: the sum of the array into the EAX
;------------------------------------------------------
SumArr PROC arr:PTR DWORD, sz:DWORD
	push esi
	push ecx

	mov esi, arr
	mov ecx, sz
	mov eax, 0
	sum_loop:
		add eax, DWORD PTR [esi]
		add esi, 4
	loop sum_loop
	
	pop ecx
	pop esi
	Ret
SumArr ENDP


DllMain PROC hInstance:DWORD, fdwReason:DWORD, lpReserved:DWORD 

mov eax, 1		; Return true to caller. 
ret 				
DllMain ENDP

END DllMain
