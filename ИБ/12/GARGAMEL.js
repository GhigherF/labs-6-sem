const crypto = require('crypto');
const readline = require('readline');

// --- МАТЕМАТИЧЕСКИЕ ФУНКЦИИ (BigInt) ---

function modPow(base, exp, modulus) {
  if (modulus === 1n) return 0n;
  let result = 1n;
  base = base % modulus;
  while (exp > 0n) {
    if (exp % 2n === 1n) result = (result * base) % modulus;
    exp = exp / 2n;
    base = (base * base) % modulus;
  }
  return result;
}

function modInverse(a, m) {
  let m0 = m, t, q;
  let x0 = 0n, x1 = 1n;
  if (m === 1n) return 0n;
  while (a > 1n) {
    q = a / m;
    t = m;
    m = a % m;
    a = t;
    t = x0;
    x0 = x1 - q * x0;
    x1 = t;
  }
  if (x1 < 0n) x1 += m0;
  return x1;
}

function gcd(a, b) {
  while (b !== 0n) {
    let t = b;
    b = a % b;
    a = t;
  }
  return a;
}

function randomBigInt(min, max) {
  const range = max - min;
  const byteLength = Math.ceil(range.toString(2).length / 8);
  while (true) {
    const bytes = crypto.randomBytes(byteLength);
    let hex = bytes.toString('hex');
    let num = BigInt('0x' + hex);
    if (num < range) return min + num;
  }
}

// Используем стандартный SHA-256
function getHashBigInt(messageBuffer) {
  const hashHex = crypto.createHash('sha512').update(messageBuffer).digest('hex');
  return BigInt('0x' + hashHex);
}

// --- ИНТЕРФЕЙС И ЛОГИКА ПРИЛОЖЕНИЯ ---

function printHeader(title) {
  console.log("\n" + "=".repeat(60));
  console.log(` ${title} `.padStart(30 + Math.floor(title.length / 2)).padEnd(60, "="));
  console.log("=".repeat(60));
}

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

rl.question('Введите сообщение для подписания (M0): ', (messageText) => {
  const M0 = Buffer.from(messageText, 'utf-8');

  printHeader("1. Генерация ключевых параметров Эль-Гамаля");

  // НАДЕЖНОЕ 1024-битное простое число RFC 2409 (Группа 2)
  // Оно гарантированно больше любого хэша SHA-256, математика сойдется идеально!
  const p = BigInt("0xFFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE65381FFFFFFFFFFFFFFFFn".replace('n', ''));
  const g = 2n;
  const pMinus1 = p - 1n;

  console.log(`Параметр p (1024 бит): ${p.toString().slice(0, 40)}...`);
  console.log(`Параметр g: ${g}`);

  let start = process.hrtime.bigint();

  const x = randomBigInt(2n, pMinus1);
  const y = modPow(g, x, p);

  let end = process.hrtime.bigint();
  const keyGenTime = Number(end - start) / 1e9;

  console.log(`[OK] Ключи сгенерированы.`);
  console.log(`Тайный ключ x: ${x.toString().slice(0, 30)}...`);
  console.log(`Открытый ключ y: ${y.toString().slice(0, 30)}...`);
  console.log(`Время генерации ключей: ${keyGenTime.toFixed(4)} сек.`);

  printHeader("2. Генерация ЭЦП (Формулы 10.5 и 10.6)");

  start = process.hrtime.bigint();

  const h = getHashBigInt(M0);
  console.log(`Хэш сообщения H(M0): ${h.toString().slice(0, 40)}...`);

  let k;
  while (true) {
    k = randomBigInt(2n, pMinus1);
    if (gcd(k, pMinus1) === 1n) break;
  }

  // Формула (10.5): a = g^k mod p
  const a = modPow(g, k, p);

  // Формула (10.6): b = (h - x*a) * k^(-1) mod (p-1)
  const kInverse = modInverse(k, pMinus1);

  const xa = (x * a) % pMinus1;
  const h_reduced = h % pMinus1;

  // Безопасное вычитание в кольце вычетов
  let target = (h_reduced - xa) % pMinus1;
  if (target < 0n) {
    target += pMinus1;
  }

  const b = (target * kInverse) % pMinus1;

  end = process.hrtime.bigint();
  const signTime = Number(end - start) / 1e9;

  console.log(`[OK] Подпись S = {a, b} успешно создана.`);
  console.log(`Компонент a: ${a.toString().slice(0, 40)}...`);
  console.log(`Компонент b: ${b.toString().slice(0, 40)}...`);
  console.log(`Время генерации подписи: ${signTime.toFixed(6)} сек.`);

  printHeader("3. Верификация ЭЦП (Формула 10.7)");
  console.log("[...] Проверяем равенство: (y^a * a^b) mod p == g^h mod p");

  start = process.hrtime.bigint();

  const h_rec = getHashBigInt(M0);

  // Левая часть уравнения (10.7): (y^a * a^b) mod p
  const leftPart1 = modPow(y, a, p);
  const leftPart2 = modPow(a, b, p);
  const leftSide = (leftPart1 * leftPart2) % p;

  // Правая часть уравнения (10.7): g^h mod p
  const rightSide = modPow(g, h_rec, p);

  const isValid = (leftSide === rightSide);

  end = process.hrtime.bigint();
  const verifyTime = Number(end - start) / 1e9;

  console.log(`Левая часть (y^a * a^b mod p): ${leftSide.toString().slice(0, 30)}...`);
  console.log(`Правая часть (g^h mod p):      ${rightSide.toString().slice(0, 30)}...`);

  if (isValid) {
    console.log("\n[ВЕРИФИКАЦИЯ УСПЕШНА] Равенство выполняется! Подпись верна.");
  } else {
    console.log("\n[ВНИМАНИЕ]  Равенство НЕ выполняется! Подпись подделана.");
  }
  console.log(`Время верификации подписи: ${verifyTime.toFixed(6)} сек.`);

  printHeader("4. Тест на компрометацию (Модификация сообщения)");
  console.log("Изменяем текст сообщения...");

  const fakedM0 = Buffer.from(messageText + " исправлено злоумышленником", 'utf-8');
  const h_faked = getHashBigInt(fakedM0);

  const rightSideFaked = modPow(g, h_faked, p);
  const isFakeValid = (leftSide === rightSideFaked);

  if (!isFakeValid) {
    console.log("[OK] Алгоритм успешно обнаружил подделку! Хэши не совпали, равенство  нарушено.");
  } else {
    console.log("[КРИТИЧЕСКАЯ ОШИБКА] Атака удалась! Система приняла фальшивое сообщение.");
  }

  printHeader("ИТОГОВЫЙ АНАЛИЗ СКОРОСТИ");
  console.log(`1. Генерация ключей (x, y):   ${keyGenTime.toFixed(4)} сек.`);
  console.log(`2. Создание подписи {a, b}:   ${signTime.toFixed(6)} сек.`);
  console.log(`3. Верификация уравнения:     ${verifyTime.toFixed(6)} сек.`);
  console.log("-".repeat(60));

  const ratio = signTime > 0 ? (verifyTime / signTime) : 0;
  console.log(`Результат: В чистом Эль-Гамале верификация идет в ${ratio.toFixed(2)} раз(а) МЕДЛЕННЕЕ подписания.`);
  console.log("=" * 60);

  rl.close();
});
