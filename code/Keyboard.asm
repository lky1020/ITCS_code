;BACS 1024 - Hardware to Hardware Communication
;Setting for Input Output
;Macros for keyboard interrupts or setting

;AH = scan_code
;AL = ASCII_code

WaitKeyEnter MACRO
	MOV AH,00H
	INT 16H
ENDM WaitKeyEnter

GetKeyEnter MACRO
	MOV AH,01H
	INT 16H
ENDM GetKeyEnter

GetKeyEnterAndFlush MACRO
	LOCAL KeyNotPressed
	GetKeyEnter
	JZ KeyNotPressed
	WaitKeyEnter
	KeyNotPressed:
ENDM GetKeyEnterAndFlush

ClearKeyQueue MACRO
	LOCAL Back, Return
	Back:
	GetKeyEnter
	JZ Return
	WaitKeyEnter
	JMP Back
	Return:
ENDM ClearKeyQueue

;Display Character
DisplayChar MACRO InChar
	MOV AH,02H
	MOV DL,InChar
	INT 21H
ENDM DisplayChar

;Read Character
ReadChar MACRO InChar
	MOV AH,07H
	INT 21H
	MOV InChar,AL
ENDM ReadChar

;Display String
DisplayStr MACRO InStr
	MOV AH,09H
	MOV DX, OFFSET InStr
	INT 21H
ENDM DisplayStr

;Read String
ReadStr MACRO InStr
	MOV AH,0AH
	MOV DX,OFFSET InStr
	INT 21H
ENDM ReadStr

