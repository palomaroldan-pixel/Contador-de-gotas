     LIST P=16F887
    #include "p16f887.inc"

    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _LVP_OFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

             
    GOTAS	    EQU 0x20          
    DISP_UNIDADES   EQU 0X21    
    DISP_DECENAS    EQU	0X22   
    INDEX_DISPLAY   EQU 0X23   
    ESTADO_GOTA     EQU 0X24   
    PASOS           EQU 0X25   
    DELAY1          EQU 0X26
    DELAY2          EQU	0X27
    UART_DATO	    EQU 0X28
    COMANDO_MOTOR   EQU 0X29
    OBJETIVO_GOTAS  EQU 0X30
 
    W_TEMP	    EQU 0X70          
    STATUS_TEMP	    EQU 0X71
;======================================================================	
    ORG 0x0000
    GOTO INICIO

    ORG 0x0004
    GOTO ISR            

; ====================================================================

;tabla de catodo comun
TABLA
    ADDWF PCL, F
    RETLW b'00111111'   ; 0
    RETLW b'00000110'   ; 1
    RETLW b'01011011'   ; 2
    RETLW b'01001111'   ; 3
    RETLW b'01100110'   ; 4
    RETLW b'01101101'   ; 5
    RETLW b'01111101'   ; 6
    RETLW b'00000111'   ; 7
    RETLW b'01111111'   ; 8
    RETLW b'01101111'   ; 9


INICIO ;configuracion de puertos

    BANKSEL ANSEL
    BSF     ANSEL, 0    
    CLRF    ANSELH      
    
    BANKSEL TRISA
    BSF     TRISA, 0    
    
    BANKSEL TRISB
    MOVLW   b'00000011' 
    MOVWF   TRISB
    
    BANKSEL TRISC
    CLRF    TRISC      
    BSF	    TRISC, 7
    
    CLRF    TRISD 
      
    BANKSEL SPBRG
    MOVLW   D'25'         
    MOVWF   SPBRG

    BANKSEL TXSTA
    MOVLW   b'00100100'  
    MOVWF   TXSTA

    BANKSEL RCSTA
    MOVLW   b'10010000'   
    MOVWF   RCSTA
    
    BANKSEL ADCON1
    CLRF    ADCON1    
    
    BANKSEL ADCON0
    MOVLW   b'11000001' 
    MOVWF   ADCON0

    BANKSEL OPTION_REG
    MOVLW   b'00000100' 
    MOVWF   OPTION_REG

;configurar interrupciones
    BANKSEL PIE1
    BSF     PIE1, ADIE      
    BSF	    PIE1, RCIE
    
    BANKSEL INTCON
    BSF     INTCON, TMR0IE 
    BSF     INTCON, PEIE    
    BSF     INTCON, GIE    

;iniciar variables
    BANKSEL GOTAS
    CLRF    GOTAS
    CLRF    DISP_UNIDADES
    CLRF    DISP_DECENAS
    CLRF    INDEX_DISPLAY
    CLRF    COMANDO_MOTOR
    CLRF    OBJETIVO_GOTAS
    CLRF    PORTB       
    CLRF    PORTC       
    CLRF    PORTD       

    MOVLW   d'1'
    MOVWF   ESTADO_GOTA

; =================================================================
;codigo principal
LOOP

    BANKSEL ADCON0
    BTFSS ADCON0, GO_DONE
    BSF   ADCON0, GO_DONE

    BANKSEL COMANDO_MOTOR

    MOVF  COMANDO_MOTOR,W
    BTFSC STATUS,Z
    GOTO  LOOP

    MOVLW d'1'
    XORWF COMANDO_MOTOR,W
    BTFSC STATUS,Z
    GOTO  MOTOR_DER


    MOVLW d'2'
    XORWF COMANDO_MOTOR,W
    BTFSC STATUS,Z
    GOTO  MOTOR_IZQ

    GOTO LOOP

MOTOR_DER
    CLRF COMANDO_MOTOR
    CALL GIRO_DER
    GOTO LOOP

MOTOR_IZQ
    CLRF COMANDO_MOTOR
    CALL GIRO_IZQ
    GOTO LOOP    
    
; ====================================================================
;motor
GIRO_DER
    MOVLW   D'255'
    MOVWF   PASOS

LOOP_MOTOR
    MOVLW   b'00000001'
    MOVWF   PORTC
    CALL    DELAY
    DECFSZ  PASOS, F
    GOTO    PASO2
    GOTO    FIN_GIRO
PASO2
    MOVLW   b'00000010'
    MOVWF   PORTC
    CALL    DELAY
    DECFSZ  PASOS, F
    GOTO    PASO3
    GOTO    FIN_GIRO
PASO3
    MOVLW   b'00000100'
    MOVWF   PORTC
    CALL    DELAY
    DECFSZ  PASOS, F
    GOTO    PASO4
    GOTO    FIN_GIRO
PASO4
    MOVLW   b'00001000'
    MOVWF   PORTC
    CALL    DELAY
    DECFSZ  PASOS, F
    GOTO    LOOP_MOTOR
FIN_GIRO
    CLRF    PORTC
    RETURN
    
GIRO_IZQ
    MOVLW   D'255'
    MOVWF   PASOS
LOOP_IZQ
    MOVLW   b'00001000'
    MOVWF   PORTC
    CALL    DELAY
    DECFSZ  PASOS, F
    GOTO    PASO2I
    GOTO    FIN_GIRO
PASO2I
    MOVLW   b'00000100'
    MOVWF   PORTC
    CALL    DELAY
    DECFSZ  PASOS, F
    GOTO    PASO3I
    GOTO    FIN_GIRO
PASO3I
    MOVLW   b'00000010'
    MOVWF   PORTC
    CALL    DELAY
    DECFSZ  PASOS, F
    GOTO    PASO4I
    GOTO    FIN_GIRO
PASO4I
    MOVLW   b'00000001'
    MOVWF   PORTC
    CALL    DELAY
    DECFSZ  PASOS, F
    GOTO    LOOP_IZQ

DELAY
    MOVLW   D'80'
    MOVWF   DELAY1
L1
    MOVLW   D'120'
    MOVWF   DELAY2
L2
    DECFSZ  DELAY2, F
    GOTO    L2
    DECFSZ  DELAY1, F
    GOTO    L1
    RETURN

;envio de caracteres
TX_CHAR
    BANKSEL PIR1

ESPERA_TX
    BTFSS PIR1, TXIF    
    GOTO ESPERA_TX

    BANKSEL TXREG
    MOVWF TXREG          
    RETURN
 ;============================================   

DIVIDIR_DIGITOS
    CLRF    DISP_DECENAS
    MOVF    GOTAS, W
    MOVWF   DISP_UNIDADES
RESTA_10
    MOVLW   d'10'
    SUBWF   DISP_UNIDADES, W    
    BTFSS   STATUS, C           
    RETURN                      
    MOVWF   DISP_UNIDADES       
    INCF    DISP_DECENAS, F     
    GOTO    RESTA_10            

; ====================================================================
;interrupcion
ISR
 ;guardar contexto
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
;======================================================================    
    BANKSEL INDEX_DISPLAY       

    BTFSS   INTCON, TMR0IF      
    GOTO    ISR_ADC           
    GOTO    ISR_TMR0

;=============================================================================
ISR_TMR0
    CLRF    PORTB              
    
    BTFSC   INDEX_DISPLAY, 0
    GOTO    VER_DECENAS   

VER_UNIDADES
    MOVF    DISP_UNIDADES, W
    CALL    TABLA
    MOVWF   PORTD               
    BSF     PORTB, 6           
    BSF     INDEX_DISPLAY, 0
    GOTO    FIN_TMR0

VER_DECENAS
    MOVF    DISP_DECENAS, W
    CALL    TABLA
    MOVWF   PORTD               
    BSF     PORTB, 7            
    BCF     INDEX_DISPLAY, 0

FIN_TMR0
    BCF     INTCON, TMR0IF      
    GOTO    RESTAURAR
;======================================================
ISR_ADC
    BANKSEL PIR1
    BTFSS   PIR1, ADIF          
    GOTO    UART           

    BANKSEL ADRESH
    MOVF    ADRESH, W           

    BANKSEL ESTADO_GOTA
    BTFSC   ESTADO_GOTA, 0      
    GOTO    COMPROBAR_SALIDA
    
 ;esperar gota
    SUBLW   d'20'             
    BTFSS   STATUS, C           
    GOTO    FIN_ADC             
    
; cayo gota
BSF     ESTADO_GOTA,0
INCF    GOTAS,F

; sin objetivo
MOVF    OBJETIVO_GOTAS,W
BTFSC   STATUS,Z
GOTO    CONTROL_100

; con objetivo
MOVF    GOTAS,W
XORWF   OBJETIVO_GOTAS,W
BTFSS   STATUS,Z
GOTO    ACTUALIZAR_DISPLAY


CLRF    GOTAS
GOTO    ACTUALIZAR_DISPLAY

CONTROL_100
    MOVLW   d'100'
    SUBWF   GOTAS,W
    BTFSC   STATUS,Z
    CLRF    GOTAS

ACTUALIZAR_DISPLAY
    CALL DIVIDIR_DIGITOS
    GOTO FIN_ADC

COMPROBAR_SALIDA
   
    SUBLW   d'230'             
    BTFSC   STATUS, C           
    GOTO    FIN_ADC             
    BCF     ESTADO_GOTA, 0      

FIN_ADC
    BANKSEL PIR1
    BCF     PIR1, ADIF          

UART
    BANKSEL PIR1
    BTFSS PIR1,RCIF
    GOTO RESTAURAR

    BANKSEL RCREG
    MOVF  RCREG,W
    MOVWF UART_DATO
    
; comando A 
    MOVLW 'A'
    XORWF UART_DATO,W
    BTFSC STATUS,Z
    GOTO SET_20

; comando B 
    MOVLW 'B'
    XORWF UART_DATO,W
    BTFSC STATUS,Z
    GOTO SET_30
 
; comando D
    MOVLW 'D'
    XORWF UART_DATO,W
    BTFSS STATUS,Z
    GOTO VERIFICAR_I

    MOVLW d'1'
    BANKSEL COMANDO_MOTOR
    MOVWF COMANDO_MOTOR
    GOTO RESTAURAR

VERIFICAR_I
;comando I
    MOVLW 'I'
    XORWF UART_DATO,W
    BTFSS STATUS,Z
    GOTO RESTAURAR

    MOVLW d'2'
    BANKSEL COMANDO_MOTOR
    MOVWF COMANDO_MOTOR

    GOTO RESTAURAR

    
RESTAURAR
    ;recuperar contexto
    BANKSEL GOTAS
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE

SET_20
    MOVLW D'20'
    MOVWF OBJETIVO_GOTAS
    CALL OBJ_20
    GOTO RESTAURAR

SET_30
    MOVLW D'30'
    MOVWF OBJETIVO_GOTAS
    CALL OBJ_30
    GOTO RESTAURAR

OBJ_20
    MOVLW 'O'
    CALL TX_CHAR
    MOVLW 'b'
    CALL TX_CHAR
    MOVLW 'j'
    CALL TX_CHAR
    MOVLW ':'
    CALL TX_CHAR
    MOVLW '2'
    CALL TX_CHAR
    MOVLW '0'
    CALL TX_CHAR
    MOVLW ' '
    CALL TX_CHAR
    MOVLW 'g'
    CALL TX_CHAR
    MOVLW 'o'
    CALL TX_CHAR
    MOVLW 't'
    CALL TX_CHAR
    MOVLW 'a'
    CALL TX_CHAR
    MOVLW 's'
    CALL TX_CHAR
    MOVLW 0x0D
    CALL TX_CHAR
    MOVLW 0x0A
    CALL TX_CHAR
    
    RETURN
    

OBJ_30
    MOVLW 'O'
    CALL TX_CHAR
    MOVLW 'b'
    CALL TX_CHAR
    MOVLW 'j'
    CALL TX_CHAR
    MOVLW ':'
    CALL TX_CHAR
    MOVLW '3'
    CALL TX_CHAR
    MOVLW '0'
    CALL TX_CHAR
    MOVLW ' '
    CALL TX_CHAR
    MOVLW 'g'
    CALL TX_CHAR
    MOVLW 'o'
    CALL TX_CHAR
    MOVLW 't'
    CALL TX_CHAR
    MOVLW 'a'
    CALL TX_CHAR
    MOVLW 's'
    CALL TX_CHAR

    MOVLW 0x0D
    CALL TX_CHAR

    MOVLW 0x0A
    CALL TX_CHAR

    RETURN      
    END


