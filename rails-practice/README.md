# rails-practice
## DockerでRailsの環境構築をする
ここまでの知識でベースのdockerについての知識はついているが、実際に開発するとなるとまだ不十分。
理由は、Webアプリケーションは一つのサーバーで動いている場合は稀で、アプリケーションサーバ・DBサーバ等複数のサーバが連携して一つのサービスになっている場合が多いからである。

そこで現れるのが**docker-compose**。
それぞれのサーバーをひとまとめにして様々な物事を実行できるコマンド・概念である。

`docker-compose.yml`に記述することで複数のdockerコンテナを管理できる優れものである。
それぞれのサービスごとに設定を記述する。

## docker-composeの基本操作
- イメージのビルド
`docker-compose build`

- コンテナの作成と起動
`docker-compose up -d`

- コンテナを停止・削除
`docker-compose down`



