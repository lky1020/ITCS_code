DrawChatArea MACRO Y, Username
    ;Draw separator line
    DrawLine 0, Y, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage
    
    ;Print user name
    SetCursorPos ChatMargin, Y+1, CurrentPage
    DisplayStr Username
    
    ;Draw line under username
    DrawLine 0, Y+2, 1, MaxUserNameSize+1, ChatLineChar, ChatLineColor, CurrentPage
ENDM DrawChatArea
;===============================================================

;Draw the chatting information bar
DrawInfoBar MACRO Y
    ;Draw begin separator
    DrawLine 0, Y, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage
    ;Print info message
    SetCursorPos ChatMargin, Y+1, CurrentPage
    DisplayStr EndChatMsg
    ;Draw end separator
    DrawLine 0, Y+2, 1, ChatAreaWidth, ChatLineChar, ChatLineColor, CurrentPage
ENDM DrawInfoBar
;===============================================================

;Process a given user input. Called from within a procedure
;User = 1 (Send)
;User = 2 (Receive)
ProcessInput MACRO Char, X, Y, OffsetY, User       
    LOCAL CheckEscape, CheckEnter, CheckBackspace, CheckPrintable, AdjustCursorPos, Return
    ;Check if ESC is pressed
    CheckEscape:
    CMP Char, ESC_AsciiCode
    JNE CheckBackspace
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
    DEC UserMsgIndex
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

    DisplayInStr Char, X, Y, OffsetY
        
    ;==================================

    ;Check if printable character is pressed
    CheckPrintable:
    CMP Char, ' '   ;Compare with lowest printable ascii value
    JB Return
    CMP Char, '~'   ;Compare with highest printable ascii value
    JA Return
    
    ;Print char
    SetCursorPos X, Y, CurrentPage
    DisplayChar Char
    
    ;If receive, no character store needed
    MOV AL, 1h
    AND AL, User        ;0001(1) AND 0001(1) = 0001(1) 
    CMP AL, 1
    JNE AdjustCursorPos
    
    ;store char
    MOV BH, 0h
    MOV BL, UserMsgIndex
    
    MOV AL,Char
    MOV UserMsg[BX], AL
    INC UserMsgIndex

    ;==================================
    
    ;Adjust new cursor position after printing the character
    AdjustCursorPos:
    INC X
    CMP X, ChatAreaWidth-ChatMargin
    JL Return
    MOV X, ChatMargin
    INC Y

    ;==================================
    
    Return:
ENDM ProcessInput
;===============================================================

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
            
            ;Check whether is last character
            MOV AL, 0DH
            MOV BH, 0H
            MOV BL, UserMsgIndex
            CMP SI, BX
            JE Sending 

        JMP Checking

    ;Scroll chat area one step up if chat area is full
    Scroll:
        CALL ClearMsgString
        
        CMP Y, ChatAreaHeight+OffsetY-1
        JBE Return
        DEC Y
        ScrollUp ChatMargin, OffsetY+3, ChatAreaWidth-ChatMargin, ChatAreaHeight+OffsetY-1, 1

    
    Return:
    RET
ENDM DisplayInStr
;===============================================================
;Includes
INCLUDE code\Consts.asm
INCLUDE code\Graphics.asm
INCLUDE code\Keyboard.asm
INCLUDE code\Port.asm


;Public variables and procedures
PUBLIC ReadyToChat

;External variables and procedures
EXTRN UserName1:BYTE
EXTRN UserName2:BYTE
;===============================================================

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
;==========================================

;Screen adjust variables
ChatAreaWidth               EQU     WindowWidth
ChatAreaHeight              EQU     (WindowHeight-3)/2
ChatMargin                  EQU     1
ChatLineColor               EQU     0FH
ChatLineChar                DB      '-'

;===============================================================

.CODE
;Start chat room between the two players
ReadyToChat PROC FAR
    CALL InitChatRoom

    Chat_Loop:

    ;Set the cursor to the primary user chat area
    SetCursorPos User1CursorX, User1CursorY, CurrentPage
    
    ;Get primary user input and send it to secondary user
    Chat_Send:
    
        GetKeyPressAndFlush
        JZ Chat_Receive                 ;Skip processing user input if no key is pressed
        MOV ChatSentChar, AL
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
;===============================================================

;Initialize chat room
InitChatRoom PROC
    ;Clear the entire screen
    ClearScreen 0, 0, WindowWidth, WindowHeight
    
    ;Draw both users chatting area
    DrawChatArea 0, UserName1
    DrawChatArea ChatAreaHeight, UserName2
    
    ;Draw information bar
    DrawInfoBar ChatAreaHeight*2
    
    ;Set chat variables
    MOV User1CursorX, ChatMargin
    MOV User1CursorY, 3
    MOV User2CursorX, ChatMargin
    MOV User2CursorY, ChatAreaHeight+3
    MOV IsChatEnded, 0
    
    RET
InitChatRoom ENDP
;===============================================================

;Process primary user input
ProcessPrimaryInput PROC
    ProcessInput ChatSentChar, User1CursorX, User1CursorY, 0, 1
    RET
ProcessPrimaryInput ENDP
;===============================================================

;Process secondary user input
ProcessSecondaryInput PROC
    ProcessInput ChatReceivedChar, User2CursorX, User2CursorY, ChatAreaHeight, 2
    RET
ProcessSecondaryInput ENDP
;===============================================================
;Clear string
ClearMsgString  PROC
   
    ;Clear msg for user1 
	MOV BX,0
	Clear_Msg:
	    mov al,UserMsg[BX]
    	MOV al, '$'
    	mov UserMsg[BX],al
    	INC BX
    	
    	CMP UserMsg[BX], al
    	JNE Clear_Msg
        
   MOV al,0
   MOV UserMsgIndex,al
   ret 
ClearMsgString ENDP
;================================================================


END