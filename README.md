# The Journey of Reverse Engineering

本レポジトリはrand_r(&v3)の記事  **The Journey of Reverse Engineering** でユキが使ったプログラムを実際に動かすことができる環境構築用のレポジトリです

誰でも簡単に、同一の環境を用意できるようにしています

## 要件 

本チュートリアルの実行には以下のファイル・デバイスが必要です

- Jailbreak可能なiPhone/iPad
    - [iOS/iPadOS 15](https://theapplewiki.com/wiki/Jailbreak/15.x)
    - [iOS/iPadOS 16](https://theapplewiki.com/wiki/Jailbreak/16.x)
    - [iOS/iPadOS 17](https://theapplewiki.com/wiki/Jailbreak/17.x)
    - [iOS/iPadOS 18](https://theapplewiki.com/wiki/Jailbreak/18.x)
- VSCode
    - 本レポジトリを実行するために必要です
- [Frida iOS Playground](https://github.com/NVISOsecurity/frida-ios-playground)
    - 今回の解析対象のアプリケーションです
- [Sideloadly](https://sideloadly.io/)
    - 未署名のIPAをインストールするソフトウェアです

> 脱獄可能なバージョン及びツールは上記のWikiから調べてください

## 事前準備

本レポジトリをVScodeで開きます

Dev Containerで立ち上げるかどうか訊かれますので、OKを押してください

無事にDev Container環境で立ち上がったら`direnv allow`を入力してエンターを押します

### 環境変数

```zsh
$ cp .env.example .env
```

環境変数用のファイルをコピーして、`FRIDA_HOST=192.168.XXX.YYY`に解析対象のデバイスのローカルIPアドレスを記入して保存します

### iDevice

次に脱獄したiPhone/iPadでのFrida実行環境を整えましょう

Fridaはデフォルトのレポジトリでは配布されていないので`https://build.frida.re/`をレポジトリとして追加します

URLスキーマが利用できる場合、以下のリンクをクリックすれば入力不要で自動でレポジトリが追加できます

- [Cydia](cydia://url/https://cydia.saurik.com/api/share#?source=https://build.frida.re/)
- [Sileo](sileo://source/https://build.frida.re/)
- [Zebra](zbra://sources/add/https://build.frida.re/)
- [Installer](installer://add/repo=https://build.frida.re/)

インストールが必要なものは以下のとおりです

- openssh-server
- NewTerm 3 Beta
- gettext-localizations

### ルートパスワード変更

NewTerm 3 Betaを起動して、

```zsh
sudo passwd root
```

と入力します。エンターキーを押すと新しいパスワードを設定できます。

### Frida Server

パスワードが変更できたらSSHで繋げられるので、

```zsh
$ ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no -o StrictHostKeyChecking=no root@192.168.XXX.YYY`
```

でパスワードを入力してログインします

> XXX.YYYのところは各自のiDeviceのローカルアドレスにしてください

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

上記のディレクトリに`re.frida.server.plist`があるのでこのファイルを編集します


```zsh
iPad-1584:~ root# sudo su
iPad-1584:~ root# vi /var/jb/Library/LaunchDaemons/re.frida.server.plist 
```

`sudo su`でアカウントを`root`に切り替えてからファイルを編集します

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

二行追加して、ファイルを保存します

```zsh
iPad-1584:~ root# launchctl unload /var/jb/Library/LaunchDaemons/re.frida.server.plist
iPad-1584:~ root# launchctl load /var/jb/Library/LaunchDaemons/re.frida.server.plist
iPad-1584:~ root# ps aux | grep frida 
root              2396   0.0  0.1 407923664   1872 s001  S+   12:27AM   0:00.05 vi /var/jb/Library/LaunchDaemons/re.frida.server.plist
root              2474   0.0  0.1 407926784   1296 s003  R+   12:33AM   0:00.06 grep frida
root              2458   0.0  0.2 407931920   4496   ??  Ss   12:32AM   0:00.10 /var/jb/usr/sbin/frida-server -l 0.0.0.0
```

保存したら設定ファイルをリロードしてから、プロセスを確認して`-l 0.0.0.0`のオプション付きで立ち上がっていることを確認します

ここまでできたら端末側の設定は完了です

## Frida Playground

解析の対象となるアプリケーションをインストールします

- [Frida iOS Playground](https://github.com/NVISOsecurity/frida-ios-playground)

Sideloadlyでインストールしたら、完了です

> Sideloadlyのインストール方法は調べたらたくさん出てくるので各自調べてください

## チュートリアル

ここから、本レポジトリでコードを実行していきます

### Frida PS

```zsh
$ frida --version
17.5.1
$ frida-ps -a                   
 PID  Name        Identifier              
----  ----------  ------------------------
2329  Playground  eu.nviso.fridaplayground
```

FridaのバージョンとインストールしているアプリのBundle Identifierが確認できます

### Frida Trace

メソッド名を指定して、フックするためのJavaScriptを自動生成、ロードします

```zsh
$ frida-trace -f eu.nviso.fridaplayground -m "-[VulnerableVault setSecretInt:]"
```

スクリプトファイルを編集すると自動で再読込してくれるので大変便利です

### 本記事の内容へ


## エラーが発生したときは

### `zsh: command not found: frida-pa`

Pythonの仮想環境が有効になっていません

`source /home/vscode/app/.venv/bin/activate`を実行するか`direnv allow`をしてから新しくタブを開いて、再度`frida-ps`を実行してみてください

### `Failed to enumerate applications: unable to connect to remote frida-server`

デバイスのIPアドレスが間違っています

`.env`が存在するか、`FRIDA_HOST`の値が間違っていないか確認してください