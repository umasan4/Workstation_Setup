# Github Actions
CI/CD環境を構築する手順や自己理解のためのメモ

## 1. 概要

- ディレクトリ構成
```properties
# 実行する処理はワークフロー(YAML)に定義する

└── .github
    └── workflows
        └── <name>.yml
```

## 2. ワークフロー / workflow
```yaml
# workflow は、次の3層で構成される
# (1) workflow : YAMLファイルそのもの、1つの自動化プロセス
# (2) job      : 処理の塊、jobは並列で実行される、job単位で仮想マシンが用意される
# (3) step     : 処理の最小単位、Jobの中で実行される（上から順に実行）

# workflow サンプルコード
name: "Hello world"
  
on: [push]
  
jobs:
  test-job:                       # ジョブID(機械が参照)
    name: Hello world job         # ジョブ名(人間が参照)
    runs-on: ubuntu-latest        # 実行環境
    steps:
      - name: Say hello           # stepにも名前を付けると良い
        run: echo "Hello world !"　
```

## 3. 
------------------------------------------------------------


# 学習メモ
## 重要
```
ブランチ保護 (Branch Protection)

なぜ重要？: 
⇒ SREの仕事は「自動化」だけでなく「ガードレール（安全装置）を作ること」だからです

何をする？: 
⇒ 「CI（terraform plan）が成功しないと、main ブランチにマージできないようにする」という設定です
    これが設定されていないCIは、ただの「飾り」になってしまいます

条件分岐 / ジョブ間の依存
⇒ 「plan が失敗したら apply を実行しない」といった制御に必要です
```
### 特定のブランチを保護する仕組みを指す
1. ブランチの指定 : ワイルドカードなどを用いて指定する
2. 保護する仕組み : マージ前に Pull Request によるレビューを要求など
- コードオーナー

## 余裕があれば
```
承認フロー
terraform apply（本番変更）の前に、「人間がボタンを押さないと進まない」ようにする設定です
本番運用のリアリティが出るため、ポートフォリオとしての評価が上がります

slack通知
apply の結果をSlackに飛ばす設定です
「ChatOps」の基礎として評価されます
```