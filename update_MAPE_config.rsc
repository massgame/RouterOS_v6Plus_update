:global updateNatRules do={
  # Args: $PSID $v4Addr
  :for i from=1 to=15 do={
    :local portStart ((i << 12) | ([:tonum $PSID] << 4))
    :local portEnd   ($portStart + 15)
    :local portRange "$portStart-$portEnd"
    :log info ("Current v4 Port range ".$"i"." : ". $"portRange")
    /ip firewall nat set [find comment=("MAPE_TCP_".$i) protocol="tcp" ] to-address=$v4Addr to-ports=$portRange
    /ip firewall nat set [find comment=("MAPE_UDP_".$i) protocol="udp" ] to-address=$v4Addr to-ports=$portRange
  }
}

:global currentPrefix
:global ipipv6TunnelName 

:local maskIpv4upperdecide ffff:ffff::; #IPv4アドレスの前２Octetを決める部分。
:local maskIpv4octet3 0:0:ff00::; #IPv4アドレスの３番目Octetを決める部分。
:local maskIpv4octet4 0:0:00ff::; #IPv4アドレスの４番目Octetを決める部分。
:local maskPsid 0:0:0:ff00::; #PSID

# マスクで該当値を求める

:local ipv4Upperdecide ($currentPrefix & $maskIpv4upperdecide)
:put $ipv4Upperdecide
:local ipv4Octet3 ($currentPrefix & $maskIpv4octet3)
:local ipv4Octet4 ($currentPrefix & $maskIpv4octet4)


# いらない部分の削除

:set ipv4Octet3 [:pick $ipv4Octet3 4 [:find $ipv4Octet3 "00::"]]
:set ipv4Octet4 [:pick $ipv4Octet4 4 [:find $ipv4Octet4 "::"]]

#PSID計算

:local ipv4Psid ($currentPrefix & $maskPsid)
:set ipv4Psid [:pick $ipv4Psid 6 [:find $ipv4Psid "00::"]]


:local ipv4Upper
:local CEIP
:local CEIPPart1
:local CEIPPart2

# IPv4アドレスの前２Octet取得。

if ([:tostr $ipv4Upperdecide] = "240b:10::" ) do={
    :set ipv4Upper "106.72"
    :set CEIPPart1 "6a"
    :set CEIPPart2 "48"
} else={
        if ([:tostr $ipv4Upperdecide] = "240b:12::" ) do={
    :set ipv4Upper "14.8"
    :set CEIPPart1 "e"
    :set CEIPPart2 "8"
    } else={    
        if ([:tostr $ipv4Upperdecide] = "240b:250::" ) do={
    :set ipv4Upper "14.10"
    :set CEIPPart1 "e"
    :set CEIPPart2 "a"
    } else={        
        if ([:tostr $ipv4Upperdecide] = "240b:252::" ) do={
    :set ipv4Upper "14.12"
    :set CEIPPart1 "e"
    :set CEIPPart2 "c"
    } else={
        if ([:tostr $ipv4Upperdecide] = "2404:7a80::" ) do={
    :set ipv4Upper "133.200"
    :set CEIPPart1 "85"
    :set CEIPPart2 "c8"
    } else={
        if ([:tostr $ipv4Upperdecide] = "2404:7a84::" ) do={
    :set ipv4Upper "133.206"
    :set CEIPPart1 "85"
    :set CEIPPart2 "ce"
    } else={
        :error "Not supporting Prefix"; #エラー検知
                    }
                }
            }
        }
    }
}


#IPv4計算
:local ipv4Final ($ipv4Upper.".".[:tonum ("0x".$ipv4Octet3);].".".[:tonum ("0x".$ipv4Octet4);]);

#CEIP計算
:local ipv6CEIP 
:set ipv6CEIP [:pick $currentPrefix 0 [:find $currentPrefix "::"]]
:set ipv6CEIP ($ipv6CEIP.":".$CEIPPart1.":".$CEIPPart2.$ipv4Octet3.":".$ipv4Octet4."00:".$ipv4Psid."00");


:log info ("Current v4 IP ".$ipv4Final)
:log info ("Current v6 CE Address ".$ipv6CEIP)

#IPv6トンネルのアドレス更新(CEIP, IPv4 Addr)
/ip address set [find interface=$ipipv6TunnelName] address=$ipv4Final network=$ipv4Final
/interface ipipv6 set [find name=$ipipv6TunnelName] local-address=$ipv6CEIP

#IPv6ゲートウェイ設定(Prefix + fffe)
:local ipv6Gateway ($currentPrefix."fffe")
/ipv6 route set [find comment="NGN"] gateway=$ipv6Gateway

#Allowed V6 Address設定
:local ngnAllowed ($currentPrefix."/64")
/ipv6 firewall address-list set [find comment="ngnAllowedV6"] address=$ngnAllowed         

#PSID計算
:local ipv4PsidOct [:tonum ("0x".$ipv4Psid);]

#NATRuleのアップデート
$updateNatRules PSID=$ipv4PsidOct v4Addr=$ipv4Final

