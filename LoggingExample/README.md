# LoggingExample

swift-log をいろいろ試す

---

Swift の Logging ライブラリー
---

* SwiftyBeaver/SwiftyBeaver
* IBM-Swift/LoggerAPI
* IBM-Swift/HeliumLogger
* emaloney/CleanroomLogger
* Nike/Willow

一般的に Logging ライブラリーに求められる
---

* 日付時刻が出力される
* 発生箇所を特定できる
  * ファイル
  * 行番号
  * クラス(struct/enum)名
  * 関数名
  * コンテキスト(サーバー:リクエスト内容/クライアント:ユーザー入力・操作)
* 一部のログ出力を制御
  * 開発中は多くのログが出る
  * リリースされたアプリでは必要なもののみ
* ログ出力先を設定できる
* ログ実装に変更があってもすぐに切り替えられる
  * 例えば特定のログ出力ライブラリー
* 複数のスレッドから(メッセージを破壊することなく)安全に出力できる
* 遅くない/ブロックしない
  * すぐにユーザーアプリケーションにコントロールが戻る
  * 外部サービスへの送信がアプリケーションを止めない

参考資料 [Java のログ出力と考え方](https://www.slideshare.net/miyakawataku/concepts-and-tools-of-logging-in-java)

