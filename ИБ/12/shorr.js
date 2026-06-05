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

// В Шнорре хэшируется сообщение М0, объединенное с математическим компонентом r
function getSchnorrHash(messageBuffer, rBigInt) {
  const hasher = crypto.createHash('md5');
  hasher.update(messageBuffer);
  hasher.update(Buffer.from(rBigInt.toString(), 'utf-8'));
  const hashHex = hasher.digest('hex');
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

  printHeader("1. Генерация ключевых параметров Шнорра");

  // Используем надежное 1024-битное простое число RFC 2409 (Группа 2)
  const p = BigInt("0xFFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE65381FFFFFFFFFFFFFFFFn".replace('n', ''));
  const g = 2n;
  const pMinus1 = p - 1n;

  console.log(`Параметр p (1024 бит): ${p.toString().slice(0, 40)}...`);
  console.log(`Параметр g: ${g}`);

  let start = process.hrtime.bigint();

  // Секретный ключ x, открытый ключ y = g^x mod p
  const x = randomBigInt(2n, pMinus1);
  const y = modPow(g, x, p);

  let end = process.hrtime.bigint();
  const keyGenTime = Number(end - start) / 1e9;

  console.log(`[OK] Ключи сгенерированы.`);
  console.log(`Тайный ключ x: ${x.toString().slice(0, 30)}...`);
  console.log(`Открытый ключ y: ${y.toString().slice(0, 30)}...`);
  console.log(`Время генерации ключей: ${keyGenTime.toFixed(4)} сек.`);

  printHeader("2. Генерация ЭЦП Шнорра");

  start = process.hrtime.bigint();

  // 1. Выбираем случайное k
  let k = randomBigInt(2n, pMinus1);

  // 2. Вычисляем r = g^k mod p
  const r = modPow(g, k, p);

  // 3. Вычисляем хэш e = H(M0 || r)
  const e = getSchnorrHash(M0, r);
  const e_reduced = e % pMinus1;

  // 4. Вычисляем s = (k - x * e) mod (p - 1)
  const xe = (x * e_reduced) % pMinus1;
  let target = (k - xe) % pMinus1;
  if (target < 0n) {
    target += pMinus1;
  }
  const s = target;

  end = process.hrtime.bigint();
  const signTime = Number(end - start) / 1e9;

  console.log(`[OK] Подпись S = {e, s} успешно создана.`);
  console.log(`Компонент e (хэш): ${e.toString().slice(0, 40)}...`);
  console.log(`Компонент s (число): ${s.toString().slice(0, 40)}...`);
  console.log(`Время генерации подписи: ${signTime.toFixed(6)} сек.`);

  printHeader("3. Верификация ЭЦП Шнорра");
  console.log("[...] Восстанавливаем r' = (g^s * y^e) mod p и проверяем хэш");

  start = process.hrtime.bigint();

  // 1. Восстанавливаем r' = (g^s * y^e) mod p
  const step1 = modPow(g, s, p);
  const step2 = modPow(y, e, p);
  const r_rec = (step1 * step2) % p;

  // 2. Считаем проверочный хэш e' = H(M0 || r')
  const e_rec = getSchnorrHash(M0, r_rec);

  // 3. Проверяем равенство e == e'
  const isValid = (e === e_rec);

  end = process.hrtime.bigint();
  const verifyTime = Number(end - start) / 1e9;

  console.log(`Исходный хэш e:    ${e.toString().slice(0, 40)}...`);
  console.log(`Полученный хэш e': ${e_rec.toString().slice(0, 40)}...`);

  if (isValid) {
    console.log("\n[ВЕРИФИКАЦИЯ УСПЕШНА] Хэши совпали! Подпись верна.");
  } else {
    console.log("\n[ВНИМАНИЕ]  Хэши НЕ совпали! Подпись подделана.");
  }
  console.log(`Время верификации подписи: ${verifyTime.toFixed(6)} сек.`);

  printHeader("4. Тест на компрометацию (Модификация сообщения)");
  console.log("Изменяем текст сообщения...");

  const fakedM0 = Buffer.from(messageText + " исправлено злоумышленником", 'utf-8');

  // Злоумышленник пытается проверить подпись под фальшивым сообщением
  const e_faked = getSchnorrHash(fakedM0, r_rec);
  const isFakeValid = (e === e_faked);

  if (!isFakeValid) {
    console.log("[OK] Алгоритм успешно обнаружил подделку! Хэши не совпали.");
  } else {
    console.log("[КРИТИЧЕСКАЯ ОШИБКА] Атака удалась! Система приняла фальшивое сообщение.");
  }

  printHeader("ИТОГОВЫЙ АНАЛИЗ СКОРОСТИ");
  console.log(`1. Генерация ключей (x, y):   ${keyGenTime.toFixed(4)} сек.`);
  console.log(`2. Создание подписи {e, s}:   ${signTime.toFixed(6)} сек.`);
  console.log(`3. Верификация уравнения:     ${verifyTime.toFixed(6)} сек.`);
  console.log("-".repeat(60));

  const ratio = signTime > 0 ? (verifyTime / signTime) : 0;
  console.log(`Результат: В схеме Шнорра верификация идет в ${ratio.toFixed(2)} раз(а) МЕДЛЕННЕЕ подписания.`);
  console.log("=" * 60);

  rl.close();
});
