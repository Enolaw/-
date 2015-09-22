;微机实验二 键盘的输入和数值转换
;13通信王燕玲


dseg segment ;定义数据段      
	mes db 'In the program,you should input a number with 4 four bits.',0AH,0DH,'$'  ;显示代码信息
	error  db 0DH,0AH, 'input error',0DH,0AH,'$'  ;输入错误提示
	result1 db 'change into 16 bits binary number:',0AH,0DH,'$'  ;结果显示
	result2 db 'change into 4 bits hexadecimal number:',0AH,0DH,'$'   ;结果显示
	end1 db 'press any key to close the window........',0AH,0DH,'$'  ;结束提示
	num db 4 dup(0)   ;存输入的四个字
	num1 dw ?         ;存输16位uBCD
	temp dw ?	  ;临时保存cx
	choose db 'choose which you want to diplay? b is for binary,h is for hexadecimal :',0AH,0DH,'$' ;选择提示
	dseg  ends
	
sseg  segment stack;定义堆栈
                dw  256 dup(?) 
	sseg  ends 
	
cseg   segment  ;定义程序段
	assume  CS:cseg,DS:dseg,ES:dseg,SS:sseg 

start:  mov ax,dseg
        mov ds,ax
        mov ax,sseg
        mov ss,ax
       	mov dx,offset mes
	mov ah,09h
	int 21h       ;显示代码信息
;---------------------------------------------------
; 接受输入的四个字符并存储到num	
again:	mov cx,04h
        mov si,offset num
loop1:  sub al,al
        mov ah,01h
        int 21h
        cmp al,39h
        ja  done
        cmp al,30h
        jb  done
        sub al,30h
        mov [si],al
        inc si
        loop loop1
        jmp next2
done:   call newline
        mov dx,offset error
        mov ah,09h
        int 21h     ; 如果输入的字符不符合要求，输出错误提示
        jmp again  ; 转到 again 再次接受输入


;-----------------------------------------------------
; 将四个字符转换为对应的十进制数存储到num1      
next2:  sub bx,bx
        sub ax,ax
loop2:  mov dh,0     
	mov dl,num[bx]
	add ax,dx
	mov cl,10
	mul cl
	inc bx
	cmp bx,4
	jnz loop2
	mov num1,ax
;------------------------------------------------------
;用户选择输出
choose1:call newline
	mov dl,offset choose
	mov ah,9
	int 21h
	
	mov ah,01h
	mov al,00h
	int 21h
	cmp al,62h
	jz  binary1
	cmp al,68h
        jnz error1
        call hexadecimal
	jmp next3
	
error1:	mov dx,offset error
	mov ah,9
	int 21h
	jmp choose1
		
binary1: call binary

next3:	call newline
        mov dl,offset end1
        mov ah,9
        int 21h
       
	
wait1:	mov ah,1
	int 16h
	jz wait1
	mov ax,4c00h
	int 21h
;------------------------------------------
binary proc near       ;子程序以二进制输出
	call newline
	mov dl,offset result1
	mov ah,9
	int 21h
	mov bx,num1
	mov cx,10h
loop3:  rol bx,1  ; 把 BX 所存字符的二进制的最高位移到最低位
        mov dl,bl
        and dl,01h ; 获取最低位
        add dl,30h; 将最低位转成数字，即字符 '0' 或 '1'
        mov ah,02h
        int 21h    ; 即将之前 BX 的最高位输出到屏幕
        loop loop3
        ret 
binary  endp
             


;-----------------------------------------
hexadecimal proc near   ;子程序以十六进制输出
        call newline
        mov dl,offset result2
        mov ah,9
        int 21h
	mov bx,num1
	mov cx,4
loop4:	mov temp,cx
	mov cl,4
	rol bx,cl
	mov dl,bl
	and dl,0fh
	cmp dl,9
	ja next
	add dl,30h
	jmp next1
next:	add dl,37h
next1:	mov ah,02h
	int 21h
	mov cx,temp
	loop loop4
	ret            
hexadecimal endp
; ----------------------------------------
 
; 功能：输出回车换行符，即转到新行
newline proc near  ; 子过程 newline 开	
        mov dl,0ah ; 设输出字符为 0x0A，即换行符
        mov ah,02h
        int 21h
 
        mov dl,0dh ; 设输出字符为 0x0D，即回车符
        mov ah,02h
        int 21h
        ret

newline endp   ; 子过程 newline 结束
cseg ends      ; 代码区定义结束
        end start ; 指定执行起点
