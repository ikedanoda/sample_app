# -*- coding: utf-8 -*-
# ワーカーの数
worker_processes 2

# ソケット経由で通信する
listen File.expand_path('tmp/sockets/unicorn.sock', ENV['RAILS_ROOT'])

# ログ
stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])

# ダウンタイムをなくす
preload_app true

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end