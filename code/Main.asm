;BACS 1024 - Hardware to Hardware Communication (Main)
;procedure to carry out for input process
InputProcessing MACRO Char, User
	LOCAL Chat_Checking, Chatting_Start, Quit_Checking, Quit, Reset, Return

	;Check F1 input
	Chat_Checking:
	CMP Char, F1_ScanCode
	JNE Quit_Checking

	MOV AL, ChatInvitation
	OR AL, User
	CMP AL, 3					;Only equals 3 when other user accept the invitation
	JE	Chatting_Start

	MOV ChatInvitation, User
	CALL SelectionScreen
	RET

	Chatting_Start:
	CALL ReadyToChat
	MOV ChatInvitation, 0
	CALL SelectionScreen
	RET
	;========================

	;Check ESC input
	Quit_Checking:
	CMP Char, ESC_ScanCode
	JNE Return					;Go to end of this macro

	MOV AL,User
	CMP AL,1
	JNE Reset

	Quit:						;Back to the system
	MOV AX, 4C00H
	INT 21H
	RET

	Reset:
	MOV ChatInvitation, 0
	MOV MainReceivedChar, 0
	CALL WaitOtherUser
	CALL SelectionScreen
	;==================================

	Return:
ENDM InputProcessing


;Includes
INCLUDE code\Consts.asm             ;testing
INCLUDE code\Graphics.asm
INCLUDE code\Keyboard.asm
INCLUDE code\Port.asm

;Public variables
PUBLIC UserNameSize1, UserName1
PUBLIC UserNameSize2, UserName2

;External variables
EXTRN ReadyToChat: FAR
;======================================================================================
								;Start of Main Module
;======================================================================================

.MODEL SMALL
.STACK 100
.DATA

;Set for Screen Output Display

;Logo Design + Input Message Coordinate
;======================================
SysLogoX			EQU		12
SysLogoY			EQU		5
SysLogoWidth		EQU		57
SysLogoHeight		EQU		7
SysLogoColor		EQU		1EH
MsgStartAtMarginX	EQU		SysLogoX
MsgStartAtMarginY	EQU		SysLogoY+SysLogoHeight+1
;===============================================================================

;System Title Design
;====================
SysTitleChar	DB		4H

;Notice Bar for invitation
;=========================
SysInvBarStartAtMarginX    EQU     0
SysInvBarStartAtMarginY    EQU     WindowHeight-SysInvBarHeight
SysInvBarWidth             EQU     WindowWidth-SysInvBarStartAtMarginX*2
SysInvBarHeight            EQU     4
SysInvBarBorderWidth       EQU     1
SysInvBarColor             EQU     3D
SysInvBarChar              DB      '-'
;===============================================================================

;System Message and String
;=========================
SysEntry				DB		'Please Enter Your Username => $'
SysEntryMsg				DB		'**Max Length 15 Characters and Start with a Letter** $'
SysContinueMsg			DB		'Press any key to continue...$'
SysWaitingMsg			DB		'Ready to Connect...$'
SysWelcome				DB		'Welcome to Our System $'
SysConnectMsg			DB		'Congratulations! You are connected with $'
OptMsg					DB		'Please choose an option to continue: $'
SysChatMenu				DB		'[F1]	To Start Chatting$'
ExitSys					DB		'[ESC]	To Exit System$'
ChatInvitation			DB		0 ;set default value for invitations
SendChatInvitation		DB		'You have sent a chat invitation to $'
ReceivedChatInvitation	DB		'Press [F1] to accept chat invitation from $'
SysErrorMsg				DB		'Invalid Data Detected!!! Please Enter Again... $'
;============================================================================================

;Username Var
UserNameSize1	DB	MaxUserNameSize, ?
UserName1		DB	MaxUserNameSize dup('$'),'$'
UserNameSize2	DB	MaxUserNameSize, ?
UserName2		DB	MaxUserNameSize dup('$'),'$'
;===================================================

;Serial Communication var
MainSentChar		DB	?
MainReceivedChar	DB	?
;==========================

.CODE
MAIN PROC FAR
	MOV AX,@DATA
	MOV DS,AX

	;Call macro in Port.asm
	InitSerialPort

	CALL GetUserName
	CALL WaitOtherUser
	CALL SelectionScreen

	Loop_In_Main:

	;Get Prim User input and send to Second User

	Send_In_Main:
	GetKeyEnterAndFlush
	JZ Receive_In_Main
	MOV MainSentChar, AH
	SendCharTo MainSentChar
	CALL PrimaryUserInput

	Receive_In_Main:
	ReceiveCharFrom
	JZ Loop_In_Main
	MOV MainReceivedChar, AL
	CALL SecondaryUserInput

	JMP Loop_In_Main
MAIN ENDP
;=======================================================================

;Get user name
GetUserName PROC

	;Draw System Logo
	CALL DrawSysLogo
	JMP UserName_Display

	Input_Error_Detected:
    CALL DrawSysLogo
    SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY+3, CurrentPage
    DisplayStr SysErrorMsg
   

	UserName_Display:
	;Set position from Graphics.asm
	;Current Page value read from Consts.asm

	SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY, CurrentPage 
	DisplayStr SysEntryMsg

	SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY+1, CurrentPage
	DisplayStr SysEntry

	;Clear Username (to update the latest name)
	MOV BX,0
	Clear_UserName:
	MOV UserName1[BX], '$'
	INC BX
	CMP BX,MaxUserNameSize
	JLE Clear_UserName

	;read user input
	ReadStr UserNameSize1

	;Validate user input (must first character)
	CMP UserName1[0], 'A'
    JB  Input_Error_Detected		;jump if below
    CMP UserName1[0], 'Z'
    JBE UserName_Return		;jump if below or equal

    CMP UserName1[0], 'a'
    JB  Input_Error_Detected	
    CMP UserName1[0], 'z'
    JA  Input_Error_Detected		;jump if above

	UserName_Return:
	SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY+4, CurrentPage
    DisplayStr SysContinueMsg
    WaitKeyEnter
    RET
GetUserName ENDP
;=====================================================================

;Handle Connection for other user to connect
WaitOtherUser PROC
	
	CALL DrawSysLogo

	;Print Message
	SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY+3, CurrentPage
	DisplayStr SysWaitingMsg

	;Hide the cursor some where in the screen
    SetCursorPos WindowWidth, WindowHeight, 0

	MOV BX,1

	Send_UserName:
	MOV CL, UserNameSize1[BX]
	SendCharTo CL

	;check whether the msg send successful
	UserName_Check: 

	;Check whether the user press ESC to quit the program

	GetKeyEnterAndFlush

	CMP	AL,ESC_AsciiCode ;formatted in consts.asm
	JNE	Continue_Receive_UserName
	MOV	AX,4C00H				;else exit from system
	INT	21H

	Continue_Receive_UserName:
	ReceiveCharFrom
	JZ	UserName_Check

	MOV UserNameSize2[BX],AL
	INC BX
	CMP BX, MaxUserNameSize
	JLE Send_UserName

	ClearKeyQueue

	RET
WaitOtherUser ENDP
;========================================================================

;Primary User Input
PrimaryUserInput PROC
	InputProcessing MainSentChar, 1
	RET
PrimaryUserInput ENDP
;========================================================================

;Secondary User Input
SecondaryUserInput PROC
	InputProcessing MainReceivedChar, 2
	RET
SecondaryUserInput ENDP
;========================================================================

;Clear System Screen and Draw system Logo
DrawSysLogo PROC
	;ClearScreen

	ClearScreen 0,0,WindowWidth,WindowHeight

	;Color a portion of the screen fr the game logo
	DrawLine SysLogoX, SysLogoY, SysLogoHeight, SysLogoWidth, ' ',SysLogoColor, CurrentPage

	;Draw for System Title
	;C logo 'upper-'
	SetCursorPos SysLogoX+1, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+2, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+3, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+4, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+5, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+6, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+7, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar

	;C logo 'Side |'
	SetCursorPos SysLogoX+1, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+1, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+1, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+1, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+1, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+1, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar


	;C logo 'lower_'
	SetCursorPos SysLogoX+2, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+3, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+4, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+5, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+6, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+7, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;H logo 'left|'
	SetCursorPos SysLogoX+9, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+9, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+9, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+9, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+9, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+9, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+9, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;H logo 'center-'
	SetCursorPos SysLogoX+10, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+11, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+12, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+13, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+14, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar


	;H logo 'Right|'
	SetCursorPos SysLogoX+15, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+15, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+15, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+15, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+15, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+15, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+15, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;A logo 'Left|'
	SetCursorPos SysLogoX+17, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+17, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+17, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+17, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+17, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+17, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+17, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;A logo 'Upper-'
	SetCursorPos SysLogoX+18, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+19, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+20, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+21, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+22, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar

	;A logo 'center-'
	SetCursorPos SysLogoX+18, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+19, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+20, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+21, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+22, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar

	;A logo 'right|'
	SetCursorPos SysLogoX+23, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+23, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+23, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+23, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+23, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+23, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+23, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;T logo 'upper-'
	SetCursorPos SysLogoX+25, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+26, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+27, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+28, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+29, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+30, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+31, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar

	;T logo '|'
	SetCursorPos SysLogoX+28, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+28, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+28, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+28, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+28, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+28, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;B logo 'left|'
	SetCursorPos SysLogoX+33, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+33, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+33, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+33, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+33, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+33, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+33, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;B logo 'Upper-'
	SetCursorPos SysLogoX+33, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+34, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+35, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+36, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+37, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+38, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+39, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar

	;B logo 'Upper right |'
	SetCursorPos SysLogoX+39, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+39, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	
	;B logo 'Center -'
	SetCursorPos SysLogoX+34, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+35, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+36, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+37, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+38, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar

	;B logo 'lower right |'
	SetCursorPos SysLogoX+39, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+39, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+39, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;B logo 'Lower -'
	SetCursorPos SysLogoX+34, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+35, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+36, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+37, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+38, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;O logo 'left|'
	SetCursorPos SysLogoX+41, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+41, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+41, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+41, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+41, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+41, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+41, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;o logo 'Upper -'
	SetCursorPos SysLogoX+42, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+43, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+44, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+45, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+46, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+47, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar

	;O logo 'right |'
	SetCursorPos SysLogoX+47, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+47, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+47, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+47, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+47, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+47, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+47, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;o logo 'lower -'
	SetCursorPos SysLogoX+42, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+43, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+44, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+45, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+46, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+47, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar


	;X logo 'left|'
	SetCursorPos SysLogoX+49, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+50, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+51, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+52, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+53, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+54, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+55, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar

	;X logo 'right |'
	SetCursorPos SysLogoX+55, SysLogoY, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+54, SysLogoY+1, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+53, SysLogoY+2, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+52, SysLogoY+3, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+51, SysLogoY+4, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+50, SysLogoY+5, CurrentPage
	DisplayChar	SysTitleChar
	SetCursorPos SysLogoX+49, SysLogoY+6, CurrentPage
	DisplayChar	SysTitleChar


	
	RET
DrawSysLogo ENDP
;======================================================================================================

;Display Selection for user to choose
SelectionScreen PROC
	CALL DrawSysLogo

	CALL DrawInvitationBar

	;Print UserName for info
	SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY+0, CurrentPage
    DisplayStr SysWelcome
    DisplayStr UserName1
    SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY+1, CurrentPage
    DisplayStr SysConnectMsg
    DisplayStr UserName2 
	

	SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY+4, CurrentPage
	DisplayStr OptMsg
	SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY+6, CurrentPage
	DisplayStr SysChatMenu
	SetCursorPos MsgStartAtMarginX, MsgStartAtMarginY+7, CurrentPage
	DisplayStr ExitSys

	;Hide Cursor
	SetCursorPos WindowWidth, WindowHeight, 0

	RET
SelectionScreen ENDP
;==============================================================================

DrawInvitationBar PROC

	;draw line to seperate with bar
	DrawLine SysInvBarStartAtMarginX, SysInvBarStartAtMarginY, SysInvBarBorderWidth, SysInvBarWidth, SysInvBarChar, SysInvBarColor, CurrentPage
	DrawLine SysInvBarStartAtMarginX, SysInvBarStartAtMarginY+SysInvBarHeight-SysInvBarBorderWidth, SysInvBarBorderWidth, SysInvBarWidth, SysInvBarChar, SysInvBarColor, CurrentPage


	;Display Invitation message for Alert
	InviteChatSent:
	CMP ChatInvitation, 1
	JNE InviteChatReceived
	SetCursorPos MsgStartAtMarginX, SysInvBarStartAtMarginY+SysInvBarBorderWidth, CurrentPage
	DisplayStr SendChatInvitation
	DisplayStr UserName2
	;===============================================================================================

	InviteChatReceived:
	CMP ChatInvitation, 2
	JNE InviteReturn
	SetCursorPos MsgStartAtMarginX, SysInvBarStartAtMarginY+SysInvBarBorderWidth, CurrentPage
    DisplayStr ReceivedChatInvitation
    DisplayStr UserName2
	;===============================================================================================

	InviteReturn:
	RET
DrawInvitationBar ENDP
;===================================================================================================



END MAIN