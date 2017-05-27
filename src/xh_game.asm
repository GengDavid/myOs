org 100h
start:	
	mov ax,6000h
	mov ds,ax
	mov ax,0xb800
	mov es,ax
	mov ax,0000h
	mov ss,ax
	mov sp,ax
	mov cx,20
	mov si,0
	mov word[score],0
	mov ax,0003h ; ah = 0, al = 3 
	int 10h ; 中断号10 ，清屏
loop1: 
	mov byte[heigh+si],11
	inc si
	loop loop1
	mov word[row],22
	mov word[clm],40
	jmp getad

p1:	mov ax,0h
	int 16h
	cmp word[dig],52
	jl feilai
	sub word[dig],2
	jmp feilai
p2:	mov ax,0h
	int 16h
	cmp word[dig],054h
	jg feilai
	add word[dig],2
	jmp feilai

show:
	mov cx,07ffh
delay:	
	push cx
	mov ax,0100h
	int 16h
	cmp al,'a'
	jz p1
	cmp al,'d'
	jz p2
	jmp feilai
feilai:
	mov cx,0ffffh
	mov bx,0e60h
	mov si,word[dig]
	mov byte[es:bx+si-1],00h
	push cx
	mov cx,3
aaa:
	mov byte[es:bx+si],'-'
	mov byte[es:bx+si+1],07h
	add si,2
	loop aaa
	pop cx
	mov byte[es:bx+si+1],00h
delay1:	loop delay1
	pop cx
	loop delay

	mov cx,20
	mov si,0
	mov bx,00d4h
loop2:
	push cx
	mov cl,byte[heigh+si]
	mov ch,00h
	push bx
	mov ax,000bh
	sub ax,cx
	push ax
loop3:
	mov ah,' '
	mov al,70h
	mov byte[es:bx],ah
	mov byte[es:bx+1],al
	add bx,0a0h
	loop loop3
	pop cx
	cmp cx,0
	jz jump
loop6:
	mov al,00h
	mov byte[es:bx+1],al
	add bx,0a0h
	loop loop6
jump:
	inc si
	pop bx
	add bx,2
	pop cx
	loop loop2

begin:
	
rre:
	mov ax,word[dir]
	add word[row],ax
	mov ax,word[dic]
	add word[clm],ax
	mov si,word[clm]
	sub si,27
	mov bl,byte[heigh+si]
	inc bl
	cmp byte[row],bl
	jng rowd
	cmp byte[clm],26
	jng clmr
	cmp byte[row],018h;01ah
	jge rowu
	cmp byte[clm],02fh;042h
	jge clml
	inc word[score]
	jmp getad
	
rowu:	shr word[dig],1
	mov ax,word[dig]
	cmp word[clm],ax
	jl return_os				;game over
	add word[dig],4
	mov ax,word[dig]
	cmp word[clm],ax
	jg return_os				;game over
	sub word[dig],4
	shl word[dig],1
	mov word[dir],-1
	mov byte[row],017h;019h
	mov ax,word[dic]
	sub word[clm],ax
	jmp rre
clml:	mov word[dic],-1
	mov byte[clm],02eh;041h
	mov ax,word[dir]
	sub word[row],ax
	jmp rre
rowd:	mov word[dir],1
	mov bl,byte[row]
	sub bl,2
	mov byte[heigh+si],bl
	inc word[row]
	mov ax,word[dic]
	sub word[clm],ax
	jmp rre
clmr:	
    mov word[dic],1
	mov byte[clm],1bh
	mov ax,word[dir]
	sub word[row],ax
	jmp rre
	
getad:	
	mov ax,word[row]
	dec ax;	
	mov bx,80
	mul bx
	mov bx,word[clm]
	dec bx
	add ax,bx	
	mov bx,2
	mul bx
	mov bx,ax
	jmp return
return:	
	mov byte[es:bx],'*'
	mov byte[es:bx+1],07h
	pop si
	push bx
	mov byte[es:si],' '
	mov byte[es:si+1],07h
	jmp show 

return_os:
	mov ax,word[score]
	push ax
	jmp $
	
define:
	dig dw 3ch
	heigh db '12345678901234567890'
	col db 0fh
	row dw 00h	;row
	clm dw 00h	;column
	dir dw -1
	dic dw -1
	score dw 0
	over db 'GAME OVER!'
	over_length equ ($-over)
    times 1024-($-$$) db 0