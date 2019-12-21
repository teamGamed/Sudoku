INCLUDE Irvine32.inc
.DATA
	
	; consts
	playerNameSize = 15
	boardSize = 81
	timeSize = 9

	; file vars 
	gamesFile 			byte "boards.txt",0
	tmpFile 			byte "tmp.txt",0
	filePaht			dword 0

	tmpfileHandle		dword 0
	fileHandle 			dword 0
	gameFileHandle		dword 0

	breakChar 			byte "/",0
	newLine				byte 13,10,0
	BytesRead 			dword 0


	; gamePlay vars 
	playerName 			dword 0
	board				dword 0
	time 				dword 0
	compTime 			dword 0
	
	CurPlayerName 		byte playerNameSize dup(' '),0
	CurBoard			byte boardSize dup('0'),0
	CurTime 			byte timeSize dup('0'),0
	tmpCur 				dword 1

	gamePlayerName 		byte playerNameSize dup(' '),0
	gameBoard			byte 80 dup('0') ,'9',0
	gameTime 			byte timeSize dup('0'),0
	

	; helpers vars
	dump 				byte 0
	selectedBoard 		dword 0
	timeB 				dword 0			; time when game begins
	timeE 				dword 0			; time when game ends
	ten   				dword 10
	eofInd				byte 0
	testBoard 			byte "123456789123456789123456789123456789123456789123456789123456789123456789123456789",0

	; str 
	dashesstr	 		byte "---------------------------------------------",0
	choseBoardIndexstr 	byte "enter the board indx ::",0
	NAMEstr 			byte "Player Name :: ",0
	TIMEstr 			byte "Time by sec :: ",0
	
.code

;-------------------------------
; get the playing time ( timeB is the time thet the game begins  , compTime is the total time for past games )
; fill time (string) with the full time ( cur game , and past games )
;-------------------------------
getTime proc uses eax ebx ecx edx edi esi
	call GetMseconds
	sub eax , timeB
	add eax , compTime  ; add tha past games time
	mov timeE , eax
	; convert timeE( int ) to time ( sring ) 
	mov esi , time 
	add esi , timeSize -1	; esi is the offset of the time dec
lp:
	mov edx , 0
	mov eax , timeE
	div ten
	add edx , '0'
	mov [esi] , dl
	dec esi
	cmp eax , 0
	je done
	mov timeE , eax
	jmp lp
done:
	ret
getTime ENDP
;---------------------------------------
;print '/' to the file
;---------------------------------------
break PROC  uses eax ebx ecx edx edi esi
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
readBreak PROC uses eax ebx ecx edx edi esi
	invoke readFile,
	fileHandle,
	offset dump,
	1,
	addr BytesRead,
	NULL
	ret
readBreak ENDP

;---------------------------------------
;print new line to the file
;---------------------------------------
line PROC  uses eax ebx ecx edx edi esi
	invoke WriteFile,
	fileHandle,
	offset newLine,
	2,
	NULL,
	NULL
	ret
line ENDP
;---------------------------------------
;read new line from the file
;---------------------------------------
readline PROC uses eax ebx ecx edx edi esi
	invoke readFile,
	fileHandle,
	offset dump,
	2,
	addr BytesRead,
	NULL
	ret
readline ENDP

;------------------------------------
; eax		--> index of the board 
; show the saved games from boards.txt to the console
;------------------------------------
showSavedGames PROC uses eax ebx ecx edx edi esi
	mov filePaht , offset gamesFile
	call openReadFile
	mov eax , fileHandle 
	mov gameFileHandle , eax
	
	; load the boards one by one
	mov edi , 0
read:
	inc edi
	call getGamefromFile
	; check if you reash the eof
	cmp eofInd , 1
	je eof

	; print the game info to console ( indx )
	mov eax , '0'
	add eax , edi
	call writeChar 
	mov al , '-'
	call writeChar 
	call crlf
	call printGame 

	jmp read
	
eof:
	call closeFiles
	ret
showSavedGames ENDP
;
;	clear the ( gamePlayerName ) => set it to ' '
;
clearPlayerName PROC uses eax ebx ecx edx edi esi
	mov ecx , playerNameSize
	mov edi , playerName
	mov al , ' '
	rep stosb
	ret
clearPlayerName ENDP
;
;	complete gamePlayerName with ' '
;
compPlayerName PROC uses eax ebx ecx edx edi esi
	mov ecx , playerNameSize
	mov edx , playerName
	call strLength
	sub ecx , eax
	cmp ecx , 0
	je done
	mov edi , playerName
	add edi , eax
	mov al , ' '
	rep stosb
done:
	ret
compPlayerName ENDP
;	inputs : fileHandle  
;	outputs : write the string ( offset playerName)
readNameFromFile PROC uses eax ebx ecx edx edi esi 
	; clear the string
	call clearPlayerName
	; read to playerName
	invoke readFile,
	fileHandle,
	PlayerName,
	playerNameSize,
	addr BytesRead,
	NULL
	
	; check the eof
	cmp BytesRead , playerNameSize
	jne eof
	
	call compPlayerName

done:
	mov eofInd , 0
	ret
eof:
	mov eofInd , 1
	ret
readNameFromFile ENDP
;	inputs : fileHandle , playerName
WriteNameToFile PROC uses eax ebx ecx edx edi esi
	invoke WriteFile,
	fileHandle,
	PlayerName,
	playerNameSize,
	NULL,
	NULL
	ret
WriteNameToFile ENDP
;	inputs : fileHandle , playerName
WriteBoardToFile PROC uses eax ebx ecx edx edi esi
	invoke WriteFile,
	fileHandle,
	board,
	boardSize,
	NULL,
	NULL
	ret
WriteBoardToFile ENDP 
;	inputs : fileHandle
;	outputs : write the string ( offset board)
ReadBoardFromFile PROC uses eax ebx ecx edx edi esi
	invoke readFile,
	fileHandle,
	board,
	boardSize,
	addr BytesRead,
	NULL
	ret
ReadBoardFromFile ENDP 
;	inputs : fileHandle
;	outputs : write the string ( offset Time)
WriteTimeToFile PROC uses eax ebx ecx edx edi esi
	invoke WriteFile,
	fileHandle,
	Time,
	TimeSize,
	NULL,
	NULL
	ret
WriteTimeToFile ENDP 
;	inputs : fileHandle
;	outputs : write the string ( offset Time)
ReadTimeFromFile PROC uses eax ebx ecx edx edi esi
	invoke readFile,
	fileHandle,
	Time,
	TimeSize,
	addr BytesRead,
	NULL
	ret
ReadTimeFromFile ENDP
;
;	open the file for write
;
openFile PROC uses eax ebx ecx edx edi esi
	invoke CreateFile,
	filePaht,
	GENERIC_READ + GENERIC_WRITE,
	DO_NOT_SHARE,
	NULL,
	OPEN_ALWAYS,
	FILE_ATTRIBUTE_NORMAL,
	0
	mov fileHandle , eax
	invoke setFilePointer,
	fileHandle,
	0,
	0,
	FILE_END
	ret
openFile ENDP
;
;	open the file for raed
;
openReadFile PROC uses eax ebx ecx edx edi esi
	invoke CreateFile,
	filePaht,
	GENERIC_READ + GENERIC_WRITE,
	DO_NOT_SHARE,
	NULL,
	OPEN_ALWAYS,
	FILE_ATTRIBUTE_NORMAL,
	0
	mov fileHandle , eax
	invoke setFilePointer,
	fileHandle,
	0,
	0,
	FILE_BEGIN
	ret
openReadFile ENDP
;
;	open the file and clear the contest
;
clearOpenFile PROC uses eax ebx ecx edx edi esi
	invoke CreateFile,
	filePaht,
	GENERIC_READ + GENERIC_WRITE,
	DO_NOT_SHARE,
	NULL,
	CREATE_ALWAYS,
	FILE_ATTRIBUTE_NORMAL,
	0
	mov fileHandle , eax
	invoke setFilePointer,
	fileHandle,
	0,
	0,
	FILE_END
	ret
ClearOpenFile ENDP
;
;	close the file handle
;
closeFiles PROC uses eax ebx ecx edx edi esi
	invoke closeHandle,
	fileHandle
	ret
closeFiles ENDP
;
; add the Game To Games File
;
saveGame PROC uses eax ebx ecx edx edi esi 
	mov filePaht, offset gamesFile
	mov playerName, offset CurPlayerName
	mov board , offset CurBoard
	mov time , offset CurTime
	call getTime
	call openFile
	call addGameToFile
	call closeFiles
	ret
saveGame ENDP
;
;	save a gameVars into the file
;
addGameToFile PROC uses eax ebx ecx edx edi esi
	call WriteNameToFile
	call break
	call WriteBoardToFile
	call break
	;call getTime
	call WriteTimeToFile
	call line
	ret
addGameToFile ENDP
;
;	load a game form the file into the gameVars
;
getGamefromFile PROC uses eax ebx ecx edx edi esi
	call readNameFromFile
	cmp eofInd , 1
	je done
	call readbreak
	call ReadBoardFromFile
	call readbreak
	call ReadTimeFromFile
	call line
done:
	ret
getGamefromFile ENDP
;
;	remove selected game from file and copy the rest to tmp.txt
;
copyGameToTmp PROC uses eax ebx ecx edx edi esi
	mov filePaht , offset tmpfile
	call clearOpenFile
	mov eax , fileHandle
	mov tmpfileHandle , eax
	mov filePaht , offset gamesFile
	call openReadFile
	mov eax , fileHandle
	mov gameFileHandle , eax
	mov playerName , offset gamePlayerName
	mov board , offset gameBoard
	mov time , offset gameTime
	mov edi , 0
read:
	inc edi
	mov eax , gameFileHandle
	mov fileHandle , eax
	call getGamefromFile
	

	cmp eofInd , 1
	je done
	cmp edi , selectedBoard
	je load
	mov eax , tmpFileHandle
	mov fileHandle , eax
	call addGameToFile

	jmp read
done:
	mov eax , gameFileHandle
	mov fileHandle , eax
	call closeFiles

	mov eax , tmpFileHandle
	mov fileHandle , eax
	call closeFiles
	
	ret
load:
	call loadGameIntoCur
	jmp read
copyGameToTmp ENDP
;
;	fill (gameVars) and gamePlayerName form the console
;
fillGameFromConsole PROC uses eax ebx ecx edx edi esi
	mov edx , offset NAMEstr
	call writeString

	mov playerName , offset gamePlayerName
	call clearPlayerName
	mov edx , offset gamePlayerName
	mov ecx , playerNameSize
	call readString
	call compPlayerName

	mov ecx , boardSize
	mov esi , offset testBoard
	mov edi , offset gameBoard
	rep movsb
	ret
fillGameFromConsole ENDP
;
;	print the game info to the console
;
printGame PROC uses eax ebx ecx edx edi esi
	mov edx , offset NAMEstr
	call writeString

	mov edx , playerName
	call writeString

	call crlf
	
	mov edx , offset TIMEstr
	call writeString

	mov edx , time
	call writeString
	call crlf
	ret
printGame ENDP
;
;	select a game from savd games and load it 
;
ContinueGame PROC uses eax ebx ecx edx edi esi
	mov playerName , offset gamePlayerName
	mov board , offset gameBoard 
	mov time , offset gameTime
	call crlf
	call showSavedGames
	call crlf 
	call readDec
	mov selectedBoard , eax
	call copyGameToTmp
	call copyTmpToGame
	mov playerName , offset CurPlayerName
	mov board , offset CurBoard 
	mov time , offset CurTime
	
	call printGame
	call crlf
	ret
ContinueGame ENDP
;
;	copy all the games in the tmp.txt to games.txt
;
copyTmpToGame  PROC uses eax ebx ecx edx edi esi
	mov filePaht , offset gamesFile
	call clearOpenFile
	mov eax , fileHandle
	mov gamefileHandle , eax
	mov filePaht , offset tmpFile
	call openReadFile
	mov eax , fileHandle
	mov tmpFileHandle , eax
	mov playerName , offset gamePlayerName
	mov board , offset gameBoard
	mov time , offset gameTime
read:
	mov eax , tmpFileHandle
	mov fileHandle , eax
	call getGamefromFile

	cmp eofInd , 1
	je done
	
	mov eax , gameFileHandle
	mov fileHandle , eax
	call addGameToFile

	jmp read
done:
	mov eax , gameFileHandle
	mov fileHandle , eax
	call closeFiles

	mov eax , tmpFileHandle
	mov fileHandle , eax
	call closeFiles
	
	ret
copyTmpToGame ENDP

;
; load the selected game and start the timer
;
loadGameIntoCur PROC uses eax ebx ecx edx edi esi
	mov esi , offset gamePlayerName
	mov edi , offset CurPlayerName
	mov ecx , playerNameSize
	rep movsb

	mov esi , offset gameBoard
	mov edi , offset CurBoard
	mov ecx , boardSize
	rep movsb
	
	mov esi , offset gameTime
	mov edi , offset CurTime
	mov ecx , TimeSize
	rep movsb

	call GetMseconds
	mov TimeB , eax
	ret
loadGameIntoCur ENDP

main PROC
; 	mov ecx , 3
; lp :
; 	call fillGameFromConsole
; 	call loadGameIntoCur
; 	call saveGame
; 	loop lp
; 	; call addGameToGamesFile
; 	; call copyGameToTmp
; 	; call fillGameFromConsole
; 	; call saveGame
; 	; call copyGameToTmp
	; call copyGameToTmp
	call ContinueGame
	mov eax , 1000
	call delay
	call saveGame
	exit
main ENDP
END main