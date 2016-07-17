;This code is de'assemblered by HOLYCHIP shanghai Ltd.. 
;Soft version 1.02
;Thanks for using, find any bug, please report it to HC!

	list p = HC18P010S, R=DEC
	#include "HC18P010s.inc"
	#include "reg.inc"		

          DATA	
;;CONST          
#Define PORTA_INI	b'00000000'	; PORTA端口初值 
#Define PORTB_INI	b'00100000'	; PORTB端口初值  

#Define TRISA_INI	b'00000000'	; PORTA方向初值  0 输出 1输入
#Define TRISB_INI	b'00001000'	; PORTB方向初值

#Define WPUB_INI	b'11111111'	; 上拉 0 使能 1禁止
#Define WPD_INI		b'11111111'	; 下拉 0 使能 1禁止 

#Define	OPTION_INI	b'10001000'	; X 上升沿下降沿 T0时钟源 T0计数沿选择 分频器派送 T0预分频1:2
#DEFINE T0_INI	        109		;156+1	4M/4T 200US	  

#DEFINE	PCON_INI	B'10111000'     ;WDT使能   外部int禁止	        
#DEFINE	IOCB_INI	B'00000000'     ;PB 中断和唤醒 0 禁止

#DEFINE	INTCON_INI	B'10100000'     ;B0=1，TM0中断使能   外部int禁止	 

;;;;;IO口定义
#DEFINE PIN_PWM		PORTB,5

;---------------------------------------------------

#Define C_RAM_START		0x20
#Define C_RAM_END		0x50

;;;;;;;RAM START HERE,优先使用20~3F的空间
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
	;开机最亮显示
	BSF	PIN_PWM
	GOTO	TIMEFLAG
	
MODE1:

	;一定时间后半亮显示
	MOVLW	B'00100000'
	XORWF	PORTB,F
	GOTO	TIMEFLAG
	
MODE2:

	;一定时间后关灯
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
	MOVLW	CONST_半亮_CONTINUE_TIME
	MOVWF	SET_TIME
	
TIMEFLAG_END:	
INT_EXIT:
        ;MOVF    PCLATH_TEMP,W
        ;MOVWF   PCLATH										
	SWAPF	STATUS_TEMP, W
	MOVWF	STATUS				;恢复STATUS
        SWAPF	W_TEMP, W			;恢复W		
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
;CLRF RAM 自加
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
	
	MOVLW	CONST_常亮_CONTINUE_TIME
	MOVWF	SET_TIME
	
;====================================================================	
;┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
;┃主循环							 ┃
;┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
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

