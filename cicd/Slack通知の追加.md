### Slack連携の構成
------------------------------
#### データの流れ
```properties
[Github Actions] --(通知)--> [Incoming Webhook] --(投稿)--> [Slack Channel]
```

------------------------------
#### 必要な準備
```properties
1. Slack API : アプリ作成とURLの発行
2. Github    : URLをSecretsに登録
3. YAML      : 通知ステップの記述
```

------------------------------
#### 1） Slack API設定

#### アプリの作成
```properties
 # 1)）https://api.slack.com/apps にアクセス
 # 2) [Create New App] -> [From scratch] を選択
 # 3) App Name (通知名) と Workspace を入力
```

#### Webhookの有効化
```properties
 # 左メニュー [Incoming Webhooks] を選択
 # [Activate Incoming Webhooks] を On にする
```

#### URLの発行
```properties
 # 1) 画面下部 [Add New Webhook to Workspace] をクリック
 # 2) 通知したいチャンネルを選択して [許可]
 # 3) 表示された Webhook URL をコピーする
 # ※ https://hooks.slack.com/services/... という形式
```

------------------------------
#### 2）Github Secrets 設定

#### URLを環境変数として隠蔽する
```properties
 # 直接コードに書くとセキュリティ事故になるため必須
```

#### 設定場所
```properties
  Settings ⇒ Secrets and Variables ⇒ Actions ⇒ New repository secret
```

#### 入力内容
```properties
  Name  : SLACK_WEBHOOK_URL
  Secret: (コピーした Webhook URL)
```

------------------------------
#### 3）YAML記述: Slack Notification
#### コード例
```yaml
# --- 省略 ---
    steps:
      # --- 省略 (Terraform Plan 等) ---

      - name: Slack Notification
        uses: rtCamp/action-slack-notify@v2 # 定番の通知アクション
        if: always()                        # 前のステップが失敗しても実行する
        env:                                # ※このアクションは with ではなく env で渡す
          SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK_URL }}
          SLACK_TITLE: "Terraform Plan Result"
          SLACK_MESSAGE: "ワークフローが終了しました"
          SLACK_COLOR: ${{ job.status }}    # 成功なら緑、失敗なら赤に自動変化
```
------------------------------