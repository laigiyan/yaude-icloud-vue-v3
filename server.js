var express = require('express');
var app = express();
var proxyMiddleware = require('http-proxy-middleware')
var config = require('./config')
var proxyTable = config.dev.proxyTable

app.set('port', (process.env.PORT || 8080));           //设置端口
app.use(express.static(__dirname + '/dist',{maxAge: 24*60*60*1000}));         //设置静态文件目录

// views is directory for all template files
app.set('views', __dirname + '/dist');                 //设置页面文件目录
app.set('view engine', 'ejs');                          //设置模板引擎为ejs

app.get('/', function (request, response) {
  response.render('index');
});

// proxy api requests
Object.keys(proxyTable).forEach(function (context) {
  var options = proxyTable[context]
  if (typeof options === 'string') {
    options = {target: options}
  }
  app.use(proxyMiddleware(options.filter || context, options))
});

app.get('*', function (request, response) {
  //404
  response.render('index');
});

app.listen(app.get('port'), function () {             //启动服务器，监听上面设置的端口
  console.log('Node app is running on port', app.get('port'));
});
