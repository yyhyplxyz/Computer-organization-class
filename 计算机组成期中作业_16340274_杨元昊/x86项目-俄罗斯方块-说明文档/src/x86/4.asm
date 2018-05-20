assume cs:code,ds:data,ss:stack
data segment

SCREEN_COLOR		dw	0700H
SCREEN_LOCTION		dw	160*3

SCREEN_ROW		dw	19
SCREEN_COL		dw	16


NEXT_ROW		dw	160

					;0123456789ABCDEF
SCREEN			db	18 dup ('1000000000000001')
			db		'1111111111111111'


BLOCK_O			db	'1100'
			db	'1100'
			db	'0000'
			db	'0000'

BLOCK_I			db	'0000'
			db	'1111'
			db	'0000'
			db	'0000'

			db	'0100'
			db	'0100'
			db	'0100'
			db	'0100'

BLOCK_S			db	'0000'
			db	'0110'
			db	'1100'
			db	'0000'

			db	'0100'
			db	'0110'
			db	'0010'
			db	'0000'

BLOCK_Z			db	'0000'
			db	'1100'
			db	'0110'
			db	'0000'

			db	'0010'
			db	'0110'
			db	'0100'
			db	'0000'

BLOCK_T			db	'0100'
			db	'1110'
			db	'0000'
			db	'0000'

			db	'0100'
			db	'0110'
			db	'0100'
			db	'0000'

			db	'0000'
			db	'1110'
			db	'0100'
			db	'0000'

			db	'0100'
			db	'1100'
			db	'0100'
			db	'0000'

BLOCK_J			db	'0010'
			db	'0010'
			db	'0110'
			db	'0000'

			db	'0000'
			db	'1000'
			db	'1110'
			db	'0000'

			db	'0110'
			db	'0100'
			db	'0100'
			db	'0000'

			db	'0000'
			db	'1110'
			db	'0010'
			db	'0000'

BLOCK_L			db	'0100'
			db	'0100'
			db	'0110'
			db	'0000'

			db	'0000'
			db	'1110'
			db	'1000'
			db	'0000'

			db	'0110'
			db	'0010'
			db	'0010'
			db	'0000'

			db	'0000'
			db	'0010'
			db	'1110'
			db	'0000'


BLOCK			dw	OFFSET BLOCK_O
			dw	OFFSET BLOCK_I
			dw	OFFSET BLOCK_S
			dw	OFFSET BLOCK_Z
			dw	OFFSET BLOCK_T
			dw	OFFSET BLOCK_J
			dw	OFFSET BLOCK_L

BLOCK_MAX_ROW		dw	2,4,3,3,3,3,3
BLOCK_MAX_COL		dw	2,4,3,3,3,3,3

BLOCK_ROW		dw	4
BLOCk_COL		dw	4

BLOCK_COLOR		dw	2201H

LEFT			db	4BH
RIGHT			db	4DH
DOWN			db	50H
BLANK			db	39H

BACK_GROUND_COLOR	dw	0030H

isAllowMoveDown		dw	1

BUTTON_BLOCK_COLOR	dw	4432H

BLOCK_HIGH		dw	4000

BLOCK_MAX_STATUS	dw	0,1,1,1,3,3,3
BLOCK_STATUS		dw	0
BLOCK_NOW_STATUS	dw	0
BLOCK_ORG_STATUS	dw	0


string			db	'GAME OVER',0

data ends


stack segment stack
	db	128 dup (0)
stack ends


code segment

	start:	mov ax,stack
		mov ss,ax
		mov sp,128
		call sav_old_int9
		call set_new_int9
		call cpy_Tetris
		mov bx,0
		push bx
		mov bx,9000H
		push bx
		retf
		mov ax,4C00H
		int 21H
;============================================================
Tetris:		call init_reg ;实现寄存器的清空
		call clear_screen ;实现屏幕的清空
		call init_screen ;实现屏幕中边界的绘制
		call init_block_high ;实现方块高度的初始化


nextBlock:	cli
		call init_block_type
		call init_block_loction
		call check_game_over
		call print_block
		sti

nextDelay:	call delay
		cli
		call isMoveDown
		cmp isAllowMoveDown,1
		je isNextDelay
		sti
		jmp nextBlock

isNextDelay:	sti
		jmp nextDelay

;==============================================================
check_game_over:
		push bx
		push si

		mov cx,BLOCK_ROW

checkGameOver:	push cx
		push bx
		mov cx,BLOCK_COL

gOver:		cmp byte ptr ds:[si],'1'
		jne nextCol_gOver
		cmp byte ptr es:[bx],'0'
		jne GameOver
nextCol_gOver:	add bx,2
		inc si
		loop gOver

		pop bx
		pop cx
		add bx,NEXT_ROW
		loop checkGameOver
		pop si
		pop bx
		ret
;==============================================================
GameOver:	add sp,6

		call clear_screen
		mov si, OFFSET string ;si存储了string的地址
		mov di,160*10 + 35*2 ;显示位置
		call show_string
		mov ax,4C00H ;退出程序，调用程序中断
		int 21H


;==============================================================
show_string:	push dx
		push si
		push ds

showString:	mov dl,ds:[si] ;dl得到了存储的数据 string
		cmp dl,0
		je getStringRet; 当所有字符都输出完毕后，调用结束语句
		mov es:[di],dl ;真正显示数据
		inc si
		add di,2
		jmp showString


getStringRet:	pop ds ;将原有的各个寄存器中数据做个保存
		pop si
		pop dx
		ret
;==============================================================
delay:		push ax
		push dx
		mov dx,8000H
		mov ax,0
delaying:	sub ax,1000H
		sbb dx,0
		cmp dx,0
		jne delaying
		pop dx
		pop ax
		ret
;==============================================================
init_block_high:
		mov BLOCK_HIGH,4000
		ret
;==============================================================
print_block:	push bx
		push si

		mov cx,BLOCK_ROW
		mov dx,BLOCK_COLOR

printBlock:	push cx
		push bx
		push si
		mov cx,BLOCK_COL

printRow:	cmp byte ptr ds:[si],'1'
		jne printCol
		mov es:[bx],dx
printCol:	add bx,2
		inc si
		loop printRow
		pop si
		pop bx
		pop cx
		add si,4
		add bx,NEXT_ROW
		loop printBlock
		pop si
		pop bx
		ret
;==============================================================
init_block_loction:
		mov bx,SCREEN_LOCTION
		add bx,7*2
		ret
;==============================================================
init_block_type:
		call get_block_type
		mov si,ds:BLOCK[bx]  ;方块的首地址
		push ds:BLOCK_MAX_ROW[bx]
		pop BLOCK_ROW  ;得到方块的行数
		push ds:BLOCK_MAX_COL[bx]
		pop BLOCK_COL  ;得到方块的列数
		mov isAllowMoveDown,1
		push ds:BLOCK_MAX_STATUS[bx]
		pop BLOCK_STATUS
		mov BLOCK_ORG_STATUS,si
		mov BLOCK_NOW_STATUS,0
		ret

;==============================================================
;随机得到一个一组方块的形状
get_block_type:	push ax
		push dx

		mov dx,0

		mov al,0
		out 70H,al
		in al,71H

		mov dl,al

		shr al,1
		shr al,1
		shr al,1
		shr al,1

		mov bl,10

		mul bl

		add ax,dx

		mov dx,0

		mov bx,7
		div bx

		mov bx,dx
		add bx,bx
		pop dx
		pop ax
		ret
;==============================================================
; 初始化屏幕样式
init_screen:	mov bx,SCREEN_LOCTION
		mov si,OFFSET SCREEN

		mov cx,SCREEN_ROW

initScreen:	push cx
		push bx
		mov cx,SCREEN_COL

initCol:	mov dx,0
		mov dl,ds:[si]
		cmp dl,'1'
		jne initRow
		or dh,00010001B
initRow:	mov es:[bx],dx
		add bx,2
		inc si
		loop initCol
		pop bx
		pop cx
		add bx,NEXT_ROW
		loop initScreen
		ret
;==============================================================
clear_screen:	mov bx,0 ;实现对显存的更改
		mov dx,SCREEN_COLOR
		mov cx,2000

clearScreen:	mov es:[bx],dx ;依次更改屏幕上每个格子的显存
		add bx,2
		loop clearScreen

		ret
;==============================================================
init_reg:
		mov bx,0B800H
		mov es,bx

		mov bx,data
		mov ds,bx
		ret
;==============================================================
new_int9:	push ax ;构建新的中断机制，处理左右下按键，以及空格键实现方块旋转
		in al,60H
		pushf
		call dword ptr cs:[200H]
		cmp al,LEFT
		je isLeft
		cmp al,RIGHT
		je isRight
		cmp al,DOWN
		je isDown
		cmp al,BLANK
		je isBlank
int9Ret:	pop ax
		iret
;=============================================================
isLeft:		call isMoveLeft
		jmp int9Ret

isRight:	call isMoveRight
		jmp int9Ret

;*****************************************************************
isDown:		call isMoveDown
		cmp isAllowMoveDown,0
		je isNextBlock
		jmp int9Ret

isNextBlock:	pop ax
		add sp,4
		popf
		jmp nextBlock
;*******************************************************************

isBlank:
		call is_turn_block
		jmp int9Ret
;=============================================================
is_turn_block:	push bx
		push si
		push BLOCK_NOW_STATUS

		inc BLOCK_NOW_STATUS  ;状态改变
		mov dx,BLOCK_NOW_STATUS
		cmp dx,BLOCK_STATUS
		jna checkTurnOne
		mov si,BLOCK_ORG_STATUS
		mov BLOCK_NOW_STATUS,0  ;
		jmp checkTurnTwo
checkTurnOne:	add si,16
checkTurnTwo:	push si


		mov cx,BLOCK_ROW

isTurnBlock:	push cx
		push bx
		push si
		mov cx,BLOCK_COL

tBlock:		cmp byte ptr ds:[si],'1'
		jne nextCol_tBlock
		cmp byte ptr es:[bx],1
		je nextCol_tBlock
		cmp byte ptr es:[bx],'0'
		jne noTurnBlock
nextCol_tBlock:	add bx,2
		inc si
		loop tBlock
		pop si
		pop bx
		pop cx
		add si,4
		add bx,NEXT_ROW
		loop isTurnBlock

		pop si
		add sp,4
		pop bx
		call clear_old_block
		call print_block
		ret
noTurnBlock:	add sp,8
		pop BLOCK_NOW_STATUS
		pop si
		pop bx
		ret
;=============================================================
isMoveDown:	push bx

		mov cx,BLOCK_ROW

moveDown:	push cx
		push bx
		mov cx,BLOCK_COL

mDown:		cmp byte ptr es:[bx],1
		jne nextCol_mDown
		cmp byte ptr es:[bx+160],1
		je nextCol_mDown
		cmp byte ptr es:[bx+160],'0'
		jne noMoveDown
nextCol_mDown:	add bx,2
		loop mDown

		pop bx
		pop cx
		add bx,NEXT_ROW
		loop moveDown

		pop bx
		call clear_old_block
		add bx,NEXT_ROW
		call print_block
		ret


noMoveDown:	add sp,4
		pop bx
		mov isAllowMoveDown,0
		call set_button_block_color
		call get_row
		call is_clear_row
		ret


;=============================================================
is_clear_row:	push bx
		mov cx,BLOCK_ROW


isClearRow:	push cx
		push bx
		mov cx,14
		mov dx,bx

checkRow:	cmp byte ptr es:[bx],'2'
		jne nextRow_cRow
		add bx,2
		loop checkRow

		mov bx,dx
		call clear_row

		cmp bx,BLOCK_HIGH
		je isNextRow_cRow
		call reDraw_screen

nextRow_cRow:	pop bx
		pop cx
		add bx,NEXT_ROW
		loop isClearRow


		pop bx
		ret


isNextRow_cRow:	add BLOCK_HIGH,160
		jmp nextRow_cRow


;=============================================================
reDraw_screen:	push bx
		push dx


		mov ax,dx
		sub ax,BLOCK_HIGH
		mov dx,0

		mov bx,NEXT_ROW

		div bx

		mov cx,ax

		pop dx

		mov di,dx
		mov si,dx
		sub si,NEXT_ROW

drawRow:	push cx
		push si
		push di
		mov cx,14

drawCol:	push es:[si]
		pop es:[di]
		add si,2
		add di,2
		loop drawCol

		pop di
		pop si
		pop cx
		sub si,NEXT_ROW
		sub di,NEXT_ROW
		loop drawRow


		pop bx
		mov bx,BLOCK_HIGH
		call clear_row

		add BLOCK_HIGH,160


		ret
;=============================================================
clear_row:	push bx
		push dx

		mov dx,BACK_GROUND_COLOR

		mov cx,14

clearRow:	mov es:[bx],dx
		add bx,2
		loop clearRow


		pop dx
		pop bx
		ret
;=============================================================
get_row:	cmp byte ptr es:[bx],'1'
		je getRow
		sub bx,2
		jmp get_row

getRow:		add bx,2

		cmp bx,BLOCK_HIGH
		jnb getRowRet

		mov BLOCK_HIGH,bx
		;mov word ptr es:[bx],5535H

getRowRet:	ret
;=============================================================
set_button_block_color:
		push bx
		mov cx,BLOCK_ROW
		mov dx,BUTTON_BLOCK_COLOR

setButtonBlockColor:
		push cx
		push bx
		mov cx,BLOCK_COL

sColor:		cmp byte ptr es:[bx],1
		jne nextCol_sColor
		mov es:[bx],dx
nextCol_sColor:	add bx,2
		loop sColor

		pop bx
		pop cx
		add bx,NEXT_ROW
		loop setButtonBlockColor
		pop bx
		ret
;=============================================================
isMoveRight:	push bx

		add bx,BLOCK_COL
		add bx,BLOCK_COL
		sub bx,2
		mov cx,BLOCK_ROW

moveRight:	push cx
		push bx
		mov cx,BLOCK_COL


mRight:		cmp byte ptr es:[bx],1
		jne nextCol_mRight
		cmp byte ptr es:[bx+2],'0'
		jne noMoveRight
		jmp nextRow_mRight
nextCol_mRight:	sub bx,2
		loop mRight

nextRow_mRight:	pop bx
		pop cx
		add bx,NEXT_ROW
		loop moveRight
		pop bx
		call clear_old_block
		add bx,2
		call print_block
		ret

noMoveRight:	add sp,4
		pop bx
		ret
;=============================================================
isMoveLeft:	push bx
		mov cx,BLOCK_ROW

moveLeft:	push cx
		push bx
		mov cx,BLOCK_COL

mLeft:	cmp byte ptr es:[bx],1
		jne nextCol_mLeft
		cmp byte ptr es:[bx-2],'0'
		jne noMoveLeft
		jmp nextRow_mLeft
nextCol_mLeft:	add bx,2
		loop mLeft

nextRow_mLeft:	pop bx
		pop cx
		add bx,NEXT_ROW
		loop moveLeft
		pop bx
		call clear_old_block
		sub bx,2
		call print_block
		ret


noMoveLeft:	add sp,4
		pop bx
		ret


;=============================================================
clear_old_block:
		push bx
		mov cx,BLOCK_ROW
		mov dx,BACK_GROUND_COLOR

clearOldBlock:	push cx
		push bx
		mov cx,BLOCK_COL

cBlock:		cmp byte ptr es:[bx],1
		jne nextCol_cBlock
		mov es:[bx],dx
nextCol_cBlock:	add bx,2
		loop cBlock

		pop bx
		pop cx
		add bx,NEXT_ROW
		loop clearOldBlock

		pop bx
		ret
;=============================================================
change_screen_color:
		push bx
		push cx
		push es

		mov bx,0B800H
		mov es,bx

		mov bx,1
		mov cx,2000

changeScreenColor:
		inc byte ptr es:[bx]
		add bx,2
		loop changeScreenColor

		pop es
		pop cx
		pop bx
		ret




Tetris_end:	nop


;============================================================
set_new_int9:
		mov bx,0
		mov es,bx
		cli
		mov word ptr es:[9*4],OFFSET new_int9 - OFFSET Tetris + 9000H
		mov word ptr es:[9*4+2],0
		sti
		ret
;============================================================
sav_old_int9:
		mov bx,0
		mov es,bx

		push es:[9*4]
		pop es:[200H]
		push es:[9*4+2]
		pop es:[202H]

		ret
;============================================================
clear_07E00H:
		mov bx,0
		mov es,bx
		mov bx,7E00H
		mov cx,1024
		mov dx,0

clear07E00H:	mov es:[bx],dx
		add bx,2
		loop clear07E00H
		ret
;============================================================
cpy_Tetris:
		mov bx,cs
		mov ds,bx
		mov si, OFFSET Tetris
		mov bx,0
		mov es,bx
		mov di,9000H
		mov cx,OFFSET Tetris_end - OFFSET Tetris
		cld
		rep movsb
		ret
code ends
end start
