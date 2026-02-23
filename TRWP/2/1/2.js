  document.onload(()=>document.getElementById("Op").value = "add")
  function Post()
    {
    let op = document.getElementById("Op").value;
    let x = document.getElementById("X").value;
    let y = document.getElementById("Y").value;
    let err = document.getElementById("Post");
    console.log(x);
    console.log(y)
    console.log(op)
    console.log(JSON.stringify({"op":op,"x":x,"y":y}))
    if (y ==""||x==""){err.style.color="red";err.innerText="Необходимо заполнить все поля"}
    else {fetch("http://localhost:20000/api/Save-JSON",{method:"POST",body:JSON.stringify({"op":op,"x":Number(x),"y":Number(y)})}).
    then(x=>x.json()).then(x=>{console.log(x);
        if (x.error!=undefined) {err.style.color="red";err.innerText=x.error}else{
        err.style.color = "green";err.innerText="Отправлено успешно"}}).catch(x=>console.log(x))}
    }

function Delete()
{
    fetch("http://localhost:20000/api/Save-JSON",{method:"DELETE"}).then(x=>x.json()).then(x=>{
        if (x.error!=undefined){
       document.getElementById("Delete").style.color="red";
       document.getElementById("Delete").innerText=x.error;
}else{
    document.getElementById("Delete").style.color="green";
    document.getElementById("Delete").innerText="Удалено успешно";
}
    }).catch(x=>console.log(x))
}

function Get()
{
    fetch("http://localhost:20000/api/Save-JSON").then(x=>x.json()).then(x=>{
    let str =  document.getElementById("Get")
        if (x.error!=undefined) {
       str.innerText=x.error;
       str.style.color="red";
       document.getElementById("results").innerHTML=""        
    }        
    else
    {
       str.innerText="Найдено успешно";
       str.style.color="green";
       document.getElementById("results").innerHTML=`<p>Operation:${x.op}</p><p>X:${x.x}</p><p>Y:${x.y}</p><p>Result:${x.result}</p>`        
    }
    }).catch(x=>console.log(x));
}

function Put()
    {
    let op = document.getElementById("PutOp").value;
    let x = document.getElementById("PutX").value;
    let y = document.getElementById("PutY").value;
    let err = document.getElementById("Put");
    console.log(x);
    console.log(y)
    console.log(op)
    console.log(JSON.stringify({"op":op,"x":x,"y":y}))
    if (y ==""||x==""){err.style.color="red";err.innerText="Необходимо заполнить все поля"}
    else {fetch("http://localhost:20000/api/Save-JSON",{method:"PUT",body:JSON.stringify({"op":op,"x":Number(x),"y":Number(y)})}).
    then(x=>x.json()).then(x=>{console.log(x);
        if (x.error!=undefined) {err.style.color="red";err.innerText=x.error}else{
        err.style.color = "green";err.innerText="Измененено успешно"}}).catch(x=>console.log(x))}
    }