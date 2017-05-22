org 100h
start:
	mov ax,4000h
	mov ds,ax
	mov ax,0xb800
	mov es,ax
	cmp byte[run],1
	jz begin
	mov word[x],12
	mov word[y],-1
	mov byte[cnt], 0x01
	mov byte[dirc],D_R
	mov byte[run],1
	mov ax,0003h ; ah = 0, al = 3 
	int 10h ; 中断号10 ，清屏
begin:
	mov cx,070h 
	cmp word[cnt2], 0200h
	jz return	
	jmp delay
	
delay:
	push cx
	mov cx,0ffffh
delay2:
	loop delay2
	pop cx
	loop delay
	inc word[cnt2]	
	cmp byte[dirc],1
	jz DDRR
	cmp byte[dirc],2
	jz DDLL
	cmp byte[dirc],3
	jz UURR
	cmp byte[dirc],4
	jz UULL
	jmp start
	
DDRR:
	mov byte[dirc],D_R
	cmp word[y],39
	jz DDLL
	cmp word[x],24
	jz UURR
	inc word[x]
	inc word[y]
	jmp display
	
DDLL:
	mov byte[dirc],D_L
	cmp word[y],0
	jz DDRR
	cmp word[x],24
	jz UULL
	inc word[x]
	dec word[y]
	jmp display

UULL:
	mov byte[dirc],U_L
	cmp word[y],0
	jz UURR
	cmp word[x],13
	jz DDLL
	dec word[x]
	dec word[y]
	jmp display

UURR:
	mov byte[dirc],U_R
	cmp word[y],39
	jz UULL
	cmp word[x],13
	jz DDRR
	dec word[x]
	inc word[y]
	jmp display
	
change:
	mov byte[cnt], 0x01
	
display:
	inc byte[cnt]
	cmp byte[cnt], 0x07
	jg change
	mov ax,[x]
	mov cx,80
	mul cx
	add ax,[y]
	mov cx,2
	mul cx
	mov bx,ax
	mov al,'A'
	mov byte[es:bx],al
	mov ah,byte[cnt]
	mov byte[es:bx+1],ah
	jmp myname
	jmp begin

myname: 
	mov word[xx],10
	mov cx,4
loop1:	
	push cx
	mov word[yy],29
	mov cx,17
loop2:
	call calculate
	mov byte[es:bx],' '
	mov al,0x97
	mov byte[es:bx+1],al
	inc word[yy]	
	loop loop2
	pop cx
	inc word[xx]
	loop loop1
	mov word[xx],11
	mov word[yy],31
	mov si,0
	mov cx,12
loop3:
	call calculate
	mov al,byte[mynm+si]
	mov byte[es:bx],al
	inc word[yy]
	inc si
	loop loop3
	mov word[xx],12
	mov word[yy],33
	mov si,0
	mov cx,8
loop4:
	call calculate
	mov al,byte[myid+si]
	mov byte[es:bx],al
	inc word[yy]
	inc si
	loop loop4
	push es
	mov ax,0
	mov es,ax
	cmp word [es:604h],1
	pop es
	jz time_share
	
	jmp begin
	
time_share:
	ret 
calculate:
	mov ax,word[xx]
	mov bx,80
	mul bx
	add ax,[yy]
	mov bx,2
	mul bx
	mov bx,ax
	ret
	
return:
	mov ax,0
	mov es,ax
	mov word[es:604h],0
	mov byte[run],0
	ret
	
datadef:
	D_R equ 1
	D_L equ 2
	U_R equ 3
	U_L equ 4
	dirc equ D_R 
	cnt db 0x0
	x_base dw 0
	y_base dw 0
    x    dw 0
    y    dw 0
	xx dw 0
	yy dw 0
	left db 0
	cnt2 dw 0	
	run db 0
	mynm db 'zhanggengwei'
	myid db '15352403'
	times 1022-($-$$) db 0
    db 0x55,0xaa