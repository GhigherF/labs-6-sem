let https = require('https');
let fs = require('fs');

let options = {
    key: fs.readFileSync('LAB.key'),
    cert: fs.readFileSync('LAB.crt')
};

https.createServer(options, (req, res) => {
    console.log('hello from https');
    res.writeHead(200, {'Content-Type': 'text/plain; charset=utf-8'});
    res.end('Успешно! Resource: DKD, CA: LVK');
}).listen(3443,"0.0.0.0");

console.log('Сервер запущен. Откройте в браузере: https://LAB22-DKD:3443 или https://DKD:3443');
