# 使用官方的 Node.js 16 镜像作为基础镜像
FROM node:16



ADD ./src src
ADD ./public public
ADD ./package.json  package.json





# 安装应用程序的依赖
RUN npm install


# 暴露应用程序监听的端口（如果需要，根据你的应用程序进行修改）
EXPOSE 3000

# 启动应用程序
#CMD ["npm", "start"]
RUN npm run serve
