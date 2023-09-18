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
#RUN rm /etc/nginx/nginx.conf
#COPY ./nginx.conf /etc/nginx/nginx.conf
#RUN usermod -u 1000 nginx && groupmod -g 1000 nginx
# 更改 Nginx 进程的 UID 为 1000
user root
RUN usermod -u 1000 nginx && \
    groupmod -g 1000 nginx && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/run && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx
EXPOSE 8080


ENTRYPOINT ["nginx", "-g", "daemon off;"]
