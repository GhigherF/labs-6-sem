const redis = require("redis");
const client = redis.createClient({url:"redis://ghigher:321QaZ451@localhost:6360"});



client.connect().then(setTimeout(()=>client.quit(),500));
client.on("ready", () => {console.log("ready ")})
client.on("error", err => console.log("Redis Client Error", err));
client.on("connect",() => {console.log("connect ")});
client.on("end",()=>{console.log("end ")})

