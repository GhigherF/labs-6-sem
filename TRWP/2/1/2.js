document.onload = () => document.getElementById("Op").value = "add";

const COLORS = ['#ff00ff','#00f5ff','#00ff88','#ff6600','#ffff00','#ff4466','#aa00ff'];

function confetti(x, y, count = 60) {
  for (let i = 0; i < count; i++) {
    const el = document.createElement('div');
    el.className = 'confetti-piece';
    el.style.cssText = `
      left:${x + (Math.random()-0.5)*200}px;
      top:${y}px;
      background:${COLORS[Math.floor(Math.random()*COLORS.length)]};
      width:${6+Math.random()*10}px;
      height:${6+Math.random()*10}px;
      border-radius:${Math.random()>0.5?'50%':'2px'};
      animation-duration:${1+Math.random()*2}s;
      animation-delay:${Math.random()*0.5}s;
    `;
    document.body.appendChild(el);
    el.addEventListener('animationend', () => el.remove());
  }
}

function shakeBtn(btn) {
  btn.style.transform = 'scale(1.2) rotate(-3deg)';
  setTimeout(() => btn.style.transform = '', 200);
}

function setStatus(id, msg, ok) {
  const el = document.getElementById(id);
  el.textContent = msg;
  el.className = ok ? 'success' : 'error';
}

function Post() {
  const op = document.getElementById("Op").value;
  const x = document.getElementById("X").value;
  const y = document.getElementById("Y").value;
  const btn = document.querySelector('.btn-post');
  if (y === "" || x === "") { setStatus("Post", "Необходимо заполнить все поля", false); return; }
  shakeBtn(btn);
  fetch("https://localhost:20443/api/Save-JSON", { method: "POST", body: JSON.stringify({ op, x: Number(x), y: Number(y) }) })
    .then(r => r.json()).then(r => {
      if (r.error) { setStatus("Post", r.error, false); }
      else { setStatus("Post", "Отправлено успешно ✓", true); confetti(btn.getBoundingClientRect().left + 50, btn.getBoundingClientRect().top); }
    }).catch(() => setStatus("Post", "Ошибка соединения", false));
}

function Delete() {
  const btn = document.querySelector('.btn-delete');
  shakeBtn(btn);
  fetch("https://localhost:20443/api/Save-JSON", { method: "DELETE" }).then(r => r.json()).then(r => {
    if (r.error) { setStatus("Delete", r.error, false); }
    else { setStatus("Delete", "Удалено успешно ✓", true); confetti(btn.getBoundingClientRect().left + 50, btn.getBoundingClientRect().top, 80); }
  }).catch(() => setStatus("Delete", "Ошибка соединения", false));
}

function Get() {
  const btn = document.querySelector('.btn-get');
  shakeBtn(btn);
  fetch("https://localhost:20443/api/Save-JSON").then(r => r.json()).then(r => {
    const str = document.getElementById("Get");
    const res = document.getElementById("results");
    if (r.error) { setStatus("Get", r.error, false); res.innerHTML = ""; }
    else {
      setStatus("Get", "Найдено успешно ✓", true);
      res.innerHTML = `<p>Операция: <span>${r.op}</span></p><p>X: <span>${r.x}</span></p><p>Y: <span>${r.y}</span></p><p>Результат: <span>${r.result}</span></p>`;
      confetti(btn.getBoundingClientRect().left + 50, btn.getBoundingClientRect().top);
    }
  }).catch(() => setStatus("Get", "Ошибка соединения", false));
}

function Put() {
  const op = document.getElementById("PutOp").value;
  const x = document.getElementById("PutX").value;
  const y = document.getElementById("PutY").value;
  const btn = document.querySelector('.btn-put');
  if (y === "" || x === "") { setStatus("Put", "Необходимо заполнить все поля", false); return; }
  shakeBtn(btn);
  fetch("https://localhost:20443/api/Save-JSON", { method: "PUT", body: JSON.stringify({ op, x: Number(x), y: Number(y) }) })
    .then(r => r.json()).then(r => {
      if (r.error) { setStatus("Put", r.error, false); }
      else { setStatus("Put", "Изменено успешно ✓", true); confetti(btn.getBoundingClientRect().left + 50, btn.getBoundingClientRect().top); }
    }).catch(() => setStatus("Put", "Ошибка соединения", false));
}
