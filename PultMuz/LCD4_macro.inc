;Макросы работы с LCD дисплеем
;==========================================================
.equ	LCD_CLR			= 0		; DB0: clear display
.equ	LCD_HOME		= 1		; DB1: return to home position

.equ	LCD_ENTRY_MODE  = 2		; DB2: set entry mode
.equ	LCD_ENTRY_INC   = 1		; DB1: increment
.equ	LCD_ENTRY_SHIFT	= 0		; DB2: shift

.equ	LCD_ON			= 3		; DB3: turn lcd/cursor on
.equ	LCD_ON_DISPLAY	= 2		; DB2: turn display on
.equ	LCD_ON_CURSOR	= 1		; DB1: turn cursor on
.equ	LCD_ON_BLINK	= 0		; DB0: blinking cursor

.equ	LCD_F			= 5		; DB5: function set
.equ	LCD_F_8B		= 4		; DB4: set 8BIT mode(1)/4BIT(0)
.equ	LCD_F_2L		= 3		; DB3: two lines(1)/one line(0)
.equ	LCD_F_10D		= 2		; DB2: 5x10 font(1)/5x7 font(0)

.equ	LCD_CGRAM		= 6		; DB6: set CG RAM address
.equ	LCD_DDRAM		= 7		; DB7: set DD RAM address
 
;Инициализация LCD
;==========================================================
.MACRO	INIT_LCD
	WR_CMD	(1<<LCD_F)|(0<<LCD_F_8B)
	WR_CMD	(1<<LCD_F)|(0<<LCD_F_8B)|(1<<LCD_F_2L)
	WR_CMD	(1<<LCD_CLR)
	WR_CMD	(1<<LCD_ENTRY_MODE)|(1<<LCD_ENTRY_INC)
	WR_CMD	(1<<LCD_ON)|(1<<LCD_ON_DISPLAY)|(0<<LCD_ON_CURSOR)
	WR_CMD	(1<<LCD_HOME)
.ENDM

;Write Data
;==========================================================
.MACRO	WR_DATA
	ldi	R17,@0
	rcall	DATA_WR
.ENDM

;Write CMD
;==========================================================
.MACRO	WR_CMD
	ldi	R17,@0
	rcall	CMD_WR
.ENDM

;LCD Clear
;==========================================================
.MACRO	LCDCLR
	ldi	R17,(1<<LCD_CLR)
	rcall	CMD_WR
.ENDM

;Write CGRAM
;==========================================================
.MACRO	WR_CGADR
	ldi	R17,(1<<LCD_CGRAM)|(@0)
	rcall	CMD_WR
.ENDM

;Write DDRAM
;==========================================================
.MACRO	WR_DDADR
	ldi	R17,(1<<LCD_DDRAM)|(@0)
	rcall	CMD_WR
.ENDM