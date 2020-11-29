;================================================================================================
;Constant Variables That will not change in this system
;================================================================================================

;Main constants
WindowWidth                 EQU     80			;Fixed the overall program's window width
WindowHeight                EQU     25			;Fixed the height of the window
ChatWindowHeight			EQU		28			;Set for the height of the chat box
CurrentPage                 EQU     0			;Set the current page of the window, for display purpose
MaxUserNameSize             EQU     16			;The maximum length of the username in Main.asm
MaxMsgSize					EQU		200			;The maximum length of the message in chat.asm

;Keys codes
;ScanCode = For input Checking
;AsciiCode = For compare purpose
ESC_ScanCode                EQU     01H			
ESC_AsciiCode               EQU     1BH			
Enter_ScanCode              EQU     1CH
Enter_AsciiCode             EQU     0DH
Back_ScanCode               EQU     0EH
Back_AsciiCode              EQU     08H
F1_ScanCode                 EQU     3BH
F2_ScanCode                 EQU     3CH
F3_ScanCode                 EQU     3DH
F4_ScanCode                 EQU     3EH