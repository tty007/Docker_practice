require 'sinatra'

configure do
  # ローカルのどのIPアドレスから来てもデータのやりとりができるようにオープンIPの0.0.0.0にバインド
  set :bind, '0.0.0.0'
end

get '/' do
  "Hello, World."
end