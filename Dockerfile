# 使用 Alpine Linux 作为基础镜像
FROM alpine:latest

# 设置工作目录
WORKDIR /app

# 安装 curl 和 jq
RUN apk add --no-cache curl jq

# 复制一个简单的脚本到镜像中
COPY entrypoint.sh /app/entrypoint.sh

# 赋予脚本执行权限
RUN chmod +x /app/entrypoint.sh

# 设置容器启动时运行的命令
ENTRYPOINT ["/app/entrypoint.sh"]
