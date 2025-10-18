# WSL2 セットアップガイド

Windows上でLinux環境を構築するWSL2 (Windows Subsystem for Linux) のインストールと初期設定の手順。

## 1. WSLの有効化

まず、Windows Terminalを**管理者として開き**、PowerShellで以下のコマンドを実行してWSLと仮想マシンプラットフォームを有効化する。

```powershell
wsl --install
```

このコマンドは、必要な機能を有効化し、デフォルトのLinuxディストリビューション（通常はUbuntu）をインストールする。実行後、PCの**再起動**が必要。

---

## 2. Linuxディストリビューションのインストール (任意)

デフォルトのUbuntu以外をインストールしたい場合、利用可能なOSのリストを確認してインストールする。

### 2-1. 利用可能なOSのリストを表示

```powershell
wsl --list --online
```

### 2-2. 任意のOSをインストール

リストから好みのOSを選び、`<Distribution-Name>` を置き換えてインストールする。

```powershell
# 例: Oracle Linux 8.7をインストールする場合
wsl --install -d OracleLinux_8_7
```

インストール後、新しいLinux環境用の**ユーザー名**と**パスワード**を設定するよう求められる。これらはWindowsの認証情報とは別のものであるため、忘れないように設定する。

---

## 3. (任意) rootユーザーのパスワード設定

セキュリティ上の理由から通常は不要だが、rootユーザーにパスワードを設定する場合は、該当のディストリビューションにrootとしてログインして設定する。

```powershell
# <Distribution-Name>は自分がインストールしたOS名に置き換える
wsl -d <Distribution-Name> -u root
```

Linux環境に入ったら、`passwd`コマンドでパスワードを設定する。

```bash
# 新しいパスワードを2回入力する
passwd
exit
```

---

## 4. WSLのバージョン確認

インストールしたLinuxディストリビューションがWSL2で動作しているか確認する。

```powershell
wsl --list --verbose
# または省略形の wsl -l -v
```

`VERSION`列が `2` になっていればセットアップは完了。✅

もしバージョンが `1` の場合は、以下のコマンドで `2` に変換できる。

```powershell
# <Distribution-Name>をバージョン2に変換
wsl --set-version <Distribution-Name> 2
```