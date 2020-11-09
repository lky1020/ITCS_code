;BACS 1024 - Hardware to Hardware Communication
;Setting for Input Output
;Macros for keyboard interrupts or setting

;AH = scan_code
;AL = ASCII_code

;Check which key is pressed, and store the ascii code in AL
TransferKeyPress MACRO
    
	MOV AH,00H
	INT 16H
	
ENDM TransferKeyPress

;Check if a key is pressed or not (ZF = 0 is pressed, ZF = 1 is not pressed)
GetKeyPress MACRO
    
	MOV AH,01H
	INT 16H
	
ENDM GetKeyPress


GetKeyPressAndFlush MACRO
	LOCAL KeyNotPressed
	
	GetKeyPress
	JZ KeyNotPressed    ;no key presses
	
	TransferKeyPress    ;transfer the key pressed to store ascii code into AL 
	
	KeyNotPressed:
	
ENDM GetKeyPressAndFlush

;Clear Keyboard buffer
ClearKeyBuffer MACRO
	LOCAL Back, Return
	
	Back:
    	GetKeyPress
    	JZ Return
    	
    	TransferKeyPress
    	JMP Back
    	
	Return:
	
ENDM ClearKeyBuffer

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

