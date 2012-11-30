#pragma once
 
// WAC.com Class Liblary for Visual C++
// Copyright (C) WAC.com Inc. All rights reserved.
//
// This file is a part of the WAC.com Class Liblary.
// The use and distribution terms for this software are covered by the
// Common Public License 1.0 (http://opensource.org/licenses/cpl.php)
// which can be found in the file CPL.TXT at the root of this distribution.
// By using this software in any fashion, you are agreeing to be bound by
// the terms of this license. You must not remove this notice, or
// any other, from this software.
 
// '07.04.06 : UNICODE対応 (sha)
// '07.06.21 : コードの整備 (sha)
 
 
/////////////////////////////////////////////////////////////////////////////
// CNotifyIconData
 
class CNotifyIconData : public NOTIFYICONDATA
{
public:    
    CNotifyIconData()
    {
        ::ZeroMemory(this, sizeof(NOTIFYICONDATA));
//        cbSize = sizeof(NOTIFYICONDATA);
#if _UNICODE
        cbSize = 936;
#else
        cbSize = 488;
#endif
        ATLTRACE(_T("%d\n"), sizeof(NOTIFYICONDATA));
    }
};
 
 
/////////////////////////////////////////////////////////////////////////////
// CTrayIconImpl
 
template <class T>
class CTrayIconImpl
{
protected:
    typedef CTrayIconImpl                        thisClass;
 
public:    
    CTrayIconImpl()
    {
        WM_TRAYICON = ::RegisterWindowMessage(_T("WM_TRAYICON"));
        WM_TASKBARCREATED = ::RegisterWindowMessage(_T("TaskbarCreated"));
 
        m_bRegistered = false;
        m_bRegistered2 = false;
        m_nDefaultID = 0;
		m_currentIconNum = 0;
    }
    virtual ~CTrayIconImpl()
    {
        T* pT = static_cast<T*>(this);
 
        HRESULT hr = S_OK;
 
        hr = pT->UnregisterIcon();
        if (FAILED(hr))
        {
            // 無視する。。
        }
    }
 
BEGIN_MSG_MAP(CTrayIconImpl)
    MESSAGE_HANDLER(WM_TRAYICON, OnTrayIcon)
    MESSAGE_HANDLER(WM_TASKBARCREATED, OnTaskBarCreated)
END_MSG_MAP()
 
// ハンドラ プロパティ:
//  LRESULT MessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
//  LRESULT CommandHandler(WORD wNotifyCode, WORD wID, HWND hWndCtl, BOOL& bHandled);
//  LRESULT NotifyHandler(int idCtrl, LPNMHDR pnmh, BOOL& bHandled);
 
// Window Message Handles
public:
    LRESULT OnTrayIcon(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& /*bHandled*/)
    {
        T* pT = static_cast<T*>(this);
 
        // Is this the ID we want?
        if (wParam != m_notifyIconData.uID)
        {
            return 0;
        }
 
        LRESULT lResult = 0;
 
        if      (LOWORD(lParam) == WM_RBUTTONUP)
        {
            lResult = pT->OnTrayIconRButtonUp();
        }
        else if (LOWORD(lParam) == WM_LBUTTONDBLCLK)
        {
            lResult = pT->OnTrayIconLButtonDblClk();
        }
        else
        {
            // 何もしない。。
        }
 
        return lResult;
    }
    LRESULT OnTaskBarCreated(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
    {
        BOOL br = ::Shell_NotifyIcon(NIM_ADD, GetCurrentIcon()/*&m_notifyIconData*/);
        if (!br)
        {
            // 無視する。。
        }
 
        return 0;
    }
 
// Command Handlers
public:
 
public:
	HRESULT RegisterIcon2(HICON hIcon)
	{ 
		if(!m_bRegistered)return E_FAIL;

        // Fill in the data        
        m_notifyIconData2.hWnd = m_notifyIconData.hWnd;
        m_notifyIconData2.uID = m_notifyIconData.uID;
        m_notifyIconData2.hIcon = hIcon;
        m_notifyIconData2.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
        m_notifyIconData2.uCallbackMessage = WM_TRAYICON;
        _tcscpy_s(m_notifyIconData2.szTip, m_notifyIconData.szTip);
  
        m_bRegistered2 = true;
 
        return S_OK;
	}
	HRESULT SwitchIcon(int num)
	{
		if(num<0 || num >1 || (!m_bRegistered) || (!m_bRegistered2))return E_FAIL;

		if(m_currentIconNum != num)
		{
			m_currentIconNum = num;

	        BOOL br = ::Shell_NotifyIcon(NIM_MODIFY, GetCurrentIcon()/*&m_notifyIconData*/);
	        if (!br)
	        {
	            return E_FAIL;
	        }
		}
 
        return S_OK;
	}

    // Install a taskbar icon
    // szToolTip : The tooltip to display
    // hIcon : The icon to display
    // nID : The resource ID of the context menu
    HRESULT RegisterIcon(HICON hIcon, LPCTSTR szTip, UINT nID)
    {
        T* pT = static_cast<T*>(this);
 
        // Fill in the data        
        m_notifyIconData.hWnd = pT->m_hWnd;
        m_notifyIconData.uID = nID;
        m_notifyIconData.hIcon = hIcon;
        m_notifyIconData.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
        m_notifyIconData.uCallbackMessage = WM_TRAYICON;
        _tcscpy_s(m_notifyIconData.szTip, szTip);
 
        BOOL br = ::Shell_NotifyIcon(NIM_ADD, &m_notifyIconData);
        if (!br)
        {
            return E_FAIL;
        }
 
        m_bRegistered = true;
 
        return S_OK;
    }
    // Remove taskbar icon
    HRESULT UnregisterIcon()
    {
        if (!m_bRegistered && !m_bRegistered2)
        {
            return E_FAIL;
        }
 
        // Remove
        m_notifyIconData.uFlags = 0;
 
		if(m_bRegistered)
		{
	        BOOL br = ::Shell_NotifyIcon(NIM_DELETE, &m_notifyIconData);
	        if (!br)
	        {
	            return E_FAIL;
	        }
		}

		if(m_bRegistered2)
		{
			BOOL br = ::Shell_NotifyIcon(NIM_DELETE, &m_notifyIconData2);
			if (!br)
			{
				return E_FAIL;
			}
		}
 
        return S_OK;
    }
    // Set the icon tooltip text
    HRESULT SetTooltip(LPCTSTR szTip)
    {
        if (szTip == NULL)
        {
            return E_FAIL;
        }
 
        // Fill the structure
        GetCurrentIcon()/*m_notifyIconData*/.uFlags = NIF_TIP;
        _tcscpy_s(GetCurrentIcon()/*m_notifyIconData*/.szTip, szTip);
 
        BOOL br = ::Shell_NotifyIcon(NIM_MODIFY, GetCurrentIcon()/*&m_notifyIconData*/);
        if (!br)
        {
            return E_FAIL;
        }
 
        return S_OK;
    }
    HRESULT ShowBalloonTip(LPCTSTR szInfo, LPCTSTR szInfoTitle, UINT uTimeout, DWORD dwInfoFlags)
    { 
        /*m_notifyIconData*/GetCurrentIcon()->uFlags = NIF_INFO | NIF_ICON;
        /*m_notifyIconData*/GetCurrentIcon()->uTimeout = uTimeout;
        /*m_notifyIconData*/GetCurrentIcon()->dwInfoFlags = dwInfoFlags;
        _tcscpy_s(/*m_notifyIconData*/GetCurrentIcon()->szInfo, szInfo ? szInfo : _T(""));
        _tcscpy_s(/*m_notifyIconData*/GetCurrentIcon()->szInfoTitle, szInfoTitle ? szInfoTitle : _T(""));
 
        BOOL br = ::Shell_NotifyIcon(NIM_MODIFY, GetCurrentIcon()/*&m_notifyIconData*/);
        if (!br)
        {
            return E_FAIL;
        }
 
        return S_OK;
    }
    // Set the default menu item ID
    void SetDefaultID(UINT nID)
    {
        m_nDefaultID = nID;
    }
 
// Overrides
public:
    LRESULT OnTrayIconRButtonUp()
    {
        T* pT = static_cast<T*>(this);
 
        // Display the menu at the current mouse location. There's a "bug"
        // (Microsoft calls it a feature) in Windows 95 that requires calling
        // SetForegroundWindow. To find out more, search for Q135788 in MSDN.
 
        // Load the menu
        CMenu menu;
        if (!menu.LoadMenu(m_notifyIconData.uID))
        {
            return 0;
        }
 
        // Get the sub-menu
        CMenuHandle menuPopup = menu.GetSubMenu(0);
 
        // Prepare
        pT->OnTrayIconPrepareMenu(menuPopup);
 
        // Get the menu position
        CPoint pos;
        ::GetCursorPos(&pos);
 
        // Make app the foreground
        ::SetForegroundWindow(pT->m_hWnd);
 
        // Set the default menu item
        if (m_nDefaultID == 0)
        {
            menuPopup.SetMenuDefaultItem(0, TRUE);
        }
        else
        {
            menuPopup.SetMenuDefaultItem(m_nDefaultID);
        }
 
        // Track
        menuPopup.TrackPopupMenu(TPM_LEFTALIGN, pos.x, pos.y, pT->m_hWnd);
 
        // BUGFIX: See "PRB: Menus for Notification Icons Don't Work Correctly"
        pT->PostMessage(WM_NULL);
 
        // Done
        menu.DestroyMenu();
 
        return 0;
    }
    LRESULT OnTrayIconLButtonDblClk()
    {
        T* pT = static_cast<T*>(this);
 
        // Make app the foreground
        ::SetForegroundWindow(pT->m_hWnd);
 
        // Load the menu
        CMenu menu;
        if (!menu.LoadMenu(m_notifyIconData.uID))
        {
            return 0;
        }
 
        // Get the sub-menu
        CMenuHandle menuPopup = menu.GetSubMenu(0);
 
        // Get the item
        if (m_nDefaultID)
        {
            // Send
            pT->SendMessage(WM_COMMAND, m_nDefaultID, 0);
        }
        else
        {
            UINT nID = menuPopup.GetMenuItemID(0);
 
            // Send
            pT->SendMessage(WM_COMMAND, nID, 0);
        }
 
        // Done
        menu.DestroyMenu();
 
        return 0;
    }
    // Allow the menu items to be enabled/checked/etc.
    void OnTrayIconPrepareMenu(HMENU hMenu)
    {
        // Stub
    }
protected:
	CNotifyIconData* GetCurrentIcon()
	{
		if(m_currentIconNum==0)return &m_notifyIconData;
		return &m_notifyIconData2;
	}
 
protected:
    UINT WM_TRAYICON;
    UINT WM_TASKBARCREATED;
 
    CNotifyIconData m_notifyIconData;
    CNotifyIconData m_notifyIconData2;
	int m_currentIconNum;
    bool m_bRegistered;
    bool m_bRegistered2;
    UINT m_nDefaultID;
};
