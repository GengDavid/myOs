Start:
	mov ax,0c50h
	mov ds,ax
	mov ax,cs
	mov es,ax
	int 33h
	int 34h
	int 35h
	int 36h
	
	
	mov cx,0ffffh
delay:
	push cx
	mov cx,0ffffh
delay2:
	loop delay2
	pop cx
	loop delay
	mov ax,0003h ; ah = 0, al = 3 
	int 10h ; 中断号10 ，清屏
	ret
times 1024-($-$$) db 0
	