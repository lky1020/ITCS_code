                                ;Game Module - BACS 1024 (Advance Feature)
;================================================================================================
                                    ;START OF GAME MODULE
;================================================================================================
;Includes (Include the outside file for calling the variables or functions)
INCLUDE code\Consts.asm
INCLUDE code\Graphics.asm
INCLUDE code\Keyboard.asm
INCLUDE code\Port.asm


;Public variables and procedures
PUBLIC ReadyToGame

;External variables and procedures
EXTRN UserName1:BYTE

.MODEL SMALL
.STACK 256
.DATA 

;Game Logo
;=======================
GameLogoX				EQU		12
GameLogoY				EQU		5
GameLogoWidth			EQU		57
GameLogoHeight			EQU		7
GameLogoColor			EQU		4EH
GameTitleChar			EQU		4H
GameMsgStartAtMarginX	EQU		GameLogoX
GameMsgStartAtMarginY	EQU		GameLogoY + GameLogoHeight + 1
;====================================================================================

;Game Message and String
;=======================
GameWel				DB	'Welcome to Our Game: $'
GameOptMenu			DB	'Please Choose an Option to Play Game: $'
GameMenu1			DB	'[F1] Balloon Shooting Game $'
GameMenu2			DB	'[ESC] To Exit Game $'
ContinueMsg			DB	'Press [SPACE] to Continue... $'


;Game Variable
;=============
Selection		DB	?
Space 			db ' ', '$'	
TutMsg			db  "		           TUTORIAL             ", 0ah,0dh
				db  "			  1)USE LEFT AND RIGHT TO MOVE  ", 0ah,0dh
				db  "			  2)PRESS SPACEBAR TO SHOOT     ", 0ah,0dh
				db  "			  3)PRESS 'Q' TO EXIT		  $"
Score 			dw 0
Arrow 			db 9
P_Score 		db "Score: $"
P_Arrow 		db "Arrow: $"
SaveChar 		db ?
G_Arrow 		db '^', '$'
Shoot			db '|', '$'
setCursor		dw 0
setCursorArrow 	dw 0
checkCursor		dw 0

;Generate Balloon Template
;=========================
ballCursor 		dw 0
balloon 		db "   0    *    0    o    0    *   0",'$'
balloon1		db "     0    o    0    *    0    o", '$'
balloon2		db "        0    o    0    o    0", '$'
balloon3		db "          0    o    0    o", '$'
balloon4		db "            0    o    0", '$'
balloon5		db "              0     o", '$'
balloon6		db "                 0", '$'
boxCursor 		dw 0
;===============================================================================================
										;Game Module
;===============================================================================================
.code
;===============================================================================================
								;Game Proc for main to call
;===============================================================================================
ReadyToGame PROC FAR

	Start: 
		;Initialize the Game Screen Before Start
		call GameMenuScreen

		;Loop for user input
		Loop_In_Game:
	
			GetKeyPressAndFlush
			JZ	Loop_In_Game

			MOV Selection, ah

			Check_F1:
				CMP		Selection, F1_ScanCode
				JNE		Check_ESC
				CALL 	BalloonMenu
				JMP		Start
			;===============================================================================================
			Check_ESC:
				CMP Selection, ESC_ScanCode
				JNE Error
				JMP Return
			;===============================================================================================

			Error:
				MOV AH, 11
				MOV AL, 40
				CALL GenerateSound
				MOV AX,0
				JMP Start

	Return:
	RET
ReadyToGame ENDP
;===============================================================================================
					;Game Screen (Message to display on Game Screen)
;===============================================================================================
GameMenuScreen PROC
	
	;Draw the Page Logo before Start
	CALL DrawGameLogo

	;Print Username for information
	SetCursorPos GameMsgStartAtMarginX, GameMsgStartAtMarginY, CurrentPage
    DisplayStr GameWel
    DisplayStr UserName1

    ;Print message
	SetCursorPos GameMsgStartAtMarginX, GameMsgStartAtMarginY+1, CurrentPage
	DisplayStr GameOptMenu	
	SetCursorPos GameMsgStartAtMarginX, GameMsgStartAtMarginY+3, CurrentPage
	DisplayStr GameMenu1
	SetCursorPos GameMsgStartAtMarginX, GameMsgStartAtMarginY+4, CurrentPage
	DisplayStr GameMenu2
    
    ;Hide Cursor
	SetCursorPos WindowWidth, WindowHeight, 0
	
    RET 
GameMenuScreen ENDP

;===============================================================================================
										;Draw Game Logo
;===============================================================================================
DrawGameLogo PROC
	
		;Clear Screen
		ClearScreen 0,0,WindowWidth,WindowHeight

		;Set the Colour Box Size
		DrawLine GameLogoX, GameLogoY, GameLogoHeight, GameLogoWidth, ' ', GameLogoColor, CurrentPage

		;===============================================================================================
													;G
		;===============================================================================================
		;G logo 'upper -'
			SetCursorPos GameLogoX+14, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+15, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+16, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+17, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+18, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+19, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+20, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar

		;G logo 'left |'
			SetCursorPos GameLogoX+14, GameLogoY+1, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+14, GameLogoY+2, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+14, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+14, GameLogoY+4, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+14, GameLogoY+5, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+14, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar

		;G logo 'lower _'
			SetCursorPos GameLogoX+15, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+16, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+17, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+18, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+19, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+20, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar

		;G logo 'right |'
			SetCursorPos GameLogoX+20, GameLogoY+5, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+20, GameLogoY+4, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+20, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar

		;G logo 'middle -'
			SetCursorPos GameLogoX+19, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+18, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+17, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar

			;A logo 'Upper -'
			SetCursorPos GameLogoX+22, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+23, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+24, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+25, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+26, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+27, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+28, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar

		;===============================================================================================
													;A
		;===============================================================================================
		;A logo 'left |'
			SetCursorPos GameLogoX+22, GameLogoY+1, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+22, GameLogoY+2, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+22, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+22, GameLogoY+4, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+22, GameLogoY+5, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+22, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar

		;A logo 'right |'
			SetCursorPos GameLogoX+28, GameLogoY+1, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+28, GameLogoY+2, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+28, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+28, GameLogoY+4, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+28, GameLogoY+5, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+28, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar

		;A logo 'middle -'
			SetCursorPos GameLogoX+23, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+24, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+25, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+26, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+27, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+28, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar

		;===============================================================================================
													;M
		;===============================================================================================
		;M logo 'Left |'
			SetCursorPos GameLogoX+30, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+30, GameLogoY+1, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+30, GameLogoY+2, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+30, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+30, GameLogoY+4, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+30, GameLogoY+5, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+30, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar

		;M logo 'upper -'
			SetCursorPos GameLogoX+31, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+32, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+34, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+35, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar

		;M logo 'short left |'
			SetCursorPos GameLogoX+32, GameLogoY+1, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+32, GameLogoY+2, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+32, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar

		;M logo 'short right |'
			SetCursorPos GameLogoX+34, GameLogoY+1, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+34, GameLogoY+2, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+34, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar

		;M logo 'middle -'
			SetCursorPos GameLogoX+33, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar

		;M logo 'Right |'
			SetCursorPos GameLogoX+36, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+36, GameLogoY+1, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+36, GameLogoY+2, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+36, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+36, GameLogoY+4, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+36, GameLogoY+5, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+36, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar

		;===============================================================================================
													;E
		;===============================================================================================
		;E logo 'Left |'
			SetCursorPos GameLogoX+38, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+38, GameLogoY+1, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+38, GameLogoY+2, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+38, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+38, GameLogoY+4, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+38, GameLogoY+5, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+38, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar

		;E logo 'upper -'
			SetCursorPos GameLogoX+39, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+40, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+41, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+42, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+43, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+44, GameLogoY, CurrentPage
			DisplayChar	GameTitleChar
			
		;E logo 'middle -'
			SetCursorPos GameLogoX+39, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+40, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+41, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+42, GameLogoY+3, CurrentPage
			DisplayChar	GameTitleChar

		;E logo 'lower-'
			SetCursorPos GameLogoX+39, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+40, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+41, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+42, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+43, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
			SetCursorPos GameLogoX+44, GameLogoY+6, CurrentPage
			DisplayChar	GameTitleChar
	RET
DrawGameLogo ENDP

;===============================================================================================
									;Generate Sound Proc
;===============================================================================================
GenerateSound PROC
	sound:
		MOV     AL, 182         ; Prepare the speaker for the note.
		OUT     43H, AL         ; Output
		;MOV     AX, ...        ; Frequency number (in decimal) already pass the value into AX before calling 
                                
		OUT     42h, AL         ; Output low byte.
		MOV     AL, AH          ; Output high byte.
		OUT     42H, AL 
		IN      AL, 61H         ; Turn on note (get value from port 61H)

		OR      AL, 00000011B   ; Set bits 1 and 0.
		OUT     61H, AL         ; Send new value.
		MOV     BX, 4			; Pause for duration of note.

	.pause1:
		MOV     CX, 65535

	.pause2:
		DEC     CX
		JNE     .pause2
		DEC     BX
		JNE     .pause1
		IN      AL, 61H         ; Turn off note (get value from port 61h).
                                
		AND     AL, 11111100B   ; Reset bits 1 and 0.
		OUT     61H, AL         ; Send new value
		
		RET
GenerateSound ENDP
;===============================================================================================
								;Balloon Menu (Tutorial for user)
;===============================================================================================
BalloonSubMenu PROC
		;Clear Screen
		ClearScreen 0,0,WindowWidth,WindowHeight

		DrawLine GameLogoX, GameLogoY, GameLogoHeight, GameLogoWidth, ' ', GameLogoColor, CurrentPage

		SetCursorPos GameLogoX, GameLogoY+2, CurrentPage
		DisplayStr TutMsg

		SetCursorPos GameMsgStartAtMarginX, GameMsgStartAtMarginY+5, CurrentPage
		DisplayStr ContinueMsg
    RET 
BalloonSubMenu ENDP

;===============================================================================================
								;Start of Balloon Game
;===============================================================================================
BalloonMenu proc
	
	JMP Loop_In_BalloonMenu

	Err_Loop_In_BalloonMenu:
		MOV AH, 11
		MOV AL, 40

		CALL	GenerateSound
	
		MOV AX,0
		Loop_In_BalloonMenu:
			CALL BalloonSubMenu
			MOV AH, 01H
			INT 21H

			CMP AL,' '
			JNE Err_Loop_In_BalloonMenu

	Normal:
		;Initialize the Variable used 
		MOV 	Score, 0
	
		;Initialize the Register
		MOV 	AX, 0
		MOV 	BX, 0
		MOV 	CX, 0
		MOV 	DX, 0
	
		;Initialize the Screen Colour 
		MOV 	AX, 0600H
		MOV 	BH, 09H
		MOV 	CX, 0000H
		MOV 	DX, 184FH
		INT 	10H

		;Set Position for the '-'
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 1513H
		INT 	10H

		;Store cursor position
		MOV 	boxCursor, DX

		;Loop '-'
		MOV 	CX, 37
		BOX:
			MOV 	DL, '-'
			MOV 	AH, 02H
			INT 	21H
		Loop BOX
	
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 0013H
		INT 	10H

		;Store cursor position
		MOV 	boxCursor, DX
	
		;Loop '|'
		MOV 	CX, 21
		BOX1:	
			MOV 	AH, 02H
			MOV 	BH, 0
			MOV 	DX, boxCursor
			INC 	DH
			INT 	10H
			MOV 	boxCursor, DX	
	
			MOV 	DL, '|'
			MOV 	AH, 02H
			INT 	21H
		Loop BOX1
	
		;Initialize Cursor Position ;004DH
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 0038H
		INT 	10H

		;Store cursor position
		MOV 	boxCursor, DX
	
		MOV 	CX, 21
		BOX2:	
			MOV 	AH, 02H
			MOV 	BH, 0
			MOV 	DX, boxCursor
			INC 	DH
			INT 	10H
			MOV 	boxCursor, DX	
	
			MOV 	DL, '|'
			MOV 	AH, 02H
			INT 	21H
		Loop 	BOX2

;================================================================================================
								;Balloon Game Template Display
;================================================================================================
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 0314H
		INC 	DH
		INT 	10H
	
		DisplayStr balloon
	
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 0414H
		INC 	DH
		INT 	10H
	
		DisplayStr balloon1
		
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 0514H
		INC 	DH
		INT 	10H
		
		DisplayStr balloon2

		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 0614H
		INC 	DH
		INT 	10H
		
		DisplayStr balloon3
		
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 0714H
		INC 	DH
		INT 	10H
		
		DisplayStr balloon4
		
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 0814H
		INC 	DH
		INT 	10H
		
		DisplayStr balloon5
		
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 0914H
		INC 	DH
		INT 	10H
		
		DisplayStr balloon6
		
;================================================================================================
								;Display Lower Part Template
;================================================================================================

		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 1714H
		INT 	10H
		
		DisplayStr P_Score
		
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 1729H
		INT 	10H
		
		DisplayStr P_Arrow

		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 1427H
		INT 	10H

		;Store cursor position
		MOV 	setCursor, DX  ; 184f
		
		DisplayStr G_Arrow

	KeyboardInput:
		
		;Initialize the Register
		MOV 	AX, 0
		MOV 	BX, 0
		MOV 	CX, 0
		MOV 	DX, 0
	
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 1730H
		INT 	10H
	
		MOV 	DX, 0
		MOV 	DL, 0
		
		MOV 	AH, 02H
		MOV 	DL, Arrow
		ADD 	DL, 30h
		INT 	21H
		
		;Initialize Cursor Position
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, 171AH
		INT 	10H


		;Display and Calculate Score (2 digits)
		MOV 	AX, Score
	
		MOV		CL,10		;store 10 into CL
		DIV		CL			;divide AL(result) by 10 
		MOV		CH,AH		;AH is remainder
		MOV		CL,AL		;result
	
		ADD		CL,30H		;add BL with 30 to change it to hexa
		MOV		DL,CL		;set DL as AL (result)
		MOV		AH,02H		;print a char 
		INT		21H			;display char
	
		ADD		CH,30H		;add BL with 30 to change it to hexa
		MOV		DL,CH		;set DL as AL (result)
		MOV		AH,02H		;print a char 
		INT		21H			;display char
		
		MOV 	AH, 0
		MOV 	AL, 0
		
		;Read Character without echo
		MOV 	AH, 08H
		INT 	21H
		
		CMP 	setCursor, 1414H
		JG  	inputA
		CMP 	setCursor, 144FH
		JL 		inputD
		JMP 	inputQ
	
	inputA:	
		CMP 	AL, 4BH
		JNE 	inputD
		
		;Replace the Arrow with Space
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, setCursor   ;184e
		INT 	10H
		
		DisplayStr Space
	
		;Print a new Arrow  at the cursor position
		MOV 	CX, setCursor
		SUB 	setCursor, 1H
		SUB 	CL, 1H
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, CX
		INT 	10H
		
		DisplayStr G_Arrow

		JMP 	KeyboardInput

	checkScore1:
		MOV 	Arrow, 9
		JMP 	quit
	
	inputD:
		CMP 	setCursor, 1438H
		JE		quit1

		CMP 	AL, 4DH
		JNE 	inputSpace
		
		MOV 	AH, 02h
		MOV 	BH, 0
		MOV 	DX, setCursor   ;184F
		INT 	10H

		DisplayStr Space
		
		MOV 	CX, setCursor
		ADD 	setCursor, 1H
		ADD 	CL, 1H
		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, CX
		INT 	10H

		DisplayStr G_Arrow
		
		JMP 	KeyboardInput

	quit1:
		JMP 	quit

	inputSpace:
		CMP 	al, ' '
		JNE 	inputQ
		CMP 	Arrow, 0
		JE 		checkScore1
		SUB 	Arrow, 1H
		
		MOV AH, 91
		MOV AL, 21
		CALL	GenerateSound

		MOV AX,0

		MOV 	CX, setCursor
		MOV 	setCursorArrow, CX
		
	loopSpace:
		MOV 	CX, setCursorArrow	 ; 18++
		SUB 	CH, 1h ; 17++
		MOV 	setCursorArrow, CX   ; 17++

		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, setCursorArrow	;setCursorArrow 17++h
		INT 	10H
		
		;Read the character at the cursor position ;BH is = page number
		MOV 	AH, 08H
		MOV 	BH, 00
		INT 	10H

		MOV 	AH, 02H
		MOV 	BH, 0
		MOV 	DX, setCursorArrow   ;setCursorArrow 17++h
		INT 	10H

		MOV 	SaveChar, al
		
		;DI will be the speed or second of displaying the shoot
		MOV 	DI, 1
		MOV 	AH, 0

		;To get the system time
		INT 	1AH
		MOV 	BX, DX
		
		MOV 	AH , 09H
		LEA 	DX, Shoot
		INT 	21h
		JMP 	Delay

	inputQ:
		CMP 	AL, 'q'
		JE 		quit
		JMP 	KeyboardInput

	Delay:
		MOV 	AH, 0
		INT 	1Ah			;Get system time
		SUB 	DX, BX		;Value of BX assign in line 814 System time when call
		CMP 	DI, DX
		JA 		Delay
	
		MOV 	CX, setCursorArrow
		MOV 	AH, 02h
		MOV 	BH, 0
		MOV 	DX, CX
		INT 	10H
		
		DisplayStr Space
		
	
		CMP 	SaveChar, '0'
		JE 		check0
		CMP 	SaveChar, 'o'
		JE 		checko
		CMP 	SaveChar, '*'
		JE 		checkAst
	
		CMP 	CH, 02H
		JE 		inputQ
		JMP 	loopSpace

	quit:
		JMP 	Back

	checkAst:
		ADD 	Arrow, 1
		JMP 	keyboardInput

	checko:
		ADD 	Score , 2
		JMP 	inputQ

	check0:
		ADD 	Score , 1
		JMP 	inputQ
	
	Back:
		RET
BalloonMenu ENDP

END
