extrn _cmain:near 
extrn _cal_pos:near
extrn _c_paint:near
extrn _c_ouch:near

extrn _pos:near
extrn _ch:near
extrn _x:near
extrn _y:near
extrn _offset_user:near
extrn _d:near
extrn _is_ouch:near

extrn _Current_Process
extrn _Save_Process
extrn _Schedule
extrn _Have_Program
extrn _special
extrn _Program_Num
extrn _CurrentPCBno

_TEXT segment byte public 'CODE'
DGROUP group _TEXT,_DATA,_BSS
	assume cs:_TEXT
	org 100h
start:
	mov  ax,  cs
	mov  ds,  ax         
	mov  es,  ax 
	mov  ax, 700h
	mov  ss,  ax      
	mov  sp, 100h
	call int36h
	call near ptr _cmain
	jmp $


clock_vector dw 0,0

;置光标位置
public _setcursor
_setcursor proc
	push ax
	push bx
	push dx
	mov ah,02h
	mov dh,byte ptr [_x]
	mov dl,byte ptr [_y]
	mov bh,0
	int 10h
	pop dx
	pop bx
	pop ax
	ret
_setcursor endp
;输出一个字符
public _printchar
_printchar proc
	push ax
	push es
	push bp
	push bx
	call _setcursor ;设置光标
	mov bp,sp
	mov ax,0b800h   
	mov es,ax
	mov al,byte ptr [bp+2+2+2+2+2];取出字符
	mov ah,0fh
	mov bx,word ptr [_pos] ;取出显示位置
	mov word ptr es:[bx],ax
	inc word ptr [_y] ;y坐标+1
	call near ptr _cal_pos ;重新计算坐标
	pop bx
	pop bp
	pop es
	pop ax
	ret
_printchar endp

;输出一个指定位置的指定颜色的字符
;put_color_char(char,x,y,color)
public _put_color_char
_put_color_char proc
	mov bp,sp
	push es
	push ax
	push bx
	
	mov ax,0b800h
	mov es,ax
	mov ax,word ptr [bp+4];x
	mov bx,80
	mul bx
	add ax,word ptr [bp+6];y
	mov bx,2
	mul bx
	mov bx,ax
	mov ax,word ptr [bp+2];char
	mov byte ptr es:[bx],al
	mov ax,word ptr [bp+8];color
	mov byte ptr es:[bx+1],al
	
	pop bx
	pop ax
	pop es
	ret
_put_color_char endp

;输出一个字符串
public _printstring
_printstring proc
    push bp
	push es
	push ax
	mov	bp, sp
	mov ax,0b800h
	mov es,ax
	mov	si, word ptr [bp+2+2+2+2];取出首字符地址
	mov	di, word ptr [_pos];取出显示位置
.1:
	mov al,byte ptr [si];把字符取出给AL
	inc si;地址变为下个字符的地址
	test al,al;检测是否为空字符
	jz .2 ;是空字符就跳转.2
	cmp al,0ah;检测是否为换行
	jz .3 ;是换行就跳转.3
	;既不是空字符也不是换行，则送显示位置显示，并更新显示位置
	mov	ah, 0Fh
	mov word ptr es:[di],ax
	inc byte ptr [_y]
	call near ptr _cal_pos
	mov di,word ptr [_pos]
	jmp .1
.3:;_x加1，_y清0，更新显示地址
	inc word ptr [_x]
	mov word ptr [_y],0
	call near ptr _cal_pos
	mov di,word ptr [_pos]
	jmp	.1
.2:;设置光标后退出
	call _setcursor
    pop ax
	pop es
	pop bp
ret
_printstring  endp

;输出一个字符串 printstring(color,char*)
public _printstring2
_printstring2 proc
    push bp
	mov	bp, sp
	push es
	push ax
	push bx
	push ds
	mov ax,cs
	mov ds,ax
	mov ax,0b800h
	mov es,ax
	mov bx,word ptr [bp+2+2]
	mov	si, word ptr [bp+2+2+2];取出首字符地址
	mov	di, word ptr [_pos];取出显示位置
.11:
	mov al,byte ptr [si];把字符取出给AL
	inc si;地址变为下个字符的地址
	test al,al;检测是否为空字符
	jz .22 ;是空字符就跳转.2
	cmp al,0ah;检测是否为换行
	jz .33 ;是换行就跳转.3
	;既不是空字符也不是换行，则送显示位置显示，并更新显示位置
	;mov	ah, 0Fh
	mov ah,bl
	mov word ptr es:[di],ax
	inc byte ptr [_y]
	call near ptr _cal_pos
	mov di,word ptr [_pos]
	jmp .11
.33:;_x加1，_y清1，更新显示地址
	inc word ptr [_x]
	mov word ptr [_y],11
	call near ptr _cal_pos
	mov di,word ptr [_pos]
	jmp	.11
.22:;设置光标后退出
	call _setcursor
	pop ds
	pop bx
    pop ax
	pop es
	pop bp
ret
_printstring2  endp

;键盘输入一个字符
public _inputchar
_inputchar proc
	push ax
	call _setcursor
	mov ax,0
	int 16h
	mov byte ptr [_ch],al
	pop ax
ret
_inputchar endp

;清屏
public _clear
_clear proc 
    push ax
    push bx
    push cx
    push dx		
    mov	ax, 0600h	; AH = 6,  AL = 0
	mov	bx, 0700h	; 黑底白字(BL = 7)
	mov	cx, 0		; 左上角: (0, 0)
	mov	dx, 184fh	; 右下角: (24, 79)
	int	10h		; 显示中断
	mov word ptr [_x],0
	mov word ptr [_y],0
	mov word ptr [_pos],0
	call _setcursor
	pop dx
	pop cx
	pop bx
	pop ax
ret
_clear endp

;读软盘到内存
;load(offset_begin,num_shanqu,pos_shanqu)
public _load
_load proc
	push ax
	push bx
	push cx
	push dx
	push es
	push bp
	mov bp,sp
	mov ax,cs              
    mov es,ax                ;设置段地址
    mov bx,word ptr [bp+12+2]  ;偏移地址
    mov ah,2                 ; 功能号
    mov al,byte ptr [bp+12+4] ;扇区数
    mov dl,0                 ;驱动器号
    mov dh,0                 ;磁头号
    mov ch,0                 ;柱面号
    mov cl,byte ptr [bp+12+6];起始扇区号
    int 13H ;                
	pop bp
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_load endp
;跳转到用户程序
public _jmp
_jmp proc
	push ax
	push bx
	push cx
	push dx
	push es
	push ds	
	call word ptr [_offset_user]
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_jmp endp
;filldata(int,int)
public _filldata
_filldata proc
	push ax
	push bx
	push cx
	push dx
	push es
	push ds
	
	mov bp,sp
	mov ax,0
	mov es,ax
	mov bx,word ptr [bp+12+2];偏移地址
	mov ax,word ptr [bp+12+4];数据
	mov word ptr es:[bx],ax
	
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_filldata endp
;readdata(int)
public _readdata 
_readdata proc
	push ax
	push bx
	push cx
	push dx
	push es
	push ds
	
	mov bp,sp
	mov ax,0
	mov es,ax
	mov bx,word ptr [bp+12+2];偏移地址
	mov ax,word ptr es:[bx]
	mov word ptr [_d],ax
	
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_readdata endp

;设置时钟中断 08h
set_clock_interrupt proc
	cli
	push es
	push ax
	xor ax,ax
	mov es,ax
	;save the vector
	mov ax,word ptr es:[20h]
	mov word ptr [clock_vector],ax
	mov ax,word ptr es:[22h]
	mov word ptr [clock_vector+2],ax
	;fill the vector
	mov word ptr es:[20h],offset Paint
	mov ax,cs
	mov word ptr es:[22h],ax
	pop ax
	pop es
	sti
	ret
set_clock_interrupt endp
;恢复时钟中断
re_clock_interrupt proc
	cli
	push es
	push ax
	xor ax,ax
	mov es,ax
	mov ax,word ptr [clock_vector]
	mov word ptr es:[20h],ax
	mov ax,word ptr [clock_vector+2]
	mov word ptr es:[22h],ax
	pop ax
	pop es
	sti
	ret
re_clock_interrupt endp

Paint proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	call near ptr _c_paint
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
Paint endp


Ouch proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	call near ptr _c_ouch
	;读缓冲区
	in al,60h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
Ouch endp

;INT 33H 左上角显示
;填充33h中断向量表
int33h proc
	cli
	push es
	push ax
	;es置零
	xor ax,ax
	mov es,ax
	;填充中断向量
	mov word ptr es:[0cch],offset interrupt33h
	mov ax,cs
	mov word ptr es:[0ceh],ax
	pop ax
	pop es
	sti
	ret
int33h endp

message33h1 db 'This is program of INT 33H'
message33h1length equ $-message33h1
message33h2 db 'zhang geng wei and xie hong'
message33h2length equ $-message33h2
;中断处理程序33h
interrupt33h proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0001h;bl颜色
	mov dx,0408h;行，列
	mov cx,message33h1length
	mov bp,offset message33h1
	int 10h
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0001h;bl颜色
	mov dx,050dh;行，列
	mov cx,message33h2length
	mov bp,offset message33h2
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
interrupt33h endp

;INT 34H 右上角显示
;填充34h中断向量表
int34h proc
	cli
	push es
	push ax
	
	xor ax,ax
	mov es,ax
	mov word ptr es:[0d0h],offset interrupt34h
	mov ax,cs
	mov word ptr es:[0d2h],ax
	
	pop ax
	pop es
	sti
	ret
int34h endp

message34h1 db 'This is program of INT 34H'
message34h1length equ $-message34h1
message34h2 db 'zhang geng wei and xie hong'
message34h2length equ $-message34h2
;中断处理程序34h
interrupt34h proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0002h;bl颜色
	mov dx,042eh;行，列
	mov cx,message34h1length
	mov bp,offset message34h1
	int 10h
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0002h;bl颜色
	mov dx,0534h;行，列
	mov cx,message34h2length
	mov bp,offset message34h2
	int 10h
	
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
interrupt34h endp

;INT 35H 左下角显示
;填充35h中断向量表
int35h proc
	cli
	push es
	push ax
	
	xor ax,ax
	mov es,ax
	mov word ptr es:[0D4h],offset interrupt35h
	mov ax,cs
	mov word ptr es:[0d6h],ax
	
	pop ax
	pop es
	sti
	ret
int35h endp

message35h1 db 'This is program of INT 35H'
message35h1length equ $-message35h1
message35h2 db 'zhang geng wei and xie hong'
message35h2length equ $-message35h2
;中断处理程序35h
interrupt35h proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0003h;bl颜色
	mov dx,1008h;行，列
	mov cx,message35h1length
	mov bp,offset message35h1
	int 10h
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0003h;bl颜色
	mov dx,110dh;行，列
	mov cx,message35h2length
	mov bp,offset message35h2
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
interrupt35h endp

;INT 36H 右下角显示
;填充36h中断向量表
int36h proc
	cli
	push es
	push ax
	
	xor ax,ax
	mov es,ax
	mov word ptr es:[0d8h],offset interrupt36h
	mov ax,cs
	mov word ptr es:[0dah],ax
	
	pop ax
	pop es
	sti
	ret
int36h endp

message36h1 db 'This is program of INT 36H'
message36h1length equ $-message36h1
message36h2 db 'zhang geng wei and xie hong'
message36h2length equ $-message36h2
;中断处理程序36h
interrupt36h proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0004h;bl颜色
	mov dx,102eh;行，列
	mov cx,message36h1length
	mov bp,offset message36h1
	int 10h
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0004h;bl颜色
	mov dx,1134h;行，列
	mov cx,message36h2length
	mov bp,offset message36h2
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
interrupt36h endp



Pro_Timer:

    cli
	push ss 	;*/flags/cs/ip/ss
	push ax	;*/flags/cs/ip/ss/ax/
	push bx	;*/flags/cs/ip/ss/ax/bx/
	push cx	;*/flags/cs/ip/ss/ax/bx/cx/
	push dx	;*/flags/cs/ip/ss/ax/bx/cx/dx/
	push sp	;*/flags/cs/ip/ss/ax/bx/cx/dx/sp/
	push bp	;*/flags/cs/ip/ss/ax/bx/cx/dx/sp/bp/
	push si		;*/flags/cs/ip/ss/ax/bx/cx/dx/sp/bp/si/
	push di	;*/flags/cs/ip/ss/ax/bx/cx/dx/sp/bp/si/di/
	push ds	;*/flags/cs/ip/ss/ax/bx/cx/dx/sp/bp/si/di/ds/
	push es	;*/flags/cs/ip/ss/ax/bx/cx/dx/sp/bp/si/di/ds/es/
	.386
	push fs	;*/flags/cs/ip/ss/ax/bx/cx/dx/sp/bp/si/di/ds/es/fs/
	push gs	;*/flags/cs/ip/ss/ax/bx/cx/dx/sp/bp/si/di/ds/es/fs/gs
	.8086

	mov ax,cs
	mov ds,ax
	mov es,ax
	call near ptr _Save_Process
	call near ptr _Schedule 
	call near ptr _Current_Process
	mov bp,ax
	mov ss,word ptr ds:[bp+0]
	mov sp,word ptr ds:[bp+16];*/flags/cs/ip/ss/ax/bx/cx/dx/
	
	add sp,16 ;*/
	
Restart:
	call near ptr _special
	push word ptr ds:[bp+30]
	push word ptr ds:[bp+28]
	push word ptr ds:[bp+26]
	
	push word ptr ds:[bp+2]
	push word ptr ds:[bp+4]
	push word ptr ds:[bp+6]
	push word ptr ds:[bp+8]
	push word ptr ds:[bp+10]
	push word ptr ds:[bp+12]
	push word ptr ds:[bp+14]
	push word ptr ds:[bp+18]
	push word ptr ds:[bp+20]
	push word ptr ds:[bp+22]
	push word ptr ds:[bp+24]

	pop ax
	pop cx
	pop dx
	pop bx
	pop bp
	pop si
	pop di
	pop ds
	pop es
	.386
	pop fs
	pop gs
	.8086
	
	push ax
    mov al,20h
	out 20h,al
	out 0a0h,al
	pop ax
    sti
    iret
	

SetTimer: 
    push ax
    mov al,34h   ; 设控制字值 
    out 43h,al   ; 写控制字到控制字寄存器 
    mov ax,29830 ; 每秒 20 次中断（50ms 一次） 
    out 40h,al   ; 写计数器 0 的低字节 
    mov al,ah    ; AL=AH 
    out 40h,al   ; 写计数器 0 的高字节 
	pop ax
	ret

public _setClock
_setClock proc
    push ax
	push bx
	push cx
	push dx
	push ds
	push es
	
    call SetTimer
    xor ax,ax
	mov es,ax
	mov word ptr es:[20h],offset Pro_Timer
	mov ax,cs
	mov word ptr es:[22h],ax
	
	pop ax
	mov es,ax
	pop ax
	mov ds,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_setClock endp

public _another_load
_another_load proc
    push ax
	push bp
	
	mov bp,sp
	
    mov ax,[bp+6]      	;段地址 ; 存放数据的内存基地址
	mov es,ax          	;设置段地址（不能直接mov es,段地址）
	mov bx,100h        	;偏移地址; 存放数据的内存偏移地址
	mov ah,2           	;功能号
	mov al,2          	;扇区数
	mov dl,0          	;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0          	;磁头号 ; 起始编号为0
	mov ch,0          	;柱面号 ; 起始编号为0
	mov cl,[bp+8]       ;起始扇区号 ; 起始编号为1
	int 13H          	; 调用中断
	
	pop bp
	pop ax
	
	ret
_another_load endp

another_Timer:
    push ax
	push bx
	push cx
	push dx
	push bp
    push es
	push ds
	
	mov ax,cs
	mov ds,ax

	cmp byte ptr [ds:count],0
	jz case1
	cmp byte ptr [ds:count],1
	jz case2
	cmp byte ptr [ds:count],2
	jz case3
	
case1:	
    inc byte ptr [ds:count]
	mov al,'/'
	jmp show
case2:	
    inc byte ptr [ds:count]
	mov al,'\'
	jmp show
case3:	
    mov byte ptr [ds:count],0
	mov al,'|'
	jmp show
	
show:
    mov bx,0b800h
	mov es,bx
	mov ah,0ah
	mov es:[((80*24+78)*2)],ax
	
	pop ax
	mov ds,ax
	pop ax
	mov es,ax
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	iret
	

	count db 0
	
_TEXT ends

;************DATA segment*************
_DATA segment word public 'DATA'
_DATA ends
;*************BSS segment*************
_BSS	segment word public 'BSS'
_BSS ends
;**************end of file***********
end start

