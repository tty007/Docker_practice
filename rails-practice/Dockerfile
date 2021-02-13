FROM ruby:2.7

# 追加
ENV RAILS_ENV=production

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

COPY start.sh /start.sh
# 実行権限の付与
RUN chmod 744 /start.sh
CMD ["sh", /start.sh]