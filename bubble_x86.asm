.model small 
.stack 100h 
.data 

arrr dw 2,3,2,0,0,'!' 

.code 

main proc 
mov ax , @data 
mov ds , ax 

xor si , si 

rep_: 
cmp arrr[si] , '!' 
je exit 
mov ax , arrr[si] 
cmp ax , arrr[si+2] 
jle inc_ 
jg swap_ 
swap_: 
mov bx , arrr[si+2] 
mov arrr[si] , bx 
mov arrr[si+2] , ax 
xor si , si 
jmp rep_ 
inc_: 
add si , 2 
jmp rep_ 


exit: 

mov cx , 5 
xor si , si 
mov ah , 2	
top: 
mov dx , arrr[si] 
add si , 2 
add dx , 30h 
int 21h 
loop top	


mov ah , 4ch 
int 21h 

main endp 
end main
