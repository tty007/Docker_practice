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
`$ docker-compose build`

- コンテナの作成と起動
`$ docker-compose up -d`

- コンテナを停止・削除
`$ docker-compose down`

## その他docker-composeでよく使うコマンド

- コンテナの一覧を表示

`$ docker-compose ps`

- ログを表示

`$ docker-compose logs`

- コマンド実行用のコマンド
  - ①コンテナを作成してコマンドを実行する場合
  `$ docker-compose run [サービス] [コマンド]`
  
    →1からコンテナを作成してコマンドを行う

  - ②起動中のコンテナに対してコマンドを実行する場合
  `$ docker-compose exec [サービス] [コマンド]`

## DockerでRailsの環境構築編
### ファイルの作成
以上を踏まえて実際にDockerでRailsの環境構築に入る。まず`Dockerfile`, `Gemfile`, `docker-compose.yml`をそれぞれ作成。

```Bash:Dockerfile
FROM ruby:2.7

# # nodejs yarn をインストールするためのコマンド. 上3行はクローズドissueからの参考コマンド
# # https://github.com/yarnpkg/yarn/issues/7329
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
#   && echo "deb https://dl.yarnpkg/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
#   && apt-get update -qq \
#   && apt-get install -y nodejs yarn

## nodejsとyarnはwebpackをインストールする際に必要
# yarnパッケージ管理ツールをインストール
RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn

# Node.jsをインストール
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
apt-get install nodejs

WORKDIR /app
COPY ./src /app
RUN bundle config --local set path 'vendor/bundle' \
  && bundle install
```

`Dockerfile`はRails6かから`webpacker`が標準搭載となったため、`nodejs`, `yarn`のライブラリを事前にインストールしておく必要がある。残りはこれまで学習した通りである。

```ruby:src/Gemfile
source 'https://rubygems.org'

gem 'rails', '~> 6.1.2'
```

`rails`を取得してくるために`Gemfile`に記述する。

```Bash:docker-compose.yml
version: '3'
services:
  db:
    image: mysql:8.0
    # MySQL8.0からはログイン認証方式がcaching_sha2_passwordに
    # MySQL5と同じログイン認証方式に変更が必要
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - ./src/db/mysql_data:/var/lib/mysql
    environment: 
      # mysqlはパスワードを設定していないとエラーになる
      MYSQL_ROOT_PASSWORD: password
  web:
    # imageはカレントディレクトリのDockerfileを参照する
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - ./src:/app
    ports:
      - "3000:3000"
    # 依存関係。DBと連携。通常であればDBサービスのIPアドレスを入れる必要があるが、サービス名を入れるだけで連携可能
    depends_on:
      - db
    # pryを使用してデバッグができるよう設定
    tty: true
    stdin_open: true
```

以上のファイルを作り終えたら、

`$ docker-compose run web rails new . --force --database=mysql`

以上の様にコマンドを打ち、作成したwebコンテナに対して、Railsコマンドを実行する。

Rails6からはwebpackerが標準搭載のため、さらにRailsにwebpackerをインストールする作業も行う。

`$ docker-compose run web rails:webpacker install`

`Gemfile`や`Dockerfile`の内容が上書きされた場合は再度イメージをビルドしなおす。

### DBの設定
`src/source/config/database.yml`より、DBの設定をコンテナの定義に合わせる。

```yaml:src/source/config/database.yml
# SQLite. Versions 3.8.0 and up are supported.
#   gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem 'sqlite3'
#
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: root
  # パスワードは設定した通りに
  password: passowrd
  # ホストはdb(DBのアプリケーション名)へ変更
  host: db
  timeout: 5000

development:
  <<: *default
  database: app_development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: test_development

production:
  <<: *default
  database: production_development
```

以上の設定が終わったら、

`$ docker-compose run web rails db:create`

で、Rails上にデータべースを作ることができる。ファイルを定義しただけではDBは実際には作られず、このコマンドをしっかりと打つ必要がある。このような表記がターミナルに出たら成功である。

```Bash
Creating rails-docker_web_run ... done
Created database 'app_development'
Created database 'test_development'
```

### Railsサーバーを起動する
`$docker-compose up`

![Railsサーバー](../img/rails-server.png)

を実行すると、ローカルホストから接続したDocker上で、サーバーの起動が確認できるハズである。
あとはローカルのファイルに変更を加えながらサーバー上で変更をチェックして、開発するという流れである。

サーバーの停止は`Ctrl+C`でも良いし、別ターミナルを開いて`$ docker-compose down`でも良い。

