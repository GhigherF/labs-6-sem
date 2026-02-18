const redis = require("redis");
const client = redis.createClient({url:"redis://ghigher:321QaZ451@localhost:6360"});


client.on("error", err => console.log("Redis Client Error", err));



(async() =>{
client.connect();
let ops = client.multi();
for (let i =1;i<=10000;i++)
{
    ops.hSet(`${i}`,{id:`${i}`,val:`val-${i}`})
}
let start = new Date()
await ops.exec();
console.log(`Hash set: ${new Date()-start} мс`);


ops = client.multi();
for (let i = 1;i<=10000;i++)
{
 ops.hGet(`${i}`,"val");
}
start = new Date()
await ops.exec();
console.log(`hash Get: ${new Date()-start} мс`);
console.log(await client.hGet("15","val"));

await client.quit();
})()