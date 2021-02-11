# practice-2
## DockerでSinatra(シナトラ)を動かす
**Sinatra（シナトラ）**は、Rubyで作成されたオープンソースのWebアプリケーションフレームワークで、Railsの軽量簡易版だと思って貰って構わない。深堀する項目ではないため、本フレームワークの説明は割愛する。まずは機能の少ないシナトラで練習してみようというのが本練習の目的である。

### Gemfileを作成して実際に環境構築を行う。
`sinatra`が使える様に、`Gemfile`というファイルにその準備を記述する。`src/Gemfile`を作成して以下記述。

```ruby:Gemfile
source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.comm/#{repo_name}" }

gem "sinatra"
```

`Gemfile`とは、Gemfileはrubyのライブラリ管理ファイルであり、ここに一括で利用するライブラリを書く事でライブラリを管理する事ができる。

### Dockerfileの作りかた
`Dockerfile`を0から作成するときに何のコマンドを記述すればいいかわからない、エラーが出るか検証したいという事が起きる。

`Dcokerfile`のコマンドはまず

```Bash:Dockerfile
# 何のイメージをベースとするか
FROM ruby:2.7
# ワークディレクトリは何でもOK
WORKDIR /app
# src以下のファイル群をワークディレクトリにコピーする
COPY ./src/ /app
CMD ["/bin/bash"]
```

と記載し、Dcokerに入ってから実際に実行し、うまくいったものを後から`Dockerfile`に記載するといったやり方が望ましい。
最初にコマンドを羅列すると思わぬエラーに遭遇する可能性があるため。上はシェルを起動するというコマンドである。

### イメージの作成、コンテナの作成、インタラクティブモードについて
イメージを作成する。

`$ docker image build -t test/sinatra:latest .`

次に、コンテナを作成する

`$ docker container -it -p 4567:4567 —name sinatra -v ${PWD}/src:/app test/sinatra:latest`

このコマンドについて補足説明が必要なのでしておく。

`4567`はシナトラデフォルトのポート番号であり、それを利用している。`-v`オプションについて。これはローカルのディレクトリとDockerコンテナ内のディレクトリの同期オプションである。左がローカルディレクトリ、右がDocker上の(ワーク)ディレクトリで、それぞれのディレクトリ構造を同期するオプションとなっている。ローカルで修正するとDocker側のコードも修正される様になる。

`-it`オプションについて：シェルというのはコマンドを打ってレスポンスが返ってくる、いわゆる**インタラクティブ**な操作が必要である。インタラクティブな操作をDockerで行う時は`-it`オプションで明記することが必要である。

![インタラクティブモード](./img/docker-it.png)

これで`Bash`(Dockerのapp(ルート)ディレクトリ)に入ることが確認できた。次の手順に移る。

### GemfileからSinatraを落としてくる
`Bash`に入った状態で、

`$ bundle config —local set path 'vender/bundle'`

その後、

`$ bundle install`

これで`Gemfile`からSinatra(シナトラ)を入れる事ができる。

### Sinatraでwebサーバーを作ってみる
ここまでできたらSinatra(シナトラ)でwebサーバーを作ってみよう。`src/app.rb`を作成する。

```ruby:app.rb
require 'sinatra'

configure do
  # ローカルのどのIPアドレスから来てもデータのやりとりができるようにオープンIPの0.0.0.0にバインド
  set :bind, '0.0.0.0'
end

get '/' do
  "Hello, World."
end
```

この様に記述し、

`$ bundle exec ruby app.rb`

`bundle exec`とは`Gemfile`を使った処理の時に記述するコマンドで、これで`app.rb`を実行する。

![sinatra-web](./img/sinatra-web.png)

Sinatraサーバーが起動している事が確認できた。

### Dockerfileへの反映作業
以上の一連のコマンドを、`Dockerfile`へと反映していく。予備知識を記載するならば、

```Bash
RUN bundle config --local set path 'vendor/bundle'
RUN bundle install

RUN bundle config --local set path 'vendor/bundle' \ 
&& bundle install
```

上部と下部のコマンドは同値である。最終的にDockerfileはこの様になる。

```Bash:Dockerfile
# 何のイメージをベースとするか
FROM ruby:2.7
# ワークディレクトリは何でもOK
WORKDIR /app
# src以下のファイル群をワークディレクトリにコピーする
COPY ./src/ /app

RUN bundle config --local set path 'vendor/bundle'
RUN bundle install

CMD ["bundle", "exec", "ruby", "app.rb"]
```

全て書き直したら、
`$ docker container run -p 4567:4567 --name sinatra -v ${PWD}/src:/app test/sinatra:latest`

同様にサーバーが起動している事が確認できるハズである。







