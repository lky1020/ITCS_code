;BACS 1024 - Hardware to Hardware Communication
;Macros for internal PC Speaker

;On the Speakear
SpeakerOn MACRO
    ;TURN SPEAKER ON
    in      al, 61h         ; get speaker status
                            
    or      al, 00000011b   ; set lowest 2 bits to on for Timer 2 gate(speaker) && data
    out     61h, al         ; turn speaker on    
    
ENDM SpeakerOn


;Off the Speaker
SpeakerOff MACRO
    ;TURN SPEAKER OFF
    in      al, 61h         ; get speaker status
    
    and     al, 11111100b   ; clear lowest 2 bits to off timer 2 for gate(speaker) and data    
    out     61h, al         ;turn speaker off
    
ENDM SpeakerOff


;Set the pitch to be play
SetPitch MACRO
    ;Specify that timer channel 2 is to be used
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
    
ENDM SetPitch

;Delay the Sound
SoundPlay MACRO
    ;Turn Speaker ON
    SpeakerOn

    soundLoop:
        
        ;mov sound array(DW) to bx
        mov bx,[si]
        
        ;store cx(sound note) with dx
        mov dx,cx
        
        ;delay
        mov cx,delay1
        
            wait1:
                push cx         ;store delay1 into stack, to put delay2 into cx
                mov cx,delay2
                
            wait2:
                loop wait2      ;wait delay2 run finish
                
                pop cx          ;retrieve delay from stack
                loop wait1      ;wait delay1 run finish      
        
        ;Play Sound
        SetPitch
        
        ;word = +02h
        mov ax,0002h
        add si,ax
        
        mov cx,dx
        
        loop soundLoop    

    ;Turn Speaker OFF
    SpeakerOff
            
ENDM SoundPlay    

