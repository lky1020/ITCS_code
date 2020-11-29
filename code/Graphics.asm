;BACS 1024 Assignment Hardware to Hardware Com (Layout Function Setting)

;Set cursor position to (X, Y) in PageNum
SetCursorPos MACRO X, Y, PageNum
    MOV AH, 02H                 ;To Set the Cursor Position
    MOV BH, PageNum             ;Set the current page number for display (page number 0...7)
    MOV DH, Y                   ;Set the Position of Y-Coordinate (Row)
    MOV DL, X                   ;Set the Position of X-Coordinate (Column)
    INT 10H                     ;Interrupt
ENDM SetCursorPos

;Get cursor position in PageNum: DH=Y, DL=X
GetCursorPos MACRO PageNum
    MOV AH, 03H                 ;To Get the Cursor Position and size
    MOV BH, PageNum             ;Set the current page number
    INT 10H     
ENDM GetCursorPos

;Scroll up or clear screen from (x1, y1) to (x2, y2)
ScrollUp MACRO X1, Y1, X2, Y2, LinesCount
    MOV AH, 06H                 ;Scroll up window (07H - scroll down window)
    MOV AL, LinesCount          ;number of lines by which to scroll (00H = clear entire window)
    MOV BH, 07H                 ;Attribute used to write blank lines at bottom of window
    MOV CH, Y1                  ;Column of window's upper left corner
    MOV CL, X1                  ;Row of window's upper left corner
    MOV DH, Y2                  ;Row of window's upper left corner
    MOV DL, X2                  ;Column of window's lower left corner
    INT 10H
ENDM ScrollUp

;Clear portion of screen from (x1, y1) to (x2, y2)
ClearScreen MACRO X1, Y1, X2, Y2
    MOV AX, 0600H
    MOV BH, 07H
    MOV CL, X1
    MOV CH, Y1
    MOV DL, X2
    MOV DH, Y2
    INT 10H
ENDM ClearScreen

;Display a character number of times with a certain color
PrintColoredChar MACRO Char, Color, Cnt, PageNum
    MOV AH, 09H         ;Display
    MOV BH, PageNum     ;Set the current page number for display (page number 0...7)
    MOV AL, Char        ;Character to display
    MOV BL, Color       ;Color(back:fore)
    MOV CX, Cnt         ;Number of times
    INT 10H
ENDM PrintColoredChar

;Draw pixel in (X, Y) position with certain color
DrawPixel MACRO X, Y, Color
    MOV AH, 0CH         ;Change Color for a single pixel
    MOV AL, Color       ;Pixel color
    MOV CX, X           ;column
    MOV DX, Y           ;row
    INT 10H
ENDM DrawPixel

;Draw a vertical line starting from (X, Y) with a certain length and width
;HorizontalWidth = number of times that wanted to display
DrawLine MACRO StartX, StartY, VerticalLength, HorizontalWidth, Char, Color, PageNum
    LOCAL Back
    
    MOV SI, 0
    
    Back:
        MOV CX, SI
        ADD CL, StartY
        SetCursorPos StartX, CL, PageNum
        PrintColoredChar Char, Color, HorizontalWidth, PageNum
        
        INC SI
        CMP SI, VerticalLength
        JB Back
ENDM DrawHorizontalLine