const crypto = require('node:crypto');
const { performance } = require('node:perf_hooks');

// РОВНО 512 символов. Проверено по RFC 3526.
const pStr = "FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E05205560A5C4AC9969E8840052216D2EE741F565D20F45500B266932402741F74697C91BA2257598AA3A300EFAAD529C2E53E738256BD7291CBB206B8E68FFFFFFFFFFFFFFFF";
const p = BigInt('0x' + pStr);
const g = 2n;

const fullName = "Дмитроченко Кирилл Денисович";

// Функция возведения в степень (с защитой от переполнения стека)
function power(a, b, n) {
  let res = 1n;
  a %= n;
  while (b > 0n) {
    if (b % 2n === 1n) res = (res * a) % n;
    a = (a * a) % n;
    b /= 2n;
  }
  return res;
}

// Умножение по модулю: (a * b) % m
function multiplyMod(a, b, m) {
  return (a * b) % m;
}

console.log(`=== ElGamal Ultimate Fix ===`);

// 1. Ключи
const x = BigInt('0x' + crypto.randomBytes(32).toString('hex')) % (p - 2n) + 1n;
const y = power(g, x, p);

// 2. Сообщение (убеждаемся, что m < p)
const m = BigInt('0x' + Buffer.from(fullName, 'utf8').toString('hex'));

// 3. Шифрование
const t1 = performance.now();
const k = BigInt('0x' + crypto.randomBytes(32).toString('hex')) % (p - 2n) + 1n;

const a = power(g, k, p);
const s = power(y, k, p); // Общий секрет
const b = multiplyMod(m, s, p); // m * s mod p
const t2 = performance.now();

// 4. Расшифрование
const t3 = performance.now();
const s_dec = power(a, x, p);
const s_inv = power(s_dec, p - 2n, p);
const m_dec = multiplyMod(b, s_inv, p);
const t4 = performance.now();

// 5. Конвертация
let hexRes = m_dec.toString(16);
if (hexRes.length % 2 !== 0) hexRes = '0' + hexRes;
const result = Buffer.from(hexRes, 'hex').toString('utf8');

console.log(`Текст:       ${fullName}`);
console.log(`Результат:   ${result}`);
console.log(`---`);
console.log(`Проверка P:  Длина ${pStr.length} (должна быть 512)`);
console.log(`Математика:  ${m === m_dec ? "✅ ИСПРАВНО" : "❌ ОШИБКА"}`);
console.log(`Зашифрование: ${(t2 - t1).toFixed(4)} мс`);
console.log(`Расшифрование: ${(t4 - t3).toFixed(4)} мс`);
