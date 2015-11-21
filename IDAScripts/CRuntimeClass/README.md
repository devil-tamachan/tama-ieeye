<p>// 使用方<br />
// 1. ms_rtti4.idcとms_ehseh.idcを事前にかけてください。<br />
// 2. CRuntimeClass.idcを実行。出力用のテキストを選択<br />
// 3. .txtの内容は以下のとおりです。MFCのバージョンによって微妙に異なります。クラス名、クラスのサイズ(vtableへのポインタとデータメンバの合計)、シリアライズのバージョン（サポートしてない場合は0xFFFF）、いろいろコンストラクタとかデストラクタとかのアドレス、最後にアラインが出力される場合もあります。<br />
//</p>
<p>
<img src="https://raw.githubusercontent.com/devil-tamachan/tama-ieeye/master/IDAScripts/CRuntimeClass/crs01.png">
</p>