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
        
        ;Initialize connected sound
        lea si,connectedSound
        mov ch,00h
        mov cl, connectedSoundNote    
    
    JMP Sound_Playing
    ;==========================
    
    ;Check if F2 is pressed
    Check_F2:
        cmp Choice, F2_ScanCode  
        jne Check_F3
        
        ;Initialize notification sound
        lea si,notificationSound
        mov ch,00h
        mov cl, notificationSoundNote
        
    JMP Sound_Playing
    ;==========================

    ;Check if F3 is pressed
    Check_F3:
        cmp Choice, F3_ScanCode  
        jne Check_F4
        
        ;Initialize disconnected sound
        lea si,disconnectedSound
        mov ch,00h
        mov cl, disconnectedSoundNote

    JMP Sound_Playing 
    ;==========================        
    
    ;Check if F4 is pressed
    Check_F4:
        cmp Choice, F4_ScanCode  
        jne Sound_ESC
        
        call SoundSetting               ;Soundstg.asm
        call SoundPlayerScreen          ;refresh sound player screen
        
    JMP Return 
    ;==========================
    
    ;Check if ESC is pressed
    Sound_ESC:
        cmp Choice, ESC_ScanCode
        jne Return
        
        ;assign 1 to SoundExit to indicate exit 
        mov al, 1
        mov SoundExit,al 
    
    call SoundPlayerScreen              ;refresh sound player screen    
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
INCLUDE code\Speaker.asm

;Public variables and procedures
PUBLIC SoundPlayer
PUBLIC connectedSound
PUBLIC notificationSound
PUBLIC disconnectedSound
PUBLIC delay1
PUBLIC delay2
PUBLIC connectedSoundNote   
PUBLIC notificationSoundNote
PUBLIC disconnectedSoundNote


;External variables and procedures
EXTRN UserName1:BYTE
EXTRN SoundSetting: FAR
;===============================================================

.model small
.stack 64
.data
;Logo Design + Input Message Coordinate
;======================================
SoundLogoX			        EQU		12
SoundLogoY			        EQU		5
SoundLogoWidth		        EQU		57
SoundLogoHeight		        EQU		7
SoundLogoColor		        EQU		3EH
SoundMsgStartAtMarginX	    EQU		SoundLogoX
SoundMsgStartAtMarginY	    EQU		SoundLogoY + SoundLogoHeight + 1
;===============================================================================

    
;System Message and String
;=========================
SoundTitleChar              DB      4H
SoundWelcome			    DB		'Welcome to Our Sound Player: $'
SoundOptMsg			        DB		'Please choose an option to play: $'
SoundChatMenu1			    DB		'[F1]	Connected Sound $'
SoundChatMenu2			    DB		'[F2]	Notification Sound $'
SoundChatMenu3			    DB		'[F3]	Disconnected Sound $'
SoundChatSetting	        DB		'[F4]	Sound Setting $'
ExitSound				    DB		'[ESC]	To Exit Sound Player$'


;Sound Data
    ;sound variable 
    delay1                  DW      7000h            ;used to delay the notes
    delay2                  DW      0150h
    
    ;Data
    SoundChoice             DB      ?   
    SoundExit               DB      0   ;1 = exit
    
    ;The notes of the sound
    connectedSound          DW      460, 380, 475
    notificationSound       DW      1020, 240
    disconnectedSound       DW      324, 475, 234
    
    ;length of note
    connectedSoundNote      DB      3
    notificationSoundNote   DB      2
    disconnectedSoundNote   DB      3

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
        cmp al, 1                   ;1 = exit
        je SoundPlayer_Exit 
    
    JMP Loop_In_Sound
    
        
    ;initialize soundExit before go back to main menu
    SoundPlayer_Exit:
        mov al, 0
        mov soundExit,al     
    RET
SoundPlayer ENDP
;-------------------------------------------------------------------------
;Draw Sound LOGO
DrawSoundLogo PROC
    ;ClearScreen
	ClearScreen 0,0,WindowWidth,WindowHeight

	;Color a portion of the screen for the sound logo
	DrawLine SoundLogoX, SoundLogoY, SoundLogoHeight, SoundLogoWidth, ' ',SoundLogoColor, CurrentPage
    
    ;Draw for Sound Title
    ;=====================================================
    ;'S'
    ;=====================================================
    
    ;S logo 'left |'
    SetCursorPos SoundLogoX+9, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+9, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+9, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+9, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+9, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;S logo 'upper center -'
    SetCursorPos SoundLogoX+10, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+11, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+12, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+13, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+14, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar

    
    ;S logo 'middle center -'
    SetCursorPos SoundLogoX+10, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+11, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+12, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+13, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+14, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;S logo 'upper center -'
    SetCursorPos SoundLogoX+10, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+11, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+12, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+13, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+14, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;S logo 'right |'
    SetCursorPos SoundLogoX+15, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+15, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+15, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+15, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+15, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;=====================================================
    ;'O'
    ;=====================================================
    ;O logo 'left |'
    SetCursorPos SoundLogoX+17, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+17, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+17, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+17, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+17, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+17, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+17, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;O logo 'upper center -'
    SetCursorPos SoundLogoX+18, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+19, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+20, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+21, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+22, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;O logo 'lower center -'
    SetCursorPos SoundLogoX+18, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+19, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+20, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+21, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+22, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;O logo 'right |'
    SetCursorPos SoundLogoX+23, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+23, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+23, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+23, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+23, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+23, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+23, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;=====================================================
    ;'U'
    ;=====================================================
    ;U logo 'left |'
    SetCursorPos SoundLogoX+25, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+25, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+25, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+25, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+25, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+25, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+25, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;U logo 'lower center -'
    SetCursorPos SoundLogoX+26, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+27, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+28, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar             
    SetCursorPos SoundLogoX+29, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+30, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;U logo 'right |'
    SetCursorPos SoundLogoX+31, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+31, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+31, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+31, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+31, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+31, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+31, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;=====================================================
    ;'N'
    ;=====================================================
    ;N logo 'left |'
    SetCursorPos SoundLogoX+33, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+33, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+33, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+33, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+33, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+33, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+33, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;N logo 'middle'
    SetCursorPos SoundLogoX+34, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+35, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+36, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+37, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+38, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    
    
    ;N logo 'right |'
    SetCursorPos SoundLogoX+39, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+39, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+39, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+39, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+39, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+39, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+39, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;=====================================================
    ;'D'
    ;=====================================================
    ;D logo 'left |'
    SetCursorPos SoundLogoX+41, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+41, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+41, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+41, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+41, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+41, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+41, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;D logo 'upper center -'
    SetCursorPos SoundLogoX+42, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+43, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+44, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+45, SoundLogoY+0, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;D logo 'lower center -'
    SetCursorPos SoundLogoX+42, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+43, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+44, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+45, SoundLogoY+6, CurrentPage
    DisplayChar	SoundTitleChar
    
    ;D logo 'right |'
    SetCursorPos SoundLogoX+46, SoundLogoY+1, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+47, SoundLogoY+2, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+47, SoundLogoY+3, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+47, SoundLogoY+4, CurrentPage
    DisplayChar	SoundTitleChar
    SetCursorPos SoundLogoX+46, SoundLogoY+5, CurrentPage
    DisplayChar	SoundTitleChar
    
        
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
	DisplayStr SoundChatSetting
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
