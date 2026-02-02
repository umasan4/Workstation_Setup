# Dev Setup Repository

## 目的
このリポジトリは、開発環境のセットアップ方法や学習の過程で得た学びや教訓をまとめたものです。Terraform、CI/CD、AWS CLI、GitHub、Linuxスクリプト、WSL2などのツールのインストールと設定手順をまとめています。

## 内容
- **aws/**: AWS CLIのセットアップガイド
- **cicd/**: CI/CDパイプラインの構築とGitHub Actionsの設定
- **github/**: GitとGitHubのSSH接続セットアップ
- **linux/**: BashスクリプトとLinuxコマンドの例
- **terraform/**: Terraformのインストールとインフラテンプレート
- **wsl2/**: WSL2環境のセットアップ

## 技術スタック (Tech Stack)
* **Infrastructure**: Terraform (Modules, Remote Backend)
* **Cloud**: AWS (VPC, ECS, S3, DynamoDB)
* **Container**: Docker, Docker Compose
* **CI/CD**: GitHub Actions
* **OS/Scripting**: Linux (Bash), WSL2

## ディレクトリ構成 (Directory Structure)
* `terraform/`: 本番運用を想定したディレクトリ構成とモジュール設計
* `docker/`: マルチステージビルドやDB初期化を含むDocker構成
* `cicd/`: 再利用可能なWorkflowテンプレート
* `linux/`: 実務で使えるシェルスクリプト集

## 工夫した点 (Highlights)
* TerraformのState管理にS3/DynamoDBを使用した排他制御の実装
* DRY原則に基づいたTerraform Moduleの分割
* (今後追加したら) DevContainerによる開発環境のコード化

## 修正課題
改善提案（ポートフォリオとして強化するため）
GitHubでの公開とブランディング:

リポジトリをGitHubで公開し、スターやフォークを増やす。オープンソースコミュニティからのフィードバックを得る。
トピックタグ（例: terraform, aws, devops, infrastructure）を追加して検索されやすくする。
READMEの充実:

作成したREADME.mdをさらに詳細に。使用例やスクリーンショットを追加。
各ディレクトリにサブREADMEを追加（例: terraform/infra_template/README.md）。
実績の追加:

実際のプロジェクトでの適用例を追加（例: 「このテンプレートを使ってXX環境を構築しました」）。
テストや検証スクリプトを追加して信頼性を高める。
品質向上:

スペルチェックと日本語の統一（例: 「Workstaion」は「Workstation」のタイポ）。
リンク切れや古いバージョンの更新。

このリポジトリ自体にCI/CDを組み込む