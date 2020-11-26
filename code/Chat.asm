                                ;Chat Module - BACS 1024
;===============================================================================================
                                ;Draw the Chat Area for User
;===============================================================================================
DrawChatArea MACRO Y, Username
    ;Draw separator line
        DrawLine 0, Y, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage
    
    ;Print user name
        SetCursorPos ChatMargin, Y+1, CurrentPage
        DisplayStr Username

    ;Draw line under username
        DrawLine 0, Y+2, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage
ENDM DrawChatArea
;================================================================================================
                                ;Draw the Chatting Information Bar
;================================================================================================
DrawInfoBar MACRO Y
    ;Draw begin separator
        DrawLine 0, Y, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage
    
    ;Print info message (Emoji_1)
        SetCursorPos ChatMargin, Y+1, CurrentPage
        DisplayStr EMOJI1
    
        SetCursorPos ChatMargin+4, Y+1, CurrentPage
        DisplayChar EJ1

    ;Print info message (Emoji_2)
        SetCursorPos ChatMargin+8, Y+1, CurrentPage
        DisplayStr EMOJI2
    
        SetCursorPos ChatMargin+12, Y+1, CurrentPage
        DisplayChar EJ2

    ;Print info message (Emoji_3)
        SetCursorPos ChatMargin+16, Y+1, CurrentPage
        DisplayStr EMOJI3
    
        SetCursorPos ChatMargin+20, Y+1, CurrentPage
        DisplayChar EJ3

    ;Draw End Separator of the Chat Room
        DrawLine 0, Y+2, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage

    ;Print ESC message
        SetCursorPos ChatMargin+45, Y+2, CurrentPage
        DisplayStr EndChatMsg
ENDM DrawInfoBar
;================================================================================================
                    ;Process a given user input. Called from within a procedure
;================================================================================================
;User = 1 (Send)
;User = 2 (Receive)
;Char = The Character Input by the User
;X,Y = The Cursor of the User
;OffsetY = The Chat Box Height of the User
ProcessInput MACRO Char, X, Y, OffsetY, User       
    LOCAL CheckEscape, CheckEnter, CheckBackspace, CheckPrintable, PrintChar, AdjustCursorPos, Return   
    
    ;Check if ESC is pressed
        CheckEscape:
            CMP Char, ESC_AsciiCode
            JNE CheckBackspace
            SendCharTO Char
            MOV IsChatEnded, 1
        RET
    ;==================================
      
    ;Check if Backspace is pressed
        CheckBackspace:
            CMP Char, Back_AsciiCode
            JNE CheckEnter
    
            CMP X, ChatMargin
            JBE CheckPrintable
    
            MOV Char, ' '
            DEC X
            
            SetCursorPos X, Y, CurrentPage
            DisplayChar Char
        RET
    ;==================================
    
    ;Check if Enter is pressed
        CheckEnter:
            CMP Char, Enter_AsciiCode
            JNE CheckPrintable
    
            MOV X, ChatMargin
            INC Y
            
            ;Play the notification sound
            call PlayNotificationSound
            
            ;MACRO to Process Send and Display in Second Screen
            DisplayInStr Char, X, Y, OffsetY

       RET
    ;==================================

    ;Check if printable character is pressed
        CheckPrintable:
            CMP Char, 1H   ;emoji
            JE PrintChar 
            
            CMP Char, 2H   ;emoji
            JE PrintChar 
            
            CMP Char, 3H   ;emoji
            JE PrintChar 
            
            CMP Char, ' '   ;Compare with lowest printable ascii value
            JB Return
            CMP Char, '~'   ;Compare with highest printable ascii value
            JA Return
    

    ;Print char
    PrintChar:
        SetCursorPos X, Y, CurrentPage
        DisplayChar Char
    
    ;If receive, no character store needed
        MOV AL, 1h
        AND AL, User        ;0001(1) AND 0001(1) = 0001(1) (Compare Two Conditions)
        CMP AL, 1
        JNE AdjustCursorPos
    
    ;Store Char
        MOV BH, 0h
        MOV BL, UserMsgIndex
    
        MOV AL,Char
        MOV UserMsg[BX], AL
        INC UserMsgIndex

    ;==================================
    
    ;Adjust new cursor position after printing the character (because Using Character Input, Therefore need to adjust once enter one character)
        AdjustCursorPos:
            INC X
            CMP X, ChatAreaWidth-ChatMargin
            JL Return
            
            MOV X, ChatMargin
            INC Y

    ;==================================
  
    Return:
ENDM ProcessInput
;================================================================================================
                            ;Process Sending and Display In Second Screen
;================================================================================================
DisplayInStr MACRO Char, X, Y, OffsetY
    LOCAL Checking, Sending, Return, Scroll
    
    MOV SI,0
    Checking:
        
        MOV AL, UserMsg[SI]
        CMP AL, '$'
        JE Scroll
        
        Sending:
            MOV ChatToSent, AL
            SendCharTO ChatToSent
        
            INC SI
            
            ;Check whether is last character (If YES, then insert ENTER character at last Element for Display Purpose)
            MOV AL, 0DH
            MOV BH, 0H
            MOV BL, UserMsgIndex
            CMP SI, BX
            JE Sending 

        JMP Checking

    ;Scroll chat area one step up if chat area is full (To Avoid Character Display Over the Maximum Window Height)
    Scroll:
        CALL ClearMsgString
        
        CMP Y, ChatAreaHeight+OffsetY-1
        JBE Return
        
        DEC Y
        ScrollUp ChatMargin, OffsetY+3, ChatAreaWidth-ChatMargin, ChatAreaHeight+OffsetY-1, 1

    Return:
    RET
ENDM DisplayInStr
;================================================================================================
                                    ;START OF CHAT MODULE
;================================================================================================
;Includes (Include the outside file for calling the variables or functions)
INCLUDE code\Consts.asm
INCLUDE code\Graphics.asm
INCLUDE code\Keyboard.asm
INCLUDE code\Port.asm
INCLUDE code\Speaker.asm

;Public variables and procedures
PUBLIC ReadyToChat

;External variables and procedures
EXTRN UserName1:BYTE
EXTRN UserName2:BYTE
EXTRN notificationSound: WORD
EXTRN delay1: WORD
EXTRN delay2: WORD
EXTRN notificationSoundNote: BYTE
;================================================================================================

.MODEL SMALL
.STACK 64
.DATA
;Chat variables
User1CursorX                DB      0
User1CursorY                DB      0
User2CursorX                DB      0
User2CursorY                DB      12
ChatSentChar                DB      ?
ChatToSent                  DB      ?
ChatReceivedChar            DB      ?
IsChatEnded                 DB      0
EndChatMsg                  DB      'Press ESC to end chatting...$'
UserMsgSize	                DB	    MaxMsgSize, ?
UserMsg		                DB	    MaxMsgSize dup('$')
UserMsgIndex                DB      0
;================================================================================================

;Emoji Display Varaibles
EMOJI1  DB  "(/)-$"
EMOJI2  DB  "(*)-$"
EMOJI3  DB  "(-)-$"
EJ1     DB  1H
EJ2     DB  2H
EJ3     DB  3H    
;================================================================================================

;Screen adjust variables
ChatAreaWidth               EQU     WindowWidth
ChatAreaHeight              EQU     (ChatWindowHeight-6)/2
ChatMargin                  EQU     1
ChatLineColor               EQU     3D
ChatLineChar                DB      '-'

;================================================================================================

.CODE
;================================================================================================
                                ;Start Chat Room between Two Users
;================================================================================================
ReadyToChat PROC FAR
    
    ;Initialize the Chat Before Start
        CALL InitChatRoom

    Chat_Loop:

        ;Set the cursor to the primary user chat area
            SetCursorPos User1CursorX, User1CursorY, CurrentPage
    
        ;Get primary user input and send it to secondary user
            Chat_Send:
    
                GetKeyPressAndFlush
                JZ Chat_Receive                 ;Skip processing user input if no key is pressed
        
                MOV  ChatSentChar, AL
                CMP  AL,Back_AsciiCode 
                JNE  ContinueProcess
         
             ;Decrease the Index and insert $ to replace the variables enter
                CMP UserMsgIndex, 0
                JE  Chat_Receive

                DEC UserMsgIndex
                MOV BH, 0h
                MOV BL, UserMsgIndex
    
                MOV AL,'$'
                MOV UserMsg[BX], AL
             
            ContinueProcess:
                CALL ProcessEmoji                ;To avoid run out of byte (use PROC)
                CALL ProcessPrimaryInput
        
       
        ;Get secondary user input
            Chat_Receive:
                ReceiveCharFrom
                JZ Chat_Check                   ;Skip processing user input if no key is received
        
                MOV ChatReceivedChar, AL
                CALL ProcessSecondaryInput

        ;Finally check if any user pressed ESC to quit chat room
            Chat_Check:
                CMP IsChatEnded, 0
                JZ Chat_Loop
     RET
ReadyToChat ENDP
;================================================================================================
                               ;Compare Input and Assign Emoji
;================================================================================================
ProcessEmoji PROC
    
    CMP ChatSentChar, '/'
    JNE Check_2
    MOV AL, EJ1
    MOV ChatSentChar, AL
    RET
    ;===========================================
    Check_2:
        CMP ChatSentChar, '*'
        JNE Check_3
        MOV AL, EJ2
        MOV ChatSentChar, AL
    RET
    ;============================================
    Check_3:
        CMP ChatSentChar, '-'
        JNE Return
        MOV AL, EJ3
        MOV ChatSentChar, AL

    Return:
    RET
ProcessEmoji ENDP
;================================================================================================
                                ;Initialize chat room
;================================================================================================
InitChatRoom PROC
    ;Clear the Entire Screen Before Start Chat Room
        ClearScreen 0, 0, WindowWidth, ChatWindowHeight
    
    ;Draw Both Users Chat Area
        DrawChatArea 0, UserName1
        DrawChatArea ChatAreaHeight, UserName2
    
    ;Draw Information Bar (Bottom Part)
        DrawInfoBar ChatAreaHeight*2
    
    ;Set Chat Variables
        MOV User1CursorX, ChatMargin
        MOV User1CursorY, 3
        MOV User2CursorX, ChatMargin
        MOV User2CursorY, ChatAreaHeight+3
        MOV IsChatEnded, 0
    
    RET
InitChatRoom ENDP
;================================================================================================
                                ;Process primary user input
;================================================================================================
ProcessPrimaryInput PROC
    ProcessInput ChatSentChar, User1CursorX, User1CursorY, 0, 1
    RET
ProcessPrimaryInput ENDP
;================================================================================================
                                ;Process secondary user input
;================================================================================================
ProcessSecondaryInput PROC
    ProcessInput ChatReceivedChar, User2CursorX, User2CursorY, ChatAreaHeight, 2
    RET
ProcessSecondaryInput ENDP
;================================================================================================
                                ;Clear String After Enter
;================================================================================================
ClearMsgString  PROC
   
    ;Clear Msg for User1 
	MOV BX,0
	Clear_Msg:
	    MOV AL,UserMsg[BX]
    	MOV AL, '$'
    	MOV UserMsg[BX],AL
    	INC BX
    	
    	CMP UserMsg[BX], AL
    	JNE Clear_Msg
        
   MOV AL,0
   MOV UserMsgIndex,AL
   RET
ClearMsgString ENDP
;================================================================================================
                                ;Play chat sound
;================================================================================================
;Play send sound
PlayNotificationSound PROC
    
    ;Play send sound
	lea si, notificationSound
	mov ch,00h
    mov cl, notificationSoundNote
    CALL ProcessSound
	RET
	
PlayNotificationSound ENDP

;CALL the MACRO to process the sound
ProcessSound PROC
    
    SoundPlay
    RET
    
ProcessSound ENDP    
END