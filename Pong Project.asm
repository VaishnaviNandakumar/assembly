org 100h 
mov cx, 0

jmp skipdata
gameWidth dw 50
gameHeight dw 50


;Order - xpos, ypos, xvel, yvel, size, newx, newy
ball dw 17,17,5,4,2,17,17     

;Order -  xpos, ypos, speed, length, newx, newy
pad dw 5,14,7,11,5,14

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
call drawPaddle
    call drawBall
    call updateBall
    call updatePad
    call checkBall_Collision
    loop mainloop
    
ret 


;FUNCTIONS


;DRAWS PADDLE
drawPaddle:
    push ax
    push bx
    push cx
    
    mov ax, pad[0]
    mov bx, pad[2]
    mov cx, pad[6]
    call vert_line_unplot
    
    mov ax, pad[8]
    mov bx, pad[10]
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




;Paddle position update
updatePad:
push ax
push bx

;New position update
mov ax, pad[8]
lea bx, pad[0]
mov [bx], ax
mov ax, pad[10]
lea bx, pad[2]
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
je up
cmp ah, 50h
jne donepu

;down
mov ax, pad[2]
add ax, pad[4]

;Collision check
mov bx, ax
add bx, pad[6]
dec bx
cmp bx, gameHeight
jl commit  
;If no collision, commit changes in ypos to the object

;if collision, set paddle to maximum possible ypos
mov bx, gameHeight
dec bx
sub bx, pad[6]
mov ax, bx
jmp commit 
;then commit the changes

up:
mov ax, pad[2]
sub ax, pad[4]

cmp ax, 0
jg commit   
;if there's a collision, simply set the ypos to 1
mov ax, 1 

commit:
lea bx, pad[10]
mov [bx], ax 

donepu:
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


checkBall_Collision:
push ax
push bx
push cx

cmp ball[4], 0
jge donep         ;check that the ball is heading towards the pad
mov ax, pad[0]
cmp ball[10], ax
jg donep          ;check that the new position is behind the pad
cmp ball[0], ax   
jle donep         ;check that the old ball position is in front of the pad

mov ax, ball[12]
mov bx, ax
add bx, ball[8]
dec bx ;because the ball's size is absolute and includes the origin xpos
mov cx, pad[10]
cmp ax, cx
jg nextc          ;now, check for both y1 and y2 being under the pad's ypos
cmp bx, cx
jl donep          ;if they both are, we're done
                  ;if not, go to nextc

nextc:
add cx, pad[6]
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

mov ax, pad[0]
inc ax
lea bx, ball[10]
mov [bx], ax     ;set the ball's new xpos to in front of the pad

inc dx           ;increment the score

donep:
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




;plot a black rectangle function
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
mov ax, 0c03h ;the right-most hex char is the color of the rectangle

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
