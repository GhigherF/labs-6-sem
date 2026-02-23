const { Sequelize, where } = require('sequelize');
const fs = require('fs')
const http = require("http");
const sequelize = new Sequelize('belstu', 'nodeuser', 'StrongPass123!', {
  dialect: 'mssql',
  host: 'localhost',
  port: 1433,  
  dialectOptions: {
    options: {
      encrypt: false,
      trustServerCertificate: true
    },
    pool:{
      max:2,
      min:1,
      acquire:30000,
      idle:10000
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
class Teacher extends Model{};



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
Teacher.init({
  teacher:{type:Sequelize.STRING,allowNull:false,primaryKey:true},
  teacher_name:{type:Sequelize.STRING,allowNull:false},
  pulpit:{type:Sequelize.STRING,allowNull:false,references:{model:Pulpit,key:"pulpit"}}
},{
sequelize,
modelName:"Teacher",
tableName:"Teacher",
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
else if (request.url == "/api/teachers"){
response.writeHead(200,{"Content-Type":"application/json; charset=utf-8"});
let Teachers =[];
await Teacher.findAll().then(teachers=>teachers.map(teacher=> Teachers.push(teacher.dataValues)));  
Teachers.map(teacher=>{
  teacher.teacher =teacher.teacher.trim();
  teacher.pulpit = teacher.pulpit.trim();
});
console.log(Teachers);
response.end(JSON.stringify(Teachers))
}
else if(request.url == "/")
{
 let file = fs.readFileSync("index.html");
 response.writeHead(200, {"Content-Type":"text/html; charset=utf-8"}); 
 response.end(file); 
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
    else if (request.url == "/api/teachers")
    {
      Teacher.create(data).then(teacher =>{
      teacher.dataValues.teacher =teacher.dataValues.teacher.trim();
      teacher.dataValues.teacher_name =teacher.dataValues.teacher_name.trim();
      teacher.dataValues.pulpit =teacher.dataValues.pulpit.trim();
      response.writeHead(201, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify(teacher.dataValues))})
      .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
      response.end(JSON.stringify({"error":err.message.toString()})
    )})}
  else
  {
    response.writeHead(404, {"Content-Type":"application/json; charset=utf-8"});
    response.end(JSON.stringify({"error":"Неправильный URI"}));
  };





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
    else if (path == "api/pulpits")
    {
        Pulpit.destroy({where:{pulpit:param}}).then((count)=>{
          if (count==0)
          {
            response.writeHead(400, {"Content-type":"application/json"});
            response.end(JSON.stringify({"error":"Кафедра не найдена"}))
          }
          else {
        response.writeHead(202,{"Content-type":"text/plain"});
        response.end("Удалено успешно")}})
        .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
        response.end(JSON.stringify({"error":err.message.toString()}) )})
    }
    else if (path == "api/subjects")
    {
        Subject.destroy({where:{subject:param}}).then((count)=>{
          if (count==0)
          {
            response.writeHead(400, {"Content-type":"application/json"});
            response.end(JSON.stringify({"error":"Предмет не найдена"}))
          }
          else {
        response.writeHead(202,{"Content-type":"text/plain"});
        response.end("Удалено успешно")}})
        .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
        response.end(JSON.stringify({"error":err.message.toString()}) )})
    }
    else if (path == "api/auditoriumstypes")
    {
        Auditorium_type.destroy({where:{auditorium_type:param}}).then((count)=>{
          if (count==0)
          {
            response.writeHead(400, {"Content-type":"application/json"});
            response.end(JSON.stringify({"error":"Неверный тип аудитории"}))
          }
          else {
        response.writeHead(202,{"Content-type":"text/plain"});
        response.end("Удалено успешно")}})
        .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
        response.end(JSON.stringify({"error":err.message.toString()}) )})
    }
    else if (path == "api/auditoriums")
    {
        Auditorium.destroy({where:{auditorium:param}}).then((count)=>{
          if (count==0)
          {
            response.writeHead(400, {"Content-type":"application/json"});
            response.end(JSON.stringify({"error":"Неверная аудитория"}))
          }
          else {
        response.writeHead(202,{"Content-type":"text/plain"});
        response.end("Удалено успешно")}})
        .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
        response.end(JSON.stringify({"error":err.message.toString()}) )})
    }
    else if (path == "api/teachers")
    {
        Teacher.destroy({where:{teacher:param}}).then((count)=>{
          if (count==0)
          {
            response.writeHead(400, {"Content-type":"application/json"});
            response.end(JSON.stringify({"error":"Неверный преподаватель"}))
          }
          else {
        response.writeHead(202,{"Content-type":"application/json"});
        response.end(JSON.stringify({"message":"Удалено успешно"}))
      }})
        .catch(err=>{response.writeHead(400, {"Content-Type":"application/json; charset=utf-8"});
        response.end(JSON.stringify({"error":err.message.toString()}) )})
    }
  else
  {
    response.writeHead(404, {"Content-Type":"application/json; charset=utf-8"});
    response.end(JSON.stringify({"error":"Неправильный URI"}));
  };

  }
}
async function PutHandle(request, response) {
  let param;
  if ((param = decodeURIComponent(request.url).split('/')[3]) == undefined) {
    response.writeHead(200, {"Content-type": "application/json"});
    response.end(JSON.stringify({"error": "неверный URI"}));
    return;
  }
  
  let data = "";
  let path = `${request.url.split('/')[1]}/${request.url.split('/')[2]}`;
  
  request.on("data", chunk => data += chunk);
  request.on("end", () => {
    data = JSON.parse(data);
    console.log(data);
    
    if (path == "api/faculties") {
      Faculty.update(data, {where: {faculty: param}}).then((count) => {
        if (count == 0) {
          response.writeHead(400, {"Content-type": "text/plain"});
          response.end("Не найдено ни одной строки для обновления");
        } else {
          data.faculty = data.faculty.trim();
          response.writeHead(201, {"Content-Type": "application/json; charset=utf-8"}); 
          response.end(JSON.stringify({"faculty":data.faculty,"faculty_name":data.faculty_name}));
        }
      })
      .catch(err => {
        response.writeHead(400, {"Content-Type": "application/json; charset=utf-8"});
        response.end(JSON.stringify({"error": err.message.toString()}
      ));
});}   
else if (path == "api/pulpits") {
      Pulpit.update(data, {where: {pulpit: param}}).then((count) => {
        if (count == 0) {
          response.writeHead(400, {"Content-type": "text/plain"});
          response.end("Не найдено ни одной строки для обновления");
        } else {
          data.pulpit = data.pulpit.trim();
          data.faculty = data.faculty.trim();
          response.writeHead(201, {"Content-Type": "application/json; charset=utf-8"}); 
          response.end(JSON.stringify({"pulpit":data.pulpit,"faculty":data.faculty,"pulpit_name":data.pulpit_name}));
        }
      })
      .catch(err => {
        response.writeHead(400, {"Content-Type": "application/json; charset=utf-8"});
        response.end(JSON.stringify({"error": err.message.toString()}
      ));
});}
else if (path == "api/subjects") {
      Subject.update(data, {where: {subject: param}}).then((count) => {
        if (count == 0) {
          response.writeHead(400, {"Content-type": "text/plain"});
          response.end("Не найдено ни одной строки для обновления");
        } else {
          data.subject = data.subject.trim();
          data.pulpit = data.pulpit.trim();
          response.writeHead(201, {"Content-Type": "application/json; charset=utf-8"}); 
          response.end(JSON.stringify({"subject":data.subject,"subject_name":data.subject_name,"pulpit":data.pulpit}));
        }
      })
      .catch(err => {
        response.writeHead(400, {"Content-Type": "application/json; charset=utf-8"});
        response.end(JSON.stringify({"error": err.message.toString()}
      ));
});}
else if (path == "api/auditoriumstypes") {
      Auditorium_type.update(data, {where: {auditorium_type: param}}).then((count) => {
        if (count == 0) {
          response.writeHead(400, {"Content-type": "text/plain"});
          response.end("Не найдено ни одной строки для обновления");
        } else {
          data.auditorium_type = data.auditorium_type.trim();
          response.writeHead(201, {"Content-Type": "application/json; charset=utf-8"}); 
          response.end(JSON.stringify({"auditorium_type":data.auditorium_type,"auditorium_typename":data.auditorium_typename}));
        }
      })
      .catch(err => {
        response.writeHead(400, {"Content-Type": "application/json; charset=utf-8"});
        response.end(JSON.stringify({"error": err.message.toString()}
      ));
});}
else if (path == "api/auditoriums") {
      Auditorium.update(data, {where: {auditorium: param}}).then((count) => {
        if (count == 0) {
          response.writeHead(400, {"Content-type": "text/plain"});
          response.end("Не найдено ни одной строки для обновления");
        } else {
          data.auditorium = data.auditorium.trim();
          data.auditorium_name = data.auditorium_name.trim();
          data.auditorium_type = data.auditorium_type.trim();
          response.writeHead(201, {"Content-Type": "application/json; charset=utf-8"}); 
          response.end(JSON.stringify({"auditorium":data.auditorium,"auditorium_name":data.auditorium_name,"auditorium_capacity":data.auditorium_capacity,"auditorium_type:":data.auditorium_type}));
        }
      })
      .catch(err => {
        response.writeHead(400, {"Content-Type": "application/json; charset=utf-8"});
        response.end(JSON.stringify({"error": err.message.toString()}
      ));
});}
else if (path == "api/teachers") {
      Teacher.update(data, {where: {teacher: param}}).then((count) => {
        if (count == 0) {
          response.writeHead(400, {"Content-type": "application/json"});
          response.end(JSON.stringify({"error":"Не найдено ни одной строки для обновления"}));
        } else {
          data.teacher = data.teacher.trim();
          data.pulpit = data.pulpit.trim();
          response.writeHead(201, {"Content-Type": "application/json; charset=utf-8"}); 
          response.end(JSON.stringify({"teacher":data.teacher,"teacher_name":data.teacher_name,"pulpit":data.pulpit}));
        }
      })
      .catch(err => {
        response.writeHead(400, {"Content-Type": "application/json; charset=utf-8"});
        response.end(JSON.stringify({"error": err.message.toString()}
      ));
});}
}); 
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
    case "PUT":PutHandle(request, response);
  }
   
});}


sequelize.authenticate()
  .then(() => {
    console.log('Успешное подключение!')
    let server = http.createServer();
    server.listen(2280);
    RequestHandler(server);    
  })
  .catch(err => {console.error('Ошибка подключения:', err);sequelize.close()});


  


