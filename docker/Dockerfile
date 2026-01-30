FROM node:22-alpine

WORKDIR /app

COPY . .

RUN npm install

CMD ["node", "start"]

# このファイルの COPY . . の場合：
# 1番目の . = ホストマシンの現在のディレクトリ（ビルドコンテキスト）の全ファイル
# 2番目の . = コンテナ内の現在のディレクトリ（この場合は WORKDIR で /app に設定されているので /app）
# つまり COPY . . は「ホストの全ファイルをコンテナの /app にコピーする」という意味です。