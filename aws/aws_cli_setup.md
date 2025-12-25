# AWS CLI v2 セットアップガイド (Linux)

WSL2などのLinux環境にAWS CLI バージョン2をインストールし設定する手順をまとめたもの。

## 1. インストール

インストーラーをダウンロードし、展開・インストールを実行する。

```bash
# ホームディレクトリへ移動
cd ~

# インストーラーをダウンロード
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# unzipをインストール
sudo apt update
sudo apt install -y unzip

# zipファイルを展開し、インストールを実行
unzip awscliv2.zip
sudo ~/aws/install
```

---

## 2. 動作確認と掃除

インストールが成功したかバージョンを確認し、不要になったファイルを削除する。

```bash
# バージョンを確認
aws --version

# 不要なファイルを削除
rm -f awscliv2.zip
rm -rf ~/aws
```

---

## 3. 認証情報の設定

AWSの認証情報を設定する

> **⚠️ 事前準備**  
> 事前に、AWSマネジメントコンソールでIAMユーザーを作成し、  
> 発行された**アクセスキーID**と**シークレットアクセスキー**を手元に用意する。

以下のコマンドを実行する。`< >` の内部は、自身が設定する値を入力する。

```bash
# IAMユーザ名入力する
aws configure --profile <profile-name>

# アクセスキーを入力する
AWS Access Key ID [None]: <access-key>
AWS Secret Access Key [None]: <secret-access-key>

# 東京リージョン(ap-northeast-1)を入力する
Default region name [None]: ap-northeast-1

# テキストフォーマット、jsonを入力する
Default output format [None]: json

# 作成した名前があるか確認する
aws configure list-profiles

# 設定ファイルは ~/.aws/credentialsに保存される
```
