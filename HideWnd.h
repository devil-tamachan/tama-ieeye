#pragma once
#include "stdafx.h"

// CWindowImpl�̔h���N���X�Ń��b�Z�[�W�ւ̔������`
class CHideWindow : public CWindowImpl<CHideWindow>
{
public:
    // �E�B���h�E�N���X����o�^
    DECLARE_WND_CLASS(_T("HideWnd"));

    // ���b�Z�[�W�}�b�v
    BEGIN_MSG_MAP(CHideWindow)
    END_MSG_MAP()

};