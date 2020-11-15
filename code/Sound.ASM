                                ;Sound Module - BACS 1024
;===============================================================================================
;Includes (Include the outside file for calling the variables or functions)
INCLUDE code\Consts.asm
INCLUDE code\Graphics.asm
INCLUDE code\Keyboard.asm
INCLUDE code\Port.asm

;Public variables and procedures
PUBLIC SoundPlayer

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
    speakerStatus db ?          ;store the status of speaker
    
    delay1 equ 7500h            ;used to delay the notes
    delay2 equ 0100h
    
    
    ;The notes of the sound
    notes dw 262,277,294,311,330,349,370,392,415,440,466,494


;TESTING PURPOSE
    ;username1           DB      "lky1020$"
    
.code
;================================================================================================
                                ;Start Chat Room between Two Users
;================================================================================================
SoundPlayer PROC FAR
    ;mov ax,@data
    ;mov ds,ax
    
    
    ;Initialize Sound Player
    call SoundPlayerScreen
    
    ;TURN SPEAKER ON
    in      al, 61h         ; get speaker status
    mov     speakerStatus,al; save speaker status (for turn off purpose)
                            
    or      al, 00000011b   ; set lowest 2 bits to on for Timer 2 gate(speaker) && data
    out     61h, al         ; turn speaker on
    
    lea si,notes
    mov ch,00h
    mov cl, 12
    
    L1:
        
        mov bx,[si]
        
        ;store cx with dx
        mov dx,cx
        
        ;delay
        mov cx,delay1
        
            wait1:
                push cx         ;store delay1 into stack,need put delay2 into cx
                mov cx,delay2
                
            wait2:
                loop wait2      ;wait delay2 run finish
                
                pop cx          ;retrieve delay from stack
                loop wait1      ;wait delay1 run finish      
    
        call setPitch
        
        mov ax,0002h
        add si,ax
        
        mov cx,dx
        
        loop L1
    
    ;TURN SPEAKER OFF
    mov     al, speakerStatus; get original speaker status
    
    and     al, 11111100b   ; clear lowest 2 bits to off timer 2 for gate(speaker) and data    
    out     61h, al         ;turn speaker off
    
    ;mov ah,4ch
    ;int 21h
    
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
setPitch PROC
    
    ;Specify that timer channel 2 is to be user
        ;10 = set time channel 2
        ;11 = read low byte(LSB) the high byte(MSB)
        ;011 = Output a square wave (0 and 1)
        ;0 = count in binary
    mov     al, 182         ; 0B6h = 1011 0110b
    out     43h, al         ; Prepare timer to expect a value and 
                            ; sets mode of operation(channel 2)
    
    
    
    ;Output byte to the port 42h
    ;Port 42h is connected to the computer's speaker and issues square wave pulses used to make sounds                         
    mov     al, bl          ; mov lower byte to al
    out     42h, al         ; Output low byte from al to timer.
    mov     al, bh          ; mov high byte to al 
    out     42h, al         ; Output high byte from al to timer.    
    
    ret
END
