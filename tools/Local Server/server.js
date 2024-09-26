const express = require('express');
const fs = require('fs');
const app = express();
const PORT = 3000;
const winston = require('winston');  
require('winston-daily-rotate-file');
  
const logDir = 'logs';  
  
// 确保日志目录存在  
if (!fs.existsSync(logDir)) {  
    fs.mkdirSync(logDir);  
}  
  
const transport = new winston.transports.DailyRotateFile({  
    filename: `${logDir}/app-%DATE%.log`,  
    datePattern: 'YYYY-MM-DD',  
    zippedArchive: true,  
    maxSize: '20m',  
    maxFiles: '14d',  
    format: winston.format.combine(  
        winston.format.timestamp(),  
        winston.format.printf(({ timestamp, level, message }) => `${timestamp} ${level}: ${message}`)  
    ),  
});  
  
const logger = winston.createLogger({  
    transports: [  
        transport,  
        new winston.transports.Console({  
            format: winston.format.simple(),  
        }),  
    ],  
});  
  

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.get('/about', (req, res) => {
    res.send('This is the about page');
});
  
app.use(express.json()); // 支持 JSON 编码的请求体
app.use(express.urlencoded({ extended: true })); // 支持 URL 编码的请求体
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header(
        "Access-Control-Allow-Headers",
        "Origin, X-Requested-With, Content-Type, Accept"
    );
    next();
});
  
app.post('/log', (req, res) => {  
  const message = req.body.message;  
  logger.info(`Received log message: ${message}`);  
  res.status(200).send('Message logged');  
});  

app.listen(PORT, () => {  
  logger.info(`Server running on http://localhost:${PORT}`);  
});
  