<p>// �g�p�O�̏���<br />
// 1. �����f�B���N�g����mfc_message_map.idc���K�v (https://quequero.org/2008/08/guidelines-to-mfc-reversing/)<br />
// 2. GenerateMFCMap()��542�s�t��<br />
//�@�@�@�@�@if(MakeStruct(ptr, "AFX_MSGMAP_ENTRY" == 0) {<br />
//          �̒��O��<br />
//					OpOff(ptr, 0, 0);<br />
//          ������Ă�������<br />
// 3. ���D�݂ɂ����WinUser.h�Aafxpriv.h��WinUser_h2mfc_message_map.mac (�G�ۃ}�N��)�����s���邱�Ƃɂ����messageName()�������ł��܂��B<br />
//</p>
<p>
// �g�p���@<br />
// 1. afx_messagemap.idc��IDA Pro�œǂݍ��݂܂��B<br />
// 2. CWnd�̔h���N���X��vftable����GetMessageMap�֐���T���܂��B�ʏ��CCmdTarget::GetTypeLib�̉��ɂ���܂��B (1.png, 2.png, 3.png�Q��)<br />
// 3. mov������MSGMAP�̏ꏊ��˂��~�߁A�J�[�\����擪�A�h���X�ɂ��킹�܂��B3.png�̏ꍇ��0x00519158<br />
// 4. Alt-F6�Ŏ��s���܂��B���s�����ꍇ�͂�����ۂ��Ƃ����͈͑I�����ĉE�N���b�N��Undefine�B�܂���AFX_MSGMAP_ENTRY�\���̂Ɏ蓮�ŕϊ����Ă��������Bdd�ȂǂɎ蓮�ŕϊ����Ă�Ǝ��s���܂�(IDA Pro��MakeStruct�̃o�O�H)</p>
<p>
<img src="https://raw.githubusercontent.com/devil-tamachan/tama-ieeye/master/afx_msgmap/1.png">
<img src="https://raw.githubusercontent.com/devil-tamachan/tama-ieeye/master/afx_msgmap/2.png">
<img src="https://raw.githubusercontent.com/devil-tamachan/tama-ieeye/master/afx_msgmap/3.png">
</p>