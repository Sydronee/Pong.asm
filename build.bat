masm Pong.asm;
link Pong.obj
@REM Commented out to not recompile previously complied code.
@REM nasm Keyboard.asm -o Keyboard.obj -f obj 
@REM tcc -c -IC:\TURBOC3\INCLUDE -LC:\TURBOC3\LIB Pong1.c
tlink Pong1.obj Pong.obj Keyboard.obj, Pong.exe, Pong.map, C:\TURBOC3\LIB\C0S.OBJ C:\TURBOC3\LIB\CS.LIB
Pong.exe