# お断り #

はっきり言ってここに書かれている方法をしても無駄です。意味はありません。ただの趣味です。


# はじめに #
LockWorkStation();一行のプログラムをVC2010でコンパイルすると7KBになりました。<br>VC2010でどこまで縮むのだろうかと興味が湧いたので実験してみることにしました。<br>
<br>
<h1>結果</h1>
TamaScreenLockDefaultWithoutRes.exe (VC2010で普通にコンパイルしたもの) 7168 bytes<br>
TamaScreenLockReduseWithoutRes.exe (実験的にexeを縮めたもの) 608 bytes<br>
<br>
<h1>ソースコード</h1>
<br>
<br>
<A href="http://code.google.com/p/tama-ieeye/source/browse/TamaScreenLock/main.cpp"><br>
<br>
<a href='http://code.google.com/p/tama-ieeye/source/browse/TamaScreenLock/main.cpp'>http://code.google.com/p/tama-ieeye/source/browse/TamaScreenLock/main.cpp</a>

</A>

<br>
<br>
<br>
<A href="http://code.google.com/p/tama-ieeye/source/browse/TamaScreenLock/mainReduse.cpp"><br>
<br>
<a href='http://code.google.com/p/tama-ieeye/source/browse/TamaScreenLock/mainReduse.cpp'>http://code.google.com/p/tama-ieeye/source/browse/TamaScreenLock/mainReduse.cpp</a>

</A>

<br>
<br>
<h1>解説</h1>
バイナリファイルやCFF Explorerで見てみると、0パディングが多いこと、無駄なセクションがあることに気づくでしょう。これを無くしていきます。<br>
<br>
"/merge:.rdata=.text" - .rdataセクションと.textセクションを結合します。<br>

"/DYNAMICBASE:NO", "/FIXED", "/NXCOMPAT:NO", "/ALIGN:16",<br>
"/INCREMENTAL:NO" - .relocセクション（再配置情報）が無駄です。また/ALIGN:16を有効にするために必要です。<br>
<br>
あと漏れていますが、DEPや例外などはすべてオフにします。デバッグ情報(.pdb)の生成もオフにします。<br>
<br>
そうすることによって<br>
<br>
<A href="http://tama-ieeye.googlecode.com/git/TamaScreenLock/TamaScreenLockReduseWithoutRes.exe"><br>
<br>
608バイトで（少なくともWindows8で）正常に動作するバイナリ<br>
<br>
</A><br>
<br>
が得られます。<br>
<br>
<h1>おまけ　～リソースを圧縮しろ！～</h1>
.exeを縮める際に問題になるのがリソース。特にアイコン。DIBは大きいです。<br>
<br>
Vistaからはicoファイル内でpng圧縮が使えるようになりました。VC2010から対応しています。(VC2008以前ではLNK1221エラーでコンパイルできません)。<br>
Gimpの最新版からicoファイルをエクスポートすることによってpng圧縮することが可能です。<br>
これによってicoファイルのサイズがぐっと縮みます。<br>
<br>
余談ですがVista以降の大きめのアイコンを表示させるにはVC2010以降でコンパイル＆リンクする必要があります。もし.rcをVC2010でコンパイルして.objにしてVC2005などでリンクしようとしても、生成された.exeのアイコンは荒い小さなものになります。<br>
<br>
<h1>最後に</h1>
いかがだったでしょうか？<br>
関連ファイルは<br>
<br>
<A href="http://code.google.com/p/tama-ieeye/source/browse/TamaScreenLock"><br>
<br>
<a href='http://code.google.com/p/tama-ieeye/source/browse/TamaScreenLock'>http://code.google.com/p/tama-ieeye/source/browse/TamaScreenLock</a>

</A>

にあります<br>
もしもっと縮めることができたら下のコメントボックスからお知らせください。devil.tamachanが褒めてくれます。