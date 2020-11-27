                          ;Sound Module - BACS 1024
;===============================================================================================
                                ;MACRO
;===============================================================================================
SoundSettingInputProcessing MACRO Choice
    Local Check_F1, Check_F2, Check_F3, Sound_ESC, Refresh, Return

    ;Check if F1 is pressed
    Check_F1:
        cmp Choice, F1_ScanCode
        jne Check_F2
        
        ;Set to sound set 1
        call SoundSet1
        
        mov al, 1
        mov CurrentSoundSet, al
        
    JMP Refresh
    ;==========================

    ;Check if F2 is pressed
    Check_F2:
        cmp Choice, F2_ScanCode
        jne Check_F3
        
        ;Set to sound set 2
        call SoundSet2
        
        mov al, 2
        mov CurrentSoundSet, al

    JMP Refresh
    ;==========================

    ;Check if F3 is pressed
    Check_F3:
        cmp Choice, F3_ScanCode
        jne Sound_ESC
        
        ;Set to sound set 3
        call SoundSet3
        
        mov al, 3
        mov CurrentSoundSet, al

    JMP Refresh
    ;==========================

    ;Check if ESC is pressed
    Sound_ESC:
        cmp Choice, ESC_ScanCode
        jne Return

        ;assign 1 to SoundSettingExit to indicate exit
        mov al, 1
        mov SoundSettingExit,al
        
    call SoundSettingScreen                 ;refresh sound player screen
    RET
    ;==========================
    
    Refresh:
        call SoundSettingScreen             ;refresh sound player screen
    
    Return:

ENDM SoundSettingInputProcessing
;===============================================================================================
                                ;START OF SOUND MODULE
;===============================================================================================
;Includes (Include the outside file for calling the variables or functions)
INCLUDE code\Consts.asm
INCLUDE code\Graphics.asm
INCLUDE code\Keyboard.asm

;Public variables and procedures
PUBLIC SoundSetting


;External variables and procedures
EXTRN UserName1:BYTE
EXTRN connectedSound:WORD
EXTRN notificationSound:WORD
EXTRN disconnectedSound:WORD
EXTRN delay1:WORD
EXTRN delay2:WORD
EXTRN connectedSoundNote:BYTE  
EXTRN notificationSoundNote:BYTE
EXTRN disconnectedSoundNote:BYTE
;===============================================================

.model small
.stack 64
.data
;Logo Design + Input Message Coordinate
;======================================
SoundSettingLogoX			    EQU		12
SoundSettingLogoY			    EQU		5
SoundSettingLogoWidth		    EQU		57
SoundSettingLogoHeight		    EQU		7
SoundSettingLogoColor		    EQU		9EH
SoundSettingMsgStartAtMarginX	EQU		SoundSettingLogoX
SoundSettingMsgStartAtMarginY	EQU		SoundSettingLogoY + SoundSettingLogoHeight + 1
;===============================================================================


;System Message and String
;=========================
SoundSettingTitleChar           DB      4H
SoundSettingWelcome			    DB		'Welcome to Our Sound Setting: $'
SoundSettingOptMsg			    DB		'Please choose a sound set for sound: $'
SoundSettingCurrentMsg          DB      'Current Sound Set: $'
SoundSettingChatMenu1			DB		'[F1]	Sound Set 1 (Default)$'
SoundSettingChatMenu2			DB		'[F2]	Sound Set 2 $'
SoundSettingChatMenu3			DB		'[F3]	Sound Set 3 $'
ExitSoundSetting				DB		'[ESC]	To Exit Sound Player$'


;Sound SET Data

    ;current sound set
    SoundSetting1Str            DB      'Sound Set 1$'
    SoundSetting2Str            DB      'Sound Set 2$'
    SoundSetting3Str            DB      'Sound Set 3$'

    ;Data
    SoundSettingChoice          DB      ?
    SoundSettingExit            DB      0   ;1 = exit
    
    
    ;Soundset (connected, notification, disconnected)
    CurrentSoundSet             DB      1
    
    ;SoundSet1
    soundSet1Array1             DW      460, 380, 475
    soundSet1Array2             DW      1020, 240
    soundSet1Array3             DW      324, 475, 234
    
    ;SoundSet2
    soundSet2Array1             DW      1345, 755, 545
    soundSet2Array2             DW      420, 1120
    soundSet2Array3             DW      755, 542, 1345
    
    ;SoundSet3
    soundSet3Array1             DW      1020, 2010, 3340
    soundSet3Array2             DW      575, 757
    soundSet3Array3             DW      245, 542, 915
    
.code
;================================================================================================
                                ;Start Chat Room between Two Users
;================================================================================================
SoundSetting PROC FAR

    ;Initialize Sound Set
    call SoundSettingScreen

    Loop_In_Sound_Setting:

        ;Get user input
        GetKeyPressAndFlush                 ;get key press
        JZ Loop_In_Sound_Setting            ;skip if not key pressed

        mov SoundSettingChoice, ah          ;store scan_code of key pressed
        call SoundSettingUserInput


        ;check whether user want to Exit sound player
        mov al, SoundSettingExit
        cmp al, 1                           ;1 = exit
        je SoundSetting_Exit

    JMP Loop_In_Sound_Setting


    ;initialize SoundSettingExit before go back to sound player
    SoundSetting_Exit:
        mov al, 0
        mov SoundSettingExit,al
        
    RET
SoundSetting ENDP
;-------------------------------------------------------------------------
;Draw Sound LOGO
DrawSoundSettingLogo PROC
    ;ClearScreen
	ClearScreen 0,0,WindowWidth,WindowHeight

	;Color a portion of the screen for the sound logo
	DrawLine SoundSettingLogoX, SoundSettingLogoY, SoundSettingLogoHeight, SoundSettingLogoWidth, ' ',SoundSettingLogoColor, CurrentPage

    ;Draw for Sound Title
    ;=====================================================
    ;'S'
    ;=====================================================

    ;S logo 'left |'
    SetCursorPos SoundSettingLogoX+9, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+9, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+9, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+9, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+9, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;S logo 'upper center -'
    SetCursorPos SoundSettingLogoX+10, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+11, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+12, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+13, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+14, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar


    ;S logo 'middle center -'
    SetCursorPos SoundSettingLogoX+10, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+11, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+12, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+13, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+14, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;S logo 'upper center -'
    SetCursorPos SoundSettingLogoX+10, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+11, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+12, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+13, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+14, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;S logo 'right |'
    SetCursorPos SoundSettingLogoX+15, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+15, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+15, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+15, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+15, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;=====================================================
    ;'O'
    ;=====================================================
    ;O logo 'left |'
    SetCursorPos SoundSettingLogoX+17, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+17, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+17, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+17, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+17, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+17, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+17, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;O logo 'upper center -'
    SetCursorPos SoundSettingLogoX+18, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+19, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+20, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+21, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+22, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;O logo 'lower center -'
    SetCursorPos SoundSettingLogoX+18, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+19, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+20, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+21, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+22, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;O logo 'right |'
    SetCursorPos SoundSettingLogoX+23, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+23, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+23, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+23, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+23, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+23, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+23, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;=====================================================
    ;'U'
    ;=====================================================
    ;U logo 'left |'
    SetCursorPos SoundSettingLogoX+25, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+25, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+25, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+25, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+25, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+25, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+25, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;U logo 'lower center -'
    SetCursorPos SoundSettingLogoX+26, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+27, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+28, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+29, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+30, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;U logo 'right |'
    SetCursorPos SoundSettingLogoX+31, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+31, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+31, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+31, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+31, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+31, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+31, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;=====================================================
    ;'N'
    ;=====================================================
    ;N logo 'left |'
    SetCursorPos SoundSettingLogoX+33, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+33, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+33, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+33, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+33, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+33, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+33, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;N logo 'middle'
    SetCursorPos SoundSettingLogoX+34, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+35, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+36, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+37, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+38, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar


    ;N logo 'right |'
    SetCursorPos SoundSettingLogoX+39, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+39, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+39, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+39, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+39, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+39, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+39, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;=====================================================
    ;'D'
    ;=====================================================
    ;D logo 'left |'
    SetCursorPos SoundSettingLogoX+41, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+41, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+41, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+41, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+41, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+41, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+41, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;D logo 'upper center -'
    SetCursorPos SoundSettingLogoX+42, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+43, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+44, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+45, SoundSettingLogoY+0, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;D logo 'lower center -'
    SetCursorPos SoundSettingLogoX+42, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+43, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+44, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+45, SoundSettingLogoY+6, CurrentPage
    DisplayChar	SoundSettingTitleChar

    ;D logo 'right |'
    SetCursorPos SoundSettingLogoX+46, SoundSettingLogoY+1, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+47, SoundSettingLogoY+2, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+47, SoundSettingLogoY+3, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+47, SoundSettingLogoY+4, CurrentPage
    DisplayChar	SoundSettingTitleChar
    SetCursorPos SoundSettingLogoX+46, SoundSettingLogoY+5, CurrentPage
    DisplayChar	SoundSettingTitleChar


    RET
DrawSoundSettingLogo ENDP
;-------------------------------------------------------------------------
;Draw Sound Player SCREEN
SoundSettingScreen PROC

    CALL DrawSoundSettingLogo

    ;Print UserName for info
	SetCursorPos SoundSettingMsgStartAtMarginX, SoundSettingMsgStartAtMarginY+0, CurrentPage
    DisplayStr SoundSettingWelcome
    DisplayStr UserName1

    ;Print Current Sound set
    SetCursorPos SoundSettingMsgStartAtMarginX, SoundSettingMsgStartAtMarginY+1, CurrentPage
    DisplayStr SoundSettingCurrentMsg
    CALL DisplayCurrentSoundSetting

    ;Print InvitationBar's message
	SetCursorPos SoundSettingMsgStartAtMarginX, SoundSettingMsgStartAtMarginY+3, CurrentPage
	DisplayStr SoundSettingOptMsg
	SetCursorPos SoundSettingMsgStartAtMarginX, SoundSettingMsgStartAtMarginY+4, CurrentPage
	DisplayStr SoundSettingChatMenu1
	SetCursorPos SoundSettingMsgStartAtMarginX, SoundSettingMsgStartAtMarginY+5, CurrentPage
	DisplayStr SoundSettingChatMenu2
	SetCursorPos SoundSettingMsgStartAtMarginX, SoundSettingMsgStartAtMarginY+6, CurrentPage
	DisplayStr SoundSettingChatMenu3
	SetCursorPos SoundSettingMsgStartAtMarginX, SoundSettingMsgStartAtMarginY+9, CurrentPage
	DisplayStr ExitSoundSetting

    ;Hide Cursor
	SetCursorPos WindowWidth, WindowHeight, 0

    RET
SoundSettingScreen ENDP
;-------------------------------------------------------------------------
;Process user input
SoundSettingUserInput PROC

    SoundSettingInputProcessing SoundSettingChoice
    RET

SoundSettingUserInput ENDP
;-------------------------------------------------------------------------
;Display the current sound set
DisplayCurrentSoundSetting PROC

    ;compare and display current sound set
    mov al, CurrentSoundSet
    cmp al, 1
    JE Set1
    cmp al, 2
    JE Set2
    cmp al, 3
    JE Set3

    Set1:
        DisplayStr SoundSetting1Str
        JMP Return

    Set2:
        DisplayStr SoundSetting2Str
        JMP Return

    Set3:
        DisplayStr SoundSetting3Str
        JMP Return

    Return:
    RET
DisplayCurrentSoundSetting ENDP
;-------------------------------------------------------------------------
;Change to sound set 1
SoundSet1 PROC
    
    ;Change sound delay
    mov ax, 7000h
    mov delay1, ax
    
    mov ax, 0150h
    mov delay2, ax
    
    ;change connected sound
    lea si, connectedSound
    lea di, soundSet1Array1
    
    mov cx, 0
    mov cl, connectedSoundNote
    
    connectedSound1_loop:
        mov ax,[di]
        mov [si], ax
        
        loop connectedSound1_loop 
    ;=====================================
    
          
    ;change notification sound
    lea si, notificationSound
    lea di, soundSet1Array2
    
    mov cx, 0
    mov cl, notificationSoundNote
    
    notificationSound1_loop:
        mov ax,[di]
        mov [si], ax
        
        loop notificationSound1_loop
    ;=====================================
    
        
    ;change disconnected sound
    lea si, disconnectedSound
    lea di, soundSet1Array3
    
    mov cx, 0
    mov cl, disconnectedSoundNote
    
    disconnectedSound1_loop:
        mov ax,[di]
        mov [si], ax
        
        loop disconnectedSound1_loop    
    ;=====================================
    

    RET    
SoundSet1 ENDP    
;-------------------------------------------------------------------------
;Change to sound set 2
SoundSet2 PROC
    
    mov ax, 5000h
    mov delay1, ax
    
    mov ax, 0100h
    mov delay2, ax
    
    ;change connected sound
    lea si, connectedSound
    lea di, soundSet2Array1
    
    mov cx, 0
    mov cl, connectedSoundNote
    
    connectedSound2_loop:
        mov ax,[di]
        mov [si], ax
        
        loop connectedSound2_loop 
    ;=====================================
    
          
    ;change notification sound
    lea si, notificationSound
    lea di, soundSet2Array2
    
    mov cx, 0
    mov cl, notificationSoundNote
    
    notificationSound2_loop:
        mov ax,[di]
        mov [si], ax
        
        loop notificationSound2_loop
    ;=====================================
    
        
    ;change disconnected sound
    lea si, disconnectedSound
    lea di, soundSet2Array3
    
    mov cx, 0
    mov cl, disconnectedSoundNote
    
    disconnectedSound2_loop:
        mov ax,[di]
        mov [si], ax
        
        loop disconnectedSound2_loop    
    ;=====================================
    

    RET    
SoundSet2 ENDP    
;-------------------------------------------------------------------------
;Change to sound set 3
SoundSet3 PROC
    
    mov ax, 8000h
    mov delay1, ax
    
    mov ax, 0250h
    mov delay2, ax
    
    ;change connected sound
    lea si, connectedSound
    lea di, soundSet3Array1
    
    mov cx, 0
    mov cl, connectedSoundNote
    
    connectedSound3_loop:
        mov ax,[di]
        mov [si], ax
        
        loop connectedSound3_loop 
    ;=====================================
    
          
    ;change notification sound
    lea si, notificationSound
    lea di, soundSet3Array2
    
    mov cx, 0
    mov cl, notificationSoundNote
    
    notificationSound3_loop:
        mov ax,[di]
        mov [si], ax
        
        loop notificationSound3_loop
    ;=====================================
    
        
    ;change disconnected sound
    lea si, disconnectedSound
    lea di, soundSet1Array3
    
    mov cx, 0
    mov cl, disconnectedSoundNote
    
    disconnectedSound3_loop:
        mov ax,[di]
        mov [si], ax
        
        loop disconnectedSound3_loop    
    ;=====================================
    

    RET    
SoundSet3 ENDP    
;-------------------------------------------------------------------------
END
