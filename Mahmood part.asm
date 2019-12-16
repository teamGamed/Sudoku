INCLUDE Irvine32.inc
.DATA
	
	; consts
	playerNameSize = 15
	boardSize = 81
	timeSize = 5

	; file vars 
	filePath byte "boards.txt",0
	breakChar byte "/",0
	endline byte 13 , 10
	fileHandle dword 0
	BytesRead dword 0

	; gamePlay vars 
	playerName byte 15 dup(' '),0
	board byte 81 dup('0'),0
	time byte "00:00",0
	
	; helpers vars
	dump byte 0
	selectedBoard Dword 0


	; str 
	dashesstr byte "---------------------------------------------",0
	choseBoardIndexstr byte "enter the board indx ::",0
	NAMEstr byte "Player Name :: ",0
	TIMEstr byte "Time by sec :: ",0
	
.code
;---------------------------------------
;print '/' to the file
;---------------------------------------
break PROC 
	invoke WriteFile,
	fileHandle,
	offset breakChar,
	1,
	NULL,
	NULL
	ret
break ENDP
;---------------------------------------
;read '/' from the file
;---------------------------------------
readBreak PROC
	invoke readFile,
	fileHandle,
	offset dump,
	1,
	offset BytesRead,
	NULL
	ret
readBreak ENDP
;--------------------------------------------- 
; add a game ( player name , time , board ) to the boards file 
;---------------------------------------------
saveGame proc
	; open boards file 
	invoke CreateFile,
	offset filePath,
	GENERIC_READ + GENERIC_WRITE,
	DO_NOT_SHARE,
	NULL,
	OPEN_ALWAYS,
	FILE_ATTRIBUTE_NORMAL,
	0
	mov fileHandle , eax
	; set pointer to the end of the file
	invoke setFilePointer,
	fileHandle,
	0,
	0,
	FILE_END
	; write the player name 
	invoke WriteFile,
	fileHandle,
	offset playerName,
	playerNameSize,
	NULL,
	NULL
	
	call break
	; write the board
	invoke WriteFile,
	fileHandle,
	offset board,
	boardSize,
	NULL,
	NULL
	
	call break
	; write the time
	invoke WriteFile,
	fileHandle,
	offset time,
	timeSize,
	NULL,
	NULL

	call break
	; close the handle
	invoke closeHandle,
	fileHandle
	
	ret
saveGame endp

;------------------------------------
; eax		--> index of the board 
; show the saved games from boards.txt to the console
;------------------------------------
showSavedGames PROC
	; open boards file
	invoke CreateFile,
	offset filePath,
	GENERIC_READ + GENERIC_WRITE,
	DO_NOT_SHARE,
	NULL,
	OPEN_ALWAYS,
	FILE_ATTRIBUTE_NORMAL,
	0
	mov fileHandle , eax

	; move the pointer to the begain 
	invoke setFilePointer,
	fileHandle,
	0,
	0,
	FILE_BEGIN
	; load the boards one by one
	mov edi , 1
read:
	; read the name 
	invoke readFile,
	fileHandle,
	offset playerName,
	playerNameSize,
	offset BytesRead,
	NULL
	; check if you reash the eof
	cmp BytesRead , playerNameSize
	jne eof

	; print the game info to console ( indx )
	mov eax , '0'
	add eax , edi
	call writeChar 
	mov al , ' '
	call writeChar 
	call crlf
	; print the game info to console ( name )
	mov edx , offset NAMEstr
	call writeString
	mov edx , offset playerName 
	call writeString 
	call crlf

	call readBreak
	;read the baord
	invoke readFile,
	fileHandle,
	offset board,
	boardSize,
	offset BytesRead,
	NULL
	
	call readBreak
	;read the time 
	invoke readFile,
	fileHandle,
	offset time,
	timeSize,
	offset BytesRead,
	NULL

	call readBreak
	; print the game info to console ( time )
	mov edx , offset TIMEstr
	call writeString
	mov edx , offset time
	call writeString
	call crlf
	inc edi
	jmp read
eof:
	invoke closeHandle,
	fileHandle
	ret
showSavedGames ENDP
;-------------------------------------
; requirements :: selectedBoard load the indx of the board
; load the game ( player name , time , board )
;-------------------------------------
getGameByIndx PROC
	; open boards file
	invoke CreateFile,
	offset filePath,
	GENERIC_READ + GENERIC_WRITE,
	DO_NOT_SHARE,
	NULL,
	OPEN_ALWAYS,
	FILE_ATTRIBUTE_NORMAL,
	0
	mov fileHandle , eax

	; move the pointer to the begain 
	invoke setFilePointer,
	fileHandle,
	0,
	0,
	FILE_BEGIN
	; load the boards one by one
	mov edi , 1
read:
	; read the name 
	invoke readFile,
	fileHandle,
	offset playerName,
	playerNameSize,
	offset BytesRead,
	NULL
	; check if you reash the eof
	cmp BytesRead , playerNameSize
	jne eof

	call readBreak
	;read the baord
	invoke readFile,
	fileHandle,
	offset board,
	boardSize,
	offset BytesRead,
	NULL
	
	call readBreak
	;read the time 
	invoke readFile,
	fileHandle,
	offset time,
	timeSize,
	offset BytesRead,
	NULL

	call readBreak
	cmp edi , selectedBoard
	je done
	inc edi
	jmp read	
eof:
	;mov edx , offset error
	;call writeString
	;call crlf
done:
	invoke closeHandle,
	fileHandle
	ret	
getGameByIndx ENDP

main PROC
	call showSavedGames
	mov edx , offset dashesstr
	call writeString
	call crlf
	mov edx , offset choseBoardIndexstr
	call writeString
	call readint
	mov selectedBoard , eax
	call getGameByIndx
	mov edx , offset NAMEstr
	call writeString
	mov edx , offset playerName
	call writeString
	call crlf
	mov edx , offset TIMEstr
	call writeString
	mov edx , offset time
	call writeString
	
	exit
main ENDP
END main