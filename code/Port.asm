;BACS 1024 - Hardware to Hardware Communication (Port Setting)
;Setting for Main and Chat Module (COM1 && COM2 connection)

;Serial Port address location for COM with value 3F8H
COMPAddressLocation EQU 3F8H

;Initialize the Port Setting
InitSerialPort MACRO
    
    ;set baud rate
    ;====================================================================================
    ;Set divisor latch access bit, for setting the baud rate
    MOV DX, COMPAddressLocation+3   ;Line control register (3FB)
    MOV AL, 10000000b               ;Set Divisor Latch Access Bit to true(Bit 7)
    OUT DX, AL                      ;Output AL to LCR
    
    
    ;Set the least significant byte of the Baud rate divisor latch register(3F8H)
    MOV DX, COMPAddressLocation     ;3F8H
    MOV AL, 0CH                     ;9600 Bps for baud rate (3F8H)
    OUT DX, AL                      ;Output AL for the Baud rate divisor latch register 
    
    
    ;Set the most significant byte of the Baud rate divisor latch register(3F9H)
    MOV DX, COMPAddressLocation+1   ;3F9H
    MOV AL, 0                       ;9600 Bps for baud rate (3F9H)
    OUT DX, AL                      ;Output AL for the Baud rate divisor latch register
    ;====================================================================================
    
    ;set serial port
    ;====================================================================================
    ;configuration for the serial port (After set the baud rate)
    MOV DX, COMPAddressLocation+3   ;Line Control Register (3FB)    
    MOV AL, 00011011B               
    ;Bit 7 = 0          :Access to receiver and transmitter buffers
    ;Bit 6 = 0          :Set break disabled
    ;Bit 5,4,3 = 011    :Even parity
    ;Bit 2 = 0          :One stop bit
    ;Bit 0,1 = 11       :8-bit word length
    OUT DX, AL          ;Output AL to LCR for the serial port
    ;====================================================================================

ENDM InitPort

;Send Character Through Serial Port
;LSR - Return current communication status (Empty or not)
SendCharTo MACRO InChar
    LOCAL Send
    
    Send:
        MOV DX, COMPAddressLocation+5   ;Line Status Register (3FD) that read only
        IN AL, DX                       ;Get the input from LSR (current communication status)
        
        AND AL, 00100000B               ;Check Transmitter Holding Register Status: 1 (transmmit buffer empty), Otherwise 0
        JZ Send                         ;Loop again if transmitter is not ready (ZF = 0)
        
        MOV DX, COMPAddressLocation
        MOV AL, InChar                  
        OUT DX, AL                      ;Output character to COM
        
ENDM SendCharTo

;Receive a character from the serial port into AL
;LSR - Return current communication status (Has Character or not)
ReceiveCharFrom MACRO
    LOCAL Return
    
    MOV AL, 0
    MOV DX, COMPAddressLocation+5       ;Line Status Register (3FD) that read only    
    IN AL, DX                           ;Get the input from LSR (current communication status)
    
    AND AL, 00000001B                   ;Check for data ready: 1 = data available (receive)
    JZ Return                           ;No Character Received
    
    MOV DX, COMPAddressLocation         ;Receive Data Register
    IN AL, DX                           ;Get the character from COM
    
    Return:
    
ENDM ReceiveCharFrom
