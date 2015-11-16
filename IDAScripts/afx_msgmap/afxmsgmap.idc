
#include <idc.idc>
#include <mfc_message_map.idc>

// �g�p�O�̏���
// 1. �����f�B���N�g����mfc_message_map.idc���K�v (https://quequero.org/2008/08/guidelines-to-mfc-reversing/)
// 2. GenerateMFCMap()��542�s�t��
//�@�@�@�@�@if(MakeStruct(ptr, "AFX_MSGMAP_ENTRY" == 0) {
//          �̒��O��
//					OpOff(ptr, 0, 0);
//          ������Ă�������
// 3. ���D�݂ɂ����WinUser.h��WinUser_h2mfc_message_map.mac (�G�ۃ}�N��)�����s���邱�Ƃɂ����messageName()�������ł��܂��B
//
// �g�p���@
// 1. afx_messagemap.idc��IDA Pro�œǂݍ��݂܂��B
// 2. CWnd�̔h���N���X��vftable����GetMessageMap�֐���T���܂��B�ʏ��CCmdTarget::GetTypeLib�̉��ɂ���܂��B (1.png, 2.png, 3.png�Q��)
// 3. mov������MSGMAP�̏ꏊ��˂��~�߁A�J�[�\����擪�A�h���X�ɂ��킹�܂��B3.png�̏ꍇ��0x00519158
// 4. Alt-F6�Ŏ��s���܂��B���s�����ꍇ�͂�����ۂ��Ƃ����͈͑I�����ĉE�N���b�N��Undefine�B�܂���AFX_MSGMAP_ENTRY�\���̂Ɏ蓮�ŕϊ����Ă��������Bdd�ȂǂɎ蓮�ŕϊ����Ă�Ǝ��s���܂�(IDA Pro��MakeStruct�̃o�O�H)

static ParseAFXMSGMAP()
{
  if(ScreenEA()!=BADADDR)
  {
    GenerateMFCMap(ScreenEA());
  }
}

static AddHotkeys()
{
  AddHotkey("Alt-F6","ParseAFXMSGMAP");
  Message("Alt-F6: decode AFX_MSGMAP\n");
}

static main(void)
{
  AddHotkeys();
}
