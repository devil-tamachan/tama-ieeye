#include <windows.h>
#pragma comment(linker,"/subsystem:windows")
//#pragma comment(linker, "/opt:nowin98")
#pragma comment(linker, "/merge:.rdata=.text")
//#pragma comment(linker, "/merge:.reloc=.text")
//#pragma comment(linker, "/ignore:4078")
#pragma comment(linker, "/DYNAMICBASE:NO")
#pragma comment(linker, "/FIXED")
#pragma comment(linker, "/NXCOMPAT:NO")
#pragma comment(linker, "/ALIGN:16")
#pragma comment(linker, "/INCREMENTAL:NO")

int __stdcall WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	LockWorkStation();
}