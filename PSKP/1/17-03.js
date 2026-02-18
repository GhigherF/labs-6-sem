const redis = require("redis");
const client = redis.createClient({url:"redis://ghigher:321QaZ451@localhost:6360"});




client.on("error", err => console.log("Redis Client Error", err));


(async ()=>{
client.connect();
client.set("incr",0);
let ops = client.multi();
for (let i =1;i<=10000;i++)
{
    ops.incr("incr");
}
let start = new Date()
await ops.exec();
console.log(`Incr: ${new Date()-start} мс`);
client.get("incr").then(x=>console.log(x));

ops = client.multi();
for (let i = 1;i<=10000;i++)
{
    ops.decr("incr");
}
start = new Date()
ops.exec();
console.log(`Decr: ${new Date()-start} мс`);
client.get("incr").then(x=>console.log(x));





await client.quit();
})();