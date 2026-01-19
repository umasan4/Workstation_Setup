# Git & GitHub セットアップガイド (SSH接続)

Gitをインストールし、GitHubとSSH接続するためのセットアップ手順。

## 1. Gitのインストール

自身の環境にGitをインストールする。

```bash
# Gitインストール
sudo apt update
sudo apt install -y git

# バージョンを確認
git --version
```

---

## 2. Gitの初期設定 (ユーザー情報)

コミット時に記録する名前とメールアドレスを設定する。  
GitHubアカウントと一致させること。

```bash
# 登録
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 確認
git config user.name
git config user.email
```

---

## 3. SSHキーの作成

GitHubとの通信に使用するSSHキーペア（秘密鍵・公開鍵）を作成する。

```bash
# <your-email> はGitHub登録メールアドレスに置き換える
ssh-keygen -t ed25519 -C "your.email@example.com"
```

実行後、パスフレーズなどを質問されるが、すべて**Enterキー**を押してデフォルトで進める。

---

## 4. SSHキーのパーミッション設定

セキュリティのため、生成されたSSHキーの権限を適切に設定する。

```bash
# ディレクトリの権限
chmod 700 ~/.ssh

# 秘密鍵の権限
chmod 600 ~/.ssh/id_ed25519
```

---

## 5. GitHubへの公開鍵の登録

ローカルで作成した**公開鍵** (`id_ed25519.pub`) をコピーし、GitHubに登録する。

### 5-1. 公開鍵をクリップボードにコピー

```bash
# WSLの場合、Windowsのクリップボードにコピー可能
cat ~/.ssh/id_ed25519.pub | clip.exe

# 上記が使えない場合は、表示して手動でコピー
# cat ~/.ssh/id_ed25519.pub
```

### 5-2. GitHubに登録

1.  GitHubにログインし、**[Settings]** > **[SSH and GPG keys]** に移動。
2.  **[New SSH key]** をクリック。
3.  以下の内容で登録する。
    * **Title**: どのPCの鍵か分かる名前 (例: `My-WSL-PC`)
    * **Key**: コピーした公開鍵の文字列 (`ssh-ed25519...`) を貼り付け。
4.  **[Add SSH key]** をクリックして完了。

---

## 6. SSH接続設定ファイル作成

`~/.ssh/config` ファイルを作成し、GitHubへの接続設定を追記する。これにより接続がスムーズになる。

```bash
# ~/.ssh/config ファイルに設定を追記 (ファイルがなければ新規作成)
cat <<EOF >> ~/.ssh/config
Host github
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
EOF
```

---

## 7. 接続テスト

GitHubへSSH接続できるかテストする。

```bash
ssh -T git@github
```

初回接続時は `yes` と入力する。以下のメッセージが表示されれば成功。

```plaintext
Hi your-username! You've successfully authenticated, but GitHub does not provide shell access.
```

これで `git clone` や `git push` がSSH経由で実行可能になる。