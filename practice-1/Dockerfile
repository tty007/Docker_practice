
FROM ruby:2.7

# ディレクトリの作成, 単純なコマンドの実行 "RUN"
RUN mkdir /workspace
# main.rbをworkspaceディレクトリに移動
COPY main.rb /workspace

# Dockerイメージを起動した時に実行するコマンド "CMD"
CMD ["ruby", "/workspace/main.rb"]

