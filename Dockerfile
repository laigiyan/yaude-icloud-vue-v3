# 使用官方的 Node.js 16 镜像作为基础镜像
FROM node:18.15.0 as nodejs


RUN mkdir code
workdir /code
COPY ./* ./
COPY ./src ./src
COPY ./public ./public

# 安装应用程序的依赖
RUN yarn install 
RUN npm -v
RUN yarn -v

RUN npm run build:dev


FROM registry.access.redhat.com/ubi8/nginx-118
MAINTAINER buhuaqiang@163.com
ENV LANG en_US.UTF-8

EXPOSE 80



