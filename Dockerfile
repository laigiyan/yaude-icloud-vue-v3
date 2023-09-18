# 使用官方的 Node.js 16 镜像作为基础镜像
FROM node:16 as nodejs


RUN mkdir code
workdir /code
COPY ./* ./

# 安装应用程序的依赖
RUN npm install --force

RUN npm run build:dev

# 第二个阶段：使用 Apache 镜像来托管前端文件并代理转发
FROM httpd:latest
COPY --from=nodejs /code/dist /usr/local/apache2/htdocs/
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# 定义容器启动时运行的命令
CMD ["httpd-foreground"]


