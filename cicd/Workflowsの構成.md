### Workflowsの構成
------------------------------
#### ディレクトリ構成
``` properties
└── .github
    └── workflows
        └── <workflow_name>.yml
```

------------------------------
#### ファイル構成
```yaml
name: "Hello world"
  
on: [push]                          # トリガ
  
jobs:                               # ジョブ
  test-job:                         # ジョブID (システムが参照)
    name: Hello world job           # ジョブ名 (人間が参照するラベル)
    runs-on: ubuntu-latest          # ランナー (実行環境)
    steps:                          # ステップ 実際に実行される内容
      - users: actions/checkout@v3  # ステップ(uses)
      - run: echo "Hello world !"   # ステップ(run)
```

------------------------------
#### 1）トリガー
```yaml
# 何をしたら実行する？
# push, pull_request
# shedule
# workflow_dispach
# workflow_run
```

------------------------------
#### 2）ジョブ
```yaml
# 実行する内容
# ジョブID
# ジョブ名
# ランナー
# ステップ

# 環境変数
 # ジョブの中で定義する変数
 # ステップごとに環境変数の値は初期化される
```

------------------------------
#### 3）ステップ
```properties
# 実行する内容の詳細(2種類)
1. run : CLIプログラム (Shellスクリプト)
2. uses: アクション (マーケットから引用もしくは自作)
```

------------------------------
#### a. ステップ: run (自身で構築する場合)
```yaml
# コード例
# --- 省略 ---
jobs:
  sample:
    name: Hello World Job
    runs-on: ubuntu-latest
    steps:
      - name: Greeting message    # ステップの表示名
        id: greeting              # ステップID
        run: echo "Hello ${NAME}" # シェルスクリプト
        env:                      # (OP)環境変数
          NAME: tanaka
        shell: bash               # (OP)実行するシェル(python等も指定可)
        working-directory: tmp    # (OP)実行する場所を指定

# 実行環境を指定できる
 # ジョブのスコープ外で定義すると、すべてのジョブに適用される
 # あるジョブの中で定義すると、そのジョブ内でのみ適用される
defaults:
  run:
    shell: bash
    working-directory: tmp
```

------------------------------
#### b. ステップ: uses (テンプレを利用する場合)
```yaml
# マーケットプレイスからアクションを探す
 # 1) https://github.com/marketplace にアクセス
 # 2) github.com の左メニュー[Marketplace]からもアクセス可能
 # 3) 検索窓から actions名を検索
 # ※ ブランチの切替えが特に利用頻度が高い

# コード例
# --- 省略 ---
jobs:
  sample:
    name: Sample Job
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository # ステップの表示名
        id: checkout              # ステップID
        uses: action/checkout@v3  # アクション(@でバージョン指定推奨)
        with:
          fetch-depth: 0          # (OP)アクションの引数

# アクションのバージョン指定を推奨する
 # ※ 暗黙のバージョンアップデートにより、突然CI/CDが動かなくなる事を避けるため

# 引数には何を指定したらいい？
 # ※ マーケットプレイスの各アクションの [usage] を確認する
 # ※ 英語が苦手なら右クリ → 日本語に翻訳を選択
```

------------------------------
#### 4）ランナー
```properties
# ジョブを実行する環境
  ランナーはジョブ単位で起動
  ジョブ間で情報を連携するには工夫が必要

# ランナーは2種類
  1. Githubホスト: Githubがホスト管理 (推奨)
  2. selfホスト  : 自分自身でホスト管理
```

------------------------------
#### ※ シークレット
```properties
GithubのWebページ上にクレデンシャルを秘匿する
ログイン等で利用する際は変数として呼び出す
利点はクレデンシャルをハードコードせずに済む

設定方法
Settings ⇒ Secrets and Variables ⇒ Actions ⇒ New Reposiries Secret

注意
Github Actions で定義した変数と他で定義した変数の呼出し方は異なる
Github Actionsでは ${{ 変数 }} と呼び出す
```
------------------------------
#### ※ ジョブの依存関係
```yaml
#needs を使う

jobs:
  job1:
  #--- 省略 ---

  job2:
    needs: [job1]
  #--- 省略 ---

  # 複数指定もできる
  job3:
    needs: [job1, job2]
```