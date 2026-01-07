## 1. CI/CD
### 1-1. CI/CDとは
ビルド、テスト、デプロイの一連の流れを自動化する手法。 手作業によるオペレーションミスを排除し、開発サイクル（リードタイム）の短縮と品質向上を実現する。

------------------------------
### 1-2. 各フェーズで行う処理
- CIフェーズ
    ```properties
    # 変更による影響範囲の可視化（Dry Run）と、構文チェックの自動化
    # 主にPull Request時に実行される

    1. Checkout             : ソースコードのチェックアウト
    2. Setup Terraform      : Terraform実行環境のセットアップ
    3. Configure AWS Creds  : OIDCを利用したAWS認証（一時クレデンシャルの取得）
    4. Terraform init       : バックエンドの初期化とプラグインのダウンロード
    5. Terraform fmt        : コードフォーマットの検証（Lintチェック）
    6. Terraform validate   : 構文（シンタックス）の正当性検証
    7. Terraform plan       : 実行計画の作成（変更内容のプレビュー）
    8. Slack Notify         : 実行結果の通知
    ```

- CDフェーズ
    ```properties
    # 検証済みコードの自動デプロイ（AWSリソースへ変更を適用）
    # 主にmainブランチへマージされた時に実行される

    1. checkout             : 
    2. setup terraform      : 
    3. terraform fmt        : 
    4. configure creds      : 
    5. terraform init       : 
    6. terraform apply      : AWSリソースを作成
    7. slack notify         : Slackに通知
    ```

## 2. OIDC
### 2-1. OIDCとは
- 認証プロトコルの1つで、長期的なアクセスキー（Access Key ID / Secret Access Key）の発行・管理を不要にするキーレスな認証方式。Terraformに一時的にAWSアクセスを許可する。

- OIDCの仕組みは以下の通り
    ```
    1. AWS側で「このGitHubリポジトリなら信頼する」という IDプロバイダ と IAMロール を設定
    2. GitHub Actions実行時に、AWSへ「信頼の証（トークン）」を提示
    3. AWSが検証し、問題なければ一時的な認証情報を発行
    4. Terraform等は、その一時情報を使ってAWSを操作する
    ```
    ```mermaid
    sequenceDiagram
    participant GH as GitHub Actions
    participant AWS as AWS (IAM)
    
    GH->>AWS: 1. OIDCトークン(信頼の証)を提示
    Note right of GH: リポジトリ情報などを含む
    AWS->>AWS: 2. IDプロバイダとIAMロールで検証
    AWS-->>GH: 3. 一時的な認証情報(STS)を発行
    GH->>AWS: 4. Terraformコマンド実行
    ```

------------------------------
### 2-2. OIDCのセットアップ
- 必要な設定は以下の通り
    ```
    a. AWS上で [IDプロバイダ] を作成  
    b. AWS上で [IAMロール] を作成  
    c. WorkflowファイルにPermissionを定義
    ```

#### a. プロバイダの作成
- AWS側で「このGitHubリポジトリなら信頼する」 というIDプロバイダを設定する
    ```properties
    1. AWSコンソール → IAM → IDプロバイダにアクセス

    2. <プロバイダの追加> ボタンを選択
    
    3. プロバイダのタイプ <OpenID Connect> を選択
    
    4. プロバイダ名 <https://token.actions.githubusercontent.com> を入力
    
    5. 対象者 <sts.amazonaws.com> を入力
    ```

#### b. IAMロール
- AWS側で「このGitHubリポジトリなら信頼する」 というIAMロールを設定する
    ```properties
    1. AWSコンソール → IAM → IDロールにアクセス
    
    2. <ロールを作成>ボタンを選択
    
    3. 信頼されたエンティティタイプ <web Identity> を選択
    
    4. アイデンティティプロバイダ <~githubusercontent.com> を選択
       # 先の手順で作成したプロバイダ名を選択する

    5. Audience <sts.amazonaws.com> を選択
    
    6. Github Organization <Githubのユーザ名 or 組織名> を入力
       # GitHubのリポジトリURLが https://github.com/hogehoge/my-repo の場合、hogehoge の部分
       
    7. 許可ポリシー <AdministratorAccess> を選択
       # 本来は最小権限を与えるのが望ましい

    8. ロール名を入力して作成
       # ロール名は任意

    9. 信頼ポリシーを編集 （任意）
    #--- 省略 ---
    "Condition": {
        "StringLike": {
            "token.actions.githubusercontent.com:aud": [
                "sts.amazonaws.com"
            ],
            "token.actions.githubusercontent.com:sub": [
                "repo:{name or org}/{repository}:*" 
                # ↑ 接続リポジトリを制限できる（デフォルトで全リポジトリアクセスが許可されている）
                # - GitHubのリポジトリURLが https://github.com/hogehoge/my-repo の場合、
                #   hogehoge/my-repo の部分を張り付ける事でそのリポジトリにアクセス可能になる
            ]
        }
    }
    ```
------------------------------
#### c. Workflow
- Github ActionsのAPIを実行する際に必要な権限を設定する
    ```properties
    1. エディタで対象のローカルリポジトリを開く
    2. ルートに <.github/workflows> の入れ子でディレクトリを2つ作成
    3. workflows 配下に <{任意のファイル名}.yml> ファイルを作成
    ```
    ```yaml
    4. 作成した.ymlファイルに以下の通り記述
    
    name: "github action test code"

    on:
    push:
        branches:
        - main
        paths:
        - #<terraformコードが格納されたディレクトリパス>/**
        - .github/workflows/**
    workflow_dispatch:

    permissions:
    id-token: write # Githubが発行するトークンを取得する権限
    contents: read  # リポジトリのコードを読み取る権限

    jobs:
    preview:
        name: "preview"
        runs-on: ubuntu-latest
        steps:
        - run: |
            echo "Hello World."
    ```
    ```properties
    5. 記述後、main ブランチに .ymlファイルをpush
    6. github → 対象リポジトリ → Actionsを開く
    7. ログに Hello World. が出力されていたら成功
    ```
------------------------------
