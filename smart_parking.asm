;=========================================================
;              8051 SMART PARKING SYSTEM
;
; Microcontroller : 8051
;
; IR SENSOR CONNECTIONS
; P1.0 -> Parking Slot 1
; P1.1 -> Parking Slot 2
; P1.2 -> Parking Slot 3
; P1.3 -> Parking Slot 4
;
; LCD CONNECTION
; P2.0-P2.7 -> LCD D0-D7
; P3.0       -> LCD RS
; P3.1       -> LCD RW
; P3.2       -> LCD EN
;
; Sensor logic:
; 0 = Vehicle detected / Slot occupied
; 1 = Slot free
;=========================================================

ORG 0000H

;---------------------------------------------------------
; MAIN PROGRAM
;---------------------------------------------------------

START:

    MOV P1, #0FFH          ; Configure Port 1 as input

    MOV P2, #00H           ; Clear LCD data port

    CLR P3.0               ; RS = 0
    CLR P3.1               ; RW = 0
    CLR P3.2               ; EN = 0

    ACALL LCD_INIT

MAIN_LOOP:

    ;-----------------------------------------------------
    ; Read parking sensors
    ;-----------------------------------------------------

    MOV A, P1
    ANL A, #0FH

    ; Save sensor status
    MOV R7, A

    ;-----------------------------------------------------
    ; Display first line
    ;-----------------------------------------------------

    MOV A, #01H
    ACALL LCD_COMMAND

    MOV DPTR, #MSG1
    ACALL DISPLAY_STRING

    ;-----------------------------------------------------
    ; Calculate number of free slots
    ;-----------------------------------------------------

    MOV A, R7
    ANL A, #0FH

    MOV R6, #00H           ; R6 = free slot count

    ; Slot 1
    JB ACC.0, SLOT1_FREE
    SJMP CHECK_SLOT2

SLOT1_FREE:
    INC R6

CHECK_SLOT2:

    ; Slot 2
    JB ACC.1, SLOT2_FREE
    SJMP CHECK_SLOT3

SLOT2_FREE:
    INC R6

CHECK_SLOT3:

    ; Slot 3
    JB ACC.2, SLOT3_FREE
    SJMP CHECK_SLOT4

SLOT3_FREE:
    INC R6

CHECK_SLOT4:

    ; Slot 4
    JB ACC.3, SLOT4_FREE
    SJMP DISPLAY_RESULT

SLOT4_FREE:
    INC R6


DISPLAY_RESULT:

    ;-----------------------------------------------------
    ; Move LCD cursor to second line
    ;-----------------------------------------------------

    MOV A, #0C0H
    ACALL LCD_COMMAND

    ;-----------------------------------------------------
    ; Check whether parking is full
    ;-----------------------------------------------------

    MOV A, R6

    JZ PARKING_FULL

    ;-----------------------------------------------------
    ; Display "FREE SLOTS: "
    ;-----------------------------------------------------

    MOV DPTR, #MSG2
    ACALL DISPLAY_STRING

    ; Display number of free slots
    MOV A, R6
    ADD A, #30H
    ACALL LCD_DATA

    SJMP WAIT


PARKING_FULL:

    MOV DPTR, #MSG3
    ACALL DISPLAY_STRING


WAIT:

    ACALL DELAY

    SJMP MAIN_LOOP


;=========================================================
; LCD INITIALIZATION
;=========================================================

LCD_INIT:

    MOV A, #38H
    ACALL LCD_COMMAND

    MOV A, #0CH
    ACALL LCD_COMMAND

    MOV A, #01H
    ACALL LCD_COMMAND

    MOV A, #06H
    ACALL LCD_COMMAND

    RET


;=========================================================
; SEND COMMAND TO LCD
;=========================================================

LCD_COMMAND:

    MOV P2, A

    CLR P3.0               ; RS = 0
    CLR P3.1               ; RW = 0

    SETB P3.2              ; EN = 1
    ACALL LCD_DELAY
    CLR P3.2               ; EN = 0

    ACALL LCD_DELAY

    RET


;=========================================================
; SEND DATA TO LCD
;=========================================================

LCD_DATA:

    MOV P2, A

    SETB P3.0              ; RS = 1
    CLR P3.1               ; RW = 0

    SETB P3.2              ; EN = 1
    ACALL LCD_DELAY
    CLR P3.2               ; EN = 0

    ACALL LCD_DELAY

    RET


;=========================================================
; DISPLAY STRING
;=========================================================

DISPLAY_STRING:

NEXT_CHAR:

    CLR A
    MOVC A, @A+DPTR

    JZ STRING_END

    ACALL LCD_DATA

    INC DPTR

    SJMP NEXT_CHAR

STRING_END:

    RET


;=========================================================
; LCD DELAY
;=========================================================

LCD_DELAY:

    MOV R4, #20H

LCD_D1:

    MOV R5, #0FFH

LCD_D2:

    DJNZ R5, LCD_D2
    DJNZ R4, LCD_D1

    RET


;=========================================================
; GENERAL DELAY
;=========================================================

DELAY:

    MOV R3, #05H

D1:

    MOV R4, #0FFH

D2:

    MOV R5, #0FFH

D3:

    DJNZ R5, D3
    DJNZ R4, D2
    DJNZ R3, D1

    RET


;=========================================================
; MESSAGES
;=========================================================

MSG1:
    DB 'SMART PARKING',00H

MSG2:
    DB 'FREE SLOTS: ',00H

MSG3:
    DB 'PARKING FULL',00H


END
