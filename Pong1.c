#include <dos.h>
extern void far install_key_handler();
extern void far uninstall_key_handler();
extern int far is_key_pressed(int code);

extern void far Setup();
extern void far FrameUpdate();
extern void far Input(int a, int b, int c, int d);
extern void far Exit();


int main()
{
	install_key_handler();
	Setup();
	while (!is_key_pressed(1))
	{
		Input(is_key_pressed(','), is_key_pressed('-'), is_key_pressed('K'), is_key_pressed('M'));
		// 					left				right				up					down
		FrameUpdate();
		delay(10);
	}
	uninstall_key_handler();
	Exit();

	return 0;
}