# Terraform セットアップガイド (tfenv使用)

Terraformのバージョン管理ツール `tfenv` を使ってTerraformをインストールする手順。

## 1. tfenvのインストール

`tfenv` 本体をGitHubからクローンして配置する。

```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
```

---

## 2. PATHの設定

`tfenv` のコマンドを使えるようにするため、`~/.bashrc` (または `~/.zshrc` など) にPATHを追加する。

```bash
# ~/.bashrcの末尾にPATH設定を追記
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc

# 設定を現在のシェルに即時反映させる
source ~/.bashrc
```

---

## 3. Terraformのインストール

`tfenv` を使ってTerraformをインストールする。

### 3-1. インストール可能なバージョンを確認 (任意)

```bash
tfenv list-remote
```

### 3-2. 最新版をインストール

特に指定がなければ、最新（latest）でも良いが、Betaなどのテストバージョンは避ける

```bash
tfenv install latest
```

特定のバージョンをインストールしたい場合は、`tfenv install 1.8.5` のように指定する。

---

## 4. 使用バージョンの指定

インストールしたバージョンの中から、この環境で使用するバージョンを指定する。

```bash
tfenv use latest
```

---

### 

## 6. 動作確認

`terraform` コマンドが正しく実行できるか、バージョンを確認する。

```bash
terraform version
```

指定したバージョンが表示されれば、セットアップ完了。
