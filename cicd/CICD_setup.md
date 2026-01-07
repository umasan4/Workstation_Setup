## 1. CI/CD
### 1-1. CI/CDとは
- 開発手法の1つで、コード変更テストから本番環境リリースまでの一連プロセスを自動化し、ソフトウェア開発の品質向上と迅速なリリースを実現する

------------------------------
### 1-2. 各フェーズで行うこと
- CI：確認 (Preview) フェーズ
    ```properties
    コードを変更した際「これを適用したらどうなるか？」を事前に動作確認する
    # 主にPull Request時に実行される

    1. checkout            : GitHubからソースコードを取得する（actions/checkout）
    2. setup terraform     : 実行環境 (runner) にTerraformツールをインストールする
    3. configure credential: AWSへの認証を行う（OIDC認証の設定を確認する）
    4. terraform fmt       : コードの書き方（フォーマット）が綺麗かチェックする
    5. terraform init      : Terraformの初期化（プラグインのDLなど）
    6. terraform validate  : 文法的な間違いがないか検証する
    7. terraform plan      : AWSに対して「何が変更されるか」だけ確認する（ドライラン）
    8. slack notify        : 結果（「エラーなし」「S3が1つ追加される予定」など）をSlack通知
    ```

- CD：適用 (Deploy) フェーズ
    ```properties
    確認が終わって問題ないコードを、実際にAWS環境へ反映させる
    # 主にmainブランチへマージされた時に実行される

    ステップ:
    # 1 ~ 4までCIと同じ
    1. checkout            : GitHubからソースコードを取得する（actions/checkout）
    2. setup terraform     : 実行環境 (runner) にTerraformツールをインストールする
    3. terraform fmt       : コードの書き方（フォーマット）が綺麗かチェックする
    4. configure credential: AWSへの認証を行う（OIDC認証の設定を確認する）
    5. terraform apply     : 実際にAWSリソースを作成・変更・削除するコマンドを実行する
    6. slack notify        : 「デプロイが完了しました」とSlackに通知する
    ```

## 2. OIDC
### 2-1. OIDCとは
- 認証プロトコルの1つで、Terraformに一時的にAWSアクセスを許可する仕組み   
  AWSのアクセスキー発行・管理（ローテーション）が不要になる利点がある

- OIDCの仕組みは以下の通り
    ```
    1. AWS側で「このGitHubリポジトリなら信頼する」という IDプロバイダ と IAMロール を設定
    2. GitHub Actions実行時に、AWSへ「信頼の証（トークン）」を提示
    3. AWSが検証し、問題なければ一時的な認証情報を発行
    4. Terraform等は、その一時情報を使ってAWSを操作する
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
    4. 作成した.ymlファイルに以下の通り記述
    ```
    ```yaml
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
