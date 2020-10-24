org 100h 
mov cx, 0


;;-------------- SETTING UP INITIAL VALUES---------------
jmp maindata
gameWidth dw 50
gameHeight dw 50

;Order - xpos, ypos, xvel, yvel, size, newx, newy
ball dw 17,17,5,4,2,17,17     

;Order -  xpos, ypos, speed, length, newx, newy   
lpad dw 5, 14, 7, 11, 02, 14    ; Left Paddle  
rpad dw 5, 14, 7, 11, 48, 14    ; Right Paddle  

player1 dw 0c00h
  
s1 db 100,?, 100 dup(' ') 
msg1  db  "Choose player theme: (1) Blue (2) Red (3) Magenta (4) Cyan (5) Green $"

score dw 02h   

;;-------------- PROGRAM STARTS-------------------------

maindata:
   
    mov dx, offset msg1
    mov ah, 9
    int 21h
    
    
    mov ah, 1
    int 21h
    
    cmp al,31h
    jz colorBlue 
     
    cmp al,32h
    jz colorRed   
    
    cmp al,33h
    jz colorMagenta 
    
    cmp al,34h
    jz colorCyan     
    
    cmp al,35h
    jz colorGreen
    
    colorBlue:   
    mov player1,0c01h   
    jmp plot
    
    colorRed:  
    mov player1,0c04h   
    jmp plot
    
    colorMagenta:  
    mov player1,0c05h 
    jmp plot
    
    colorCyan:
    mov player1,0c0bh
    jmp plot 
    
    colorGreen:
    mov player1,0c02h
    jmp plot 
    
        
                      
                      
    
    
    ;SET BOUNDRY/PLAY AREA 
    plot:     
        ;SET TO GRAPHICS DISPLAY MODE   
    
        mov ax, 0013h
        int 10h
    
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
    
    
    
;;---------------------MAIN LOOP----------------------------
    mov cx, 0  
    mainloop:
        call drawPaddleL 
        call drawPaddleR 
        call drawBall
        call updateBall 
        call updatePadL 
        call checkBall_CollisionL     
        call updatePadR   
        call checkBall_CollisionR 
        
    
    loop mainloop
    
       
    ret 
    
      
;;-------------------DRAW FUNCTIONS--------------------------    
    
    ;Left Paddle
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
    
    ;Right Paddle
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
    
    
    
    ;Draws Ball
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
        
        
;;---------------------PLOT PLAY AREA----------------------------   

     rect_plot:
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        
        push ax                         ;Store the origin x in the stack
        
        mov di, cx 
        mov si, dx 
         
        mov cx, ax
        mov dx, bx
        mov ax, 0c0eh                   ;Color of rectangle - the right-most hex char 
        
        rect_loop:
        int 10h                         ;Draw Pixel
        
        inc cx 
        cmp cx, di                      ;Check if xpos > destination x
        jng rect_loop
        
        pop cx                          ;Xpos to the origin x
        push cx
        
        inc dx
        cmp dx, si                      ;Check if ypos > destination y
        jng rect_loop
        
        pop si
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
        
    

    
    rect_unplot:
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        
        push ax 
        
        mov di, cx
        mov si, dx 
        mov cx, ax
        mov dx, bx
        mov ax, 0c00h              ;the right-most hex char is the color of the rectangle   - change color to see path - 0c03h
        
        rect_loop2:
        int 10h 
        
        inc cx 
        cmp cx, di                  
        jng rect_loop2
        
        pop cx                     
        push cx
        
        inc dx
        cmp dx, si                 
        jng rect_loop2
        pop si
        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
    

    
    verticallBoundry:
        push ax
        push bx
        push cx
        push dx
        
        ;moving values around for pixel plotting
        mov dx, bx
        mov bx, cx
        mov cx, ax
        mov ax, player1
        
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
    
    
    
    move_pixel:
        push bx
        push ax
        
        ;cx and dx are popped within the function
        push dx
        push cx
        
        mov cx, ax
        mov dx, bx
        
        ;store the old color in bl
        mov ax, 0d00h
        int 10h
        mov bl, al
        
        ;un-plot the old pixel   - replace with black
        mov ax, 0c00h
        int 10h
        
        ;plot the new pixel
        mov al, bl
        mov ah, 0ch
        pop cx
        pop dx
        int 10h
        
        pop ax
        pop bx
        ret
            
        
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

        
    
;;-------------------UPDATE POSITION VALUE--------------------
    
    ;Ball position Values
    updateBall:
        push ax
        push bx
        push cx
        mov ax, ball[10]
        lea bx, ball[0]
        mov [bx], ax
        mov ax, ball[12]
        lea bx, ball[2]
        mov [bx], ax           
        
        ;X coordinate positions        
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
                              
        ;Y coordinate positions                    
        mov ax, ball[2]
        mov bx, ball[6]
        add ax, bx
        
        and bx, 8000h
        jz checkPositiveY  
        
        cmp ax, 0    
        jg updateY
        
        neg ax
        inc ax
        mov cx, ball[6]
        neg cx
        lea bx, ball[6]
        mov [bx], cx
        jmp updateY
        
        checkPositiveY:
        mov cx, ax
        add cx, ball[8]
        sub cx, gameHeight
        cmp cx, 0
        jle updateY
        
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
    
    
    
    
    ;Left Paddle Position Values
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
        
        ;Player 1 character -  keyboard buffer   
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
        
        ;If collision, set paddle to maximum possible ypos
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
    
    ;;Right Paddle Position Values
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
        
        ;Player 2 character - keyboard buffer   
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
        
        
        mov ax, rpad[2]
        add ax, rpad[4]
        
        ;Collision check
        mov bx, ax
        add bx, rpad[6]
        dec bx
        cmp bx, gameHeight
        jl commitR 
        dec score 
 
        mov bx, gameHeight
        dec bx
        sub bx, rpad[6]
        mov ax, bx
        jmp commitR 
        
        upR:
        mov ax, rpad[2]
        sub ax, rpad[4]
        
        cmp ax, 0
        jg commitR   
        mov ax, 1 
        
        commitR:
        lea bx, rpad[10]
        mov [bx], ax 
        
        donepuR:
        pop bx
        pop ax
        ret
    
    
 
;;--------------------------------CHECK COLLISIONS-----------------------------------   
    
    checkBall_CollisionL:
        push ax
        push bx
        push cx
        
        cmp ball[4], 0
        jge donep         ; To check if ball is heading towards the pad
        mov ax, lpad[0]
        cmp ball[10], ax
        jg donep          ; To check if the new position is behind the pad
        cmp ball[0], ax   
        jle donep         ; To check if the old ball position is in front of the pad
        
        mov ax, ball[12]
        mov bx, ax
        add bx, ball[8]
        dec bx 
        mov cx, lpad[10]
        cmp ax, cx
        jg nextc          ; To check for both y1 and y2 being under the pad's ypos
        cmp bx, cx
        jl donep  
               
        nextc:
        add cx, lpad[6]
        dec cx 
        cmp ax, cx
        jg donep         
   
        
        mov ax, ball[4]
        lea bx, ball[4]
        neg ax
        mov [bx], ax     ;Negate the x velocity
        
        mov ax, lpad[0]
        inc ax
        lea bx, ball[10]
        mov [bx], ax     ;Set the ball's new xpos to in front of the pad
        
        inc dx           ;Increment the score
        
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
        jle donepr         
        mov ax, rpad[0]
        cmp ball[10], ax
        jg donepr          
        cmp ball[0], ax   
        jle donepr        
        
        mov ax, ball[12]
        mov bx, ax
        add bx, ball[8]
        dec bx 
        mov cx, rpad[10]
        cmp ax, cx
        jg nextcr          
        cmp bx, cx
        jl donepr          
                       
        nextcr:
        add cx, rpad[6]
        dec cx 
        cmp ax, cx
        jg donepr         , 

        mov ax, ball[4]
        lea bx, ball[4]
        neg ax
        mov [bx], ax     
        
        mov ax, rpad[0]
        inc ax
        lea bx, ball[10]
        mov [bx], ax     
        
        inc dx
        
        donepr:
        pop cx
        pop bx
        pop ax
        ret