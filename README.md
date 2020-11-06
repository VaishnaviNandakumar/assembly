## Multiplayer Ping Pong Game
#### A multiplayer arcade game created using ASM with EMU8086

## Introduction
This project produces the implementation of a classic arcade game Ping Pong which can be managed using arrow keys between two players, and displays the game on an 8086 emulator. The arrow keys control the movement of the paddles on both sides which involves hitting the ball to the other side.

## How it works
* Player 1 controls the left paddle using the up and down arrow keys. Values 4800H (Up) and 5000H (Down) are taken as input in the keyboard buffer. 
* Player 2 controls the right paddle using the left and right arrow keys. Values 4D00H (Up) and 4B00H (Down) are taken as input in the keyboard buffer.
* All movable objects are plotted in a sequence using the respective color theme and are unplotted after perdioic * intervals to accomodate change in position values.

## Sample Outputs

#### Theme Selection Output Screen 
![Theme Selection](https://github.com/VaishnaviNandakumar/assembly/blob/master/images/themes.PNG)

#### Sample Theme outputs (Cyan, Green, Magenta)
![Theme Output](https://github.com/VaishnaviNandakumar/assembly/blob/master/images/theme_ouput.jpg)

#### Keyboard Buffer for Navigation
![Keyboard Buffer](https://github.com/VaishnaviNandakumar/assembly/blob/master/images/keyboard_buffer.PNG)

