// MainDlg.h : interface of the CMainDlg class
//
/////////////////////////////////////////////////////////////////////////////

#pragma once

const unsigned char footer[] = {0x56, 0x34, 0x12, 0xFA};


class CMainDlg : public CDialogImpl<CMainDlg>, public CUpdateUI<CMainDlg>,
		public CMessageFilter, public CIdleHandler
{
public:
	enum { IDD = IDD_MAINDLG };

	virtual BOOL PreTranslateMessage(MSG* pMsg)
	{
		return CWindow::IsDialogMessage(pMsg);
	}

	virtual BOOL OnIdle()
	{
		return FALSE;
	}

  CEdit m_edit_proj;
  CEdit m_edit_swf;

	BEGIN_UPDATE_UI_MAP(CMainDlg)
	END_UPDATE_UI_MAP()

	BEGIN_MSG_MAP(CMainDlg)
		MESSAGE_HANDLER(WM_INITDIALOG, OnInitDialog)
		MESSAGE_HANDLER(WM_DESTROY, OnDestroy)
    MSG_WM_CLOSE(OnClose)
		COMMAND_ID_HANDLER(ID_APP_ABOUT, OnAppAbout)
		COMMAND_ID_HANDLER(IDB_CONV, OnConv)
		COMMAND_ID_HANDLER(IDB_SEL_PROJ, OnSelProj)
		COMMAND_ID_HANDLER(IDB_SEL_SWF, OnSelSwf)
  END_MSG_MAP()

// Handler prototypes (uncomment arguments if needed):
//	LRESULT MessageHandler(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
//	LRESULT CommandHandler(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
//	LRESULT NotifyHandler(int /*idCtrl*/, LPNMHDR /*pnmh*/, BOOL& /*bHandled*/)

  void OnClose()
  {
    DestroyWindow();
  }

	LRESULT OnInitDialog(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		// center the dialog on the screen
		CenterWindow();

		// set icons
		HICON hIcon = AtlLoadIconImage(IDR_MAINFRAME, LR_DEFAULTCOLOR, ::GetSystemMetrics(SM_CXICON), ::GetSystemMetrics(SM_CYICON));
		SetIcon(hIcon, TRUE);
		HICON hIconSmall = AtlLoadIconImage(IDR_MAINFRAME, LR_DEFAULTCOLOR, ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON));
		SetIcon(hIconSmall, FALSE);

		// register object for message filtering and idle updates
		CMessageLoop* pLoop = _Module.GetMessageLoop();
		ATLASSERT(pLoop != NULL);
		pLoop->AddMessageFilter(this);
		pLoop->AddIdleHandler(this);

		UIAddChildWindowContainer(m_hWnd);

    m_edit_proj = GetDlgItem(IDE_PROJ);
    m_edit_swf = GetDlgItem(IDE_SWF);

		return TRUE;
	}

	LRESULT OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		// unregister message filtering and idle updates
		CMessageLoop* pLoop = _Module.GetMessageLoop();
		ATLASSERT(pLoop != NULL);
		pLoop->RemoveMessageFilter(this);
		pLoop->RemoveIdleHandler(this);
    
    PostQuitMessage(0);

		return 0;
	}

	LRESULT OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
		CAboutDlg dlg;
		dlg.DoModal();
		return 0;
	}


	LRESULT OnConv(WORD /*wNotifyCode*/, WORD wID, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
  {
    CFileDialog dlg(FALSE, _T("exe"), _T("保存"), OFN_OVERWRITEPROMPT,
      _T("swf結合済みプロジェクタ (*.exe)\0*.exe\0すべてのファイル (*.*)\0*.*\0\0"));

    if(dlg.DoModal() == IDOK)
    {
      ATL::CString pathProj, pathSwf;
      m_edit_proj.GetWindowText(pathProj);
      m_edit_swf.GetWindowText(pathSwf);
      if(pathProj.GetLength()==0 || pathSwf.GetLength()==0)return 0;
      fpos_t filesizeProj = 0;
      fpos_t filesizeSwf = 0;
      unsigned char *pProj = MyReadFile(CW2A(pathProj), &filesizeProj);
      if(pProj==NULL)return 0;
      unsigned char *pSwf = MyReadFile(CW2A(pathSwf), &filesizeSwf);
      if(pSwf==NULL)
      {
        free(pProj);
        return 0;
      }

      FILE *fp = fopen(CW2A(dlg.m_szFileName), "wb");
      if(fp)
      {
        fwrite(pProj, filesizeProj, 1, fp);
        fwrite(pSwf, filesizeSwf, 1, fp);
        fwrite(footer, 4, 1, fp);
        DWORD dwSwf = filesizeSwf;
        fwrite(&dwSwf, 4, 1, fp);
      }
      free(pProj);
      free(pSwf);
      fclose(fp);
    }
		return 0;
	}

  unsigned char* MyReadFile(LPCSTR pFileName, fpos_t *pFileSize)
  {
    FILE *fp = fopen(pFileName, "rb");
    if(!fp)return NULL;
    fseek(fp, 0, SEEK_END);
    fpos_t filesize = 0;
    fgetpos(fp, &filesize);
    fseek(fp, 0, SEEK_SET);
    unsigned char *pBuf = (unsigned char*)malloc(filesize);
    if(pBuf==NULL)
    {
      fclose(fp);
      return NULL;
    }
    fread(pBuf, filesize, 1, fp);
    fclose(fp);
    if(pFileSize)*pFileSize = filesize;
    return pBuf;
  }

	LRESULT OnSelProj(WORD /*wNotifyCode*/, WORD wID, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
  {
    CFileDialog dlg(TRUE, _T("exe"), NULL, OFN_FILEMUSTEXIST,
      _T("Flashプロジェクター (*.exe)\0*.exe\0すべてのファイル (*.*)\0*.*\0\0"));

    if(dlg.DoModal() == IDOK)
    {
      m_edit_proj.SetWindowText(dlg.m_szFileName);
    }
		return 0;
	}

	LRESULT OnSelSwf(WORD /*wNotifyCode*/, WORD wID, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
    CFileDialog dlg(TRUE, _T("swf"), NULL, OFN_FILEMUSTEXIST,
      _T("swfファイル (*.swf)\0*.swf\0すべてのファイル (*.*)\0*.*\0\0"));

    if(dlg.DoModal() == IDOK)
    {
      m_edit_swf.SetWindowText(dlg.m_szFileName);
    }
		return 0;
	}

	void CloseDialog(int nVal)
	{
		DestroyWindow();
		::PostQuitMessage(nVal);
	}
};
