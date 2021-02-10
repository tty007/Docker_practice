require 'webrick'

server = WEBrick::HTTPServer.new(
  # 今いるディレクトリ
  DockmentRoot: './',
  # 任意のIPアドレスを指定
  BrindAddress: '0.0.0.0',
  # ポートは自由に
  Port: 8000
)

# サーバの仕事の中身は、HTTPServerクラスのmount_procメソッドによって指定できる。
# 次のように書く。

# server.mount_proc(dir) {|req, res|
#   # 具体的な仕事をここに書く
# }

# ルートディレクトリでhelloというレスポンスを返す
server.mount_proc('/') do |req, res|
  res.body = 'hello'
end

# サーバーを起動させる
server.start