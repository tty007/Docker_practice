# 何のイメージをベースとするか
FROM ruby:2.7

# ワークディレクトリは何でもOK
WORKDIR /app

# src以下のファイル群をワークディレクトリにコピーする
COPY ./src/ /app

RUN bundle config --local set path 'vendor/bundle'
RUN bundle install

CMD ["bundle", "exec", "ruby", "app.rb"]

