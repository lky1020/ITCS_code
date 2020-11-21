                          ;Sound Module - BACS 1024
;===============================================================================================
                                ;MACRO
;===============================================================================================
SoundSetInputProcessing MACRO Choice
    Local Check_F1, Check_F2, Check_F3, Sound_ESC, Sound_Playing, Return

    ;Check if F1 is pressed
    Check_F1:
        cmp Choice, F1_ScanCode
        jne Check_F2

        mov al, 1
        mov CurrentSoundSet, al 
        
    JMP Sound_Playing
    ;==========================

    ;Check if F2 is pressed
    Check_F2:
        cmp Choice, F2_ScanCode
        jne Check_F3

        mov al, 2
        mov CurrentSoundSet, al
        
    JMP Sound_Playing
    ;==========================

    ;Check if F3 is pressed
    Check_F3:
        cmp Choice, F3_ScanCode
        jne Sound_ESC

        mov al, 3
        mov CurrentSoundSet, al
        
    JMP Sound_Playing
    ;==========================

    ;Check if ESC is pressed
    Sound_ESC:
        cmp Choice, ESC_ScanCode
        jne Return

        ;assign 1 to SoundSetExit to indicate exit
        mov al, 1
        mov SoundSetExit,al

    call SoundSetScreen      ;refresh sound player screen
    RET
    ;==========================

    Sound_Playing:

        call SoundSetScreen          ;refresh sound player screen

    Return:

ENDM SoundSetInputProcessing
;===============================================================================================
                                ;START OF SOUND MODULE
;===============================================================================================
;Includes (Include the outside file for calling the variables or functions)
INCLUDE code\Consts.asm
INCLUDE code\Graphics.asm
INCLUDE code\Keyboard.asm
INCLUDE code\Port.asm

;Public variables and procedures
PUBLIC SoundSet 


;External variables and procedures
EXTRN UserName1:BYTE
EXTRN SoundPlayer:WORD
EXTRN connectedSound:WORD
EXTRN notificationSound:WORD
EXTRN disconnectedSound:WORD
;===============================================================

.model small
.stack 64
.data
;Logo Design + Input Message Coordinate
;======================================
SoundSetLogoX			    EQU		12
SoundSetLogoY			    EQU		5
SoundSetLogoWidth		    EQU		57
SoundSetLogoHeight		    EQU		7
SoundSetLogoColor		    EQU		9EH
SoundSetMsgStartAtMarginX	EQU		SoundSetLogoX
SoundSetMsgStartAtMarginY	EQU		SoundSetLogoY + SoundSetLogoHeight + 1
;===============================================================================


;System Message and String
;=========================
SoundSetTitleChar           DB      4H
SoundSetWelcome			    DB		'Welcome to Our Sound Set: $'
SoundSetOptMsg			    DB		'Please choose a sound set for sound: $'
SoundSetCurrentMsg          DB      'Current Sound Set: $'
SoundSetChatMenu1			DB		'[F1]	Sound Set 1 (Default)$'
SoundSetChatMenu2			DB		'[F2]	Sound Set 2 $'
SoundSetChatMenu3			DB		'[F3]	Sound Set 3 $'
ExitSoundSet				DB		'[ESC]	To Exit Sound Player$'


;Sound SET Data
    
    ;current sound set
    SoundSet1Str            DB      'Sound Set 1$'
    SoundSet2Str            DB      'Sound Set 2$'
    SoundSet3Str            DB      'Sound Set 3$'
    
    CurrentSoundSet         DB      1
    
    ;Data
    SoundSetChoice          DB      ?
    SoundSetExit            DB      0   ;1 = exit

.code
;================================================================================================
                                ;Start Chat Room between Two Users
;================================================================================================
SoundSet PROC FAR

    ;Initialize Sound Set
    call SoundSetScreen

    Loop_In_Sound_Set:

        ;Get user input
        GetKeyPressAndFlush         ;get key press
        JZ Loop_In_Sound_Set            ;skip if not key pressed

        mov SoundSetChoice, ah         ;store scan_code of key pressed
        call SoundSetUserInput


        ;check whether user want to Exit sound player
        mov al, SoundSetExit
        cmp al, 1           ;1 = exit
        je SoundSet_Exit

    JMP Loop_In_Sound_Set


    ;initialize SoundSetExit before go back to main menu
    SoundSet_Exit:
        mov al, 0
        mov SoundSetExit,al

    RET
SoundSet ENDP
;-------------------------------------------------------------------------
;Draw Sound LOGO
DrawSoundSetLogo PROC
    ;ClearScreen
	ClearScreen 0,0,WindowWidth,WindowHeight

	;Color a portion of the screen for the sound logo
	DrawLine SoundSetLogoX, SoundSetLogoY, SoundSetLogoHeight, SoundSetLogoWidth, ' ',SoundSetLogoColor, CurrentPage

    ;Draw for Sound Title
    ;=====================================================
    ;'S'
    ;=====================================================

    ;S logo 'left |'
    SetCursorPos SoundSetLogoX+9, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+9, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+9, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+9, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+9, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;S logo 'upper center -'
    SetCursorPos SoundSetLogoX+10, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+11, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+12, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+13, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+14, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar


    ;S logo 'middle center -'
    SetCursorPos SoundSetLogoX+10, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+11, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+12, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+13, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+14, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;S logo 'upper center -'
    SetCursorPos SoundSetLogoX+10, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+11, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+12, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+13, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+14, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;S logo 'right |'
    SetCursorPos SoundSetLogoX+15, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+15, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+15, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+15, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+15, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;=====================================================
    ;'O'
    ;=====================================================
    ;O logo 'left |'
    SetCursorPos SoundSetLogoX+17, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+17, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+17, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+17, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+17, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+17, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+17, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;O logo 'upper center -'
    SetCursorPos SoundSetLogoX+18, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+19, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+20, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+21, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+22, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;O logo 'lower center -'
    SetCursorPos SoundSetLogoX+18, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+19, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+20, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+21, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+22, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;O logo 'right |'
    SetCursorPos SoundSetLogoX+23, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+23, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+23, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+23, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+23, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+23, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+23, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;=====================================================
    ;'U'
    ;=====================================================
    ;U logo 'left |'
    SetCursorPos SoundSetLogoX+25, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+25, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+25, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+25, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+25, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+25, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+25, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;U logo 'lower center -'
    SetCursorPos SoundSetLogoX+26, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+27, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+28, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+29, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+30, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;U logo 'right |'
    SetCursorPos SoundSetLogoX+31, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+31, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+31, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+31, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+31, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+31, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+31, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;=====================================================
    ;'N'
    ;=====================================================
    ;N logo 'left |'
    SetCursorPos SoundSetLogoX+33, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+33, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+33, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+33, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+33, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+33, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+33, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;N logo 'middle'
    SetCursorPos SoundSetLogoX+34, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+35, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+36, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+37, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+38, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar


    ;N logo 'right |'
    SetCursorPos SoundSetLogoX+39, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+39, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+39, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+39, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+39, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+39, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+39, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;=====================================================
    ;'D'
    ;=====================================================
    ;D logo 'left |'
    SetCursorPos SoundSetLogoX+41, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+41, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+41, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+41, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+41, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+41, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+41, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;D logo 'upper center -'
    SetCursorPos SoundSetLogoX+42, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+43, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+44, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+45, SoundSetLogoY+0, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;D logo 'lower center -'
    SetCursorPos SoundSetLogoX+42, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+43, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+44, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+45, SoundSetLogoY+6, CurrentPage
    DisplayChar	SoundSetTitleChar

    ;D logo 'right |'
    SetCursorPos SoundSetLogoX+46, SoundSetLogoY+1, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+47, SoundSetLogoY+2, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+47, SoundSetLogoY+3, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+47, SoundSetLogoY+4, CurrentPage
    DisplayChar	SoundSetTitleChar
    SetCursorPos SoundSetLogoX+46, SoundSetLogoY+5, CurrentPage
    DisplayChar	SoundSetTitleChar


    RET
DrawSoundSetLogo ENDP
;-------------------------------------------------------------------------
;Draw Sound Player SCREEN
SoundSetScreen PROC

    CALL DrawSoundSetLogo

    ;Print UserName for info
	SetCursorPos SoundSetMsgStartAtMarginX, SoundSetMsgStartAtMarginY+0, CurrentPage
    DisplayStr SoundSetWelcome
    DisplayStr UserName1
    
    ;Print Current Sound set
    SetCursorPos SoundSetMsgStartAtMarginX, SoundSetMsgStartAtMarginY+1, CurrentPage
    DisplayStr SoundSetCurrentMsg
    CALL DisplayCurrentSoundSet
    
    ;Print InvitationBar's message
	SetCursorPos SoundSetMsgStartAtMarginX, SoundSetMsgStartAtMarginY+3, CurrentPage
	DisplayStr SoundSetOptMsg
	SetCursorPos SoundSetMsgStartAtMarginX, SoundSetMsgStartAtMarginY+4, CurrentPage
	DisplayStr SoundSetChatMenu1
	SetCursorPos SoundSetMsgStartAtMarginX, SoundSetMsgStartAtMarginY+5, CurrentPage
	DisplayStr SoundSetChatMenu2
	SetCursorPos SoundSetMsgStartAtMarginX, SoundSetMsgStartAtMarginY+6, CurrentPage
	DisplayStr SoundSetChatMenu3
	SetCursorPos SoundSetMsgStartAtMarginX, SoundSetMsgStartAtMarginY+9, CurrentPage
	DisplayStr ExitSoundSet

    ;Hide Cursor
	SetCursorPos WindowWidth, WindowHeight, 0

    RET
SoundSetScreen ENDP
;-------------------------------------------------------------------------
;Process user input
SoundSetUserInput PROC

    SoundSetInputProcessing SoundSetChoice
    RET

SoundSetUserInput ENDP
;-------------------------------------------------------------------------
;Display the current sound set
DisplayCurrentSoundSet PROC

    ;compare and display current sound set
    mov al, CurrentSoundSet
    cmp al, 1
    JE Set1
    cmp al, 2
    JE Set2
    cmp al, 3
    JE Set3
    
    Set1:
        DisplayStr SoundSet1Str
        JMP Return   
    
    Set2:
        DisplayStr SoundSet2Str
        JMP Return
    
    Set3:
        DisplayStr SoundSet3Str
        JMP Return
    
    Return:    
    RET    
DisplayCurrentSoundSet ENDP
;-------------------------------------------------------------------------
END
