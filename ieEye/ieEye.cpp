// ieEye.cpp : main source file for ieEye.exe
//

#include "stdafx.h"

#include <atlframe.h>
#include <atlctrls.h>
#include <atldlgs.h>

#include "resource.h"

#include "TaskTray.h"
#include "HideWnd.h"

CAppModule _Module;

int WINAPI _tWinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPTSTR /*lpstrCmdLine*/, int /*nCmdShow*/)
{
	HRESULT hRes = ::CoInitialize(NULL);
// If you are running on NT 4.0 or higher you can use the following call instead to 
// make the EXE free threaded. This means that calls come in on a random RPC thread.
//	HRESULT hRes = ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	ATLASSERT(SUCCEEDED(hRes));

	SetPriorityClass(GetCurrentProcess(), BELOW_NORMAL_PRIORITY_CLASS);

	// this resolves ATL window thunking problem when Microsoft Layer for Unicode (MSLU) is used
	::DefWindowProc(NULL, 0, 0, 0L);

	AtlInitCommonControls(ICC_BAR_CLASSES);	// add flags to support other controls

	hRes = _Module.Init(NULL, hInstance);
	ATLASSERT(SUCCEEDED(hRes));

	CMessageLoop theLoop;
	_Module.AddMessageLoop(&theLoop);

	int nRet = 0;
	CTaskTray trayicon;
//	CHideWindow hideWnd;
	// BLOCK: Run application
	{
	//	hideWnd.
		if (trayicon.Create(NULL, CWindow::rcDefault, _T("ieEye"), WS_OVERLAPPEDWINDOW) == NULL)
		{
			ATLTRACE(_T("ウィンドウの生成に失敗しました！\n"));
			return 0;
		}
		trayicon.RegisterIcon(AtlLoadIcon(IDI_ICON1), _T("ieEye"), IDR_MENU1);
		trayicon.RegisterIcon2(AtlLoadIcon(IDR_MAINFRAME));
//		CMainDlg dlgMain;
	//	nRet = dlgMain.DoModal();
	}

	RegisterHotKey(trayicon, ID_HOTKEYPAUSE, 0, VK_PAUSE);


	nRet = theLoop.Run();
	_Module.RemoveMessageLoop();

	UnregisterHotKey(trayicon, ID_HOTKEYPAUSE);

//	trayicon.DestroyWindow();

	_Module.Term();
	::CoUninitialize();

	return nRet;
}
