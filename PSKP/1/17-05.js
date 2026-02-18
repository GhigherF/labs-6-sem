const redis = require("redis");
const sub = redis.createClient({url:"redis://ghigher:321QaZ451@localhost:6360"});
const pub = redis.createClient({url:"redis://ghigher:321QaZ451@localhost:6360"});

(async ()=>{
await sub.connect();
await pub.connect()

sub.on("error", err => console.log("Redis Client Error", err));
pub.on("error", err => console.log("Redis Client Error", err));


sub.on("subscribe",(channel,count)=>{console.log("subscribe:"," channel  = ",channel,"count= ",count)});

sub.subscribe("channel-01",message => console.log("Message: ",message ));
setTimeout(()=>{sub.unsubscribe();sub.quit()},5000);

pub.publish("channel-01"," from pub message 1");
pub.publish("channel-01"," from pub message 2");

setTimeout(()=>pub.quit(),5000)

})()
