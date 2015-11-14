<p>// 使用前の準備</p>
<p>// 1. 同じディレクトリにmfc_message_map.idcが必要 (https://quequero.org/2008/08/guidelines-to-mfc-reversing/)</p>
<p>// 2. GenerateMFCMap()の542行付近</p>
<p>//　　　　　if(MakeStruct(ptr, "AFX_MSGMAP_ENTRY" == 0) {</p>
<p>//          の直前に</p>
<p>//					OpOff(ptr, 0, 0);</p>
<p>//          をいれてください</p>
<p>// 3. お好みによってWinUser.hにWinUser_h2mfc_message_map.mac (秀丸マクロ)を実行することによってmessageName()を強化できます。</p>
<p>//</p>
<p>// 使用方法</p>
<p>// 1. afx_messagemap.idcをIDA Proで読み込みます。</p>
<p>// 2. CWndの派生クラスのvftableからGetMessageMap関数を探します。通常はCCmdTarget::GetTypeLibの下にあります。 (1.png, 2.png, 3.png参照)</p>
<p>// 3. mov元からMSGMAPの場所を突き止め、カーソルを先頭アドレスにあわせます。3.pngの場合は0x00519158</p>
<p>// 4. Alt-F6で実行します。失敗した場合はそれっぽいところを範囲選択して右クリック→Undefine。またはAFX_MSGMAP_ENTRY構造体に手動で変換してください。ddなどに手動で変換してると失敗します(IDA ProのMakeStructのバグ？)</p>