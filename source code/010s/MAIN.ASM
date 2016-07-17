;This code is de'assemblered by HOLYCHIP shanghai Ltd.. 
;Soft version 1.02
;Thanks for using, find any bug, please report it to HC!

	list p = HC18P010S, R=DEC
	#include "HC18P010s.inc"
	#include "reg.inc"		

          DATA	
;;CONST          
#Define PORTA_INI	b'00000000'	; PORTA�˿ڳ�ֵ 
#Define PORTB_INI	b'00100000'	; PORTB�˿ڳ�ֵ  

#Define TRISA_INI	b'00000000'	; PORTA�����ֵ  0 ��� 1����
#Define TRISB_INI	b'00001000'	; PORTB�����ֵ

#Define WPUB_INI	b'11111111'	; ���� 0 ʹ�� 1��ֹ
#Define WPD_INI		b'11111111'	; ���� 0 ʹ�� 1��ֹ 

#Define	OPTION_INI	b'10001000'	; X �������½��� T0ʱ��Դ T0������ѡ�� ��Ƶ������ T0Ԥ��Ƶ1:2
#DEFINE T0_INI	        109		;156+1	4M/4T 200US	  

#DEFINE	PCON_INI	B'10111000'     ;WDTʹ��   �ⲿint��ֹ	        
#DEFINE	IOCB_INI	B'00000000'     ;PB �жϺͻ��� 0 ��ֹ

#DEFINE	INTCON_INI	B'10100000'     ;B0=1��TM0�ж�ʹ��   �ⲿint��ֹ	 

;;;;;IO�ڶ���
#DEFINE PIN_PWM		PORTB,5

;---------------------------------------------------

#Define C_RAM_START		0x20
#Define C_RAM_END		0x50

;;;;;;;RAM START HERE,����ʹ��20~3F�Ŀռ�
MODE		EQU	0X20
CNT_10MS	EQU	0X21
CNT_2S		EQU	0X22
CNT_2MIN	EQU	0X23
FLAG_BYTE	EQU	0X24
#DEFINE		F_KEYLOCK_BIT	FLAG_BYTE,0
#DEFINE		F_2MS_BIT	FLAG_BYTE,1
#DEFINE		F_SLEEP_BIT	FLAG_BYTE,2
CNT_1H		EQU	0X25
CNT_40US	EQU	0X26
SET_TIME	EQU	0X27

PCLATH_TEMP	EQU       0X3D 
STATUS_TEMP     EQU       0X3E
W_TEMP          EQU       0X3F


;********************************************
;               CODE START                  
;********************************************
        CODE

        ORG     0000H	
        GOTO    RESET  
        GOTO    RESET   
	GOTO    RESET   
        GOTO    RESET        
                
        ORG     0004H  						
INTPROGRAM:		

	MOVWF	W_TEMP
	SWAPF	W_TEMP,F	; SAVE W
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	; SAVE STATUS
     
	BTFSS	T0IF		;200us
	GOTO	INT_EXIT
	BCF	T0IF
	
	MOVLW	T0_INI
	MOVWF	T0
		
	movlw	b'00010000'
	xorwf	PORTB,f
PWM_OUTPUT:

	MOVF	MODE,W
	BTFSC	Z
	GOTO	MODE0
	BTFSC	MODE,0
	GOTO	MODE1
	GOTO	MODE2
	
MODE0:
	;����������ʾ
	BSF	PIN_PWM
	GOTO	TIMEFLAG
	
MODE1:

	;һ��ʱ��������ʾ
	MOVLW	B'00100000'
	XORWF	PORTB,F
	GOTO	TIMEFLAG
	
MODE2:

	;һ��ʱ���ص�
	BCF	PIN_PWM
	GOTO	INT_EXIT
	
TIMEFLAG:
	
	INCF	CNT_40US,F
	MOVLW	D'250'
	SUBWF	CNT_40US,W
	BTFSS	C
	GOTO	TIMEFLAG_END
	CLRF	CNT_40US		;10MS IS DUE
	INCF	CNT_10MS,F
	MOVLW	D'200'
	SUBWF	CNT_10MS,W
	BTFSS	C
	GOTO	TIMEFLAG_END
	CLRF	CNT_10MS		;2S IS DUE
	INCF	CNT_2S,F
	MOVLW	D'60'
	SUBWF	CNT_2S,W
	BTFSS	C
	GOTO	TIMEFLAG_END
	CLRF	CNT_2S			;2MIN IS DUE
	INCF	CNT_2MIN,F
	MOVLW	D'30'
	SUBWF	CNT_2MIN,W
	BTFSS	C
	GOTO	TIMEFLAG_END
	CLRF	CNT_2MIN		;1H IS DUE
	INCF	CNT_1H,F
	MOVF	SET_TIME,W
	SUBWF	CNT_1H,W
	BTFSS	C
	GOTO	TIMEFLAG_END
MODE_CHANGE:

	CLRF	CNT_1H
	INCF	MODE,F
	MOVLW	CONST_����_CONTINUE_TIME
	MOVWF	SET_TIME
	
TIMEFLAG_END:	
INT_EXIT:
        ;MOVF    PCLATH_TEMP,W
        ;MOVWF   PCLATH										
	SWAPF	STATUS_TEMP, W
	MOVWF	STATUS				;�ָ�STATUS
        SWAPF	W_TEMP, W			;�ָ�W		
	RETFIE					

;***************************************  	   
RESET:   
        CLRF    INTCON
	CLRF	PCON    
 	CLRWDT
;***************************************   

PORT_INI:

	MOVLW	PORTA_INI
	MOVWF	PORTA
		
	MOVLW	TRISA_INI
	MOVWF	TRISA
		
	MOVLW	PORTB_INI
	MOVWF	PORTB

	MOVLW	TRISB_INI
	MOVWF	TRISB
	
	MOVLW	WPUB_INI
	MOVWF	WPUB	

	MOVLW	WPD_INI
	MOVWF	WPD
	
	MOVLW	IOCB_INI
	MOVWF	IOCB	

;***************************************      
;IO

;***************************************	
;***************************************	
;CLRF RAM �Լ�
;#Define C_RAM_START		0x10
;#Define C_RAM_END		0xC0
	
	MOVLW	C_RAM_START
	MOVWF	FSR
	
_INI_RAM_Loop:

	CLRF	INDF
	INCF	FSR, F

        MOVF    FSR,W
	XORLW	C_RAM_END 
	BTFSS	Z         
	GOTO	_INI_RAM_Loop 
	
;***************************************	

MAIN_INI0:

	MOVLW	OPTION_INI		 
	MOVWF	OPTION

	MOVLW	T0_INI
        MOVWF   T0

	BCF	T0IF
	
	MOVLW	PCON_INI
	MOVWF	PCON
	
	MOVLW   INTCON_INI
	MOVWF   INTCON
	
	MOVLW	CONST_����_CONTINUE_TIME
	MOVWF	SET_TIME
	
;====================================================================	
;������������������������������������������������������������������
;����ѭ��							 ��
;������������������������������������������������������������������
MAINLOOP:

	CLRWDT
	GOTO	MAINLOOP


;********************************************
        ORG     03FFH                   ;       
        GOTO    RESET                           
        END


;********************************************
;               CODE END                    
;********************************************
