const express = require('express')
const app = express()
const  {createProxyMiddleware}  = require('http-proxy-middleware');

app.use('/yaude-boot', createProxyMiddleware({
  // 代理跨域目标接口 TAP 特殊写法，需要取ingress local url 而非简单的取服务名
  target: 'http://yaude-icloud-java.develop-ns.svc.cluster.local/',
  //changeOrigin如果设置成false：请求头中host仍然是浏览器发送过来的host；
  //如果设置成true：发送请求头中host会设置成target。
  //tips：这个改变并不能在network里直观显示
  changeOrigin: true,
}));
const port = 8080 // 自定义端口号（不要与已存在端口冲突）
app.use(express.static('dist')) // dist 是项目的打包资源路径，一般为根目录下dist
app.listen(port, () => console.log(`服务器 ${port} 开启成功!`))
