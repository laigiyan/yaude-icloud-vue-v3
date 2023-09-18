FROM caddy:latest


# 定义容器启动时运行的命令
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
