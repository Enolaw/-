;实验七 并行接口芯片8255与输出控制

dseg segment
	com_add dw 0f003h
	pa_add dw 0f000h ;a为位选
	pb_add dw 0f001h ;b为段选
	temp1 db 11111110b,11111101b,11111011b,11110111b,11101111b,11011111b ;位选
	temp db 10111110b,10110110b,01100110b,11110010b,11011010b,01100000b	;对应输出1，2，3，4，5，6
dseg ends

sseg segment stack
	dw  100 dup(?) 
sseg ends

cseg segment
	assume cs:cseg,ds:dseg,ss:sseg

start:
	mov ax,dseg
	mov ds,ax
	mov ax,sseg
	mov ss,ax
	mov al,80h
	mov dx,com_add
	out dx,al    ;设置控制字，a，b口为输出
	
lop:	mov bx,0
again:
	mov dx,pa_add
	mov al,temp1[bx] 
	out dx,al
	mov dx,pb_add
	mov al,temp[bx]
	out dx,al
	call delay
	inc bl
	cmp bl,6
	jnz again
	jmp lop
	
	mov ah,4ch  ;结束程序，返回DOS
	int 21h

;------------------------------------------	
delay proc near   ;延迟函数定义
	push bx
	mov bx,1
jp2:
	mov cx,0
jp3:
	loop jp3
	dec bx
	jnz jp2
	pop bx
	ret
delay endp

cseg ends
end start

