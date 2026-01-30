# Git/GitHub チートシート

日常的に使用する Git コマンドのまとめです。

## 1. 初期設定・確認 (Setup & Config)

| コマンド | 説明 |
| :--- | :--- |
| `git config --global user.name "名前"` | ユーザー名の設定 |
| `git config --global user.email "email"` | メールアドレスの設定 |
| `git config --list` | 設定内容の確認 |
| `git remote -v` | リモートURL（originなど）の確認 |

## 2. 開始・取得 (Start & Get)

| コマンド | 説明 |
| :--- | :--- |
| `git init` | 現在のディレクトリをリポジトリとして初期化 |
| `git clone [url]` | リモートリポジトリを複製（HTTPS/SSH） |

## 3. 基本操作 (Basic Workflow)

| コマンド | 説明 |
| :--- | :--- |
| `git status` | 変更状態の確認（必須） |
| `git add .` | 全ての変更をステージングエリアに追加 |
| `git add [file]` | 特定のファイルのみ追加 |
| `git commit -m "メッセージ"` | ステージングされた変更をコミット |
| `git commit --amend` | 直前のコミット内容やメッセージを修正 |

## 4. ブランチ操作 (Branching)

| コマンド | 説明 |
| :--- | :--- |
| `git branch` | ローカルブランチの一覧表示 |
| `git branch -a` | リモート含む全ブランチを表示 |
| `git switch -c [branch-name]` | 新しいブランチを作成して切り替え |
| `git switch [branch-name]` | 既存のブランチに切り替え |
| `git branch -d [branch-name]` | ブランチを削除（マージ済みのみ） |
| `git branch -D [branch-name]` | ブランチを強制削除 |

## 5. 同期・リモート操作 (Sync & Remote)

| コマンド | 説明 |
| :--- | :--- |
| `git pull origin [branch]` | リモートの変更を取り込む |
| `git push origin [branch]` | ローカルの変更をリモートへ送信 |
| `git fetch --prune` | リモートで削除されたブランチ情報をローカルに反映（掃除） |

## 6. 取り消し・修正 (Undo & Fix)

> **注意:** `reset` 系は履歴が変わるため、共有ブランチでは慎重に使用してください。

| コマンド | 説明 |
| :--- | :--- |
| `git restore [file]` | ファイルの変更を破棄（add前） |
| `git restore --staged [file]` | ステージングを取り消す（add後、commit前） |
| `git reset --soft HEAD^` | 直前のコミットを取り消す（変更内容は残る） |
| `git reset --hard HEAD^` | 直前のコミットを完全に取り消す（変更内容も消える） |

## 7. 一時待避 (Stash)

作業途中で別のブランチに切り替えたい時に便利です。

| コマンド | 説明 |
| :--- | :--- |
| `git stash` | 変更を一時的に退避する |
| `git stash list` | 退避したリストを表示 |
| `git stash pop` | 最新の退避内容を戻して適用 |

## 8. ログ確認 (Log)

| コマンド | 説明 |
| :--- | :--- |
| `git log` | コミット履歴を表示 |
| `git log --oneline --graph --all` | コミットツリーをグラフで簡潔に表示 |