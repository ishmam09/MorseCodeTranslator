.MODEL SMALL          
.STACK 100H           
.DATA                 
    ;MENU MESSAGES(Raisa)
    MENU_TITLE      DB '--- MORSE CODE TRANSLATOR ---$'
    OPT1            DB '1. Text to Morse Code$'
    OPT2            DB '2. Morse Code to Text$'
    OPT3            DB '3. History Buffer$'
    OPT4            DB '4. Adjustable Morse Speed$'
    PROMPT_CHOICE   DB 0DH, 0AH, 'Enter your choice: $'
    PROMPT_TEXT     DB 0DH, 0AH, 'Enter Text (Press Enter): $'
    PROMPT_MORSE    DB 0DH, 0AH, 'Enter Morse (Use spaces for letters, / for words): $'
    RESULT_MSG      DB 0DH, 0AH, 'Result: $'
    INVALID_MSG     DB 0DH, 0AH, 'Error: Invalid Input!$' 
    PRESS_SPACE_MSG DB 0DH, 0AH, 'Press Space to go to Main Menu...$'
    
    ;Variables
    INPUT_BUF       DB 50           
                    DB ?            
                    DB 50 DUP('$')  
    TEMP_MORSE      DB 10 DUP('$')  
    
    ;Morse Code patterns
    M_A DB '.-$' 
    M_B DB '-...$' 
    M_C DB '-.-.$' 
    M_D DB '-..$' 
    M_E DB '.$' 
    M_F DB '..-.$'    
    M_G DB '--.$' 
    M_H DB '....$' 
    M_I DB '..$' 
    M_J DB '.---$' 
    M_K DB '-.$' 
    M_L DB '.-..$' 
    M_M DB '--$' 
    M_N DB '-.$' 
    M_O DB '---$' 
    M_P DB '.--.$' 
    M_Q DB '--.-$' 
    M_R DB '.-.$' 
    M_S DB '...$' 
    M_T DB '-$' 
    M_U DB '..-$' 
    M_V DB '...-$' 
    M_W DB '.--$' 
    M_X DB '-..-$' 
    M_Y DB '-.--$' 
    M_Z DB '--..$'
    M_0 DB '-----$'
    M_1 DB '.----$'
    M_2 DB '..---$'
    M_3 DB '...--$'
    M_4 DB '....-$'
    M_5 DB '.....$'
    M_6 DB '-....$'
    M_7 DB '--...$'
    M_8 DB '---..$'
    M_9 DB '----.$'
    
    ALPHABET_TABLE DW M_A, M_B, M_C, M_D, M_E, M_F, M_G, M_H, M_I, M_J, M_K, M_L, M_M, M_N, M_O, M_P, M_Q, M_R, M_S, M_T, M_U, M_V, M_W, M_X, M_Y, M_Z
    NUMBER_TABLE   DW M_0, M_1, M_2, M_3, M_4, M_5, M_6, M_7, M_8, M_9

    ;Feature History Buffer (Nahian)
    HISTORY_COUNT   DB 0                    
    MAX_HISTORY     EQU 5                   
    HISTORY_BUFFER  DB 250 DUP('$')        ; 5 entries x 50 chars each
    HISTORY_MSG     DB 0DH, 0AH, '--- TRANSLATION HISTORY ---$'
    NO_HISTORY_MSG  DB 0DH, 0AH, 'No history available.$'
    ENTRY_PREFIX    DB 0DH, 0AH, ' > $'
    
    ;Feature Adjustable Morse Speed (Nahian)
    MORSE_SPEED     DB 1                    ; 1=Slow, 2=Medium, 3=Fast
    SPEED_MSG       DB 0DH, 0AH, '--- MORSE SPEED SETTINGS ---$'
    SPEED_OPT1      DB 0DH, 0AH, '1. Slow$'
    SPEED_OPT2      DB 0DH, 0AH, '2. Medium$'
    SPEED_OPT3      DB 0DH, 0AH, '3. Fast$'
    CURRENT_SPEED   DB 0DH, 0AH, 'Current Speed: $'
    SPEED_SET_MSG   DB 0DH, 0AH, 'Speed updated!$'

.CODE                 
MAIN PROC             
    MOV AX, @DATA     
    MOV DS, AX        
    MOV ES, AX        

;Main Menu (Raisa)
SHOW_MENU:            
    MOV AH, 00h       
    MOV AL, 03h       
    INT 10h           

    CALL PRINT_NEWLINE 
    LEA DX, MENU_TITLE 
    MOV AH, 09H        
    INT 21H            
    
    CALL PRINT_NEWLINE 
    LEA DX, OPT1       
    MOV AH, 09H        
    INT 21H            
    CALL PRINT_NEWLINE 
    LEA DX, OPT2       
    MOV AH, 09H        
    INT 21H            
    CALL PRINT_NEWLINE 
    LEA DX, OPT3       
    MOV AH, 09H        
    INT 21H            
    CALL PRINT_NEWLINE 
    LEA DX, OPT4       
    MOV AH, 09H        
    INT 21H                    
    CALL PRINT_NEWLINE            

    LEA DX, PROMPT_CHOICE 
    MOV AH, 09H        
    INT 21H            

    MOV AH, 01H        
    INT 21H            
    
    CMP AL, '1'        
    JE START_TEXT_TO_MORSE
    CMP AL, '2'        
    JE START_MORSE_TO_TEXT
    CMP AL, '3'     
    JE SHOW_HISTORY
    CMP AL, '4'
    JE ADJUST_SPEED_MENU
    
    LEA DX, INVALID_MSG
    MOV AH, 09H
    INT 21H
    JMP WAIT_AND_MENU   
    

SHOW_HISTORY:       
    ;Calls Feature 4 Procedure (Nahian)           
    CALL DISPLAY_HISTORY            
    JMP WAIT_AND_MENU 
    
ADJUST_SPEED_MENU:     
    ;Calls Feature 5 Procedure (Nahian)             
    CALL ADJUST_SPEED               
    JMP WAIT_AND_MENU      

;Feature 2: Text to Morse (Ishmam)
START_TEXT_TO_MORSE:    
    CALL PRINT_NEWLINE 
    LEA DX, PROMPT_TEXT 
    MOV AH, 09H        
    INT 21H            

    LEA DX, INPUT_BUF 
    MOV AH, 0AH        
    INT 21H            
    
    CALL PRINT_NEWLINE 
    LEA DX, RESULT_MSG 
    MOV AH, 09H        
    INT 21H            

    LEA BX, INPUT_BUF + 2 
    MOV CH, 0          
    MOV CL, [INPUT_BUF+1] 
    
    CMP CL, 0          
    JE SHOW_MENU       

PROCESS_LOOP:         
    MOV AL, [BX]       
    CMP AL, ' '        
    JE PRINT_MORSE_SPACE    
    
    CMP AL, 'a'
    JB NOT_LOW
    CMP AL, 'z'
    JA NOT_LOW
    SUB AL, 32
NOT_LOW:
    CMP AL, 'A'
    JB CHECK_NUM_IN_TEXT
    CMP AL, 'Z'
    JA CHECK_NUM_IN_TEXT
    SUB AL, 'A'
    MOV AH, 0
    MOV SI, AX
    ADD SI, SI
    MOV DX, ALPHABET_TABLE[SI]
    JMP PRINT_M_STR

CHECK_NUM_IN_TEXT:
    CMP AL, '0'
    JB TEXT_INVALID_TRIGGER 
    CMP AL, '9'
    JA TEXT_INVALID_TRIGGER
    SUB AL, '0'
    MOV AH, 0
    MOV SI, AX
    ADD SI, SI
    MOV DX, NUMBER_TABLE[SI]

PRINT_M_STR:
    PUSH BX
    MOV BX, DX
    MOV AH, 09H
    INT 21H
    ;Calls Feature 6 Procedure (Ishmam)
    CALL PLAY_MORSE_SOUND
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    POP BX
    JMP NEXT_TEXT_ITERATION

PRINT_MORSE_SPACE:
    MOV DL, '/'
    MOV AH, 02H
    INT 21H

NEXT_TEXT_ITERATION:
    INC BX
    DEC CL
    JNZ PROCESS_LOOP
    ;Calls Feature 4 Procedure (Nahian)
    CALL SAVE_TO_HISTORY
    JMP WAIT_AND_MENU

TEXT_INVALID_TRIGGER:
    LEA DX, INVALID_MSG
    MOV AH, 09H
    INT 21H
    JMP WAIT_AND_MENU
;Feature 3: Morse to text (Raisa)
START_MORSE_TO_TEXT:
    CALL PRINT_NEWLINE
    LEA DX, PROMPT_MORSE
    MOV AH, 09H
    INT 21H

    LEA DX, INPUT_BUF
    MOV AH, 0AH
    INT 21H

    CALL PRINT_NEWLINE
    LEA DX, RESULT_MSG
    MOV AH, 09H
    INT 21H

    LEA SI, INPUT_BUF + 2 
    MOV CL, [INPUT_BUF + 1] 
    MOV CH, 0

DECODE_MAIN_LOOP:
    LEA DI, TEMP_MORSE    
    
EXTRACT_ONE_LETTER:
    MOV AL, [SI]
    ;Space detector here
    CMP AL, '/'
    JE HANDLE_WORD_SPACE

    CMP AL, '.'
    JE VALID_M
    CMP AL, '-'
    JE VALID_M
    CMP AL, ' '
    JE FIND_IN_TABLE
    CMP AL, 0DH 
    JE FIND_IN_TABLE
    JMP MORSE_ERR_LBL

VALID_M:
    MOV [DI], AL
    INC DI
    INC SI
    DEC CL
    JZ FIND_IN_TABLE
    JMP EXTRACT_ONE_LETTER

HANDLE_WORD_SPACE:
    MOV DL, ' '             
    MOV AH, 02H
    INT 21H
    INC SI                  
    DEC CL
    JZ WAIT_AND_MENU
    JMP DECODE_MAIN_LOOP    

FIND_IN_TABLE:
    MOV BYTE PTR [DI], '$' 
    PUSH SI
    PUSH CX
    
    MOV BX, 0 
COMPARE_START:
    MOV DX, ALPHABET_TABLE[BX] 
    LEA SI, TEMP_MORSE
    MOV DI, DX

COMPARE_STEP:
    MOV AL, [SI]
    MOV DL, [DI]
    CMP AL, DL
    JNE TRY_NEXT
    
    CMP AL, '$' 
    JE MATCH_SUCCESS
    
    INC SI
    INC DI
    JMP COMPARE_STEP

TRY_NEXT:
    ADD BX, 2
    CMP BX, 52 
    JB COMPARE_START
    JMP NO_MATCH

MATCH_SUCCESS:
    MOV AX, BX
    SHR AX, 1
    ADD AL, 'A'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP CLEANUP_TOKEN

NO_MATCH:
    CMP TEMP_MORSE, '$'   
    JE CLEANUP_TOKEN
    MOV DL, '?' 
    MOV AH, 02H
    INT 21H

CLEANUP_TOKEN:
    POP CX
    POP SI
    MOV AL, [SI]
    CMP AL, 0DH 
    JE WAIT_AND_MENU
    INC SI      
    DEC CL
    JG DECODE_MAIN_LOOP
DONE_DECODING:
    ;Calls Feature 4 Procedure (Nahian)
    CALL SAVE_TO_HISTORY
    JMP WAIT_AND_MENU

;Feature: Invalid input detector (Raisa)
MORSE_ERR_LBL:
    LEA DX, INVALID_MSG
    MOV AH, 09H
    INT 21H

WAIT_AND_MENU:
    CALL PRINT_NEWLINE
    LEA DX, PRESS_SPACE_MSG
    MOV AH, 09H
    INT 21H
WAIT_FOR_KEY:
    MOV AH, 07H
    INT 21H
    CMP AL, ' '
    JNE WAIT_FOR_KEY
    JMP SHOW_MENU

MAIN ENDP             

;Procedures

PRINT_NEWLINE PROC    
    MOV DL, 13        
    MOV AH, 02H        
    INT 21H            
    MOV DL, 10        
    MOV AH, 02H        
    INT 21H            
    RET                
PRINT_NEWLINE ENDP    
                    
;Feature Audio Beeps (Ishmam)
PLAY_MORSE_SOUND PROC 
    PUSH SI            
    MOV SI, BX        
S_LOOP:            
    MOV AL, [SI]       
    CMP AL, '$'        
    JE E_SOUND       
    CMP AL, '.'        
    JE D_DOT         
    CMP AL, '-'        
    JE D_DASH        
    JMP N_SOUND     
D_DOT:                
    CALL BEEP_DOT     
    JMP N_SOUND     
D_DASH:              
    CALL BEEP_DASH    
N_SOUND:            
    INC SI            
    JMP S_LOOP     
E_SOUND:            
    POP SI            
    RET                
PLAY_MORSE_SOUND ENDP 
             

;Procedure for Feature 6 (Ishmam)
BEEP_DOT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ;Play sound
    MOV AH, 02H
    MOV DL, 07H
    INT 21H

    ;Sound Duration Logic
    MOV AL, MORSE_SPEED
    CMP AL, 1
    JE DOT_SOUND_SLOW
    CMP AL, 2
    JE DOT_SOUND_MED
    JMP DOT_SOUND_FAST

DOT_SOUND_SLOW:
    MOV CX, 01H
    MOV DX, 0FFFFH
    MOV AH, 86H
    INT 15H
    MOV CX, 01H
    MOV DX, 0FFFFH
    MOV AH, 86H
    INT 15H
    JMP DOT_SILENCE_CHECK

DOT_SOUND_MED:
    MOV CX, 00H
    MOV DX, 0C350H
    MOV AH, 86H
    INT 15H
    JMP DOT_SILENCE_CHECK

DOT_SOUND_FAST:
    MOV CX, 00H
    MOV DX, 7530H
    MOV AH, 86H
    INT 15H

    ;Gap of sound
DOT_SILENCE_CHECK:
    MOV AL, MORSE_SPEED
    CMP AL, 1
    JE DOT_GAP_SLOW
    CMP AL, 2
    JE DOT_GAP_MED
    JMP DOT_GAP_FAST

DOT_GAP_SLOW:
    ;Slow mode
    MOV CX, 02H
    MOV DX, 0000H
    MOV AH, 86H
    INT 15H
    JMP DOT_EXIT

DOT_GAP_MED:
    ;Medium mode
    MOV CX, 00H
    MOV DX, 0C350H
    MOV AH, 86H
    INT 15H
    JMP DOT_EXIT

DOT_GAP_FAST:
    ;Fast mode
    MOV CX, 00H
    MOV DX, 7530H
    MOV AH, 86H
    INT 15H

DOT_EXIT:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
BEEP_DOT ENDP
;Procedure for Feature 6 (Ishmam)
BEEP_DASH PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ;Play sound
    MOV AL, MORSE_SPEED
    CMP AL, 1
    JE DASH_SOUND_SLOW
    CMP AL, 2
    JE DASH_SOUND_MED
    JMP DASH_SOUND_FAST

DASH_SOUND_SLOW:
    MOV BX, 6       ;6 times for long dash
SLOW_LOOP:
    MOV AH, 02H
    MOV DL, 07H
    INT 21H
    MOV CX, 00H
    MOV DX, 7530H
    MOV AH, 86H
    INT 15H
    DEC BX
    JNZ SLOW_LOOP
    JMP DASH_SILENCE_CHECK

DASH_SOUND_MED:
    MOV BX, 4       ;4 times
MED_LOOP:
    MOV AH, 02H
    MOV DL, 07H
    INT 21H
    MOV CX, 00H
    MOV DX, 7530H
    MOV AH, 86H
    INT 15H
    DEC BX
    JNZ MED_LOOP
    JMP DASH_SILENCE_CHECK

DASH_SOUND_FAST:
    MOV BX, 2       ;Loop 2 times
FAST_LOOP:
    MOV AH, 02H
    MOV DL, 07H
    INT 21H
    MOV CX, 00H
    MOV DX, 7530H
    MOV AH, 86H
    INT 15H
    DEC BX
    JNZ FAST_LOOP
    
;Silence between gaps
DASH_SILENCE_CHECK:
    MOV AL, MORSE_SPEED
    CMP AL, 1
    JE DASH_GAP_SLOW
    CMP AL, 2
    JE DASH_GAP_MED
    JMP DASH_GAP_FAST

DASH_GAP_SLOW:
    ;Long silence
    MOV CX, 02H
    MOV DX, 0000H
    MOV AH, 86H
    INT 15H
    JMP DASH_EXIT

DASH_GAP_MED:
    ;Medium silence 
    MOV CX, 00H
    MOV DX, 0C350H
    MOV AH, 86H
    INT 15H
    JMP DASH_EXIT

DASH_GAP_FAST:
    ;Short silence 
    MOV CX, 00H
    MOV DX, 7530H
    MOV AH, 86H
    INT 15H

DASH_EXIT:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
BEEP_DASH ENDP

;Feature 4: History Buffer (Nahian)
SAVE_TO_HISTORY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    MOV AL, HISTORY_COUNT
    CMP AL, MAX_HISTORY
    JB SAVE_DIRECT
    
    LEA SI, HISTORY_BUFFER + 50
    LEA DI, HISTORY_BUFFER
    MOV CX, 200
    REP MOVSB
    DEC HISTORY_COUNT
    
SAVE_DIRECT:
    MOV AL, HISTORY_COUNT
    MOV AH, 0
    MOV BX, 50
    MUL BX
    LEA DI, HISTORY_BUFFER
    ADD DI, AX
    
    LEA SI, INPUT_BUF + 2
    MOV CL, [INPUT_BUF + 1]
    MOV CH, 0
    
COPY_LOOP:
    LODSB
    STOSB
    LOOP COPY_LOOP
    
    MOV BYTE PTR [DI], '$'
    INC HISTORY_COUNT
    
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
SAVE_TO_HISTORY ENDP

;Procedure for History(Nahian)
DISPLAY_HISTORY PROC
    CALL PRINT_NEWLINE
    LEA DX, HISTORY_MSG
    MOV AH, 09H
    INT 21H
    
    MOV AL, HISTORY_COUNT
    CMP AL, 0
    JE NO_HIST
    
    LEA SI, HISTORY_BUFFER
    MOV CL, HISTORY_COUNT
    MOV CH, 0
    
PRINT_HIST_LOOP:
    LEA DX, ENTRY_PREFIX
    PUSH SI
    MOV AH, 09H
    INT 21H
    POP SI
    
    MOV DX, SI
    PUSH SI
    MOV AH, 09H
    INT 21H
    POP SI
    
    ADD SI, 50
    LOOP PRINT_HIST_LOOP
    JMP HIST_END
    
NO_HIST:
    LEA DX, NO_HISTORY_MSG
    MOV AH, 09H
    INT 21H
    
HIST_END:
    RET
DISPLAY_HISTORY ENDP
        
       
;Feature: Adjustable Morse Speed (Nahian)
ADJUST_SPEED PROC
    CALL PRINT_NEWLINE
    LEA DX, SPEED_MSG
    MOV AH, 09H
    INT 21H
    
    LEA DX, SPEED_OPT1
    MOV AH, 09H
    INT 21H
    
    LEA DX, SPEED_OPT2
    MOV AH, 09H
    INT 21H
    
    LEA DX, SPEED_OPT3
    MOV AH, 09H
    INT 21H
    
    CALL PRINT_NEWLINE
    LEA DX, CURRENT_SPEED
    MOV AH, 09H
    INT 21H
    ;Display current speed
    MOV AL, MORSE_SPEED
    CMP AL, 1
    JE SHOW_SLOW
    CMP AL, 2
    JE SHOW_MED
    LEA DX, SPEED_OPT3 + 6  ;"Fast"
    JMP SHOW_CURR
SHOW_SLOW:
    LEA DX, SPEED_OPT1 + 6  ;"Slow"
    JMP SHOW_CURR
SHOW_MED:
    LEA DX, SPEED_OPT2 + 6  ;"Medium"
SHOW_CURR:
    MOV AH, 09H
    INT 21H
    
    CALL PRINT_NEWLINE
    LEA DX, PROMPT_CHOICE
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    
    CMP AL, '1'
    JB SPEED_INVALID
    CMP AL, '3'
    JA SPEED_INVALID
    
    SUB AL, '0'
    MOV MORSE_SPEED, AL
    
    LEA DX, SPEED_SET_MSG
    MOV AH, 09H
    INT 21H
    JMP SPEED_END
    
SPEED_INVALID:
    LEA DX, INVALID_MSG
    MOV AH, 09H
    INT 21H
    
SPEED_END:
    RET
ADJUST_SPEED ENDP

END MAIN