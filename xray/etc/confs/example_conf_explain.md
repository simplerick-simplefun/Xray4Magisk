Example configuration for sing-box:
Explained:

```
{
```
> Set log level to “trace” for debug purpose.

> 为便于调试设置log level 为 “trace”

> If user need to debug or report a bug, set `"disabled": false`, restart the proxy service, run into the bug again, to log the bug.

> 如果用户需要调试或反馈bug，设置`"disabled": false`，重启代理服务，再次触发bug，来记录。
```
  "log": {
    "disabled": true,
    "level": "trace",
    "output": "/data/adb/xray/run/sing-box.log",
    "timestamp": true
  },
```
> Assuming the user have 1 highly stable and fast(low ping&stable) proxy, and 3 slower proxies for more internet data.

> 假设用户有1个快速的代理节点（ping低且稳定），3个较慢但流量多的代理节点。

> We let the apps that require fast and reliable connection(low ping&stable), but not comsuming a lot of data, to use the fast proxy. For example: voice and video calling apps like telegram, GCM/FCM, email, and so on.

> 我们让需要快速稳定的网络连接(ping低且稳定)、不需要过多流量的应用使用快速节点。例如：语音视频聊天应用如telegram，GCM/FCM推送服务，电子邮件，等。

> And we let the apps that need a good bandwidth and use a lot of internet traffic, to use the normal/data proxies. For example: youtube, browser, webview.

> 我们让需要高流量速率并使用较多流量的应用，使用普通/（大）流量的代理节点。如：油管，浏览器，webview。

```
  "dns": {
```
> Secure DNS is recommended; dns over tls (DOT) is generally faster than dns over https (DOH); using ip address is a bit faster than domain

> 推荐使用安全DNS。DOT较DOH更快，使用ip相比域名连接更快。
```
    "servers": [
      {
        "tag": "dns-data-proxy",
        "address": "tls://8.8.8.8",
        "strategy": "prefer_ipv4",
        "detour": "out-data-proxy"
      },
      {
        "tag": "dns-fast-proxy",
        "address": "tls://8.8.4.4",
        "strategy": "ipv4_only",
        "detour": "out-fast-proxy"
      },
      {
        "tag": "dns-direct",
        "address": "tls://223.5.5.5",
        "strategy": "prefer_ipv4",
        "detour": "out-direct"
      },
      {
        "tag": "dns-block",
        "address": "rcode://name_error"
      }
    ],
    "rules": [
      {
        "geosite": [
          "category-ads-all"
        ],
        "server": "dns-block"
      },
      {
        "geosite": [
          "private"
        ],
        "server": "dns-direct"
      },
```
> We let the apps that require fast and reliable connection(low ping&stable), but not comsuming a lot of data, to use the fast proxy.

> 让需要快速稳定的网络连接(ping低且稳定)、不需要过多流量的应用使用快速节点。

> Note for these apps, we *DO NOT* dns/route their traffic based on traffic destination--We always proxy all of their traffic, since they donot have cn/local traffic. 

> 注意对于这些应用，我们 *不* 对它们的DNS和流量进行分流--我们总是代理它们的流量，因为它们没有中国/本地网络流量。

>*local* means in the local country where internet is restricted. *本地*指在限制网络的本国内。

> These are: Discord, Telegram, Google GMS/FCM and Google contact sync

> 这里有：Discord, Telegram, Google GMS/FCM 和 Google 联系人同步

> Find package names of apps using https://github.com/whalechoi/Xray4Magisk_Manager

> 使用 https://github.com/whalechoi/Xray4Magisk_Manager 查找应用的package_name
```
      {
        "package_name": [
          "com.discord",
          "org.telegram.messenger",
          "com.google.android.gms",
          "com.google.android.syncadapters.contact"
        ],
        "server": "dns-fast-proxy"
      },
```
> And we let the apps that need a good bandwidth and use a lot of internet traffic, to use the normal/data proxies.

> 我们让需要较大速率、使用较多流量的应用，使用正常/大流量代理节点。

> Note for these apps, we *DO* dns/route their traffic based on traffic destination, since they have cn/local traffic.

> 注意对于这些应用，我们 *会* 对它们的DNS和流量进行分流，因为它们有中国/本地流量。

> We do this by specifying that when traffic from these apps goes to CN/local, we send the traffic to Direct access in DNS module and Routing module.(Whitelisting) And all rest of the traffic goes to proxy in "final".

> 我们设置让这些应用去往中国/本地的流量在DNS和路由模块直连，来分流。（白名单）这些应用的其他流量在"final"走代理。

>*local* means in the local country where internet is restricted. *本地*指在限制网络的本国内。

> These are: Android system webview, System document ui (for cloud drive function), shell (for remote install of pkg's, ping's and so on), Chrome (Browsers that you want to be proxied)

> 这里有：安卓系统webview，系统文件UI（云盘功能），shell，Chrome（要被代理的浏览器）

```
      {
        "package_name": [
          "com.google.android.webview",
          "com.google.android.documentsui",
          "com.android.shell",
          "com.android.chrome"
        ],
        "geosite": [
          "cn",
          "microsoft@cn",
          "apple-cn",
          "category-games@cn"
        ],
        "server": "dns-direct"
      }
    ],
```
> And all the rest of the apps, and traffic of apps not yet splitted to Direct, goes to Proxy(normal/data proxies)

> 剩下的其他应用，和上面应用没有被分流到直连的流量，走代理（正常/大流量代理节点）
```
    "final": "dns-data-proxy",
    "disable_cache": false,
    "disable_expire": false
  },
```
> Same mechanism as in DNS module

> 与DNS模块相同的机理

> Using loyalsoldier's geo files

>使用了loyalsoldier的geo文件
```
  "route": {
    "geoip": {
      "download_url": "https://github.com/icepony/sing-geoip/releases/latest/download/geoip-cn.db",
      "download_detour": "out-data-proxy"
    },
    "geosite": {
      "download_url": "https://github.com/icepony/sing-geosite/releases/latest/download/geosite.db",
      "download_detour": "out-data-proxy"
    },
    "rules": [
      {
        "protocol": "dns",
        "outbound": "out-dns"
      },
      {
        "geosite": [
          "category-ads-all"
        ],
        "outbound": "out-blackhole"
      },
      {
        "geosite": [
          "private"
        ],
        "geoip": [
          "private"
        ],
        "domain_keyword": "ntp",
        "outbound": "out-direct"
      },
      {
        "package_name": [
          "com.google.android.webview",
          "com.google.android.documentsui",
          "com.android.shell",
          "com.android.chrome"
        ],
        "geoip": [
          "cn"
        ],
        "geosite": [
          "cn",
          "microsoft@cn",
          "apple@cn",
          "category-games@cn"
        ],
        "outbound": "out-direct"
      },
      {
        "package_name": [
          "com.discord",
          "org.telegram.messenger",
          "com.google.android.gms",
          "com.google.android.syncadapters.contact"
        ],
        "outbound": "out-fast-proxy"
      }
    ],
    "final": "out-data-proxy",
```
> If tun fails, try to set interface manually.

> 如果tun模式失败，尝试手动设置interface。
```
    "auto_detect_interface": true,
```
> set to have tun work with system vpn

> 使tun与系统vpn共同工作。
```
    "override_android_vpn": true
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "in-tun",
      "inet4_address": "172.19.0.1/30",
      "inet6_address": "fdfe:dcba:9876::1/126",
      "auto_route": true,
      "strict_route": true,
      "stack": "gvisor",
```
> Proxy Whitelist mode.

> 代理白名单模式。

> Put the uid's of apps getting proxied here.

> 将被代理应用的uid放在这里

> User can copy and paste from "/data/adb/xray/appid.list", make sure to add the comma"," in between each uid.

> 用户可以直接从"/data/adb/xray/appid.list"里面复制粘贴，注意每个uid之间要有逗号","

> "/data/adb/xray/appid.list" can be generated by using the APP https://github.com/whalechoi/Xray4Magisk_Manager

> "/data/adb/xray/appid.list"可通过 https://github.com/whalechoi/Xray4Magisk_Manager 生成
```
      "include_uid": [
        10111,
        10222,
        10333,
        10444
      ],
```
> make sure set sniff and override to true. Helps splitting traffic, and makes sure dns setting applies everytime. 

> 确保sniff和override设置为true。帮助分流，确保dns设置实现。
```
      "sniff": true,
      "sniff_override_destination": true
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "out-direct"
    },
    {
      "type": "block",
      "tag": "out-blackhole"
    },
```
> must have dns outbound for dns module to work. 

> dns模块工作需要dns出站。
```
    {
      "type": "dns",
      "tag": "out-dns"
    },
```
> Proxy for heave internet traffic: A selector for easy switching between proxies. 

> 用于大流量/速率网络流量的代理节点：这是一个能轻松选择/更换代理节点的选择器。
```
    {
      "tag": "out-data-proxy",
      "type": "selector",
      "outbounds": [
        "out-data_proxy_1",
        "out-data_proxy_2",
        "out-data_proxy_3"
      ],
      "default": "out-data_proxy_1"
    },
```
> Proxy for fast and reliable internet traffic. 

> 用于高速稳定网络流量的代理节点
```
    {
      "tag": "out-fast-proxy",
      "type": "vmess",
      "server": "i.p.i.p",
      "server_port": 12345,
      "uuid": "67a1182e-5941-4264-8617-4e5586d86b91",
      "domain_strategy": "ipv4_only"
    },
```
> Proxies for heave internet traffic, easily switched in the selector. 

> 用于大流量/速率网络流量的代理节点，在选择器中可以方便的选择/更换。
```
    {
      "tag": "out-data_proxy_1",
      "type": "trojan",
      "server": "i.p.i.p",
      "server_port": 443,
      "password": "password1",
      "tls": {
        "enabled": true,
        "disable_sni": false,
        "server_name": "123.example.com",
        "insecure": false
      },
      "domain_strategy": "ipv4_only"
    },
    {
      "tag": "out-data_proxy_2",
      "type": "trojan",
      "server": "i:p:i:p:i:p:i:p",
      "server_port": 443,
      "password": "password2",
      "tls": {
        "enabled": true,
        "disable_sni": false,
        "server_name": "456.example.com",
        "insecure": false
      },
      "domain_strategy": "prefer_ipv6"
    },
    {
      "tag": "out-data_proxy_1",
      "type": "shadowsocks",
      "server": "i.p.i.p",
      "server_port": 56789,
      "method": "2022-blake3-chacha20-poly1305",
      "password": "password",
      "domain_strategy": "ipv4_only"
    }
  ]
}
```