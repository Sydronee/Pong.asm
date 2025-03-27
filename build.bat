masm Pong.asm;
link Pong.obj
nasm Keyboard.asm -o Keyboard.obj -f obj
tcc -c -IC:\TURBOC3\INCLUDE -LC:\TURBOC3\LIB Pong1.c
tlink Pong1.obj Pong.obj Keyboard.obj, Pong.exe, Pong.map, C:\TURBOC3\LIB\C0S.OBJ C:\TURBOC3\LIB\CS.LIB
Pong.exe