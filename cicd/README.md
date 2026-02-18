# CI/CD メモ

## 目次

1. [CI/CD の構成](#1-cicd-の構成)
2. [CI/CD の実装方法](#2-実装方法)

---

## 1. CI/CD の構成

**ディレクトリ構成例:**

```properties
└── .github
    └── workflows
        └── <workflow_name>.yml
```

**ファイル構成例:**

```yaml
name: "Hello world"

on: [push]                        # トリガー

jobs:                             # ジョブ
  test-job:                       # ジョブID
    name: Hello world job         # ジョブ名
    runs-on: ubuntu-latest        # ランナー
    steps:                        # ステップ
      - uses: actions/checkout@v3
      - run: echo "Hello world !"
```

### Workflows の要素

| 要素         | 説明 |
| ------------ | ---- |
| **トリガー** | 実行タイミング。`push`, `pull_request`, `schedule`, `workflow_dispatch`, `workflow_run` |
| **ジョブ**   | 実行単位。ID・名前・ランナー・ステップを定義。環境変数はジョブ内で定義し、ステップごとにリセット |
| **ステップ** | `run`（Shell 直接） or `uses`（アクション利用）。バージョンは `@v3` 固定推奨 |
| **ランナー** | ジョブごとに1つ起動。GitHub ホスト（推奨） / self ホスト。ジョブ間連携は `needs` や成果物で |
| **シークレット** | クレデンシャルを GitHub に登録し、`${{ secrets.変数名 }}` で参照 |
| **依存関係** | `needs: [job1]` で実行順を指定 |

### 各フェーズの処理

#### CI フェーズ

- 変更影響の可視化（Dry Run）と構文チェックの自動化。主に PR 時に実行。

```properties
1. Checkout             : ソースコードのチェックアウト
2. Terraform Setup       : Terraform実行環境のセットアップ
3. Configure AWS Creds   : OIDCでAWS認証（一時クレデンシャル取得）
4. Terraform init        : バックエンド初期化・プラグインDL
5. Terraform format      : フォーマット検証（Lint）
6. Terraform validate    : 構文検証
7. Terraform plan        : 実行計画（変更プレビュー）
8. Slack Notify          : 結果通知
```

#### CD フェーズ

- 検証済みコードを AWS に自動デプロイ。主に main マージ時に実行。

```properties
1. checkout ～ 5. terraform init  : CIと同様
6. terraform apply       : AWSリソースに変更適用
7. slack notify          : Slackに通知
```

> **補足** ワークフローに `terraform fmt` を差し込んだらいいのでは？ → Runner 上でだけ整形されるので、リポジトリのソースは変わらない。

**ステップ `run` の例:**

```yaml
steps:
  - name: Greeting message
    id: greeting
    run: echo "Hello ${NAME}"
    env:
      NAME: tanaka
    shell: bash
    working-directory: tmp
# ジョブ全体のデフォルト: defaults.run で shell / working-directory を指定可能
```

**ステップ `uses` の例:**

```yaml
steps:
  - name: Checkout Repository
    uses: actions/checkout@v3
    with:
      fetch-depth: 0
```

**ジョブの依存関係:**

```yaml
jobs:
  job1:
    # ...
  job2:
    needs: [job1]
    # ...
  job3:
    needs: [job1, job2]
```

### 認証・通知の構成

- **認証:** OIDC（キーレス）。GitHub Actions → トークン提示 → AWS が検証 → 一時認証情報発行 → Terraform が AWS 操作。
- **通知:** GitHub Actions → Incoming Webhook → Slack チャンネル。

---

## 2. 実装方法

### OIDC のセットアップ

次の3つを行う。(1) IDプロバイダ作成 (2) IAM ロール作成 (3) Workflow に Permission 定義と接続テスト。

#### a. プロバイダの作成

「このリポジトリを信頼する」ID プロバイダを AWS で作成する。

```
1. AWSコンソール → IAM → IDプロバイダにアクセス
2. <プロバイダの追加> を選択
3. プロバイダのタイプ <OpenID Connect>
4. プロバイダ名 <https://token.actions.githubusercontent.com>
5. 対象者 <sts.amazonaws.com>
```

#### b. IAM ロール

「このリポジトリを信頼する」IAM ロールを AWS で作成する。

```
1. AWSコンソール → IAM → ロールにアクセス
2. <ロールを作成>
3. 信頼されたエンティティ <Web Identity>
4. アイデンティティプロバイダ <~githubusercontent.com>（上で作成したプロバイダ）
5. Audience <sts.amazonaws.com>
6. Github Organization <ユーザ名 or 組織名>（例: github.com/hogehoge/my-repo なら hogehoge）
7. 許可ポリシー <AdministratorAccess>（本来は最小権限推奨）
8. ロール名を入力して作成
9. **推奨** 信頼ポリシーを編集し、`sub` でリポジトリ（と必要ならブランチ）を制限する。未設定だと他リポジトリからも Assume されうる。
```

**信頼ポリシー例（リポジトリ制限）:**  
ロールの「信頼関係」で `Condition` を追加。`aud` は `StringEquals`、`sub` は `StringLike` が公式推奨。

```json
"Condition": {
    "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:org-name/repo-name:*"
    }
}
```

- 特定ブランチのみ: `"repo:org-name/repo-name:ref:refs/heads/main"`
- 環境を使う場合: `"repo:org-name/repo-name:environment:prod"`

#### c. Workflow での権限と接続テスト

`.github/workflows/*.yml` を作成し、以下を記述（コメント 1〜3 は環境に合わせる）。

```yaml
name: "OIDC Connection Test"

on:
  push:
    branches: [main]
    paths:
      - 'path/to/terraform/**'  # 1. Terraform のパス
      - '.github/workflows/**'
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  test-auth:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ap-northeast-1         # 2. リージョン
          role-to-assume: arn:aws:iam::...  # 3. IAM ロールの ARN
      - run: aws sts get-caller-identity
```

main に push 後、Actions タブで実行し、ログに `UserId` / `Account` / `Arn` の JSON が出れば成功。

---

### エラー処理

#### ステップ

| 目的 | 書き方 | 備考 |
|------|--------|------|
| エラーでも最後まで実行 | `shell: bash +e {0}` | 失敗扱い。exit code 取得向け。 |
| エラーを無視して成功扱い | `continue-on-error: true` | 失敗想定のテスト向け。 |
| 成否に関係なく必ず実行 | `if: always()` | 通知・結果出力向け。 |

```yaml
# 例
- name: sample
  shell: bash +e {0}
  run: echo "Hello world"

- name: sample
  continue-on-error: true
  run: echo "Hello world"

- name: sample
  if: always()
  run: echo "Hello world"
```

#### ジョブ

ジョブに `continue-on-error: true` を付けるとエラーを無視（成功扱い）。ジョブ内で失敗したステップ以降は実行されないが、後続ジョブは実行される。

```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    continue-on-error: true
    steps: # ...
```

---

### Slack 通知

**準備:** (1) Slack でアプリ作成・Webhook URL 発行 (2) GitHub Secrets に URL 登録 (3) Workflow に通知ステップを記述

**Slack API:** [api.slack.com/apps](https://api.slack.com/apps) → Create New App → From scratch → Incoming Webhooks を On → Add New Webhook to Workspace → チャンネル選択 → Webhook URL をコピー。

**GitHub Secrets:** `Settings` → `Secrets and Variables` → `Actions` → New repository secret。名前 `SLACK_WEBHOOK_URL`、値にコピーした URL。

**Workflow 記述例:**

```yaml
    steps:
      # ... (Terraform Plan 等) ...
      - name: Slack Notification
        uses: rtCamp/action-slack-notify@v2
        if: always()
        env:
          SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK_URL }}
          SLACK_TITLE: "Terraform Plan Result"
          SLACK_MESSAGE: "ワークフローが終了しました"
          SLACK_COLOR: ${{ job.status }}   # 成功=緑、失敗=赤
```

※ このアクションは `env` で渡す（`with` ではない）。

---

### 参考: sample_workflows

- `sample_workflows/infra.preview-deploy.yml`
- `sample_workflows/infra.destroy.yml`

実例は上記を参照。
