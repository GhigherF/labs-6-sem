function setStatus(id, msg, ok) {
  const el = document.getElementById(id);
  el.textContent = msg;
  el.className = 'status-msg ' + (ok ? 'success' : 'error');
}

export function Post() {
  const op = document.getElementById("Op").value;
  const x = document.getElementById("X").value;
  const y = document.getElementById("Y").value;
  if (y === "" || x === "") { setStatus("Post", "Необходимо заполнить все поля", false); return; }
  fetch("https://localhost:20443/api/Save-JSON", { method: "POST", body: JSON.stringify({ op, x: Number(x), y: Number(y) }) })
    .then(r => r.json()).then(r => {
      if (r.error) setStatus("Post", r.error, false);
      else setStatus("Post", "Отправлено успешно ✓", true);
    }).catch(() => setStatus("Post", "Ошибка соединения", false));
}

export function Delete() {
  fetch("https://localhost:20443/api/Save-JSON", { method: "DELETE" }).then(r => r.json()).then(r => {
    if (r.error) setStatus("Delete", r.error, false);
    else setStatus("Delete", "Удалено успешно ✓", true);
  }).catch(() => setStatus("Delete", "Ошибка соединения", false));
}

export function Get() {
  fetch("https://localhost:20443/api/Save-JSON").then(r => r.json()).then(r => {
    if (r.error) {
      setStatus("Get", r.error, false);
      document.getElementById("results").innerHTML = "";
    } else {
      setStatus("Get", "Найдено успешно ✓", true);
      document.getElementById("results").innerHTML =
        `<p>Операция: <span>${r.op}</span></p><p>X: <span>${r.x}</span></p><p>Y: <span>${r.y}</span></p><p>Результат: <span>${r.result}</span></p>`;
    }
  }).catch(() => setStatus("Get", "Ошибка соединения", false));
}

export function Put() {
  const op = document.getElementById("PutOp").value;
  const x = document.getElementById("PutX").value;
  const y = document.getElementById("PutY").value;
  if (y === "" || x === "") { setStatus("Put", "Необходимо заполнить все поля", false); return; }
  fetch("https://localhost:20443/api/Save-JSON", { method: "PUT", body: JSON.stringify({ op, x: Number(x), y: Number(y) }) })
    .then(r => r.json()).then(r => {
      if (r.error) setStatus("Put", r.error, false);
      else setStatus("Put", "Изменено успешно ✓", true);
    }).catch(() => setStatus("Put", "Ошибка соединения", false));
}
