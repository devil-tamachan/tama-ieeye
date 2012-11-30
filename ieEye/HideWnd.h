#pragma once
#include "stdafx.h"

// CWindowImplの派生クラスでメッセージへの反応を定義
class CHideWindow : public CWindowImpl<CHideWindow>
{
public:
    // ウィンドウクラス名を登録
    DECLARE_WND_CLASS(_T("HideWnd"));

    // メッセージマップ
    BEGIN_MSG_MAP(CHideWindow)
    END_MSG_MAP()

};