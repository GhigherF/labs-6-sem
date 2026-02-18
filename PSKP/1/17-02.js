const redis = require("redis");
const client = redis.createClient({url:"redis://ghigher:321QaZ451@localhost:6360"});




client.on("error", err => console.log("Redis Client Error", err));

(async ()=>{
client.connect();
let ops = client.multi(); 
for (let i =1;i<=10000;i++)
{
 ops.set(`${i}`,`set${i}`)
}
let start = new Date()
await ops.exec();
console.log(`Set: ${new Date()-start} мс`);

client.get("10000").then(x=>console.log(x));


ops = client.multi();
for (let i = 1;i<=10000;i++)
{
  ops.get(`${i}`)
}
start = new Date()
ops.exec();
console.log(`Get: ${new Date()-start} мс`);

ops=client.multi();
for (let i = 1;i<=10000;i++)
{
   ops.del(`${i}`)
    
}
start = new Date()
await ops.exec();
console.log(`Del: ${new Date()-start} мс`);
client.get("10000").then(x=>console.log(x));




await client.quit();
})()