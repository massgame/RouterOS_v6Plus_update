:global currentPrefix;

#この部分は各ルータの状況によって対応
:global bridgeName "bridge-ngn"; #Bridgeの名前
:global ipipv6TunnelName "ipipv6-v6plus"; #v6トンネルの名前
#ここまで

:local source [/ipv6/address get [:pick [find dynamic global interface=$bridgeName] 0 ] address]; #SLAACで流れて来るv6 IPの取得
:local ip [:toip6 [:pick $source 0 [:find $source "/"]]]; #/64の削除
:local maskPrefix ffff:ffff:ffff:ffff::; #Prefixだけ

:local newPrefix ($ip & $maskPrefix)

:if ($currentPrefix != $newPrefix) do={
    :log info ("New Prefix : $newPrefix (old : $currentPrefix)");
    /system script run updateMAPEConfig
    :set $currentPrefix $newPrefix;
    } else={
    :log info ("No Change on Prefix : $currentPrefix");
    }
