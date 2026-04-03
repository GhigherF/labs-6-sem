"use client"
import { Post, Put, Delete, Get } from "@/scripts/2"
import { useRef } from "react"

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

function boom(e) {
  const r = e.currentTarget.getBoundingClientRect();
  confetti(r.left + r.width/2, r.top);
  e.currentTarget.style.transform = 'scale(1.2) rotate(-3deg)';
  setTimeout(() => e.currentTarget.style.transform = '', 200);
}

export default function Home() {
  return (
    <main>
      <h1 className="page-title">⚡ API CONSOLE</h1>

      <div className="card card-get">
        <h1>📡 GET</h1>
        <p id="Get" className="status-msg"></p>
        <div id="results"></div>
        <div className="form-row" style={{marginTop:'12px'}}>
          <button className="btn-get" onClick={(e) => { boom(e); Get(); }}>GET</button>
        </div>
      </div>

      <div className="card card-post">
        <h1>📤 POST</h1>
        <p id="Post" className="status-msg"></p>
        <div className="form-row">
          <input type="number" id="X" placeholder="X"/>
          <input type="number" id="Y" placeholder="Y"/>
          <select id="Op">
            <option>add</option><option>sub</option><option>mul</option><option>div</option>
          </select>
          <button className="btn-post" onClick={(e) => { boom(e); Post(); }}>POST</button>
        </div>
      </div>

      <div className="card card-put">
        <h1>✏️ PUT</h1>
        <p id="Put" className="status-msg"></p>
        <div className="form-row">
          <input type="number" id="PutX" placeholder="X"/>
          <input type="number" id="PutY" placeholder="Y"/>
          <select id="PutOp">
            <option>add</option><option>sub</option><option>mul</option><option>div</option>
          </select>
          <button className="btn-put" onClick={(e) => { boom(e); Put(); }}>PUT</button>
        </div>
      </div>

      <div className="card card-delete">
        <h1>💥 DELETE</h1>
        <p id="Delete" className="status-msg"></p>
        <div className="form-row">
          <button className="btn-delete" onClick={(e) => { boom(e); Delete(); }}>DELETE</button>
        </div>
      </div>

      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img className="ricardo ricardo-left"  src="https://media.tenor.com/NjOsRH-9mukAAAAi/ricardo-milos.gif" alt="ricardo"/>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img className="ricardo ricardo-right" src="https://media.tenor.com/NjOsRH-9mukAAAAi/ricardo-milos.gif" alt="ricardo"/>
    </main>
  );
}
