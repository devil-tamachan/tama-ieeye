<p>// �g�p��<br />
// 1. ms_rtti4.idc��ms_ehseh.idc�����O�ɂ����Ă��������B<br />
// 2. CRuntimeClass.idc�����s�B�o�͗p�̃e�L�X�g��I��<br />
// 3. .txt�̓��e�͈ȉ��̂Ƃ���ł��BMFC�̃o�[�W�����ɂ���Ĕ����ɈقȂ�܂��B�N���X���A�N���X�̃T�C�Y(vtable�ւ̃|�C���^�ƃf�[�^�����o�̍��v)�A�V���A���C�Y�̃o�[�W�����i�T�|�[�g���ĂȂ��ꍇ��0xFFFF�j�A�e�N���X��CRuntimeClass�\���̂ւ̃A�h���X�Ƃ����낢��A�Ō�ɃA���C�����o�͂����ꍇ������܂��B<br />
<br />
// *1. ���S�ɂ��ׂĂ�CRuntimeClass�����o�ł���킯�ł͂Ȃ��ł��B���������d�l�ł��Bpush offset infoStrcAddr, call IsKindOf�݂����Ȋ֐��͑��v�ł����Amov ebx offset infoStrcAddr, push ebx, call IsKindOf�݂����Ȃ��̂͌��o�ł��܂���B�܂�push��call�̊Ԃ�jmp�Ȃǂŕ��򂵂Ă���ƌ��m���Ȃ�������댟�m���܂��B�댟�m�̏ꍇ�͂��Ԃ�o��.txt�̃N���X���̂Ƃ��낪�ςɂȂ��Ă܂��B<br />
//</p>
<p>
<img src="https://raw.githubusercontent.com/devil-tamachan/tama-ieeye/master/IDAScripts/CRuntimeClass/crs01.png">
</p>