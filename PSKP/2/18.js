const { Sequelize } = require('sequelize');
const http = require("http");
const sequelize = new Sequelize('belstu', 'nodeuser', 'StrongPass123!', {
  dialect: 'mssql',
  host: 'localhost',
  port: 1433,  
  dialectOptions: {
    options: {
      encrypt: false,
      trustServerCertificate: true
    }
  },
  logging: false
});


const Model = Sequelize.Model;
class Faculty extends Model{}; 
class Pulpit extends Model{};
class Subject extends Model{};
class Auditorium extends Model{};
class Auditorium_type extends Model{};



Faculty.init({
  faculty:{type:Sequelize.STRING,allowNull:false,primaryKey:true},
  faculty_name:{type:Sequelize.STRING,allowNull:false}
},{
sequelize,
modelName:"Faculty",
tableName:"Faculty",
timestamps:false
})
Pulpit.init({
  pulpit:{type:Sequelize.STRING,allowNull:false,primaryKey:true},
  pulpit_name:{type:Sequelize.STRING,allowNull:false},
  faculty:{type:Sequelize.STRING,allowNull:false,references:{model:Faculty,key:"faculty"}}
},{
sequelize,
modelName:"Pulpit",
tableName:"Pulpit",
timestamps:false
})
Subject.init({
  subject:{type:Sequelize.STRING,allowNull:false,primaryKey:true},
  subject_name:{type:Sequelize.STRING,allowNull:false},
  pulpit:{type:Sequelize.STRING,allowNull:false,references:{model:Pulpit,key:"pulpit"}}
},{
sequelize,
modelName:"Subject",
tableName:"Subject",
timestamps:false
})
Auditorium_type.init({
  auditorium_type:{type:Sequelize.STRING,allowNull:false,primaryKey:true},
  auditorium_typename:{type:Sequelize.STRING,allowNull:false}
},{
sequelize,
modelName:"Auditorium_type",
tableName:"Auditorium_type",
timestamps:false
})
Auditorium.init({
  auditorium:{type:Sequelize.STRING,allowNull:false,primaryKey:true},
  auditorium_name:{type:Sequelize.STRING,allowNull:false},
  auditorium_capacity:{type:Sequelize.INTEGER,allowNull:false},
  auditorium_type:{type:Sequelize.STRING,allowNull:false,references:{model:Auditorium_type,key:"auditorium_type"}}
},{
sequelize,
modelName:"Auditorium",
tableName:"Auditorium",
timestamps:false
})

async function GetHandle(request,response)
{
if (request.url == "/api/faculties"){
response.writeHead(200,{"Content-Type":"application/json; charset=utf-8"});
let Faculties =[];
await Faculty.findAll().then(faculties=>faculties.map(faculty=> Faculties.push(faculty.dataValues)));  
Faculties.map(faculty=>faculty.faculty = faculty.faculty.trim());
console.log(Faculties);
response.end(JSON.stringify(Faculties))
}
else if (request.url == "/api/pulpits"){
response.writeHead(200,{"Content-Type":"application/json; charset=utf-8"});
let Pulpits =[];
await Pulpit.findAll().then(pulpits=>pulpits.map(pulpit=> Pulpits.push(pulpit.dataValues)));  
Pulpits.map(pulpit=>{
  pulpit.pulpit = pulpit.pulpit.trim();
  pulpit.faculty = pulpit.faculty.trim();
});
console.log(Pulpits);
response.end(JSON.stringify(Pulpits))
}
else if (request.url == "/api/subjects"){
response.writeHead(200,{"Content-Type":"application/json; charset=utf-8"});
let Subjects =[];
await Subject.findAll().then(subjects=>subjects.map(subject=> Subjects.push(subject.dataValues)));  
Subjects.map(subject=>{
  subject.pulpit = subject.pulpit.trim();
  subject.subject = subject.subject.trim();
});
console.log(Subjects);
response.end(JSON.stringify(Subjects))
}
else if (request.url == "/api/auditoriumstypes"){
response.writeHead(200,{"Content-Type":"application/json; charset=utf-8"});
let Atypes =[];
await Auditorium_type.findAll().then(atypes=>atypes.map(Atype=> Atypes.push(Atype.dataValues)));  
Atypes.map(atype=>{
  atype.auditorium_type = atype.auditorium_type.trim();
});
console.log(Atypes);
response.end(JSON.stringify(Atypes))
}
else if (request.url == "/api/auditoriums"){
response.writeHead(200,{"Content-Type":"application/json; charset=utf-8"});
let Auditoriums =[];
await Auditorium.findAll().then(auditoriums=>auditoriums.map(auditorium=> Auditoriums.push(auditorium.dataValues)));  
Auditoriums.map(auditorium=>{
  auditorium.auditorium_type =auditorium.auditorium_type.trim();
  auditorium.auditorium = auditorium.auditorium.trim();
});
console.log(Auditoriums);
response.end(JSON.stringify(Auditoriums))
}
else
  {
    response.writeHead(404, {"Content-Type":"application/json; charset=utf-8"});
    response.end(JSON.stringify({"error":"Неправильный URI"}));
  };
}
async function PostHandle(request,response)
{
  let data = "";
  request.on("data",chunk=>data+=chunk);
  
  request.on("end",()=>
  {
    data = JSON.parse(data);
    console.log(data);

    if (request.url == "/api/faculties")
    {
      Faculty.create(data).then(faculty =>{
      faculty.dataValues.faculty = faculty.dataValues.faculty.trim();
      response.writeHead(201, {"Content-Type":"application/json; charset=utf-8"}); 
      response.end(JSON.stringify(faculty.dataValues))})
      .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify({"error":err.message.toString()})
    )})}
    else if (request.url == "/api/pulpits")
    {
      Pulpit.create(data).then(pulpit =>{
      pulpit.dataValues.pulpit = pulpit.dataValues.pulpit.trim();
      pulpit.dataValues.faculty = pulpit.dataValues.faculty.trim();
      response.writeHead(201, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify(pulpit.dataValues))})
      .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify({"error":err.message.toString()})
    )})}
    else if (request.url == "/api/subjects")
    {
      Subject.create(data).then(subject =>{
      subject.dataValues.subject = subject.dataValues.subject.trim();
      subject.dataValues.pulpit = subject.dataValues.pulpit.trim();
      response.writeHead(201, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify(subject.dataValues))})
      .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify({"error":err.message.toString()})
    )})}
    else if (request.url == "/api/auditoriumstypes")
    {
      Auditorium_type.create(data).then(atype =>{
      atype.dataValues.auditorium_type = atype.dataValues.auditorium_type.trim();
      response.writeHead(201, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify(atype.dataValues))})
      .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify({"error":err.message.toString()})
    )})}
    else if (request.url == "/api/auditoriums")
    {
      Auditorium.create(data).then(auditorium =>{
      auditorium.dataValues.auditorium =auditorium.dataValues.auditorium.trim();
      auditorium.dataValues.auditorium_type =auditorium.dataValues.auditorium_type.trim();
      auditorium.dataValues.auditorium_name =auditorium.dataValues.auditorium_name.trim();
      response.writeHead(201, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify(auditorium.dataValues))})
      .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify({"error":err.message.toString()})
    )})}





  })
}
async function DeleteHandle(request,response)
{
  let param;
  if ((param = decodeURIComponent(request.url).split('/')[3])==undefined)
  {
    response.writeHead(200,{"Content-type":"application/json"});
    response.end(JSON.stringify({"error":"неверный URI"}))
  }
  else 
  {
   let path = `${request.url.split('/')[1]}/${request.url.split('/')[2]}`;
  console.log(path)
   if (path == "api/faculties")
   {
        Faculty.destroy({where:{faculty:param}}).then((count)=>{
          if (count==0)
          {
            response.writeHead(400, {"Content-type":"application/json"});
            response.end(JSON.stringify({"error":"Код факультета не найден"}))
          }
          else {
        response.writeHead(202,{"Content-type":"text/plain"});
        response.end("Удалено успешно")}})
        .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
        response.end(JSON.stringify({"error":err.message.toString()}) )})
    }
  }
}



async function RequestHandler(server)
{
await sequelize.sync({force:false}); 
server.on("request",async (request,response)=>
{
   switch(request.method)
   {
    case "GET": GetHandle(request,response);break;
    case "POST": PostHandle(request,response);break;
    case "DELETE": DeleteHandle(request, response);break;
  }
   
});}


sequelize.authenticate()
  .then(() => {
    console.log('✅ Подключение к SQL Server Express успешно!')
    let server = http.createServer();
    server.listen(2280);
    RequestHandler(server);    
  })
  .catch(err => {console.error('❌ Ошибка подключения:', err);sequelize.close()});


  


