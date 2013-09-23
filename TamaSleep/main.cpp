#include <Windows.h>
#include <powrprof.h>


int APIENTRY _WinMain()
{
	SetSuspendState(FALSE, FALSE, FALSE);
	return 0;
}