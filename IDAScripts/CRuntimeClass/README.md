<p>// 使用方<br />
// 1. ms_rtti4.idcとms_ehseh.idcを事前にかけてください。<br />
// 2. CRuntimeClass.idcを実行。出力用のテキストを選択<br />
// 3. .txtの内容は以下のとおりです。MFCのバージョンによって微妙に異なります。クラス名、クラスのサイズ(vtableへのポインタとデータメンバの合計)、シリアライズのバージョン（サポートしてない場合は0xFFFF）、親クラスのCRuntimeClass構造体へのアドレスとかいろいろ、最後にアラインが出力される場合もあります。<br />
<br />
// *1. 完全にすべてのCRuntimeClassが抽出できるわけではないです。そういう仕様です。push offset infoStrcAddr, call IsKindOfみたいな関数は大丈夫ですが、mov ebx offset infoStrcAddr, push ebx, call IsKindOfみたいなものは検出できません。またpushとcallの間がjmpなどで分岐していると検知しなかったり誤検知します。誤検知の場合はたぶん出力.txtのクラス名のところが変になってます。<br />
//</p>
<p>
<img src="https://raw.githubusercontent.com/devil-tamachan/tama-ieeye/master/IDAScripts/CRuntimeClass/crs01.png">
</p>