;BACS 1024 - Hardware to Hardware Communication (Port Setting)
;Setting for Chat Module

;Set Computer Address Location to 3F8H
COMPAddLoc EQU 3F8H

;Initialize the Port Setting
InitPort MACRO

    ;Setting for Divisor Latch Register
    MOV DX, COMPAddLoc+3    ;Line control register
    MOV AL, 10000000b       ;AL = -128
    OUT DX, AL              ;Output byte in AL to I/O port address in DX.

    MOV DX, COMPAddLoc
    MOV AL, 0CH
    OUT DX, AL

    MOV DX, COMPAddLoc+1
    MOV AL, 0
    OUT DX, AL

    ;configurations
    MOV DX, COMPAddLoc+3    
    MOV AL, 00011011B
    OUT DX, AL

ENDM InitPort

;Send and Receive Character Through Serial Port
SendCharTo MACRO InChar
    LOCAL Send
    Send:
    MOV DX, COMPAddLoc+5    ;Line Status Register
    IN AL, DX
    AND AL, 00100000B       ;Check Transmitter Holding Register Status: 1 Ready, Otherwise 0
    JZ Send                 ;Transmitter not ready
    MOV DX, COMPAddLoc
    MOV AL, InChar
    OUT DX, AL
ENDM SendCharTo

;Receive a character from the serial port into AL
ReceiveCharFrom MACRO
    LOCAL Return
    MOV AL, 0
    MOV DX, COMPAddLoc+5    
    IN AL, DX
    AND AL, 00000001B       ;Check for Data Ready
    JZ Return               ;No Character Received
    MOV DX, COMPAddLoc      ;Receive Data Register
    IN AL, DX
    Return:
ENDM ReceiveCharFrom
