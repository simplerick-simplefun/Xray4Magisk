Example configuration for sing-box:
Explained:

```
{
```
> set log level to trace for debug purpose.
> if user need to debug or report a bug, set `"disabled": false`, restart the proxy service, run into the bug again, to log the bug.
```
  "log": {
    "disabled": true,
    "level": "trace",
    "output": "/data/adb/xray/run/sing-box.log",
    "timestamp": true
  },
```
> Assuming the user have 1 highly stable and fast(ping) proxy, and 3 slower proxies for more internet data 
> We let the apps that require fast and reliable connection, but not comsuming a lot of data, to use the fast proxy. For example: voice and video calling apps like telegram, GCM/FCM, email, and so on.
> And we let the apps that only need a good bandwidth and a lot of internet traffic, to use the normal/data proxies. For example: youtube, browser, webview.
```
  "dns": {
```
> Secure DNS is recommended; dns over tls (DOT) is generally faster than dns over https (DOH); using ip address is a bit faster than domain
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
> We let the apps that require fast and reliable connection, but not comsuming a lot of data, to use the fast proxy
> Note for these apps, we DO NOT dns/route their traffic based on traffic destination; we always proxy all of their traffic because that's what they need.
> These are: Discord, Telegram, Google GMS/FCM and Google contact sync
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
> And we let the apps that only need a good bandwidth and a lot of internet traffic, to use the normal/data proxies.
> These are: Android system webview, System document ui (for cloud drive function), shell (for remote install of pkg's, ping's and so on), Chrome (Browsers that you want to be proxied)
> Note for these apps, we DO dns/route their traffic based on traffic destination. As that's what they should do.
> We do this by specifying that when traffic from these apps goes to CN, we send the traffic to Direct DNS and Routing. And all rest of the traffic goes to proxy.
> Therefore we should add all of the apps which should have their traffic splitted here.
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
> And all the rest of the apps, and traffic of apps not yet splitted to Direct, goes to Proxy
```
    "final": "dns-data-proxy",
    "disable_cache": false,
    "disable_expire": false
  },
```
> Same mechanism as in DNS module
> Using loyalsoldier's geo files
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
> set true for Tun to work. If tun fails, try to set interface manually.
```
    "auto_detect_interface": true,
```
> set to have tun work with system vpn
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
> Proxy Whitelist mode
> Put the uid's of apps getting proxied here.
>  User can copy and paste from "/data/adb/xray/appid.list", make sure to add the comma"," in between each id.
> "/data/adb/xray/appid.list" can be generated by using the APP https://github.com/whalechoi/Xray4Magisk_Manager
```
      "include_uid": [
        10111,
        10222,
        10333,
        10444
      ],
```
> make sure set sniff and override to true. Helps splitting traffic, and makes sure dns setting applies everytime. 
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
> must have dns server for dns module to work. 
```
    {
      "type": "dns",
      "tag": "out-dns"
    },
```
> Proxy for heave internet traffic: A selector for easy switching between proxies. 
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
> Proxy for fast(ping) and reliable(less packet loss) internet traffic. 
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