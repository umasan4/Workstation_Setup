# README.md

# 何が書くか？構成を決めてから書き込む

## terraform console
- AWS環境に一切変更を加えず、terraformの関数や変数の挙動を試せるコマンド
- 対象の tfファイルがあるディレクトリで実行する

```properties
# 例: 以下の変数を確認する
variable "environment" {
  type        = list(string)
  default     = ["dev", "prod"]
}

# 1. ターミナルでコンソールモードを起動
terraform console

# 2. 確認(変数直打ち)
> var.environment
tolist([
  "dev",
  "prod"
])

# 3. 確認(listの場合はtoset で確認できる)
> toset(var.environment)
toset([
  "base",
  "dev"
])
```
--------------------
## 複数リソースを一度に作成する
- for_each と toset()を使い、リストから複数リソースを一度に作成する

- tosetの機能
    ```properties
    # tosetの機能
      重複を取り除く（"dev" が2回あっても1つにする）
      インデックス番号（0, 1, 2...）を捨てる
      値を「ID（識別子）」として使える状態にする
      ※ toset を使った場合、key と value は同じ値になる

    # ListとSetの特徴
      # List (リスト):
        順番が一意。中身がダブってもOK
        ["dev", "prod"] 

      # Set (セット):
        中身が一意。順番はどうでもいい
        {"dev", "prod"}
    ```
- for_eachの機能
    ```properties
    # リストは受け取れない
      リストには重複や順序があって一意にリソースを指定できないため

    # 機能
      toset() で整地されたデータを受け取り、その数だけリソースをコピーして作成する
      このとき、ループの中で使える each オブジェクト が提供される
      each.key: Setの要素そのもの（例: "dev"）
      each.value: Setの要素そのもの（例: "dev"）
      ※ toset を使った場合、key と value は同じ値になる
    ```
