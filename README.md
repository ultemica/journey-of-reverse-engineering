# Frida

## Frida Server

```zsh
var/
└── jb/
    ├── Library/
    │   └── LaunchDaemons/
    │       └── re.frida.server.plist
    └── usr/
        └── lib/
            ├── frida/
            │   └── frida-agent.dylib
            └── sbin/
                └── frida-serer
```

`ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no -o StrictHostKeyChecking=no root@192.168.XXX.YYY`

```zsh
iPad-1584:~ root# sudo su
iPad-1584:~ root# vi /var/jb/Library/LaunchDaemons/re.frida.server.plist 
```

```diff
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>Label</key>
 <string>re.frida.server</string>
 <key>Program</key>
 <string>/var/jb/usr/sbin/frida-server</string>

<key>ProgramArguments</key>
<array>
 <string>/var/jb/usr/sbin/frida-server</string>
+ <string>-l</string>
+ <string>0.0.0.0</string>
</array>

 <key>UserName</key>
 <string>root</string>
 <key>POSIXSpawnType</key>
 <string>Interactive</string>
 <key>RunAtLoad</key>
 <true/>
 <key>KeepAlive</key>
 <true/>
 <key>ThrottleInterval</key>
 <integer>5</integer>
 <key>ExecuteAllowed</key>
 <true/>
</dict>
</plist>
```

```zsh
iPad-1584:~ root# launchctl unload /var/jb/Library/LaunchDaemons/re.frida.server.plist
iPad-1584:~ root# launchctl load /var/jb/Library/LaunchDaemons/re.frida.server.plist
iPad-1584:~ root# ps aux | grep frida 
root              2396   0.0  0.1 407923664   1872 s001  S+   12:27AM   0:00.05 vi /var/jb/Library/LaunchDaemons/re.frida.server.plist
root              2474   0.0  0.1 407926784   1296 s003  R+   12:33AM   0:00.06 grep frida
root              2458   0.0  0.2 407931920   4496   ??  Ss   12:32AM   0:00.10 /var/jb/usr/sbin/frida-server -l 0.0.0.0
```

## Frida PS

```zsh
$ frida --version
17.5.1
$ frida-ps -a                   
 PID  Name        Identifier              
----  ----------  ------------------------
2329  Playground  eu.nviso.fridaplayground
```