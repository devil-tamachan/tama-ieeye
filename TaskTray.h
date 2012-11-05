#pragma once
#include "stdafx.h"

class CTaskTray : public CWindowImpl<CTaskTray>,
                  public CTrayIconImpl<CTaskTray>
{
public:
    DECLARE_WND_CLASS(_T("TrayIcon"));

	BEGIN_MSG_MAP(CTaskTray)
		CHAIN_MSG_MAP(CTrayIconImpl<CTaskTray>)
		MSG_WM_TIMER(OnTimer);
		MSG_WM_CREATE(OnCreate)
        MSG_WM_DESTROY(OnDestroy)
		MSG_WM_HOTKEY(OnHotKey)
		COMMAND_ID_HANDLER_EX(ID_MENU1_EXIT, OnMenu1Exit)
	END_MSG_MAP()

	void OnHotKey(int nHotKeyID, UINT uModifiers, UINT uVirtKey)
	{
		if(uVirtKey==VK_PAUSE)
		{
			HWND targetHWND = GetForegroundWindow();
			if(targetHWND!=NULL)
			{
				::SetWindowPos(targetHWND, isTopMostWnd(targetHWND)?HWND_NOTOPMOST:(HWND)HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
				MyFlashWindow(targetHWND, 10);
			}

	//		MessageBox(L"aa");
		}
	}

	//g_hwndCurSel(HWND)は最前列ウィンドウか？
	int isTopMostWnd(HWND targetHWND) {
		return (::GetWindowLong(targetHWND, GWL_EXSTYLE)&WS_EX_TOPMOST);
	}

	void MyFlashWindow(HWND hwndTarget, unsigned int cnt)
	{
		FLASHWINFO info;
		info.cbSize = sizeof(info);
		info.hwnd = hwndTarget;
		info.dwFlags = FLASHW_ALL;  // キャプションとタスクバーのボタンを両方とも点滅
		info.uCount = cnt;            // 点滅回数は５回
		info.dwTimeout = 30;         // 標準的な点滅速度
		FlashWindowEx( &info );
	}

	CTaskTray()
	{
	//	m_lastTime = 0;
	//	::SetTimer(NULL, ID_CHECKTIMER, 1000*60, OnTimer);
	}
		
    void OnTimer(UINT)
	{
	//	DWORD t = GetTickCount();

		BOOL ieStat = CheckIexplorer();
		ATLTRACE("OnTimer...%d\n", ieStat);
		if(ieStat)
		{
			SwitchIcon(1);
			ShowBalloonTip(_T("IE running..."), _T("ieEye"), 3000, NIIF_INFO);
		} else {
			SwitchIcon(0);
		}
    }

	BOOL CheckIexplorer()
	{
		DWORD allProc[1024];
		DWORD cbNeeded;
		int nProc;
		int i;

		// PID一覧を取得
		if (!EnumProcesses(allProc, sizeof(allProc), &cbNeeded)) {
			return 1;
		}

		nProc = cbNeeded / sizeof(DWORD);

		for (i = 0; i < nProc; i++) {
			TCHAR procName[MAX_PATH] = TEXT("<unknown>");

			HANDLE hProcess = OpenProcess(
				PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
				FALSE, allProc[i]);

			// プロセス名を取得
			if (NULL != hProcess) {
				HMODULE hMod;
				DWORD cbNeeded;

				if (EnumProcessModules(hProcess, &hMod, sizeof(hMod), &cbNeeded)) {
					GetModuleBaseName(hProcess, hMod, procName, 
						sizeof(procName)/sizeof(TCHAR));
				}
			}

			// プロセス名とPIDを表示
	//		ATLTRACE(TEXT("%s  (PID: %u)\n"), procName, allProc[i]);
			CloseHandle(hProcess);
			if(_wcsicmp(procName, _T("iexplore.exe"))==0)return true;
//			if(_wcsicmp(procName, _T("flashutil10t_activex.exe"))==0)return true;
			if(_wcsnicmp(procName, _T("flashutil"), 9)==0)return true;
		}
		return false;
	}
	
	int OnCreate(LPCREATESTRUCT lpCreateStruct){
		
		SetTimer(ID_CHECKTIMER, 1000*10, NULL);
        return 0;
    }

    void OnDestroy(){
        PostQuitMessage(0);
    }

	void OnMenu1Exit(UINT uNotifyCode, int nID, CWindow wndCtl)
	{
		//	this->UnregisterIcon();
	//	SwitchIcon(1);
	//	Sleep(10000);
		DestroyWindow();
	//	PostQuitMessage(0);
	}

private:
//	DWORD m_lastTime;
};