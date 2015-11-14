<p>// 使用前の準備<br />
// 1. 同じディレクトリにmfc_message_map.idcが必要 (https://quequero.org/2008/08/guidelines-to-mfc-reversing/)<br />
// 2. GenerateMFCMap()の542行付近<br />
//　　　　　if(MakeStruct(ptr, "AFX_MSGMAP_ENTRY" == 0) {<br />
//          の直前に<br />
//					OpOff(ptr, 0, 0);<br />
//          をいれてください<br />
// 3. お好みによってWinUser.h、afxpriv.hにWinUser_h2mfc_message_map.mac (秀丸マクロ)を実行することによってmessageName()を強化できます。<br />
//</p>
<p>
// 使用方法<br />
// 1. afx_messagemap.idcをIDA Proで読み込みます。<br />
// 2. CWndの派生クラスのvftableからGetMessageMap関数を探します。通常はCCmdTarget::GetTypeLibの下にあります。 (1.png, 2.png, 3.png参照)<br />
// 3. mov元からMSGMAPの場所を突き止め、カーソルを先頭アドレスにあわせます。3.pngの場合は0x00519158<br />
// 4. Alt-F6で実行します。失敗した場合はそれっぽいところを範囲選択して右クリック→Undefine。またはAFX_MSGMAP_ENTRY構造体に手動で変換してください。ddなどに手動で変換してると失敗します(IDA ProのMakeStructのバグ？)</p>
<p>
<img src="https://raw.githubusercontent.com/devil-tamachan/tama-ieeye/master/afx_msgmap/1.png">
<img src="https://raw.githubusercontent.com/devil-tamachan/tama-ieeye/master/afx_msgmap/2.png">
<img src="https://raw.githubusercontent.com/devil-tamachan/tama-ieeye/master/afx_msgmap/3.png">
</p>