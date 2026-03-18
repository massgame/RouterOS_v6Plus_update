# RouterOS_v6Plus_update
Update MAP-E (v6Plus) Configuration for RouterOS
Mikrotik RouterOS環境でのv6プラス設定自動更新スクリプト

フレッツNGN+v6プラス環境にて、v6 Prefixの変更がある場合検知してMAP-E関係設定を自動でアップデートするRouterOS Scriptです。

前提条件
- フレッツNGN+v6プラス（MAP-E)
- ひかり電話なし
- 固定IPなし
- Prefix変更によって設定が変わる各所にコメントが正しく設定されている。
  : IPv6 default routeは "NGN" / IPv6 Firewall allowed addressの場合 "ngnAllowedV6" / NATポートリストは MAPE_(TCP/UDP_n(1~15)


使用方法
- update_MAPE_config.rscをupdateMAPEConfigという名前に指定
- v6_Prefix_Change.rscを適当にスケジュール設定

例
  /system scheduler
add interval=1w name=detectPrefixChange on-event="/system script run checkPrefixChange" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=2026-03-18 start-time=06:00:00


AIが流行ってるこの時代手で作成したのでコードは汚いです
動作確認はしましたが責任は取りません

# Special Thanks to
    * http://ipv4.web.fc2.com/map-e.html
    * RouterOSでフレッツのv6プラス(MAP-E)を利用する　https://qiita.com/mooglejp/items/e15335842cbd12f4cd0b
    * RouterOSv7でv6プラスでの接続が確立できない https://forum.rb-ug.jp/t/topic/127
    * RouterOSv7においてv6プラス固定IP接続ができない https://forum.rb-ug.jp/t/topic/205
    * [ROUTEROS] 日本のISPにおける一般的なIPV4/IPV6 DUAL STACK構築方法 https://blog.gaftnochec.net/infrastructure/routeros-ipv4-ipv6-dual-stack/
    * NTT東が6月に提供を開始したSFPタイプのONU https://mum.mikrotik.com/presentations/JP15/presentation_2968_1444887529.pdf
