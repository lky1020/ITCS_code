                          ;Sound Module - BACS 1024
;===============================================================================================
                                ;MACRO
;===============================================================================================
SoundInputProcessing MACRO Choice
    Local Check_F1, Check_F2, Check_F3, Check_F4, Sound_ESC, Sound_Playing, Return

    ;Check if F1 is pressed
    Check_F1:
        cmp Choice, F1_ScanCode  
        jne Check_F2
        
        lea si,notes1
        mov ch,00h
        mov cl, 2                   ;number of notes
    
    JMP Sound_Playing
    ;==========================
    
    ;Check if F2 is pressed
    Check_F2:
        cmp Choice, F2_ScanCode  
        jne Check_F3
        
        lea si,notes2
        mov ch,00h
        mov cl, 2                   ;number of notes
        
    JMP Sound_Playing
    ;==========================
    
    ;Check if F3 is pressed
    Check_F3:
        cmp Choice, F3_ScanCode  
        jne Check_F4
        
        lea si,notes3
        mov ch,00h
        mov cl, 2                   ;number of notes
        
    JMP Sound_Playing
    ;==========================
    
    ;Check if F4 is pressed
    Check_F4:
        cmp Choice, F4_ScanCode  
        jne Sound_ESC
        
        lea si,notes4
        mov ch,00h
        mov cl, 2                   ;number of notes

    JMP Sound_Playing 
    ;==========================        
    
    ;Check if ESC is pressed
    Sound_ESC:
        cmp Choice, ESC_ScanCode
        jne Return
        
        ;assign 1 to SoundExit to indicate exit 
        mov al, 1
        mov SoundExit,al 
    
    call SoundPlayerScreen      ;refresh sound player screen    
    RET
    ;==========================
    
    Sound_Playing:

        ;Play sound
        SoundPlay

        call SoundPlayerScreen          ;refresh sound player screen
        
    Return:    

ENDM SoundInputProcessing 
;===============================================================================================
                                ;START OF SOUND MODULE
;===============================================================================================
;Includes (Include the outside file for calling the variables or functions)
INCLUDE code\Consts.asm
INCLUDE code\Graphics.asm
INCLUDE code\Keyboard.asm
INCLUDE code\Port.asm
INCLUDE code\Speaker.asm

;Public variables and procedures
PUBLIC SoundPlayer
PUBLIC notes1
PUBLIC notes2
PUBLIC notes3
PUBLIC notes4
PUBLIC delay1
PUBLIC delay2

;External variables and procedures
EXTRN UserName1:BYTE
;===============================================================

.model small
.stack 64
.data
;Logo Design + Input Message Coordinate
;======================================
SoundLogoX			    EQU		12
SoundLogoY			    EQU		5
SoundLogoWidth		    EQU		57
SoundLogoHeight		    EQU		7
SoundLogoColor		    EQU		03FH
SoundMsgStartAtMarginX	EQU		SoundLogoX
SoundMsgStartAtMarginY	EQU		SoundLogoY + SoundLogoHeight + 1
;===============================================================================

    
;System Message and String
;=========================
SoundWelcome			DB		'Welcome to Our Sound Player: $'
SoundOptMsg			    DB		'Please choose an option to play: $'
SoundChatMenu1			DB		'[F1]	Connected Sound $'
SoundChatMenu2			DB		'[F2]	Send Sound $'
SoundChatMenu3			DB		'[F3]	Receive Sound $'
SoundChatMenu4			DB		'[F4]	Disconnected Sound $'
ExitSound				DB		'[ESC]	To Exit Sound Player$'


;Sound Data
    ;sound variable 
    delay1              DW      7000h            ;used to delay the notes
    delay2              DW      0150h
    
    ;Data
    SoundChoice         DB      ?   
    SoundExit           DB      0   ;1 = exit
    
    ;The notes of the sound
    notes1              DW      460, 380
    notes2              DW      1020, 240
    notes3              DW      846, 551
    notes4              DW      324, 119

.code
;================================================================================================
                                ;Start Chat Room between Two Users
;================================================================================================
SoundPlayer PROC FAR
    
    ;Initialize Sound Player
    call SoundPlayerScreen
    
    Loop_In_Sound:

        ;Get user input
        GetKeyPressAndFlush         ;get key press
        JZ Loop_In_Sound            ;skip if not key pressed
        
        mov soundChoice, ah         ;store scan_code of key pressed
        call SoundUserInput
        
        
        ;check whether user want to Exit sound player
        mov al, soundExit
        cmp al, 1           ;1 = exit
        je SoundPlayer_Exit 
    
    JMP Loop_In_Sound
    
        
    ;initialize soundExit before go back to main menu
    SoundPlayer_Exit:
        mov al, 0
        mov soundExit,al     
        SendCharTO soundChoice
    RET
SoundPlayer ENDP
;-------------------------------------------------------------------------
;Draw Sound LOGO
DrawSoundLogo PROC
    ;ClearScreen
	ClearScreen 0,0,WindowWidth,WindowHeight

	;Color a portion of the screen for the sound logo
	DrawLine SoundLogoX, SoundLogoY, SoundLogoHeight, SoundLogoWidth, ' ',SoundLogoColor, CurrentPage

        
    RET
DrawSoundLogo ENDP
;-------------------------------------------------------------------------
;Draw Sound Player SCREEN
SoundPlayerScreen PROC
    
    CALL DrawSoundLogo

    ;Print UserName for info
	SetCursorPos SoundMsgStartAtMarginX, SoundMsgStartAtMarginY+0, CurrentPage
    DisplayStr SoundWelcome
    DisplayStr UserName1
    
    ;Print InvitationBar's message
	SetCursorPos SoundMsgStartAtMarginX, SoundMsgStartAtMarginY+2, CurrentPage
	DisplayStr SoundOptMsg
	SetCursorPos SoundMsgStartAtMarginX, SoundMsgStartAtMarginY+3, CurrentPage
	DisplayStr SoundChatMenu1
	SetCursorPos SoundMsgStartAtMarginX, SoundMsgStartAtMarginY+4, CurrentPage
	DisplayStr SoundChatMenu2
	SetCursorPos SoundMsgStartAtMarginX, SoundMsgStartAtMarginY+5, CurrentPage
	DisplayStr SoundChatMenu3
	SetCursorPos SoundMsgStartAtMarginX, SoundMsgStartAtMarginY+6, CurrentPage
	DisplayStr SoundChatMenu4
	SetCursorPos SoundMsgStartAtMarginX, SoundMsgStartAtMarginY+8, CurrentPage
	DisplayStr ExitSound
    
    ;Hide Cursor
	SetCursorPos WindowWidth, WindowHeight, 0
	
    RET   
SoundPlayerScreen ENDP
;-------------------------------------------------------------------------
;Process user input
SoundUserInput PROC
    
    SoundInputProcessing soundChoice
    RET
    
SoundUserInput ENDP   
;-------------------------------------------------------------------------
END
