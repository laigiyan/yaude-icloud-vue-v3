# 使用官方的 Node.js 16 镜像作为基础镜像
FROM node:16 as nodejs


RUN mkdir code
workdir /code
COPY ./* ./

# 安装应用程序的依赖
RUN npm install --force

RUN npm run build:dev

FROM nginx
MAINTAINER buhuaqiang@163.com
VOLUME /tmp
ENV LANG en_US.UTF-8
RUN echo "server {  \
                      listen       8080; \
                      location ^~ /yaude-boot { \
                      proxy_pass              http://yaude-icloud-java:8080/yaude-boot/; \
                      proxy_set_header        Host yaude-icloud-java; \
                      proxy_set_header        X-Real-IP \$remote_addr; \
                      proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for; \
                  } \
                  #解决Router(mode: 'history')模式下，刷新路由地址不能找到页面的问题 \
                  location / { \
                     root   /var/www/html/; \
                      index  index.html index.htm; \
                      if (!-e \$request_filename) { \
                          rewrite ^(.*)\$ /index.html?s=\$1 last; \
                          break; \
                      } \
                  } \
                  access_log  /var/log/nginx/access.log ; \
              } " > /etc/nginx/conf.d/default.conf \
    &&  mkdir  -p  /var/www \
    &&  mkdir -p /var/www/html

COPY --from=nodejs /code/dist /var/www/html/
EXPOSE 8080
USER root

ENTRYPOINT ["nginx", "-g", "daemon off;"]

