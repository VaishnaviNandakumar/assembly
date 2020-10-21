org 100h 
mov cx, 0

jmp skipdata
gameWidth dw 50
gameHeight dw 50


;Order - xpos, ypos, xvel, yvel, size, newx, newy
ball dw 17,17,5,4,2,17,17     

;Order -  xpos, ypos, speed, length, newx, newy
lpad dw 5,14,7,11,5,14      

rpad dw 5, 14, 7, 11, 44, 14

score dw 02h

skipdata:

;SET TO GRAPHICS DISPLAY MODE
mov ax, 0013h
int 10h



;SET BOUNDRY/PLAY AREA
mov ax, 0
mov bx, 0   
mov cx, gameWidth
call horizontalBoundry

mov cx, gameHeight
call verticallBoundry 
   
add ax, gameWidth
call verticallBoundry

mov ax, 0
mov bx, gameHeight
mov cx, gameWidth
call horizontalBoundry  




;MAIN LOOP
mov cx, 0 

mainloop:
    call drawPaddleL 
    call drawPaddleR 
    
    call drawBall
    call updateBall
    call updatePadL     
    call updatePadR    
    call checkBall_CollisionR 
    call checkBall_CollisionL  

    cmp score, 00
    jnz mainloop

   
ret 



;FUNCTIONS


;DRAWS PADDLE
drawPaddleL:
    push ax
    push bx
    push cx
    
    mov ax, lpad[0]
    mov bx, lpad[2]
    mov cx, lpad[6]
    call vert_line_unplot
    
    mov ax, lpad[8]
    mov bx, lpad[10]
    call verticallBoundry
    
    pop cx
    pop bx
    pop ax
    ret


drawPaddleR:
    push ax
    push bx
    push cx
    
    mov ax, rpad[0]
    mov bx, rpad[2]
    mov cx, rpad[6]
    call vert_line_unplot
    
    mov ax, rpad[8]
    mov bx, rpad[10]
    call verticallBoundry
    
    pop cx
    pop bx
    pop ax
    ret



;DRAWS BALL
drawBall:
    push ax
    push bx
    push cx
    push dx
    
    
    mov ax, ball[0]
    mov cx, ax
    mov bx, ball[2]
    mov dx, bx
    
    add cx, ball[8]
    dec cx
    add dx, ball[8]
    dec dx
    
    call rect_unplot
    
    mov ax, ball[10]
    mov cx, ax
    mov bx, ball[12]
    mov dx, bx
    
    add cx, ball[8]
    dec cx
    add dx, ball[8]
    dec dx
    
    call rect_plot
    
    pop dx
    pop cx
    pop bx
    pop ax 
    ret
    


;UPDATE BALL POSITION VALUES
updateBall:
    push ax
    push bx
    push cx
    
    ;Update old ball positions
    mov ax, ball[10]
    lea bx, ball[0]
    mov [bx], ax
    mov ax, ball[12]
    lea bx, ball[2]
    mov [bx], ax
    
    ;New X Position
    mov ax, ball[0]
    mov bx, ball[4]
    add ax, bx
    
    ;Sign of Velocity
    and bx, 8000h
    jz checkPositiveX  
    
    ;Collision Check
    cmp ax, 0    
    jg updateX
    
    ;Update positions and negate velocity
    neg ax
    inc ax
    mov cx, ball[4]
    neg cx
    lea bx, ball[4]
    mov [bx], cx
    jmp updateX
    
    ;Collision Check
    checkPositiveX:
    mov cx, ax
    add cx, ball[8]
    sub cx, gameWidth
    cmp cx, 0  
    
    
    jle updateX
    
    ;Update positions and negate velocity
    shl cx, 1
    sub ax, cx
    mov cx, ball[4]
    neg cx
    lea bx, ball[4]
    mov [bx], cx 
    
    ;Update the new position
    updateX:
    lea bx, ball[10]
    mov [bx], ax
                          
    ;Repeat process for y coordinate    
                      
    ;New Y Position
    mov ax, ball[2]
    mov bx, ball[6]
    add ax, bx
    
    ;Sign of Velocity
    and bx, 8000h
    jz checkPositiveY  
    
    ;Collision Check
    cmp ax, 0    
    jg updateY
    
    ;Update positions and negate velocity
    neg ax
    inc ax
    mov cx, ball[6]
    neg cx
    lea bx, ball[6]
    mov [bx], cx
    jmp updateY
    
    ;step 3: Collison Check
    checkPositiveY:
    mov cx, ax
    add cx, ball[8]
    sub cx, gameHeight
    cmp cx, 0
    jle updateY
    
    ;Update positions and negate velocity
    shl cx, 1
    sub ax, cx
    mov cx, ball[6]
    neg cx
    lea bx, ball[6]
    mov [bx], cx 
    
    ;Update the new position
    updateY:
    lea bx, ball[12]
    mov [bx], ax                    
    
    pop cx
    pop bx
    pop ax
    ret




;Paddle position update  - Left
updatePadL:
push ax
push bx

;New position update
mov ax, lpad[8]
lea bx, lpad[0]
mov [bx], ax
mov ax, lpad[10]
lea bx, lpad[2]
mov [bx], ax

mov al, 0
mov ah, 1

;Check for character in keyboard buffer   
;up arrow:    4800h
;down arrow:  5000h         

int 16h
;No input, Ignore    
jz donepu  


mov ax, 0  
;Get character input from keyboard buffer
int 16h    

cmp al, 00h
jne donepu
cmp ah, 48h
je upL
cmp ah, 50h
jne donepu

;down
mov ax, lpad[2]
add ax, lpad[4]

;Collision check
mov bx, ax
add bx, lpad[6]
dec bx
cmp bx, gameHeight
jl commit 
dec score 
;If no collision, commit changes in ypos to the object

;if collision, set paddle to maximum possible ypos
mov bx, gameHeight
dec bx
sub bx, lpad[6]
mov ax, bx
jmp commit 
;then commit the changes

upL:
mov ax, lpad[2]
sub ax, lpad[4]

cmp ax, 0
jg commit   
;if there's a collision, simply set the ypos to 1
mov ax, 1 

commit:
lea bx, lpad[10]
mov [bx], ax 

donepu:
pop bx
pop ax
ret


updatePadR:
push ax
push bx

;New position update
mov ax, rpad[8]
lea bx, rpad[0]
mov [bx], ax
mov ax, rpad[10]
lea bx, rpad[2]
mov [bx], ax

mov al, 0
mov ah, 1

;Check for character in keyboard buffer   
;right arrow: 4D00h
;left arrow:  4B00h         

int 16h
;No input, Ignore    
jz donepu  


mov ax, 0  
;Get character input from keyboard buffer
int 16h    

cmp al, 00h
jne donepuR
cmp ah, 4dh
je upR
cmp ah, 4bh
jne donepu

;down
mov ax, rpad[2]
add ax, rpad[4]

;Collision check
mov bx, ax
add bx, rpad[6]
dec bx
cmp bx, gameHeight
jl commitR 
dec score 
;If no collision, commit changes in ypos to the object

;if collision, set paddle to maximum possible ypos
mov bx, gameHeight
dec bx
sub bx, rpad[6]
mov ax, bx
jmp commitR 
;then commit the changes

upR:
mov ax, rpad[2]
sub ax, rpad[4]

cmp ax, 0
jg commitR   
;if there's a collision, simply set the ypos to 1
mov ax, 1 

commitR:
lea bx, rpad[10]
mov [bx], ax 

donepuR:
pop bx
pop ax
ret


;Check if ball hits paddle
;Ball Data Storage - [oldxpos, oldypos, dx, dy, size, xpos, ypos]
;Paddle Data Storage - [xpos, ypos, speed, length, newx, newy]



;Algorithm
;if ball[4] < 0, it's heading towards the pad
;if ball[0] > pad[0], and ball[10] <= pad[0], it passes through the pad's xpos

;finally, we have two y-values to consider, the top and bottom of the ball
;for this part, we will consider the pad's & ball's new position, since the 
;player will be trying to move the pad to intercept the ball.

;if both are under the pad's ypos, or over the pad's ypos+length, ignore
;if this is not true, register a collision:
;negate ball[4], set ball[10]=pad[0]+1


checkBall_CollisionL:
push ax
push bx
push cx

cmp ball[4], 0
jge donep         ;check that the ball is heading towards the pad
mov ax, lpad[0]
cmp ball[10], ax
jg donep          ;check that the new position is behind the pad
cmp ball[0], ax   
jle donep         ;check that the old ball position is in front of the pad

mov ax, ball[12]
mov bx, ax
add bx, ball[8]
dec bx ;because the ball's size is absolute and includes the origin xpos
mov cx, lpad[10]
cmp ax, cx
jg nextc          ;now, check for both y1 and y2 being under the pad's ypos
cmp bx, cx
jl donep          ;if they both are, we're done
                  ;if not, go to nextc

nextc:
add cx, lpad[6]
dec cx ;again, length/size include the origin
cmp ax, cx
jg donep          ;since the ball's y values only increase from it's ypos, we can just 
                  ;compare ypos to the pad's ending position
                  
;if after all of that, the ball did not make this function end, it means that it has
;made contact with the pad's new position (approximately)

mov ax, ball[4]
lea bx, ball[4]
neg ax
mov [bx], ax     ;negate the x velocity

mov ax, lpad[0]
inc ax
lea bx, ball[10]
mov [bx], ax     ;set the ball's new xpos to in front of the pad

inc dx           ;increment the score

donep:
pop cx
pop bx
pop ax 
ret


checkBall_CollisionR:
push ax
push bx
push cx

cmp ball[4], 0
jge donepr         ;check that the ball is heading towards the pad
mov ax, rpad[0]
cmp ball[10], ax
jg donepr          ;check that the new position is behind the pad
cmp ball[0], ax   
jle donepr         ;check that the old ball position is in front of the pad

mov ax, ball[12]
mov bx, ax
add bx, ball[8]
dec bx ;because the ball's size is absolute and includes the origin xpos
mov cx, rpad[10]
cmp ax, cx
jg nextcr          ;now, check for both y1 and y2 being under the pad's ypos
cmp bx, cx
jl donepr          ;if they both are, we're done
                  ;if not, go to nextc

nextcr:
add cx, rpad[6]
dec cx ;again, length/size include the origin
cmp ax, cx
jg donepr          ;since the ball's y values only increase from it's ypos, we can just 
                  ;compare ypos to the pad's ending position
                  
;if after all of that, the ball did not make this function end, it means that it has
;made contact with the pad's new position (approximately)

mov ax, ball[4]
lea bx, ball[4]
neg ax
mov [bx], ax     ;negate the x velocity

mov ax, rpad[0]
inc ax
lea bx, ball[10]
mov [bx], ax     ;set the ball's new xpos to in front of the pad

inc dx           ;increment the score

donepr:
pop cx
pop bx
pop ax 
ret



;plot a rectangle function
;ax - origin x
;bx - origin y
;cx - destination x
;dx - destination y
rect_plot:
push ax
push bx
push cx
push dx
push di
push si

push ax ;store the origin x in the stack

mov di, cx ;di stores the x
mov si, dx ;si stores the y
 
mov cx, ax
mov dx, bx
mov ax, 0c0eh ;the right-most hex char is the color of the rectangle

rect_loop:
int 10h ;draw a pixel

inc cx ;increment x value
cmp cx, di ;check if xpos > destination x
jng rect_loop

pop cx ;reset the xpos to the origin x
push cx

inc dx
cmp dx, si ;check if ypos > destination y
jng rect_loop

pop si
pop si
pop di
pop dx
pop cx
pop bx
pop ax

ret




;plot a b
;lack rectangle function
;ax - origin x
;bx - origin y
;cx - destination x
;dx - destination y
rect_unplot:
push ax
push bx
push cx
push dx
push di
push si

push ax ;store the origin x in the stack

mov di, cx ;di stores the x
mov si, dx ;si stores the y
 
mov cx, ax
mov dx, bx
mov ax, 0c00h ;the right-most hex char is the color of the rectangle   - change color to see path - 0c03h

rect_loop2:
int 10h ;draw a pixel

inc cx ;increment x value
cmp cx, di ;check if xpos > destination x
jng rect_loop2

pop cx ;reset the xpos to the origin x
push cx

inc dx
cmp dx, si ;check if ypos > destination y
jng rect_loop2

pop si
pop si
pop di
pop dx
pop cx
pop bx
pop ax

ret




;plot a vertical line function 
;ax - start x-value
;bx - start y-value
;cx - length 

verticallBoundry:
push ax
push bx
push cx
push dx

;moving values around for pixel plotting
mov dx, bx
mov bx, cx
mov cx, ax
mov ax, 0c04h

vert_loop:
int 10h
inc dx
dec bx
jns vert_loop

pop dx
pop cx
pop bx
pop ax

ret




;unlot a vertical line function 
;ax - start x-value
;bx - start y-value
;cx - length  

vert_line_unplot:
push ax
push bx
push cx
push dx

;moving values around for pixel plotting
mov dx, bx
mov bx, cx
mov cx, ax
mov ax, 0c00h

vert_loopu:
int 10h
inc dx
dec bx
jns vert_loopu

pop dx
pop cx
pop bx
pop ax

ret




;plot a horizontal line function
;ax - start x-value
;bx - start y-value
;cx - length
horizontalBoundry:
push ax
push bx
push cx
push dx

;moving values around for pixel plotting
mov dx, bx
mov bx, cx
mov cx, ax
mov ax, 0c01h

horiz_loop:
int 10h
inc cx
dec bx
jns horiz_loop

pop dx
pop cx
pop bx
pop ax 

ret




;plot a black pixel at old location, and re-plot at the new location
;ax - old x
;bx - old y
;cx - new x
;dx - new y
move_pixel:
push bx
push ax

;cx and dx are popped within the function
push dx
push cx

;set cx, dx, to old x and y
mov cx, ax
mov dx, bx

;store the old color in bl
mov ax, 0d00h
int 10h
mov bl, al

;un-plot the old pixel
mov ax, 0c00h
int 10h

;plot the new pixel
mov al, bl
mov ah, 0ch
pop cx
pop dx
int 10h

;exit
pop ax
pop bx
ret




;plot a pixel function
;ax - x position
;bx - y position
plot_pixel:
push ax
push cx
push dx

mov cx, ax
mov dx, bx
mov ax, 0c0fh
int 10h

pop dx
pop cx
pop ax
ret         
