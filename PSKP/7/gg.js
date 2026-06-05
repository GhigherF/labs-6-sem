const JsonRPCServer = require("jsonrpc-server-http-nats");

const server = new JsonRPCServer();

let bin_validator = (param,method)=>{
  console.log('validator0',param);
  if (!Array.isArray(param)) throw new Error("Ожидается массив");
  if (param.length !=2 && (method=="div"||method=="proc")) throw new Error('Ожидается 2 значения');
  if (!isFinite(param[0])||!isFinite(param[1])) throw new Error('Ожидается число');
  return param;
}




server.on('sum',bin_validator,(params,channel,response)=>{response(null,
  params.reduce((x,count)=>count+=x))
});
server.on('mul',bin_validator,(params,channel,response)=>{response(null,
  params.reduce((x,count)=>count*=x))
});


server.on('div',bin_validator,(params,channel,response)=>{response(null,params[0]/params[1])});
server.on('proc',bin_validator,(params,channel,response)=>{response(null,(params[0]/params[1])*100)});

server.listenHttp({host:"127.0.0.1",port:3000},()=>{console.log('JSON-RPC Server REDY')});











